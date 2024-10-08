import 'package:dima_project/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dima_project/models/watchlist.dart';
import 'package:dima_project/models/movie.dart';
import 'package:dima_project/services/watchlist_service.dart';
import 'package:dima_project/api/constants.dart';
import 'package:dima_project/api/tmdb_api.dart';
import 'package:dima_project/pages/movies/film_details_page.dart';
import 'package:dima_project/pages/watchlists/search_page.dart';
import 'package:dima_project/pages/account/user_profile_page.dart';
import 'package:dima_project/models/user_model.dart';
import 'package:dima_project/pages/watchlists/followers_list_page.dart';
import 'package:share_plus/share_plus.dart';
import 'package:dima_project/pages/watchlists/invite_collaborators_page.dart';
import 'package:dima_project/pages/watchlists/collaborators_list_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Events
abstract class ManageWatchlistEvent {}

class LoadWatchlist extends ManageWatchlistEvent {
  final String watchlistId;
  final String userId;
  final String sortOption;
  LoadWatchlist(this.userId, this.watchlistId, this.sortOption);
}

class AddMovieToWatchlist extends ManageWatchlistEvent {
  final Movie movie;
  AddMovieToWatchlist(this.movie);
}

class RemoveMovieFromWatchlist extends ManageWatchlistEvent {
  final Movie movie;
  RemoveMovieFromWatchlist(this.movie);
}

// Add a new event for updating the watchlist name
class UpdateWatchlistName extends ManageWatchlistEvent {
  final String newName;
  UpdateWatchlistName(this.newName);
}

class ToggleWatchlistPrivacy extends ManageWatchlistEvent {}

// States
abstract class ManageWatchlistState {}

class ManageWatchlistInitial extends ManageWatchlistState {}

class ManageWatchlistLoading extends ManageWatchlistState {}

class ManageWatchlistLoaded extends ManageWatchlistState {
  final WatchList watchlist;
  final List<Movie> movies;
  final List<Movie> sortedMovies;

  ManageWatchlistLoaded(this.watchlist, this.movies, this.sortedMovies);
}

class ManageWatchlistError extends ManageWatchlistState {
  final String message;
  ManageWatchlistError(this.message);
}

// BLoC
class ManageWatchlistBloc
    extends Bloc<ManageWatchlistEvent, ManageWatchlistState> {
  final WatchlistService _watchlistService;

  ManageWatchlistBloc(this._watchlistService)
      : super(ManageWatchlistInitial()) {
    on<LoadWatchlist>(_onLoadWatchlist);
    on<RemoveMovieFromWatchlist>(_onRemoveMovieFromWatchlist);
    on<UpdateWatchlistName>(_onUpdateWatchlistName);
    on<ToggleWatchlistPrivacy>(_onToggleWatchlistPrivacy);
  }

  Future<void> _onLoadWatchlist(
      LoadWatchlist event, Emitter<ManageWatchlistState> emit) async {
    emit(ManageWatchlistLoading());
    try {
      final watchlist =
          await _watchlistService.getWatchList(event.userId, event.watchlistId);
      if (watchlist != null) {
        final movies = await _fetchMoviesForWatchlist(watchlist);
        List<Movie> sortedMovies = movies;
        switch (event.sortOption) {
          case 'Latest Added':
            sortedMovies = movies.reversed.toList();
            break;
          case 'Name':
            sortedMovies = List.from(movies)
              ..sort((a, b) => a.title.compareTo(b.title));
            break;
          case 'Release Date':
            sortedMovies = List.from(movies)
              ..sort((a, b) => b.releaseDate!.compareTo(a.releaseDate!));
            break;
          case 'Default':
            sortedMovies = movies;
            break;
        }
        emit(ManageWatchlistLoaded(watchlist, movies, sortedMovies));
      } else {
        emit(ManageWatchlistError('Watchlist not found'));
      }
    } catch (e) {
      emit(ManageWatchlistError(e.toString()));
    }
  }

  Future<void> _onRemoveMovieFromWatchlist(RemoveMovieFromWatchlist event,
      Emitter<ManageWatchlistState> emit) async {
    final currentState = state;
    if (currentState is ManageWatchlistLoaded) {
      try {
        final updatedMovies = List<int>.from(currentState.watchlist.movies);
        updatedMovies.remove(event.movie.id);
        final updatedWatchlist =
            currentState.watchlist.copyWith(movies: updatedMovies);
        await _watchlistService.updateWatchList(updatedWatchlist);
        final updatedMovieList =
            currentState.movies.where((m) => m.id != event.movie.id).toList();

        //update also sortedMovies
        final updatedSortedMovies = currentState.sortedMovies
            .where((m) => m.id != event.movie.id)
            .toList();
        emit(ManageWatchlistLoaded(
            updatedWatchlist, updatedMovieList, updatedSortedMovies));
      } catch (e) {
        emit(ManageWatchlistError('Failed to remove movie: ${e.toString()}'));
      }
    }
  }

  Future<List<Movie>> _fetchMoviesForWatchlist(WatchList watchlist) async {
    List<Movie> movies = [];
    for (final movieId in watchlist.movies) {
      final movie = await retrieveFilmInfo(movieId);
      movie.trailer = await retrieveTrailer(movieId);
      movie.cast = await retrieveCast(movieId);
      movies.add(movie);
    }
    return movies;
  }

  Future<void> _onUpdateWatchlistName(
      UpdateWatchlistName event, Emitter<ManageWatchlistState> emit) async {
    final currentState = state;
    if (currentState is ManageWatchlistLoaded) {
      try {
        final updatedWatchlist =
            currentState.watchlist.copyWith(name: event.newName);
        await _watchlistService.updateWatchList(updatedWatchlist);
        emit(ManageWatchlistLoaded(
            updatedWatchlist, currentState.movies, currentState.sortedMovies));
      } catch (e) {
        emit(ManageWatchlistError(
            'Failed to update watchlist name: ${e.toString()}'));
      }
    }
  }

  Future<void> _onToggleWatchlistPrivacy(
      ToggleWatchlistPrivacy event, Emitter<ManageWatchlistState> emit) async {
    final currentState = state;
    if (currentState is ManageWatchlistLoaded) {
      try {
        final updatedWatchlist = currentState.watchlist.copyWith(
          isPrivate: !currentState.watchlist.isPrivate,
        );
        await _watchlistService.updateWatchList(updatedWatchlist);
        emit(ManageWatchlistLoaded(
            updatedWatchlist, currentState.movies, currentState.sortedMovies));
      } catch (e) {
        emit(ManageWatchlistError(
            'Failed to toggle watchlist privacy: ${e.toString()}'));
      }
    }
  }
}

class ManageWatchlistPage extends StatefulWidget {
  final String watchlistId;
  final String userId;

  const ManageWatchlistPage({
    super.key,
    required this.userId,
    required this.watchlistId,
  });

  @override
  State<ManageWatchlistPage> createState() => _ManageWatchlistPageState();
}

class _ManageWatchlistPageState extends State<ManageWatchlistPage> {
  late ManageWatchlistBloc _manageWatchlistBloc;
  final UserService _userService = UserService();
  MyUser? user, currentUser;
  bool canEdit = false;
  WatchList? actualWatchlist;
  bool isFollowing = false;
  bool isCollaborator = false;
  String currentSortOption = 'Default';
  final prefs = SharedPreferences.getInstance();
  bool needsRefresh = true;
  List<Movie> sortedMovies = [];

  @override
  void initState() {
    super.initState();
    _manageWatchlistBloc = ManageWatchlistBloc(WatchlistService());
    if (needsRefresh) {
      _loadBasics();
    }
    needsRefresh = true;
  }

  Future<void> _loadBasics() async {
    isCollaborator = false;
    actualWatchlist = await _manageWatchlistBloc._watchlistService
        .getWatchList(widget.userId, widget.watchlistId);
    user = await _userService.getUser(widget.userId);
    currentUser = await _userService.getCurrentUser();

    //load prefs
    currentSortOption = await prefs
        .then((value) => value.getString(actualWatchlist!.id) ?? 'Default');

    _manageWatchlistBloc.add(
        LoadWatchlist(widget.userId, widget.watchlistId, currentSortOption));
    if (currentUser != null &&
        actualWatchlist != null &&
        user != null &&
        (currentUser!.id == widget.userId)) {
      canEdit = true;
      isCollaborator = false;
    }
    if (actualWatchlist!.collaborators.contains(currentUser!.id)) {
      canEdit = true;
      isCollaborator = true;
    }
    if (currentUser != null && user != null && currentUser!.id != user!.id) {
      // Check if the current user is following this watchlist
      isFollowing = currentUser!.followedWatchlists
              .containsKey(actualWatchlist!.userID) &&
          currentUser!.followedWatchlists[actualWatchlist!.userID]!
              .contains(actualWatchlist!.id);
    }
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

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _manageWatchlistBloc,
      child: BlocBuilder<ManageWatchlistBloc, ManageWatchlistState>(
        builder: (context, state) {
          return Scaffold(
            body: SafeArea(
              child: _buildBody(context, state),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, ManageWatchlistState state) {
    if (state is ManageWatchlistLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is ManageWatchlistLoaded) {
      return CustomScrollView(
        slivers: [
          _buildSliverAppBar(context, state),
          SliverToBoxAdapter(
            child: _buildWatchlistHeaderContent(context, state),
          ),
          SliverToBoxAdapter(
            child: _buildAddMovieButton(context, state.watchlist),
          ),
          _buildMovieList(context, state),
        ],
      );
    } else if (state is ManageWatchlistError) {
      return Center(child: Text('Error: ${state.message}'));
    }
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildSliverAppBar(BuildContext context, ManageWatchlistLoaded state) {
    return SliverAppBar(
      expandedHeight: 20.0,
      floating: false,
      pinned: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        if (!canEdit && !state.watchlist.isPrivate)
          IconButton(
            icon: Icon(isFollowing ? Icons.favorite : Icons.favorite_border),
            onPressed: _toggleFollowWatchlist,
          ),
        IconButton(
          icon: const Icon(Icons.sort),
          onPressed: () => _showSortingOptions(context, state),
        ),
        IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () => _showWatchlistOptions(context, state.watchlist),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWatchlistHeaderContent(
      BuildContext context, ManageWatchlistLoaded state) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                state.watchlist.name,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              if (state.watchlist.isPrivate)
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Icon(
                    Icons.lock,
                    size: 24,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          _buildCreatedByText(context, state.watchlist.userID),
          _buildFollowersCount(context, state.watchlist),
        ],
      ),
    );
  }

  void _showSortingOptions(BuildContext context, ManageWatchlistLoaded state) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                title: const Text('Default'),
                leading: const Icon(Icons.sort),
                onTap: () => _sortMovies('Default', state),
              ),
              ListTile(
                title: const Text('Latest Added'),
                leading: const Icon(Icons.add_circle_outline),
                onTap: () => _sortMovies('Latest Added', state),
              ),
              ListTile(
                title: const Text('Name'),
                leading: const Icon(Icons.sort_by_alpha),
                onTap: () => _sortMovies('Name', state),
              ),
              ListTile(
                title: const Text('Release Date'),
                leading: const Icon(Icons.calendar_today),
                onTap: () => _sortMovies('Release Date', state),
              ),
            ],
          ),
        );
      },
    );
  }

  void _sortMovies(String sortOption, ManageWatchlistLoaded state) {
    switch (sortOption) {
      case 'Latest Added':
        sortedMovies = state.movies.reversed.toList();
        break;
      case 'Name':
        sortedMovies = List.from(state.movies)
          ..sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'Release Date':
        sortedMovies = List.from(state.movies)
          ..sort((a, b) => b.releaseDate!.compareTo(a.releaseDate!));
        break;
      case 'Default':
        sortedMovies = state.movies;
        break;
    }

    setState(() {
      needsRefresh = false;
      currentSortOption = sortOption;
      prefs.then((value) => value.setString(state.watchlist.id, sortOption));
    });

    Navigator.pop(context);
  }

  Widget _buildFollowersCount(BuildContext context, WatchList watchlist) {
    return GestureDetector(
      onTap: () => watchlist.followers.isNotEmpty
          ? _showFollowersList(context, watchlist)
          : (),
      child: Row(
        children: [
          const Icon(Icons.people, size: 16),
          const SizedBox(width: 4),
          watchlist.followers.length != 1
              ? Text(
                  '${watchlist.followers.length} followers',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                )
              : Text(
                  '${watchlist.followers.length} follower',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
          //add number of movies in the watchlist. If there is only one movie, display "1 movie", otherwise "n movies"
          const SizedBox(width: 4),
          watchlist.movies.length != 1
              ? Text(
                  '· ${watchlist.movies.length} movies',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                )
              : Text(
                  '· ${watchlist.movies.length} movie',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
        ],
      ),
    );
  }

  void _showFollowersList(BuildContext context, WatchList watchlist) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FollowersListPage(watchlist: watchlist),
      ),
    );
  }

  Widget _buildCreatedByText(BuildContext context, String creatorId) {
    if (user == null) {
      return const Text('Created by Unknown');
    }

    int collaboratorsCount = actualWatchlist!.collaborators.length;

    return Row(
      children: [
        const Text('Created by '),
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserProfilePage(user: user!),
            ),
          ),
          child: Text(
            user!.username,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (collaboratorsCount > 0) ...[
          const Text(' and '),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    CollaboratorsListPage(watchlist: actualWatchlist!),
              ),
            ),
            child: Text(
              '$collaboratorsCount ${collaboratorsCount == 1 ? 'other' : 'others'}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _showWatchlistOptions(BuildContext context, WatchList watchlist) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (canEdit || isCollaborator)
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: const Text('Rename watchlist'),
                  onTap: () {
                    Navigator.pop(context);
                    _showRenameDialog(context, watchlist);
                  },
                ),
              if (canEdit && !isCollaborator)
                ListTile(
                  leading:
                      Icon(watchlist.isPrivate ? Icons.public : Icons.lock),
                  title: Text(watchlist.isPrivate
                      ? 'Make it public'
                      : 'Make it private'),
                  onTap: () {
                    Navigator.pop(context);
                    _manageWatchlistBloc.add(ToggleWatchlistPrivacy());
                  },
                ),
              if (canEdit && !isCollaborator)
                ListTile(
                  leading: const Icon(Icons.person_add),
                  title: const Text('Invite as collaborator'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            InviteCollaboratorsPage(watchlist: watchlist),
                      ),
                    );
                  },
                ),
              ListTile(
                leading: const Icon(Icons.share),
                title: const Text('Share'),
                onTap: () {
                  Navigator.pop(context);
                  _shareWatchlist(watchlist);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _toggleFollowWatchlist() async {
    if (currentUser == null) return;
    try {
      if (isFollowing == false) {
        await _manageWatchlistBloc._watchlistService.followWatchlist(
            currentUser!.id, actualWatchlist!.id, actualWatchlist!.userID);
      } else {
        await _manageWatchlistBloc._watchlistService.unfollowWatchlist(
            currentUser!.id, actualWatchlist!.id, actualWatchlist!.userID);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  isFollowing ? 'Watchlist unfollowed' : 'Watchlist followed')),
        );
      }
      setState(() {
        isFollowing = !isFollowing;
      });
    } catch (e) {
      // Revert the state if the operation fails
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update follow status')),
        );
      }
    }
  }

  void _showRenameDialog(BuildContext context, WatchList watchlist) {
    final TextEditingController controller =
        TextEditingController(text: watchlist.name);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Rename Watchlist'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: "Enter new name"),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  Navigator.of(context).pop();
                  _manageWatchlistBloc
                      .add(UpdateWatchlistName(controller.text));
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildAddMovieButton(BuildContext context, WatchList watchlist) {
    if (!canEdit) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SearchPage(
                watchlist: watchlist,
              ),
            ),
          ).then((_) => _loadBasics());
        },
        icon: const Icon(Icons.add),
        label: const Text('Add a movie'),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
        ),
      ),
    );
  }

  Widget _buildMovieList(BuildContext context, ManageWatchlistLoaded state) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (sortedMovies.isEmpty ||
              sortedMovies.length != state.movies.length) {
            sortedMovies = state.sortedMovies;
          }
          final movie = sortedMovies[index];
          return ListTile(
            leading: movie.posterPath != null
                ? Image.network('${Constants.imagePath}${movie.posterPath}')
                : const Icon(Icons.movie),
            title: Text(movie.title),
            subtitle: Text(movie.releaseDate ?? 'Release date unknown'),
            onTap: () => _navigateToFilmDetails(context, movie),
            onLongPress: () => canEdit
                ? _showRemoveMovieMenu(context, movie, state.watchlist.name)
                : null,
          );
        },
        childCount: state.sortedMovies.length,
      ),
    );
  }

  void _navigateToFilmDetails(BuildContext context, Movie movie) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FilmDetailsPage(movie: movie),
      ),
    ).then((_) {
      // Refresh the watchlist when returning from FilmDetailsPage
      _loadBasics();
    });
  }

  void _showRemoveMovieMenu(
      BuildContext context, Movie movie, String watchlistName) {
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
                ListTile(
                  leading: Icon(Icons.delete, color: theme.colorScheme.error),
                  title: Text(
                    'Remove from $watchlistName',
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                  onTap: () {
                    _manageWatchlistBloc.add(RemoveMovieFromWatchlist(movie));
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text('${movie.title} removed from watchlist')),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _manageWatchlistBloc.close();
    super.dispose();
  }
}
