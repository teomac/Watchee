import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dima_project/models/watchlist.dart';
import 'package:dima_project/services/watchlist_service.dart';
import 'package:dima_project/services/user_service.dart';
import 'package:logger/logger.dart';
import 'package:dima_project/models/user_model.dart'; // Add this line to import MyUser class
import 'package:dima_project/pages/watchlists/manage_watchlist_page.dart';
import 'dart:async';
import 'package:dima_project/services/user_menu_manager.dart';
import 'package:dima_project/pages/watchlists/liked_seen_movies_page.dart';

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
  final Map<MyUser, List<WatchList>> ownWatchlists;
  final Map<MyUser, List<WatchList>> followedWatchlists;

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

class DeleteWatchlist extends MyListsEvent {
  final WatchList watchlist;
  DeleteWatchlist(this.watchlist);
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
    on<DeleteWatchlist>(_onDeleteWatchlist);
  }

  Future<void> _onLoadMyLists(
      LoadMyLists event, Emitter<MyListsState> emit) async {
    emit(MyListsLoading());
    try {
      final currentUser = await _userService.getCurrentUser();
      if (currentUser != null) {
        final tempOwnWatchlists =
            await _watchlistService.getOwnWatchLists(currentUser.id);
        final tempCollaboratorWatchlists =
            await _watchlistService.getCollabWatchLists(currentUser.id);
        for (final watchlist in tempCollaboratorWatchlists) {
          tempOwnWatchlists.add(watchlist);
        }
        final tempFollowedWatchlists =
            await _watchlistService.getFollowingWatchlists(currentUser);

        //for each watchlist in ownWatchlist, create the map with the MyUser object as key and its watchlists as value
        Map<MyUser, List<WatchList>> ownWatchlists = {};
        for (var watchlist in tempOwnWatchlists) {
          MyUser? user = await _userService.getUser(watchlist.userID);
          if (user != null) {
            if (ownWatchlists.containsKey(user)) {
              ownWatchlists[user]!.add(watchlist);
            } else {
              ownWatchlists[user] = [watchlist];
            }
          }
        }

        //for each watchlist in followedWatchlist, create the map with the MyUser object as key and its watchlists as value
        Map<MyUser, List<WatchList>> followedWatchlists = {};
        for (var watchlist in tempFollowedWatchlists) {
          MyUser? user = await _userService.getUser(watchlist.userID);
          if (user != null) {
            if (followedWatchlists.containsKey(user)) {
              followedWatchlists[user]!.add(watchlist);
            } else {
              followedWatchlists[user] = [watchlist];
            }
          }
        }

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

  Future<void> _onDeleteWatchlist(
      DeleteWatchlist event, Emitter<MyListsState> emit) async {
    try {
      await _watchlistService.deleteWatchList(event.watchlist);
      _logger.d("Watchlist deleted: ${event.watchlist.name}");
      // Reload the lists after successful deletion
      add(LoadMyLists());
    } catch (e, stackTrace) {
      _logger.e("Error deleting watchlist", error: e, stackTrace: stackTrace);
      emit(MyListsError("Failed to delete watchlist. Please try again."));
    }
  }
}

class MyLists extends StatefulWidget {
  const MyLists({super.key});

  @override
  State<MyLists> createState() => _MyListsState();
}

class _MyListsState extends State<MyLists> {
  late final Logger logger = Logger();
  late MyListsBloc myListsBloc;
  MyUser? currentUser;

  @override
  void initState() {
    super.initState();
    myListsBloc = MyListsBloc(WatchlistService(), UserService());
    loadBasics();
  }

  void loadBasics() async {
    currentUser = await UserService().getCurrentUser();
    myListsBloc.add(LoadMyLists());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: myListsBloc,
      child: BlocBuilder<MyListsBloc, MyListsState>(
        builder: (context, state) {
          return Scaffold(
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: _buildBody(context, state),
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () => _showCreateWatchlistDialog(context),
              child: const Icon(Icons.add),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, MyListsState state) {
    if (state is MyListsLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is MyListsLoaded) {
      return CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            pinned: true,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 12, bottom: 12),
              title: Text(
                'My Lists',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            actions: const [
              UserInfo(),
            ],
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 4),
                _buildLikedSection(context, currentUser!.id), // New section
                _buildSeenSection(context, currentUser!.id),
                const SizedBox(
                  height: 8,
                ) // New section
              ],
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              _buildWatchlistSection(
                  context, 'My Watchlists', state.ownWatchlists, true),
              _buildWatchlistSection(context, 'Followed Watchlists',
                  state.followedWatchlists, false),
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
              onPressed: () => myListsBloc.add(LoadMyLists()),
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
            myListsBloc.add(CreateWatchlist(name, isPrivate));
          },
        );
      },
    );
  }

  Widget _buildLikedSection(context, String userId) {
    return ListTile(
      leading: const CircleAvatar(
        backgroundColor: Colors.purple,
        child: Icon(Icons.favorite, color: Colors.white),
      ),
      title: const Text('Liked Movies'),
      subtitle: const Text('All your favorite movies in one place'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LikedSeenMoviesPage(
              userId: userId, // Make sure to get the current user's ID
              isLiked: true, // For liked movies
            ),
          ),
        );
      },
    );
  }

  Widget _buildSeenSection(context, String userId) {
    return ListTile(
      leading: const CircleAvatar(
        backgroundColor: Colors.green,
        child: Icon(Icons.visibility, color: Colors.white),
      ),
      title: const Text('Seen Movies'),
      subtitle: const Text('Movies you have already watched'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LikedSeenMoviesPage(
              userId: userId, // Make sure to get the current user's ID
              isLiked: false, // For liked movies
            ),
          ),
        );
      },
    );
  }

  Widget _buildWatchlistSection(BuildContext context, String title,
      Map<MyUser, List<WatchList>> watchlists, bool isOwnWatchlist) {
    if (watchlists.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: isOwnWatchlist
                ? const Text(
                    'My Watchlists',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  )
                : const Text(
                    'Followed Watchlists',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
          ),
          const SizedBox(height: 48),
          Center(
            child: isOwnWatchlist
                ? Text(
                    'Press the + button to create your first watchlist',
                    style: Theme.of(context).textTheme.bodySmall,
                  )
                : Text(
                    'You are currently not following any watchlists',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
          ),
          const SizedBox(height: 16),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          ...watchlists.entries.expand((entry) {
            final user = entry.key;
            final userWatchlists = entry.value;
            return userWatchlists.map((watchlist) => ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.primaries[
                        watchlist.name.length % Colors.primaries.length],
                    child: Text(watchlist.name[0].toUpperCase()),
                  ),
                  title: Text(watchlist.name),
                  subtitle: watchlist.movies.length != 1
                      ? Text(
                          '${watchlist.movies.length} movies · ${user.username}')
                      : Text(
                          '${watchlist.movies.length} movie · ${user.username}'),
                  trailing: watchlist.isPrivate ? const Icon(Icons.lock) : null,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ManageWatchlistPage(
                            userId: watchlist.userID,
                            watchlistId: watchlist.id),
                      ),
                    ).then((_) {
                      if (context.mounted) {
                        myListsBloc.add(LoadMyLists());
                      }
                    });
                  },
                  onLongPress: () => _showWatchlistOptions(
                      context,
                      watchlist,
                      isOwnWatchlist,
                      (WatchList wl) => myListsBloc.add(DeleteWatchlist(wl))),
                ));
          }),
          const SizedBox(height: 20),
        ],
      );
    }
  }

  void _showWatchlistOptions(BuildContext context, WatchList watchlist,
      bool isOwnWatchlist, Function(WatchList) onDelete) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[900] : Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isOwnWatchlist)
                  ListTile(
                    leading: Icon(Icons.person_add,
                        color: theme.colorScheme.secondary),
                    title: Text('Invite', style: theme.textTheme.titleMedium),
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Invite functionality coming soon')),
                      );
                    },
                  ),
                ListTile(
                  leading:
                      Icon(Icons.share, color: theme.colorScheme.secondary),
                  title: Text('Share', style: theme.textTheme.titleMedium),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Share functionality coming soon')),
                    );
                  },
                ),
                if (isOwnWatchlist)
                  ListTile(
                    leading: Icon(Icons.delete, color: theme.colorScheme.error),
                    title: Text('Delete',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(color: theme.colorScheme.error)),
                    onTap: () {
                      Navigator.pop(context);
                      _showDeleteConfirmation(context, watchlist, onDelete);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(
      BuildContext context, WatchList watchlist, Function(WatchList) onDelete) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Delete Watchlist',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          content: Text(
            'Are you sure you want to delete "${watchlist.name}"?',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDarkMode ? Colors.white70 : Colors.black87,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: theme.colorScheme.secondary),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                onDelete(watchlist);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    myListsBloc.close();
    super.dispose();
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
    final theme = Theme.of(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      backgroundColor: theme.dialogBackgroundColor,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Create New Watchlist',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _nameController,
                    style: theme.textTheme.bodyMedium,
                    decoration: InputDecoration(
                      labelText: 'Watchlist Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor:
                          isDarkMode ? Colors.grey[800] : Colors.grey[200],
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a name for your watchlist';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  SwitchListTile(
                    title: Text('Private Watchlist',
                        style: theme.textTheme.bodyLarge),
                    subtitle: Text(
                      'Only you can see private watchlists',
                      style: theme.textTheme.bodySmall,
                    ),
                    value: _isPrivate,
                    onChanged: (bool value) {
                      setState(() {
                        _isPrivate = value;
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancel',
                      style: TextStyle(color: theme.colorScheme.secondary)),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      widget.onCreateWatchlist(
                          _nameController.text, _isPrivate);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                  ),
                  child: const Text('Create'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
