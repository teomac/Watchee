import 'package:dima_project/models/movie.dart';
import 'package:dima_project/pages/film_details/film_details_page.dart';
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
  final TextEditingController _searchController = TextEditingController();
  List<Movie> _searchResults = [];

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

  Future<void> _onSearch(String query) async {
    try {
      final results =
          await searchMovie(query); // Call your searchMovie function
      setState(() {
        _searchResults = results;
      });
    } catch (e) {
      logger.d('Error searching movies: $e');
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
                child: _searchResults.isNotEmpty
                    ? _buildSearchResults()
                    : SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildMovieSection(
                                'Trending movies',
                                _data.trendingMovies,
                                (movies) =>
                                    TrendingSlider(trendingMovies: movies),
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
              return TextField(
                controller: _searchController,
                onChanged: (value) {
                  _onSearch(value);
                },
                decoration: InputDecoration(
                  hintText: 'Search movies...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                ),
              );
            },
            suggestionsBuilder:
                (BuildContext context, SearchController controller) {
              if (_searchResults.isEmpty) {
                return [];
              }
              return _searchResults.take(5).map((movie) {
                return ListTile(
                  title: Text(movie.title),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                FilmDetailsPage(movie: movie)));
                  },
                );
              }).toList();
            },
          ),
        ),
        const SizedBox(width: 16),
        const UserInfo(),
      ],
    );
  }

  Widget _buildSearchResults() {
    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final movie = _searchResults[index];
        return ListTile(
          leading: movie.posterPath != null
              ? Image.network(
                  'https://image.tmdb.org/t/p/w92${movie.posterPath}',
                  width: 50,
                  fit: BoxFit.cover,
                )
              : const Icon(Icons.movie),
          title: Text(movie.title),
          subtitle: Text(movie.releaseDate ?? ''),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => FilmDetailsPage(movie: movie)));
          },
        );
      },
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
