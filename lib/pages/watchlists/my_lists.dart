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
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Events
abstract class MyListsEvent {}

class LoadMyLists extends MyListsEvent {
  String currentSortOptionOWN;
  String currentSortOptionFOLLOWED;
  LoadMyLists(
      {this.currentSortOptionOWN = 'Latest Added',
      this.currentSortOptionFOLLOWED = 'Latest Added'});
}

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

class DeleteWatchlist extends MyListsEvent {
  final WatchList watchlist;
  DeleteWatchlist(this.watchlist);
}

class RemoveCollab extends MyListsEvent {
  final WatchList watchlist;
  final String userId;
  RemoveCollab(this.watchlist, this.userId);
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
    on<RemoveCollab>(_onRemoveCollab);
  }

  Future<void> _onRemoveCollab(
      RemoveCollab event, Emitter<MyListsState> emit) async {
    try {
      await _watchlistService.removeMyselfAsCollaborator(
          event.watchlist.id, event.watchlist.userID, event.userId);
      add(LoadMyLists());
    } catch (e, stackTrace) {
      _logger.e("Error removing collaborator",
          error: e, stackTrace: stackTrace);
      emit(MyListsError("Failed to remove collaborator. Please try again."));
    }
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

        switch (event.currentSortOptionOWN) {
          case 'Latest Added':
            tempOwnWatchlists
                .sort((a, b) => b.createdAt.compareTo(a.createdAt));
            break;
          case 'Name':
            tempOwnWatchlists.sort(
                (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
            break;
          case 'Movie Count':
            tempOwnWatchlists
                .sort((a, b) => b.movies.length.compareTo(a.movies.length));
            break;
          case 'Latest Edit':
            tempOwnWatchlists
                .sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
            break;
        }

        switch (event.currentSortOptionFOLLOWED) {
          case 'Latest Added':
            tempFollowedWatchlists
                .sort((a, b) => b.createdAt.compareTo(a.createdAt));
            break;
          case 'Name':
            tempFollowedWatchlists.sort(
                (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

            break;
          case 'Movie Count':
            tempFollowedWatchlists
                .sort((a, b) => b.movies.length.compareTo(a.movies.length));
            break;
          case 'Latest Edit':
            tempFollowedWatchlists
                .sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
            break;
        }

        emit(MyListsLoaded(tempOwnWatchlists, tempFollowedWatchlists));
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
  String currentSortOptionOWN = 'Latest Added';
  String currentSortOptionFOLLOWED = 'Latest Added';
  bool needsReload = true;
  final prefs = SharedPreferences.getInstance();

  @override
  void initState() {
    super.initState();
    if (needsReload) {
      _loadSortPreference();
      loadBasics();
    }
    myListsBloc = MyListsBloc(WatchlistService(), UserService());
    needsReload = true;
  }

  void _loadSortPreference() async {
    final sharedPreferences = await prefs;
    setState(() {
      currentSortOptionOWN =
          sharedPreferences.getString('sortOptionOWN') ?? 'Latest Added';
      currentSortOptionFOLLOWED =
          sharedPreferences.getString('sortOptionFOLLOWED') ?? 'Latest Added';
    });
  }

  void loadBasics() async {
    currentUser = await UserService().getCurrentUser();
    myListsBloc.add(LoadMyLists(
        currentSortOptionOWN: currentSortOptionOWN,
        currentSortOptionFOLLOWED: currentSortOptionFOLLOWED));
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
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
      List<WatchList> watchlists, bool isOwnWatchlist) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12, top: 12, right: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              watchlists.isNotEmpty
                  ? TextButton.icon(
                      icon: const Icon(Icons.sort),
                      label: Text(
                        isOwnWatchlist
                            ? currentSortOptionOWN
                            : currentSortOptionFOLLOWED,
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                      onPressed: () => _showSortingOptions(
                          context, watchlists, isOwnWatchlist),
                    )
                  : const SizedBox.shrink(),
            ],
          ),
        ),
        if (watchlists.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 48.0, bottom: 32),
              child: Text(
                isOwnWatchlist
                    ? 'Press the + button to create your first watchlist'
                    : 'You are currently not following any watchlists',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          )
        else
          ...watchlists.map((watchlist) {
            return FutureBuilder<String>(
              future: findCreatorUsername(watchlist),
              builder: (context, snapshot) {
                final username = snapshot.data ?? 'Unknown';
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.primaries[
                        watchlist.name.length % Colors.primaries.length],
                    child: Text(
                      watchlist.name[0].toUpperCase(),

                      //color of the first letter of the watchlist name
                    ),
                  ),
                  title: Text(watchlist.name),
                  subtitle: Text(
                      '${watchlist.movies.length} ${watchlist.movies.length == 1 ? 'movie' : 'movies'} · $username'),
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
                );
              },
            );
          }),
        const SizedBox(height: 20),
      ],
    );
  }

  void _showSortingOptions(
      BuildContext context, List<WatchList> watchlists, bool isOwnWatchlist) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                title: const Text('Sort by Latest Added'),
                leading: const Icon(Icons.add_circle_outline),
                onTap: () =>
                    _sortWatchlists(watchlists, 'Latest Added', isOwnWatchlist),
              ),
              ListTile(
                title: const Text('Sort by Name'),
                leading: const Icon(Icons.sort_by_alpha),
                onTap: () =>
                    _sortWatchlists(watchlists, 'Name', isOwnWatchlist),
              ),
              ListTile(
                title: const Text('Sort by Movie Count'),
                leading: const Icon(Icons.movie_filter),
                onTap: () =>
                    _sortWatchlists(watchlists, 'Movie Count', isOwnWatchlist),
              ),
              ListTile(
                title: const Text('Sort by Latest Edit'),
                leading: const Icon(Icons.edit),
                onTap: () =>
                    _sortWatchlists(watchlists, 'Latest Edit', isOwnWatchlist),
              ),
            ],
          ),
        );
      },
    );
  }

  void _sortWatchlists(
      List<WatchList> watchlists, String sortOption, bool isOwnWatchlist) {
    setState(() {
      switch (sortOption) {
        case 'Latest Added':
          watchlists.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          break;
        case 'Name':
          watchlists.sort(
              (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
          break;
        case 'Movie Count':
          watchlists.sort((a, b) => b.movies.length.compareTo(a.movies.length));
          break;
        case 'Latest Edit':
          watchlists.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
          break;
      }
    });
    _saveSortPreference(sortOption, isOwnWatchlist);
    Navigator.pop(context);
  }

  void _saveSortPreference(String sortOption, bool isOwnWatchlist) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (isOwnWatchlist) {
      currentSortOptionOWN = sortOption;
      prefs.setString('sortOptionOWN', sortOption);
    } else {
      currentSortOptionFOLLOWED = sortOption;
      prefs.setString('sortOptionFOLLOWED', sortOption);
    }
  }

  Future<String> findCreatorUsername(WatchList watchlist) async {
    final user = await UserService().getUser(watchlist.userID);
    if (user == null) {
      return 'Unknown';
    }
    return user.username;
  }

  void _showWatchlistOptions(BuildContext context, WatchList watchlist,
      bool isOwnWatchlist, Function(WatchList) onDelete) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading:
                      Icon(Icons.share, color: theme.colorScheme.secondary),
                  title: Text('Share', style: theme.textTheme.titleMedium),
                  onTap: () {
                    Navigator.pop(context);
                    _shareWatchlist(watchlist);
                  },
                ),
                if (isOwnWatchlist &&
                    !(watchlist.collaborators.contains(currentUser!.id)))
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
                if (isOwnWatchlist &&
                    (watchlist.collaborators.contains(currentUser!.id)))
                  ListTile(
                    leading: Icon(Icons.delete, color: theme.colorScheme.error),
                    title: Text('Remove myself as collaborator',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(color: theme.colorScheme.error)),
                    onTap: () {
                      Navigator.pop(context);
                      _removeAsCollaborator(context, watchlist);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _shareWatchlist(WatchList watchlist) async {
    // Generate a deep link for the watchlist
    final String deepLink =
        'https://dima-project-matteo.web.app/?watchlistId=${watchlist.id}&userId=${watchlist.userID}&invitedBy=${currentUser!.id}';

    // Create the share message
    final String shareMessage =
        '${currentUser!.name} has shared a watchlist with you. Check out "${watchlist.name}"!\n\n$deepLink';

    try {
      await Share.share(shareMessage, subject: 'Check out this watchlist!');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to share watchlist')),
        );
      }
    }
  }

  void _showDeleteConfirmation(
      BuildContext context, WatchList watchlist, Function(WatchList) onDelete) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
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
            style: const TextStyle(fontSize: 14),
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

  void _removeAsCollaborator(BuildContext context, WatchList watchlist) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Remove myself as collaborator',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          content: Text(
            'Are you sure you want to remove yourself from "${watchlist.name}"?',
            style: const TextStyle(fontSize: 14),
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
                myListsBloc.add(RemoveCollab(watchlist, currentUser!.id));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Remove'),
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
