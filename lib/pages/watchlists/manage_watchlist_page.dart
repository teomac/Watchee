import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dima_project/models/watchlist.dart';
import 'package:dima_project/models/movie.dart';
import 'package:dima_project/services/watchlist_service.dart';
import 'package:dima_project/widgets/movie_search_bar_widget.dart';
import 'package:dima_project/api/constants.dart';
import 'package:dima_project/api/tmdb_api.dart';
import 'package:dima_project/pages/movies/film_details_page.dart';

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
    on<AddMovieToWatchlist>(_onAddMovieToWatchlist);
    on<RemoveMovieFromWatchlist>(_onRemoveMovieFromWatchlist);
    on<UpdateWatchlistName>(_onUpdateWatchlistName);
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

  Future<void> _onAddMovieToWatchlist(
      AddMovieToWatchlist event, Emitter<ManageWatchlistState> emit) async {
    final currentState = state;
    if (currentState is ManageWatchlistLoaded) {
      try {
        final updatedWatchlist = currentState.watchlist.copyWith(
          movies: {...currentState.watchlist.movies, event.movie.id: true},
        );
        await _watchlistService.updateWatchList(updatedWatchlist);
        final updatedMovies = [...currentState.movies, event.movie];
        emit(ManageWatchlistLoaded(updatedWatchlist, updatedMovies));
      } catch (e) {
        emit(ManageWatchlistError('Failed to add movie: ${e.toString()}'));
      }
    }
  }

  Future<void> _onRemoveMovieFromWatchlist(RemoveMovieFromWatchlist event,
      Emitter<ManageWatchlistState> emit) async {
    final currentState = state;
    if (currentState is ManageWatchlistLoaded) {
      try {
        final updatedMovies =
            Map<int, bool>.from(currentState.watchlist.movies);
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
    for (final movieId in watchlist.movies.keys) {
      final movie = await retrieveFilmInfo(movieId);
      movie.trailer = await retrieveTrailer(movieId);
      movie.cast = await retrieveCast(movieId);
      return [movie];
    }
    return [];
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
}

class ManageWatchlistPage extends StatefulWidget {
  final String watchlistId;
  final String userId;

  const ManageWatchlistPage(
      {super.key, required this.userId, required this.watchlistId});

  @override
  State<ManageWatchlistPage> createState() => ManageWatchlistPageState();
}

class ManageWatchlistPageState extends State<ManageWatchlistPage> {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) {
          return;
        }
        // Notify the previous page to refresh
        Navigator.of(context).pop();
      },
      child: BlocProvider(
        create: (context) => ManageWatchlistBloc(WatchlistService())
          ..add(LoadWatchlist(widget.userId, widget.watchlistId)),
        child: const ManageWatchlistView(),
      ),
    );
  }
}

class ManageWatchlistView extends StatelessWidget {
  const ManageWatchlistView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ManageWatchlistBloc, ManageWatchlistState>(
      builder: (context, state) {
        if (state is ManageWatchlistLoading) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        } else if (state is ManageWatchlistLoaded) {
          return SafeArea(
              child: Scaffold(
            appBar: _buildAppBar(context, state.watchlist),
            body: Column(
              children: [
                _buildAddMovieButton(context),
                Expanded(child: _buildMovieList(context, state)),
              ],
            ),
          ));
        } else if (state is ManageWatchlistError) {
          return Scaffold(body: Center(child: Text('Error: ${state.message}')));
        }
        return const Scaffold(
            body: Center(child: Text('Something went wrong')));
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, WatchList watchlist) {
    return AppBar(
      centerTitle: true,
      title: Text(
        watchlist.name,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () => _showEditNameDialog(context, watchlist),
        ),
      ],
    );
  }

  void _showEditNameDialog(BuildContext context, WatchList watchlist) {
    final TextEditingController controller =
        TextEditingController(text: watchlist.name);

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Edit Watchlist Name'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: "Enter new name"),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  Navigator.of(dialogContext).pop();
                  // Use the outer context to access the BLoC
                  context
                      .read<ManageWatchlistBloc>()
                      .add(UpdateWatchlistName(controller.text));
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildAddMovieButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton.icon(
        onPressed: () => _showAddMovieDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add a movie'),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
        ),
      ),
    );
  }

  Widget _buildMovieList(BuildContext context, ManageWatchlistLoaded state) {
    return ListView.builder(
      itemCount: state.movies.length,
      itemBuilder: (context, index) {
        final movie = state.movies[index];
        return InkWell(
          onTap: () => _navigateToFilmDetails(context, movie),
          onLongPress: () => _showRemoveMovieSnackBar(context, movie),
          child: ListTile(
            leading: movie.posterPath != null
                ? Image.network('${Constants.imagePath}${movie.posterPath}')
                : const Icon(Icons.movie),
            title: Text(movie.title),
            subtitle: Text(movie.releaseDate ?? 'Release date unknown'),
          ),
        );
      },
    );
  }

  void _navigateToFilmDetails(BuildContext context, Movie movie) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FilmDetailsPage(movie: movie),
      ),
    );
  }

  void _showRemoveMovieSnackBar(BuildContext context, Movie movie) {
    final snackBar = SnackBar(
      content: Text('Remove ${movie.title} from watchlist?'),
      backgroundColor: Colors.red,
      duration: const Duration(seconds: 5),
      action: SnackBarAction(
        label: 'REMOVE',
        textColor: Colors.white,
        onPressed: () {
          context
              .read<ManageWatchlistBloc>()
              .add(RemoveMovieFromWatchlist(movie));
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${movie.title} removed from watchlist')),
          );
        },
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _showAddMovieDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add a movie'),
          content: MovieSearchBarWidget(
            theme: Theme.of(context),
            isDarkMode: Theme.of(context).brightness == Brightness.dark,
            onExpandChanged: (bool expanded) {},
            onSearchResults: (List<Movie> movies) {
              // Handle search results
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}
