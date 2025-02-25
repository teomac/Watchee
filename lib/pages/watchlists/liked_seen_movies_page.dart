import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dima_project/models/movie.dart';
import 'package:dima_project/services/user_service.dart';
import 'package:dima_project/services/tmdb_api_service.dart';
import 'package:dima_project/pages/movies/film_details_page.dart';
import 'package:dima_project/api/constants.dart';
import 'package:dima_project/pages/watchlists/search_page.dart'; // Add this import
import 'package:dima_project/pages/account/user_profile_page.dart'; // Import UserProfilePage class
import 'package:dima_project/models/user.dart';
import 'package:provider/provider.dart';
import 'package:dima_project/models/tiny_movie.dart';

// Events
abstract class LikedSeenMoviesEvent {}

class LoadMovies extends LikedSeenMoviesEvent {
  final String userId;
  final bool isLiked; // true for liked movies, false for seen movies
  LoadMovies(this.userId, this.isLiked);
}

class AddMovie extends LikedSeenMoviesEvent {
  final String userId;
  final String movie;
  final bool isLiked; // true for liked movies, false for seen movies
  AddMovie(this.userId, this.movie, this.isLiked);
}

class RemoveMovie extends LikedSeenMoviesEvent {
  final String userId;
  final String movie;
  final bool isLiked; // true for liked movies, false for seen movies
  RemoveMovie(this.userId, this.movie, this.isLiked);
}

// States
abstract class LikedSeenMoviesState {}

class LikedSeenMoviesInitial extends LikedSeenMoviesState {}

class LikedSeenMoviesLoading extends LikedSeenMoviesState {}

class LikedSeenMoviesLoaded extends LikedSeenMoviesState {
  final List<Movie> movies;
  LikedSeenMoviesLoaded(this.movies);
}

class LikedSeenMoviesError extends LikedSeenMoviesState {
  final String message;
  LikedSeenMoviesError(this.message);
}

// BLoC
class LikedSeenMoviesBloc
    extends Bloc<LikedSeenMoviesEvent, LikedSeenMoviesState> {
  final UserService _userService;
  final TmdbApiService _tmdbApiService;

  LikedSeenMoviesBloc(this._userService, this._tmdbApiService)
      : super(LikedSeenMoviesInitial()) {
    on<LoadMovies>(_onLoadMovies);
    on<RemoveMovie>(_onRemoveMovie);
  }

  Tinymovie fromString(String string) {
    final List<String> split = string.split(',,,');
    return Tinymovie(
      id: int.parse(split[0]),
      title: split[1],
      posterPath: split[2],
      releaseDate: split[3],
    );
  }

  Future<void> _onLoadMovies(
      LoadMovies event, Emitter<LikedSeenMoviesState> emit) async {
    emit(LikedSeenMoviesLoading());
    try {
      final user = await _userService.getUser(event.userId);
      if (user != null) {
        final movieStrings = event.isLiked ? user.likedMovies : user.seenMovies;
        final movies = await Future.wait(movieStrings.map(
            (movie) => _tmdbApiService.retrieveFilmInfo(fromString(movie).id)));
        emit(LikedSeenMoviesLoaded(movies));
      } else {
        emit(LikedSeenMoviesError("User not found"));
      }
    } catch (e) {
      emit(LikedSeenMoviesError(e.toString()));
    }
  }

  Future<void> _onRemoveMovie(
      RemoveMovie event, Emitter<LikedSeenMoviesState> emit) async {
    if (event.isLiked) {
      try {
        _userService.removeFromLikedMovies(event.userId, event.movie);
        final user = await _userService.getUser(event.userId);
        if (user != null) {
          final movies = await Future.wait(user.likedMovies.map((movie) =>
              _tmdbApiService.retrieveFilmInfo(fromString(movie).id)));
          emit(LikedSeenMoviesLoaded(movies));
        }
      } catch (e) {
        emit(LikedSeenMoviesError(e.toString()));
      }
    } else {
      try {
        _userService.removeFromSeenMovies(event.userId, event.movie);
        final user = await _userService.getUser(event.userId);
        if (user != null) {
          final movies = await Future.wait(user.seenMovies.map((movie) =>
              _tmdbApiService.retrieveFilmInfo(fromString(movie).id)));
          emit(LikedSeenMoviesLoaded(movies));
        }
      } catch (e) {
        emit(LikedSeenMoviesError(e.toString()));
      }
    }
  }
}

class LikedSeenMoviesPage extends StatefulWidget {
  final String userId;
  final bool isLiked;

  const LikedSeenMoviesPage({
    super.key,
    required this.userId,
    required this.isLiked,
  });

  @override
  State<LikedSeenMoviesPage> createState() => _LikedSeenMoviesPageState();
}

class _LikedSeenMoviesPageState extends State<LikedSeenMoviesPage> {
  late LikedSeenMoviesBloc _likedSeenMoviesBloc;
  MyUser? user;

  @override
  void initState() {
    super.initState();
    _likedSeenMoviesBloc = LikedSeenMoviesBloc(
        Provider.of<UserService>(context, listen: false),
        Provider.of<TmdbApiService>(context, listen: false));
    loadBasics();
  }

  Future<void> loadBasics() async {
    _likedSeenMoviesBloc.add(LoadMovies(widget.userId, widget.isLiked));
    user = await Provider.of<UserService>(context, listen: false)
        .getUser(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _likedSeenMoviesBloc,
      child: BlocBuilder<LikedSeenMoviesBloc, LikedSeenMoviesState>(
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

  Widget _buildBody(BuildContext context, LikedSeenMoviesState state) {
    if (state is LikedSeenMoviesLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is LikedSeenMoviesLoaded) {
      return CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(
            child: widget.isLiked
                ? _buildWatchlistHeaderContent(context, 'Liked')
                : _buildWatchlistHeaderContent(context, 'Seen'),
          ),
          SliverToBoxAdapter(
            child: _buildAddMovieButton(context, state.movies),
          ),
          _buildMovieList(context, state),
        ],
      );
    } else if (state is LikedSeenMoviesError) {
      return Center(child: Text('Error: ${state.message}'));
    } else {
      return const Center(child: Text('Error: Unknown state'));
    }
  }

  Widget _buildSliverAppBar(BuildContext context) {
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

  Widget _buildWatchlistHeaderContent(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
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
          _buildCreatedByText(context, widget.userId),
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

  Widget _buildAddMovieButton(BuildContext context, List<Movie> movies) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SearchPage(
                userId: widget.userId,
                movieList: movies,
                isLiked: widget.isLiked,
              ),
            ),
          ).then((_) => loadBasics());
        },
        icon: const Icon(Icons.add),
        label: const Text('Add a movie'),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
        ),
      ),
    );
  }

  Widget _buildMovieList(BuildContext context, LikedSeenMoviesLoaded state) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final movie = state.movies[index];
          Image? image;
          try {
            if (movie.posterPath != null) {
              image =
                  Image.network('${Constants.imagePath}${movie.posterPath}');
            } else {
              image = null;
            }
          } catch (e) {
            image = null;
          }
          return ListTile(
            leading: image ?? const Icon(Icons.movie),
            title: Text(movie.title),
            subtitle: Text(movie.releaseDate ?? 'Release date unknown'),
            onTap: () => _navigateToFilmDetails(context, movie),
            onLongPress: () => (widget.isLiked)
                ? _showRemoveMovieMenu(context, movie, 'liked')
                : _showRemoveMovieMenu(context, movie, 'seen'),
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
    ).then((value) {
      loadBasics();
    });
  }

  void _showRemoveMovieMenu(BuildContext context, Movie movie, String name) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[900] : Colors.white,
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
                    'Remove from $name',
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                  onTap: () {
                    _likedSeenMoviesBloc.add(RemoveMovie(widget.userId,
                        movie.toTinyMovie().toString(), widget.isLiked));
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
    _likedSeenMoviesBloc.close();
    super.dispose();
  }
}
