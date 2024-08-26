// ignore: depend_on_referenced_packages
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dima_project/api/constants.dart';
import 'package:flutter/material.dart';
import 'package:dima_project/models/movie.dart';

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
          itemCount: 10,
          options: CarouselOptions(
              height: 175,
              autoPlay: true,
              viewportFraction: 0.35,
              enlargeCenterPage: true,
              pageSnapping: true,
              autoPlayCurve: Curves.fastOutSlowIn,
              autoPlayAnimationDuration: const Duration(seconds: 1)),
          itemBuilder: (context, itemIndex, pageViewIndex) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                  height: 175,
                  width: 110,
                  child: Image.network(
                      filterQuality: FilterQuality.high,
                      fit: BoxFit.cover,
                      '${Constants.imagePath}${trendingMovies[itemIndex].posterPath}')),
            );
          },
        ));
  }
}
