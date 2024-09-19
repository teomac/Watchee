import 'package:dima_project/models/watchlist.dart';
import 'package:flutter/material.dart';
import 'package:dima_project/widgets/movie_search_bar_widget.dart';
import 'package:dima_project/models/movie.dart';
import 'package:dima_project/pages/movies/film_details_page.dart';
import 'package:dima_project/services/watchlist_service.dart';
import 'package:logger/logger.dart';
import 'package:dima_project/services/user_service.dart';

class SearchPage extends StatefulWidget {
  final WatchList? watchlist;
  final String? userId;
  final List<Movie>? movieList;
  final bool? isLiked;

  const SearchPage({
    super.key,
    this.watchlist,
    this.userId,
    this.movieList,
    this.isLiked,
  });

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<Movie> _searchResults = [];
  final WatchlistService _watchlistService = WatchlistService();
  final UserService _userService = UserService();
  final Logger logger = Logger();
  final Set<int> _addedMovies = {};
  List<int> _moviesIds = [];

  @override
  void initState() {
    super.initState();
    if (widget.movieList != null) {
      _moviesIds = generateList(widget.movieList!);
      _addedMovies.addAll(_moviesIds);
    } else if (widget.watchlist != null) {
      _addedMovies.addAll(widget.watchlist!.movies);
    }
  }

  List<int> generateList(List<Movie> movies) {
    List<int> moviesIds = movies.map((e) => e.id).toList();
    return moviesIds;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Movies'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: MovieSearchBarWidget(
              theme: Theme.of(context),
              isDarkMode: Theme.of(context).brightness == Brightness.dark,
              onExpandChanged: (_) {},
              onSearchResults: (results) {
                setState(() {
                  _searchResults = results;
                });
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final movie = _searchResults[index];
                final bool movieAlreadyAdded = _addedMovies.contains(movie.id);
                return ListTile(
                  leading: movie.posterPath != null
                      ? Image.network(
                          'https://image.tmdb.org/t/p/w92${movie.posterPath}')
                      : const Icon(Icons.movie),
                  title: Text(movie.title),
                  subtitle: Text(movie.releaseDate ?? 'Release date unknown'),
                  trailing: (movieAlreadyAdded)
                      ? IconButton(
                          icon: const Icon(Icons.check),
                          onPressed: () {
                            _removeMovie(movie.id);
                          },
                        )
                      : IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            _addMovie(movie.id);
                          },
                        ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FilmDetailsPage(movie: movie),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _addMovie(int movieId) async {
    if (widget.watchlist != null) {
      try {
        await _watchlistService.addMovieToWatchlist(
          widget.watchlist!.userID,
          widget.watchlist!.id,
          movieId,
        );
        setState(() {
          _addedMovies.add(movieId);
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Successfully added to watchlist'),
            ),
          );
        }
      } catch (e) {
        logger.e('Error adding movie to watchlist: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to add movie to watchlist'),
            ),
          );
        }
      }
    } else {
      if (widget.isLiked!) {
        try {
          await _userService.addToLikedMovies(widget.userId!, movieId);
          setState(() {
            _addedMovies.add(movieId);
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Successfully added to liked movies'),
              ),
            );
          }
        } catch (e) {
          logger.e('Error adding movie to liked movies: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to add movie to liked movies'),
              ),
            );
          }
        }
      } else if (widget.isLiked == false) {
        try {
          await _userService.addToSeenMovies(widget.userId!, movieId);
          setState(() {
            _addedMovies.add(movieId);
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Successfully added to seen movies'),
              ),
            );
          }
        } catch (e) {
          logger.e('Error adding movie to seen movies: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to add movie to seen movies'),
              ),
            );
          }
        }
      }
    }
  }

  void _removeMovie(int movieId) async {
    if (widget.watchlist != null) {
      try {
        await _watchlistService.removeMovieFromWatchlist(
          widget.watchlist!.userID,
          widget.watchlist!.id,
          movieId,
        );
        setState(() {
          _addedMovies.remove(movieId);
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Successfully removed from watchlist'),
            ),
          );
        }
      } catch (e) {
        logger.e('Error removing movie from watchlist: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to remove movie from watchlist'),
            ),
          );
        }
      }
    } else {
      if (widget.isLiked!) {
        try {
          await _userService.removeFromLikedMovies(widget.userId!, movieId);
          setState(() {
            _addedMovies.remove(movieId);
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Successfully removed from liked movies'),
              ),
            );
          }
        } catch (e) {
          logger.e('Error removing movie from liked movies: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to remove movie from liked movies'),
              ),
            );
          }
        }
      } else if (widget.isLiked == false) {
        try {
          await _userService.removeFromSeenMovies(widget.userId!, movieId);
          setState(() {
            _addedMovies.remove(movieId);
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Successfully removed from seen movies'),
              ),
            );
          }
        } catch (e) {
          logger.e('Error removing movie from seen movies: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to remove movie from seen movies'),
              ),
            );
          }
        }
      }
    }
  }
}
