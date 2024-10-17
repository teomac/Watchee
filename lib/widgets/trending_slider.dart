// ignore: depend_on_referenced_packages
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dima_project/api/constants.dart';
import 'package:flutter/material.dart';
import 'package:dima_project/models/movie.dart';
import 'package:dima_project/pages/movies/film_details_page.dart';

//widget used to display the trending movies with a self moving horizontal slider
class TrendingSlider extends StatelessWidget {
  final List<Movie> trendingMovies;

  const TrendingSlider({
    super.key,
    required this.trendingMovies,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: CarouselSlider.builder(
        itemCount: trendingMovies.length,
        options: CarouselOptions(
          height: 185,
          autoPlay: true,
          viewportFraction: 0.33,
          enlargeCenterPage: true,
          pageSnapping: true,
          autoPlayCurve: Curves.fastOutSlowIn,
          autoPlayAnimationDuration: const Duration(seconds: 1),
        ),
        itemBuilder: (context, itemIndex, pageViewIndex) {
          final movie = trendingMovies[itemIndex];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FilmDetailsPage(movie: movie),
                ),
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                height: 185,
                width: 115,
                child: Image.network(
                  filterQuality: FilterQuality.high,
                  fit: BoxFit.cover,
                  '${Constants.imagePath}${movie.posterPath}',
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(
                        Icons.error,
                        color: Colors.red,
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
