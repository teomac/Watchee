import 'package:dima_project/models/movie.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dima_project/api/tmdb_api.dart';
import 'package:dima_project/widgets/movies_slider.dart';
import 'package:dima_project/widgets/trending_slider.dart';
import 'package:dima_project/models/home_movies_data.dart';
import 'package:dima_project/services/user_menu_manager.dart';
import 'package:dima_project/theme/theme_provider.dart';
import 'package:logger/logger.dart';

class HomeMovies extends StatefulWidget {
  const HomeMovies({super.key});
  @override
  State<HomeMovies> createState() => HomeMoviesState();
}

class HomeMoviesState extends State<HomeMovies> {
  HomeMoviesData _data = HomeMoviesData();
  final Logger logger = Logger();

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      final trending = await fetchTrendingMovies();
      final topRated = await fetchTopRatedMovies();
      final upcoming = await fetchUpcomingMovies();

      if (mounted) {
        setState(() {
          _data = _data.copyWith(
            trendingMovies: trending,
            topRatedMovies: topRated,
            upcomingMovies: upcoming,
          );
        });
      }
    } catch (e) {
      logger.d('Error initializing data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildHeader(theme, isDarkMode),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMovieSection(
                          'Trending movies',
                          _data.trendingMovies,
                          (movies) => TrendingSlider(trendingMovies: movies),
                          theme),
                      _buildMovieSection(
                          'Top rated movies',
                          _data.topRatedMovies,
                          (movies) => MoviesSlider(movies: movies),
                          theme),
                      _buildMovieSection(
                          'Upcoming Movies',
                          _data.upcomingMovies,
                          (movies) => MoviesSlider(movies: movies),
                          theme),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, bool isDarkMode) {
    return Row(
      children: [
        Expanded(
          child: SearchAnchor(
            builder: (BuildContext context, SearchController controller) {
              return SearchBar(
                controller: controller,
                onTap: () => controller.openView(),
                onChanged: (_) => controller.openView(),
                leading: Icon(Icons.search, color: theme.iconTheme.color),
                hintText: 'Search movies...',
                hintStyle: WidgetStateProperty.all(
                  TextStyle(color: theme.hintColor),
                ),
                backgroundColor: WidgetStateProperty.all(
                  theme.brightness == Brightness.dark
                      ? Colors.grey[900]
                      : Colors.grey[200],
                ),
                elevation: WidgetStateProperty.all(0),
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                padding: const WidgetStatePropertyAll<EdgeInsets>(
                  EdgeInsets.symmetric(horizontal: 16),
                ),
                constraints: const BoxConstraints(
                  minHeight: 48,
                  maxHeight: 48,
                ),
              );
            },
            suggestionsBuilder:
                (BuildContext context, SearchController controller) {
              // TODO: Implement search suggestions
              return List<ListTile>.generate(5, (int index) {
                return ListTile(
                  title: Text('Suggestion $index'),
                  onTap: () {
                    // Handle suggestion tap
                  },
                );
              });
            },
          ),
        ),
        const SizedBox(width: 16),
        const UserInfo(),
      ],
    );
  }

  Widget _buildMovieSection(String title, List<Movie>? movies,
      Function(List<Movie>) sliderBuilder, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 6),
        SizedBox(
          child: movies != null
              ? sliderBuilder(movies)
              : Center(
                  child: Text(
                    'Failed to load $title',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
