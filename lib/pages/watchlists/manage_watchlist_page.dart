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
import 'package:dima_project/pages/account/user_profile_page.dart'; // Add this import
import 'package:dima_project/models/user_model.dart';

// Events
abstract class ManageWatchlistEvent {}

class LoadWatchlist extends ManageWatchlistEvent {
  final String watchlistId;
  final String userId;
  LoadWatchlist(this.userId, this.watchlistId);
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

  ManageWatchlistLoaded(this.watchlist, this.movies);
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
        emit(ManageWatchlistLoaded(watchlist, movies));
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
        emit(ManageWatchlistLoaded(updatedWatchlist, updatedMovieList));
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
        emit(ManageWatchlistLoaded(updatedWatchlist, currentState.movies));
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
        emit(ManageWatchlistLoaded(updatedWatchlist, currentState.movies));
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
  MyUser? user;

  @override
  void initState() {
    super.initState();
    _manageWatchlistBloc = ManageWatchlistBloc(WatchlistService());
    _loadBasics();
  }

  Future<void> _loadBasics() async {
    _manageWatchlistBloc.add(LoadWatchlist(widget.userId, widget.watchlistId));
    user = await _userService.getUser(widget.userId);
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
          _buildSliverAppBar(context, state.watchlist),
          SliverToBoxAdapter(
            child: _buildWatchlistHeaderContent(context, state.watchlist),
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
    return const Center(child: Text('Something went wrong'));
  }

  Widget _buildSliverAppBar(BuildContext context, WatchList watchlist) {
    return SliverAppBar(
      expandedHeight: 20.0,
      floating: false,
      pinned: true,
      backgroundColor: Colors.black,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () => _showWatchlistOptions(context, watchlist),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.7),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWatchlistHeaderContent(
      BuildContext context, WatchList watchlist) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                watchlist.name,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              if (watchlist.isPrivate)
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
          _buildCreatedByText(context, watchlist.userID),
        ],
      ),
    );
  }

  Widget _buildCreatedByText(BuildContext context, String creatorId) {
    if (user == null) {
      return const Text('Created by Unknown');
    }
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
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Rename watchlist'),
                onTap: () {
                  Navigator.pop(context);
                  _showRenameDialog(context, watchlist);
                },
              ),
              ListTile(
                leading: Icon(watchlist.isPrivate ? Icons.public : Icons.lock),
                title: Text(
                    watchlist.isPrivate ? 'Make it public' : 'Make it private'),
                onTap: () {
                  Navigator.pop(context);
                  _manageWatchlistBloc.add(ToggleWatchlistPrivacy());
                },
              ),
              ListTile(
                leading: const Icon(Icons.person_add),
                title: const Text('Invite as collaborator'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement invite functionality
                },
              ),
              ListTile(
                leading: const Icon(Icons.share),
                title: const Text('Share'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement share functionality
                },
              ),
            ],
          ),
        );
      },
    );
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
          final movie = state.movies[index];
          return ListTile(
            leading: movie.posterPath != null
                ? Image.network('${Constants.imagePath}${movie.posterPath}')
                : const Icon(Icons.movie),
            title: Text(movie.title),
            subtitle: Text(movie.releaseDate ?? 'Release date unknown'),
            onTap: () => _navigateToFilmDetails(context, movie),
            onLongPress: () =>
                _showRemoveMovieMenu(context, movie, state.watchlist.name),
          );
        },
        childCount: state.movies.length,
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
