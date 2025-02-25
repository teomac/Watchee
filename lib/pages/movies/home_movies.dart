// ignore_for_file: use_build_context_synchronously

import 'package:dima_project/models/genres.dart';
import 'package:provider/provider.dart';
import 'package:dima_project/models/movie.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/pages/movies/film_details_page.dart';
import 'package:dima_project/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:dima_project/services/tmdb_api_service.dart';
import 'package:dima_project/widgets/movies_slider.dart';
import 'package:dima_project/widgets/trending_slider.dart';
import 'package:dima_project/models/home_movies_data.dart';
import 'package:dima_project/services/user_menu_manager.dart';
import 'package:logger/logger.dart';
import 'package:dima_project/widgets/universal_search_bar_widget.dart';
import 'package:dima_project/api/constants.dart';
import 'package:dima_project/models/person.dart';
import 'package:dima_project/pages/movies/person_details_page.dart';
import 'package:dima_project/widgets/home_carousel.dart';
import 'package:dima_project/widgets/double_row_slider.dart';

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
  MyUser? _currentUser;
  final MovieGenres movieGenres = MovieGenres();
  late TabController _tabController;
  bool _firstTime = true;
  late TmdbApiService tmdbApi;

  @override
  void initState() {
    super.initState();
    tmdbApi = Provider.of<TmdbApiService>(context, listen: false);
    if (_firstTime) {
      _initializeData();
      _firstTime = false;
    }
    _tabController = TabController(length: 2, vsync: this);
  }

  Future<void> _initializeData() async {
    final currentUser =
        await Provider.of<UserService>(context, listen: false).getCurrentUser();
    if (currentUser != null) {
      _currentUser = currentUser;
    }
    try {
      final trending = await tmdbApi.fetchTrendingMovies();
      final topRated = await tmdbApi.fetchTopRatedMovies();
      final upcoming = await tmdbApi.fetchUpcomingMovies();
      final nowPlaying = await tmdbApi.fetchNowPlayingMovies();

      List<int> genreIds = _currentUser?.favoriteGenres
              .map((genreName) => movieGenres.getIdFromName(genreName))
              .where((genreId) => genreId != null && genreId != -1)
              .cast<int>()
              .toList() ??
          [];
      if (genreIds.isEmpty) {
        genreIds = [
          28,
          12,
          16,
          35,
          80,
          99,
          18,
          10751,
          14,
          36,
          27,
          10402,
          9648,
          10749,
          878,
          10770,
          53,
          10752,
          37
        ];
      }

      final recommended = await tmdbApi.fetchMoviesByGenres(genreIds);
      final animation = await tmdbApi.fetchMoviesByGenres([16]);
      final family = await tmdbApi.fetchMoviesByGenres([10751]);
      final documentary = await tmdbApi.fetchMoviesByGenres([99]);
      final drama = await tmdbApi.fetchMoviesByGenres([18]);
      final comedy = await tmdbApi.fetchMoviesByGenres([35]);
      final horror = await tmdbApi.fetchMoviesByGenres([27]);

      if (mounted) {
        setState(() {
          _data = _data.copyWith(
            trendingMovies: trending,
            topRatedMovies: topRated,
            upcomingMovies: upcoming,
            nowPlayingMovies: nowPlaying,
            recommendedMovies: recommended,
            animationMovies: animation,
            familyMovies: family,
            documentaryMovies: documentary,
            dramaMovies: drama,
            comedyMovies: comedy,
            horrorMovies: horror,
          );
        });
      }
    } catch (e) {
      logger.e('Error initializing data: $e');
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

        final recommended = await tmdbApi.fetchMoviesByGenres(genreIds);

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
      _isSearching = true;
    });
  }

  void _onSearchExpandChanged(bool expanded) {
    setState(() {
      _isSearchExpanded = expanded;
      _isSearching = true;
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
              const SizedBox(height: 12),
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
        _movieResults.isEmpty
            ? const Center(child: Text('No movies found'))
            : ListView.builder(
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
        _peopleResults.isEmpty
            ? const Center(child: Text('No people found'))
            : ListView.builder(
                itemCount: _peopleResults.length,
                itemBuilder: (context, index) {
                  final person = _peopleResults[index];
                  return ListTile(
                    leading: person.profilePath != null
                        ? Image.network(
                            '${Constants.lowQualityImagePath}${person.profilePath}',
                            width: 50,
                            height: 75,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              logger.w(
                                  'Failed to load image: ${person.profilePath}',
                                  error: error,
                                  stackTrace: stackTrace);
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
                          builder: (context) =>
                              PersonDetailsPage(person: person),
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
              '${Constants.lowQualityImagePath}${movie.posterPath}',
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
    //check if the screen orientation is vertical or horizontal
    final bool isVertical =
        MediaQuery.of(context).orientation == Orientation.portrait;

    bool isTablet = MediaQuery.of(context).size.shortestSide >= 500;
    return SingleChildScrollView(
      child: isVertical
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHomeCarousel(_data.trendingMovies, isTablet),
                const SizedBox(height: 12),
                if (!isTablet)
                  _buildMovieSection(
                      'Trending Movies',
                      _data.trendingMovies,
                      (movies) => TrendingSlider(trendingMovies: movies),
                      Theme.of(context)),
                if (isTablet)
                  _buildMovieSection(
                      'Trending Movies',
                      _data.trendingMovies,
                      (movies) => MoviesSlider(movies: movies, shuffle: true),
                      Theme.of(context)),
                _buildMovieSection(
                    'Recommended for You',
                    _data.recommendedMovies,
                    (movies) => MoviesSlider(movies: movies),
                    Theme.of(context)),
                _buildMovieSection(
                    'Top rated Movies',
                    _data.topRatedMovies,
                    (movies) => MoviesSlider(movies: movies),
                    Theme.of(context)),
                _buildMovieSection(
                    'Upcoming Movies',
                    _data.upcomingMovies,
                    (movies) => MoviesSlider(movies: movies),
                    Theme.of(context)),
                _buildMovieSection(
                    'Now Playing',
                    _data.nowPlayingMovies,
                    (movies) => MoviesSlider(movies: movies),
                    Theme.of(context)),
                _buildMovieSection(
                    'Family Movies',
                    _data.familyMovies,
                    (movies) => MoviesSlider(movies: movies),
                    Theme.of(context)),
                _buildMovieSection(
                    'Documentary Movies',
                    _data.documentaryMovies,
                    (movies) => MoviesSlider(movies: movies),
                    Theme.of(context)),
                _buildMovieSection(
                    'Animation Movies',
                    _data.animationMovies,
                    (movies) => MoviesSlider(movies: movies),
                    Theme.of(context)),
                _buildMovieSection(
                    'Comedy Movies',
                    _data.comedyMovies,
                    (movies) => MoviesSlider(movies: movies),
                    Theme.of(context)),
                _buildMovieSection(
                    'Horror Movies',
                    _data.horrorMovies,
                    (movies) => MoviesSlider(movies: movies),
                    Theme.of(context)),
                _buildMovieSection(
                    'Drama Movies',
                    _data.dramaMovies,
                    (movies) => MoviesSlider(movies: movies),
                    Theme.of(context)),
              ],
            )
          : //landscape tablet mode
          Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHorizontalTabletLayout(),
                _buildMovieSection(
                    'Recommended for You',
                    _data.recommendedMovies,
                    (movies) => MoviesSlider(movies: movies),
                    Theme.of(context)),
                _buildMovieSection(
                    'Top rated Movies',
                    _data.topRatedMovies,
                    (movies) => MoviesSlider(movies: movies),
                    Theme.of(context)),
                _buildMovieSection(
                    'Upcoming Movies',
                    _data.upcomingMovies,
                    (movies) => MoviesSlider(movies: movies),
                    Theme.of(context)),
                _buildMovieSection(
                    'Now Playing',
                    _data.nowPlayingMovies,
                    (movies) => MoviesSlider(movies: movies),
                    Theme.of(context)),
                _buildMovieSection(
                    'Family Movies',
                    _data.familyMovies,
                    (movies) => MoviesSlider(movies: movies),
                    Theme.of(context)),
                _buildMovieSection(
                    'Documentary Movies',
                    _data.documentaryMovies,
                    (movies) => MoviesSlider(movies: movies),
                    Theme.of(context)),
                _buildMovieSection(
                    'Animation Movies',
                    _data.animationMovies,
                    (movies) => MoviesSlider(movies: movies),
                    Theme.of(context)),
                _buildMovieSection(
                    'Comedy Movies',
                    _data.comedyMovies,
                    (movies) => MoviesSlider(movies: movies),
                    Theme.of(context)),
                _buildMovieSection(
                    'Horror Movies',
                    _data.horrorMovies,
                    (movies) => MoviesSlider(movies: movies),
                    Theme.of(context)),
                _buildMovieSection(
                    'Drama Movies',
                    _data.dramaMovies,
                    (movies) => MoviesSlider(movies: movies),
                    Theme.of(context)),
              ],
            ),
    );
  }

  _buildHorizontalTabletLayout() {
    return Row(
      children: [
        Expanded(
            child: Column(
          children: [_buildHomeCarousel(_data.trendingMovies, true)],
        )),
        const SizedBox(width: 12),
        Expanded(
            child: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: _buildMovieSection(
              'Trending Movies',
              _data.trendingMovies,
              (movies) => DoubleRowSlider(movies: movies, shuffle: true),
              Theme.of(context)),
        ))
      ],
    );
  }

  _buildHomeCarousel(List<Movie>? trendingMovies, bool isTablet) {
    if (trendingMovies == null || trendingMovies.isEmpty) {
      return const SizedBox.shrink();
    }
    return HomeCarousel(
      movies: trendingMovies.sublist(0, 5),
      isTablet: isTablet,
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
      final fullMovie = await tmdbApi.retrieveFilmInfo(movie.id);
      final cast = await tmdbApi.retrieveCast(movie.id);
      final trailer = await tmdbApi.retrieveTrailer(movie.id);

      movie = fullMovie;
      movie.cast = cast;
      movie.trailer = trailer;
    } catch (e) {
      logger.e('Error retrieving movie info: $e');
    }
  }
}
