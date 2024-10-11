import 'package:dima_project/models/genres.dart';
import 'package:dima_project/models/movie.dart';
import 'package:dima_project/models/user_model.dart';
import 'package:dima_project/pages/movies/film_details_page.dart';
import 'package:dima_project/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:dima_project/api/tmdb_api.dart';
import 'package:dima_project/widgets/movies_slider.dart';
import 'package:dima_project/widgets/trending_slider.dart';
import 'package:dima_project/models/home_movies_data.dart';
import 'package:dima_project/services/user_menu_manager.dart';
import 'package:logger/logger.dart';
import 'package:dima_project/widgets/universal_search_bar_widget.dart';
import 'package:dima_project/api/constants.dart';
import 'package:dima_project/models/person.dart';
import 'package:dima_project/pages/movies/person_details_page.dart';

class HomeMovies extends StatefulWidget {
  const HomeMovies({super.key});
  @override
  State<HomeMovies> createState() => HomeMoviesState();
}

class HomeMoviesState extends State<HomeMovies>
    with SingleTickerProviderStateMixin {
  HomeMoviesData _data = HomeMoviesData();
  final Logger logger = Logger();
  List<Movie> _movieResults = [];
  List<Person> _peopleResults = [];
  bool _isSearchExpanded = false;
  bool _isSearching = false;
  final UserService _userService = UserService();
  MyUser? _currentUser;
  final MovieGenres movieGenres = MovieGenres();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _tabController = TabController(length: 2, vsync: this);
  }

  Future<void> _initializeData() async {
    final currentUser = await _userService.getCurrentUser();
    if (currentUser != null) {
      _currentUser = currentUser;
    }
    try {
      final trending = await fetchTrendingMovies();
      final topRated = await fetchTopRatedMovies();
      final upcoming = await fetchUpcomingMovies();
      final nowPlaying = await fetchNowPlayingMovies();

      List<int> genreIds = _currentUser?.favoriteGenres
              .map((genreName) => movieGenres.getIdFromName(genreName))
              .where((genreId) => genreId != null && genreId != -1)
              .cast<int>()
              .toList() ??
          [];

      final recommended = await fetchMoviesByGenres(genreIds);

      if (mounted) {
        setState(() {
          _data = _data.copyWith(
            trendingMovies: trending,
            topRatedMovies: topRated,
            upcomingMovies: upcoming,
            nowPlayingMovies: nowPlaying,
            recommendedMovies: recommended,
          );
        });
      }
    } catch (e) {
      logger.e('Error initializing data: $e');
      // Handle error (e.g., show a snackbar)
    }
  }

  Future<void> refreshRecommendedMovies() async {
    try {
      if (_currentUser != null) {
        List<int> genreIds = _currentUser!.favoriteGenres
            .map((genreName) => movieGenres.getIdFromName(genreName))
            .where((genreId) => genreId != null && genreId != -1)
            .cast<int>()
            .toList();

        final recommended = await fetchMoviesByGenres(genreIds);

        if (mounted) {
          setState(() {
            _data = _data.copyWith(recommendedMovies: recommended);
          });
        }
      }
    } catch (e) {
      logger.e('Error refreshing recommended movies: $e');
    }
  }

  void _onSearchResults(List<Movie> results, List<Person> peopleResults) {
    setState(() {
      _movieResults = results;
      _peopleResults = peopleResults;
      _isSearching = results.isNotEmpty || peopleResults.isNotEmpty;
    });
  }

  void _onSearchExpandChanged(bool expanded) {
    setState(() {
      _isSearchExpanded = expanded;
      if (!_isSearchExpanded) {
        _isSearching = false;
        _movieResults.clear();
        _peopleResults.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 12.0, left: 12, right: 12),
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
          child: UniversalSearchBarWidget(
            theme: theme,
            isDarkMode: isDarkMode,
            onExpandChanged: _onSearchExpandChanged,
            onSearchResults: _onSearchResults,
          ),
        ),
        const SizedBox(width: 16),
        UserInfo(
          onFavoriteGenresUpdated: refreshRecommendedMovies,
        ),
      ],
    );
  }

  Widget _buildSearchResults() {
    return Column(children: [
      TabBar(
        controller: _tabController,
        tabs: const [Tab(text: 'Movies'), Tab(text: 'People')],
      ),
      Expanded(
          child: TabBarView(controller: _tabController, children: [
        ListView.builder(
          itemCount: _movieResults.length,
          itemBuilder: (context, index) {
            final movie = _movieResults[index];
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
        ),
        ListView.builder(
          itemCount: _peopleResults.length,
          itemBuilder: (context, index) {
            final person = _peopleResults[index];
            return ListTile(
              leading: person.profilePath != null
                  ? Image.network(
                      '${Constants.imagePath}${person.profilePath}',
                      width: 50,
                      height: 75,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        logger.w('Failed to load image: ${person.profilePath}',
                            error: error, stackTrace: stackTrace);
                        return _buildPlaceholderImage();
                      },
                    )
                  : _buildPlaceholderImage(),
              title: Text(person.name),
              subtitle: Text(person.knownForDepartment),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PersonDetailsPage(person: person),
                  ),
                );
              },
            );
          },
        )
      ]))
    ]);
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
          _buildMovieSection('Recommended for You', _data.recommendedMovies,
              (movies) => MoviesSlider(movies: movies), Theme.of(context)),
          _buildMovieSection('Top rated movies', _data.topRatedMovies,
              (movies) => MoviesSlider(movies: movies), Theme.of(context)),
          _buildMovieSection('Upcoming Movies', _data.upcomingMovies,
              (movies) => MoviesSlider(movies: movies), Theme.of(context)),
          _buildMovieSection('Now Playing', _data.nowPlayingMovies,
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
        const SizedBox(height: 12),
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
