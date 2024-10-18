import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dima_project/models/movie.dart';
import 'package:dima_project/api/constants.dart';
import 'package:dima_project/pages/movies/film_details_page.dart';

class CustomSlider extends StatefulWidget {
  final Widget Function(BuildContext context, int itemIndex, int) itemBuilder;
  final int itemCount;
  final bool isTablet;

  const CustomSlider({
    super.key,
    required this.itemBuilder,
    required this.itemCount,
    this.isTablet = false,
  });

  @override
  State<CustomSlider> createState() => _CustomSliderState();
}

class _CustomSliderState extends State<CustomSlider> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isVertical =
        MediaQuery.of(context).orientation == Orientation.portrait;

    if (widget.itemCount == 0) {
      return SizedBox(
        height: !widget.isTablet ? size.height * 0.48 : size.height * 0.38,
        child: const Center(
          child: Text('No movies available'),
        ),
      );
    }
    return Stack(
      children: [
        ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CarouselSlider.builder(
              itemCount: widget.itemCount,
              options: CarouselOptions(
                viewportFraction: 1,
                height: !widget.isTablet
                    ? size.height * 0.48
                    : isVertical
                        ? size.height * 0.38
                        : 398,
                autoPlay: true,
                onPageChanged: (index, reason) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
              ),
              itemBuilder: widget.itemBuilder,
            )),
        Positioned(
          left: 0,
          right: 0,
          bottom: 8,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.itemCount, (index) {
              return Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentIndex == index
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.primary.withOpacity(0.5),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

class SliderCard extends StatelessWidget {
  final Movie movie;
  final int itemIndex;

  const SliderCard({
    super.key,
    required this.movie,
    required this.itemIndex,
  });

  @override
  Widget build(BuildContext context) {
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
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              '${Constants.imageOriginalPath}${movie.backdropPath}',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[900],
                  child: const Icon(Icons.error, size: 50, color: Colors.white),
                );
              },
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.1),
                      Colors.black.withOpacity(0.4),
                      Colors.black.withOpacity(0.7),
                      Colors.black.withOpacity(0.9),
                    ],
                    stops: const [0.0, 0.5, 0.65, 0.8, 1.0],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    movie.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    movie.releaseDate ?? 'Unknown release date',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeCarousel extends StatelessWidget {
  final List<Movie> movies;
  final bool isTablet;

  const HomeCarousel({super.key, required this.movies, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    if (movies.isEmpty) {
      return const SizedBox.shrink();
    }
    return CustomSlider(
      isTablet: isTablet,
      itemCount: movies.length,
      itemBuilder: (context, itemIndex, _) {
        return SliderCard(
          movie: movies[itemIndex],
          itemIndex: itemIndex,
        );
      },
    );
  }
}
