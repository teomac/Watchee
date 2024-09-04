import 'package:dima_project/api/constants.dart';
import 'package:flutter/material.dart';
import 'package:dima_project/models/movie.dart';
import 'package:dima_project/pages/film_details/film_details_page.dart';

class MoviesSlider extends StatelessWidget {
  final List<Movie> movies;

  const MoviesSlider({
    super.key,
    required this.movies,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 175,
      width: double.infinity,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: movies.length > 10 ? 10 : movies.length,
        itemBuilder: (context, index) {
          final movie = movies[index];
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () {
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
                  height: 175,
                  width: 110,
                  child: Image.network(
                    filterQuality: FilterQuality.high,
                    fit: BoxFit.cover,
                    '${Constants.imagePath}${movie.posterPath}',
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
