import 'package:dima_project/models/movie.dart';
import 'package:dima_project/pages/movies/film_details_page.dart';
import 'package:flutter/material.dart';
import 'package:dima_project/api/tmdb_api.dart';
import 'package:dima_project/widgets/movies_slider.dart';
import 'package:dima_project/widgets/trending_slider.dart';
import 'package:dima_project/models/home_movies_data.dart';
import 'package:dima_project/services/user_menu_manager.dart';
import 'package:logger/logger.dart';
import 'package:dima_project/widgets/movie_search_bar_widget.dart';
import 'package:dima_project/api/constants.dart';

class HomeMovies extends StatefulWidget {
  const HomeMovies({super.key});
  @override
  State<HomeMovies> createState() => HomeMoviesState();
}

class HomeMoviesState extends State<HomeMovies> {
  HomeMoviesData _data = HomeMoviesData();
  final Logger logger = Logger();
  List<Movie> _searchResults = [];
  bool _isSearchExpanded = false;
  bool _isSearching = false;

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
      logger.e('Error initializing data: $e');
      // Handle error (e.g., show a snackbar)
    }
  }

  void _onSearchResults(List<Movie> results) {
    setState(() {
      _searchResults = results;
      _isSearching = results.isNotEmpty;
    });
  }

  void _onSearchExpandChanged(bool expanded) {
    setState(() {
      _isSearchExpanded = expanded;
      if (!_isSearchExpanded) {
        _isSearching = false;
        _searchResults.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              _buildHeader(theme, isDarkMode),
              const SizedBox(height: 16),
              Expanded(
                child:
                    _isSearching ? _buildSearchResults() : _buildMovieContent(),
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
          child: MovieSearchBarWidget(
            theme: theme,
            isDarkMode: isDarkMode,
            onExpandChanged: _onSearchExpandChanged,
            onSearchResults: _onSearchResults,
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
          leading: _buildMoviePoster(movie),
          title: Text(movie.title),
          subtitle: Text(movie.releaseDate ?? 'Release date unknown'),
          onTap: () {
            _retrieveAllMovieInfo(movie);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FilmDetailsPage(movie: movie),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMoviePoster(Movie movie) {
    return SizedBox(
      width: 50,
      height: 75,
      child: movie.posterPath != null
          ? Image.network(
              '${Constants.imagePath}${movie.posterPath}',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                logger.w('Failed to load image: ${movie.posterPath}',
                    error: error, stackTrace: stackTrace);
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
            )
          : _buildPlaceholderImage(),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: Colors.grey[300],
      child: const Icon(Icons.movie, color: Colors.grey),
    );
  }

  Widget _buildMovieContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMovieSection(
              'Trending movies',
              _data.trendingMovies,
              (movies) => TrendingSlider(trendingMovies: movies),
              Theme.of(context)),
          _buildMovieSection('Top rated movies', _data.topRatedMovies,
              (movies) => MoviesSlider(movies: movies), Theme.of(context)),
          _buildMovieSection('Upcoming Movies', _data.upcomingMovies,
              (movies) => MoviesSlider(movies: movies), Theme.of(context)),
        ],
      ),
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
              : //show a loading indicator while movies are being fetched
              const Center(child: CircularProgressIndicator()),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  void _retrieveAllMovieInfo(Movie movie) async {
    try {
      final fullMovie = await retrieveFilmInfo(movie.id);
      final cast = await retrieveCast(movie.id);
      final trailer = await retrieveTrailer(movie.id);

      movie = fullMovie;
      movie.cast = cast;
      movie.trailer = trailer;
    } catch (e) {
      logger.e('Error retrieving movie info: $e');
      // Handle error (e.g., show a snackbar)
    }
  }
}
