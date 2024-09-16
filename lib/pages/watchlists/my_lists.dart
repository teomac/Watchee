import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dima_project/models/watchlist.dart';
import 'package:dima_project/services/watchlist_service.dart';
import 'package:dima_project/services/user_service.dart';
import 'package:logger/logger.dart';
import 'package:dima_project/pages/watchlists/manage_watchlist_page.dart';
import 'dart:async';

// Events
abstract class MyListsEvent {}

class LoadMyLists extends MyListsEvent {}

class CreateWatchlist extends MyListsEvent {
  final String name;
  final bool isPrivate;

  CreateWatchlist(this.name, this.isPrivate);
}

// States
abstract class MyListsState {}

class MyListsInitial extends MyListsState {}

class MyListsLoading extends MyListsState {}

class MyListsLoaded extends MyListsState {
  final List<WatchList> ownWatchlists;
  final List<WatchList> followedWatchlists;

  MyListsLoaded(this.ownWatchlists, this.followedWatchlists);
}

class MyListsError extends MyListsState {
  final String message;

  MyListsError(this.message);
}

class WatchlistCreating extends MyListsState {}

class WatchlistCreated extends MyListsState {}

class WatchlistCreationError extends MyListsState {
  final String message;

  WatchlistCreationError(this.message);
}

// BLoC
class MyListsBloc extends Bloc<MyListsEvent, MyListsState> {
  final WatchlistService _watchlistService;
  final UserService _userService;
  final Logger _logger = Logger();

  MyListsBloc(this._watchlistService, this._userService)
      : super(MyListsInitial()) {
    on<LoadMyLists>(_onLoadMyLists);
    on<CreateWatchlist>(_onCreateWatchlist);
    add(LoadMyLists());
  }

  Future<void> _onLoadMyLists(
      LoadMyLists event, Emitter<MyListsState> emit) async {
    emit(MyListsLoading());
    try {
      final currentUser = await _userService.getCurrentUser();
      if (currentUser != null) {
        final ownWatchlists =
            await _watchlistService.getOwnWatchLists(currentUser.id);
        final followedWatchlists =
            await _watchlistService.getFollowingWatchlists(currentUser);
        emit(MyListsLoaded(ownWatchlists, followedWatchlists));
      } else {
        emit(MyListsError("User not found"));
      }
    } catch (e, stackTrace) {
      _logger.e("Error loading watchlists", error: e, stackTrace: stackTrace);
      emit(MyListsError(e.toString()));
    }
  }

  Future<void> _onCreateWatchlist(
      CreateWatchlist event, Emitter<MyListsState> emit) async {
    emit(WatchlistCreating());
    try {
      final currentUser = await _userService.getCurrentUser();
      if (currentUser != null) {
        await _watchlistService.createWatchList(
          currentUser,
          event.name,
          event.isPrivate,
        );
        emit(WatchlistCreated());
        add(LoadMyLists());
      } else {
        emit(WatchlistCreationError("User not found"));
      }
    } catch (e, stackTrace) {
      _logger.e("Error creating watchlist", error: e, stackTrace: stackTrace);
      emit(WatchlistCreationError(
          "Failed to create watchlist. Please try again."));
    }
  }
}

class MyLists extends StatelessWidget {
  MyLists({super.key});
  final Logger logger = Logger();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final watchlistService = WatchlistService();
        logger.d('Creating MyListsBloc');
        return MyListsBloc(watchlistService, UserService())..add(LoadMyLists());
      },
      child: BlocConsumer<MyListsBloc, MyListsState>(
        listener: (context, state) {
          logger.d('MyLists state changed: $state');
          if (state is MyListsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is MyListsLoaded) {
            return MyListsView(
              ownWatchlists: state.ownWatchlists,
              followedWatchlists: state.followedWatchlists,
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

class MyListsView extends StatelessWidget {
  final List<WatchList> ownWatchlists;
  final List<WatchList> followedWatchlists;

  const MyListsView({
    super.key,
    required this.ownWatchlists,
    required this.followedWatchlists,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MyListsBloc, MyListsState>(
      listener: (context, state) {
        if (state is WatchlistCreated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Watchlist created successfully')),
          );
        } else if (state is WatchlistCreationError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: SafeArea(
            child: _buildBody(context, state),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showCreateWatchlistDialog(context),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, MyListsState state) {
    if (state is MyListsLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is MyListsLoaded) {
      return CustomScrollView(
        slivers: [
          const SliverAppBar(
            floating: true,
            pinned: true,
            title: Text('My Lists'),
          ),
          SliverToBoxAdapter(
            child: _buildLikedSection(),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              _buildWatchlistSection(context, 'My Watchlists', ownWatchlists),
              _buildWatchlistSection(
                  context, 'Followed Watchlists', followedWatchlists),
            ]),
          ),
        ],
      );
    } else if (state is MyListsError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(state.message),
            ElevatedButton(
              onPressed: () => context.read<MyListsBloc>().add(LoadMyLists()),
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  void _showCreateWatchlistDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return CreateWatchlistDialog(
          onCreateWatchlist: (String name, bool isPrivate) {
            Navigator.of(dialogContext).pop();
            context.read<MyListsBloc>().add(CreateWatchlist(name, isPrivate));
          },
        );
      },
    );
  }

  Widget _buildLikedSection() {
    return ListTile(
      leading: const CircleAvatar(
        backgroundColor: Colors.purple,
        child: Icon(Icons.favorite, color: Colors.white),
      ),
      title: const Text('Liked Movies'),
      subtitle: const Text('All your favorite movies in one place'),
      onTap: () {
        // TODO: Navigate to Liked Movies page
      },
    );
  }

  Widget _buildWatchlistSection(
      BuildContext context, String title, List<WatchList> watchlists) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        ...watchlists.map((watchlist) => ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors
                    .primaries[watchlist.name.length % Colors.primaries.length],
                child: Text(watchlist.name[0].toUpperCase()),
              ),
              title: Text(watchlist.name),
              subtitle: Text('${watchlist.movies.length} movies'),
              trailing: watchlist.isPrivate ? const Icon(Icons.lock) : null,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ManageWatchlistPage(
                        userId: watchlist.userID, watchlistId: watchlist.id),
                  ),
                ).then((_) {
                  // Refresh the watchlists when returning from ManageWatchlistPage
                  context.read<MyListsBloc>().add(LoadMyLists());
                });
              },
            )),
        const SizedBox(height: 16),
      ],
    );
  }
}

//////////////////////////////////////////////////////////////////////////////

class CreateWatchlistDialog extends StatefulWidget {
  final Function(String name, bool isPrivate) onCreateWatchlist;

  const CreateWatchlistDialog({
    super.key,
    required this.onCreateWatchlist,
  });

  @override
  State<CreateWatchlistDialog> createState() => _CreateWatchlistDialogState();
}

class _CreateWatchlistDialogState extends State<CreateWatchlistDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _isPrivate = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create New Watchlist'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Watchlist Name'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name for your watchlist';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Private'),
              value: _isPrivate,
              onChanged: (bool value) {
                setState(() {
                  _isPrivate = value;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onCreateWatchlist(_nameController.text, _isPrivate);
            }
          },
          child: const Text('Create'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
