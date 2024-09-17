import 'package:dima_project/models/watchlist.dart';
import 'package:flutter/material.dart';
import 'package:dima_project/widgets/movie_search_bar_widget.dart';
import 'package:dima_project/models/movie.dart';
import 'package:dima_project/pages/movies/film_details_page.dart';
import 'package:dima_project/services/watchlist_service.dart';
import 'package:logger/logger.dart';

class SearchPage extends StatefulWidget {
  final WatchList watchlist;

  const SearchPage({
    super.key,
    required this.watchlist,
  });

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<Movie> _searchResults = [];
  final WatchlistService _watchlistService = WatchlistService();
  final Logger logger = Logger();
  final Set<int> _addedMovies = {};

  @override
  void initState() {
    super.initState();
    _addedMovies.addAll(widget.watchlist.movies);
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
                      ? const Icon(Icons.check)
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
    try {
      await _watchlistService.addMovieToWatchlist(
        widget.watchlist.userID,
        widget.watchlist.id,
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
  }
}
