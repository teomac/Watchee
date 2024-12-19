import 'package:dima_project/api/constants.dart';
import 'package:dima_project/services/tmdb_api_service.dart';
import 'package:flutter/material.dart';
import 'package:dima_project/models/movie.dart';
import 'package:dima_project/pages/movies/film_details_page.dart';
import 'package:logger/logger.dart';
import 'dart:math';

import 'package:provider/provider.dart';

class DoubleRowSlider extends StatelessWidget {
  final List<Movie> movies;
  final bool? shuffle;
  final Logger logger = Logger();

  DoubleRowSlider({
    super.key,
    required this.movies,
    this.shuffle,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    if (shuffle == true) {
      movies.shuffle(Random());
    }

    return SizedBox(
      height: 390, //optimal is 390
      width: double.infinity,
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio:
                115 / 185, // Adjusted for poster aspect ratio (185/115)
            crossAxisSpacing: 8,
            mainAxisSpacing: 0,
            mainAxisExtent: size.height * 0.23 - 40),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: movies.length,
        itemBuilder: (context, index) {
          final movie = movies[index];
          return Padding(
            padding: const EdgeInsets.all(8),
            child: GestureDetector(
              onTap: () {
                _retrieveAllMovieInfo(
                    movie, Provider.of<TmdbApiService>(context, listen: false));
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FilmDetailsPage(movie: movie),
                  ),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  height: 185,
                  width: 115,
                  child: _buildMoviePoster(movie),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMoviePoster(Movie movie) {
    if (movie.posterPath == null) {
      return _buildPlaceholderImage();
    }

    try {
      return Image.network(
        '${Constants.imagePath}${movie.posterPath}',
        errorBuilder: (context, error, stackTrace) {
          logger.d('Error loading image for movie ${movie.title}: $error');
          return _buildPlaceholderImage();
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
      );
    } catch (e) {
      logger.d('Error loading image for movie ${movie.title}: $e');
      return _buildPlaceholderImage();
    }
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: Colors.grey[300],
      child: const Center(
        child: Icon(Icons.movie, size: 40, color: Colors.grey),
      ),
    );
  }

  void _retrieveAllMovieInfo(Movie movie, TmdbApiService api) async {
    try {
      final fullMovie = await api.retrieveFilmInfo(movie.id);
      final cast = await api.retrieveCast(movie.id);
      final trailer = await api.retrieveTrailer(movie.id);

      movie = fullMovie;
      movie.cast = cast;
      movie.trailer = trailer;
    } catch (e) {
      logger.e('Error retrieving movie info: $e');
      // Handle error (e.g., show a snackbar)
    }
  }
}
