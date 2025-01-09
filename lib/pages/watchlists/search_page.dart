import 'package:dima_project/models/watchlist.dart';
import 'package:flutter/material.dart';
import 'package:dima_project/widgets/movie_search_bar_widget.dart';
import 'package:dima_project/models/movie.dart';
import 'package:dima_project/pages/movies/film_details_page.dart';
import 'package:dima_project/services/watchlist_service.dart';
import 'package:logger/logger.dart';
import 'package:dima_project/services/user_service.dart';
import 'package:provider/provider.dart';
import 'package:dima_project/models/tiny_movie.dart';

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
  final Logger logger = Logger();
  final Set<Tinymovie> _addedMovies = {};
  List<Tinymovie> _tinyMovies = [];

  @override
  void initState() {
    super.initState();
    if (widget.movieList != null) {
      _tinyMovies = generateList(widget.movieList!);
      _addedMovies.addAll(_tinyMovies);
    } else if (widget.watchlist != null) {
      for (int i = 0; i < widget.watchlist!.movies.length; i++) {
        _addedMovies.add(fromString(widget.watchlist!.movies[i]));
      }
    }
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

  List<Tinymovie> generateList(List<Movie> movies) {
    List<Tinymovie> tinyMovies = [];
    for (int i = 0; i < movies.length; i++) {
      tinyMovies.add(movies[i].toTinyMovie());
    }
    return tinyMovies;
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
                final bool movieAlreadyAdded =
                    _addedMovies.contains(movie.toTinyMovie());
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
                            _removeMovie(movie);
                          },
                        )
                      : IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            _addMovie(movie);
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

  void _addMovie(Movie movie) async {
    if (widget.watchlist != null) {
      try {
        await Provider.of<WatchlistService>(context, listen: false)
            .addMovieToWatchlist(
          widget.watchlist!.userID,
          widget.watchlist!.id,
          movie.toTinyMovie(),
        );
        setState(() {
          _addedMovies.add(movie.toTinyMovie());
        });
        if (mounted) {
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
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
          await Provider.of<UserService>(context, listen: false)
              .addToLikedMovies(widget.userId!, movie.toTinyMovie().toString());
          setState(() {
            _addedMovies.add(movie.toTinyMovie());
          });
          if (mounted) {
            ScaffoldMessenger.of(context).removeCurrentSnackBar();
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
          await Provider.of<UserService>(context, listen: false)
              .addToSeenMovies(widget.userId!, movie.toTinyMovie().toString());
          setState(() {
            _addedMovies.add(movie.toTinyMovie());
          });
          if (mounted) {
            ScaffoldMessenger.of(context).removeCurrentSnackBar();
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

  void _removeMovie(Movie movie) async {
    if (widget.watchlist != null) {
      try {
        await Provider.of<WatchlistService>(context, listen: false)
            .removeMovieFromWatchlist(
          widget.watchlist!.userID,
          widget.watchlist!.id,
          movie.toTinyMovie(),
        );
        setState(() {
          _addedMovies.remove(movie.toTinyMovie());
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
          await Provider.of<UserService>(context, listen: false)
              .removeFromLikedMovies(
                  widget.userId!, movie.toTinyMovie().toString());
          setState(() {
            _addedMovies.remove(movie.toTinyMovie());
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
          await Provider.of<UserService>(context, listen: false)
              .removeFromSeenMovies(
                  widget.userId!, movie.toTinyMovie().toString());
          setState(() {
            _addedMovies.remove(movie.toTinyMovie());
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
