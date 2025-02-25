// ignore_for_file: deprecated_member_use

import 'package:dima_project/services/tmdb_api_service.dart';
import 'package:dima_project/models/movie_review.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/models/watchlist.dart';
import 'package:dima_project/services/user_service.dart';
import 'package:dima_project/services/watchlist_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dima_project/models/movie.dart';
import 'package:intl/intl.dart';
import 'package:dima_project/api/constants.dart';
import 'package:logger/logger.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dima_project/pages/movies/person_details_page.dart';
import 'package:dima_project/models/person.dart';
import 'package:dima_project/widgets/squared_header.dart';
import 'package:provider/provider.dart';
import 'package:dima_project/models/tiny_movie.dart';

class FilmDetailsBloc extends Bloc<FilmDetailsEvent, FilmDetailsState> {
  final TmdbApiService _apiService;

  FilmDetailsBloc(this._apiService) : super(FilmDetailsInitial()) {
    on<LoadFilmDetails>(_onLoadFilmDetails);
  }

  Future<void> _onLoadFilmDetails(
    LoadFilmDetails event,
    Emitter<FilmDetailsState> emit,
  ) async {
    emit(FilmDetailsLoading());
    try {
      final movie = await _apiService.retrieveFilmInfo(event.movieId);
      final trailerKey = await _apiService.retrieveTrailer(event.movieId);
      final cast = await _apiService.retrieveCast(event.movieId);

      emit(FilmDetailsLoaded(movie, trailerKey: trailerKey, cast: cast));
    } catch (e) {
      emit(FilmDetailsError(e.toString()));
    }
  }
}

// Event
abstract class FilmDetailsEvent {}

class LoadFilmDetails extends FilmDetailsEvent {
  final int movieId;
  LoadFilmDetails(this.movieId);
}

class DisposeYoutubePlayer extends FilmDetailsEvent {}

// State
abstract class FilmDetailsState {}

class FilmDetailsInitial extends FilmDetailsState {}

class FilmDetailsLoading extends FilmDetailsState {}

class FilmDetailsLoaded extends FilmDetailsState {
  final Movie movie;
  final String? trailerKey;
  final List<Map<String, dynamic>>? cast;

  FilmDetailsLoaded(this.movie, {this.trailerKey, this.cast});
}

class FilmDetailsError extends FilmDetailsState {
  final String message;
  FilmDetailsError(this.message);
}

class FilmDetailsPage extends StatefulWidget {
  final Movie movie;

  const FilmDetailsPage({required this.movie, super.key});

  @override
  State<FilmDetailsPage> createState() => _FilmDetailsPageState();
}

class _FilmDetailsPageState extends State<FilmDetailsPage> {
  bool _isDisposing = false;
  final bool _showYoutubePlayer = true;
  final TextEditingController _reviewController = TextEditingController();
  int _selectedRating = 0;
  MyUser? _currentUser;
  List<MovieReview> _friendsReviews = [];
  List<WatchList> _userWatchlists = [];
  List<String> _likedMovies = [];
  List<String> _seenMovies = [];
  bool _isSubmitButtonEnabled = false;
  YoutubePlayerController? _youtubePlayerController;
  bool _showAllReviews = false;
  final List<String> _countries = ['US', 'IT', 'UK', 'FR', 'DE', 'CH', 'ES'];
  String _selectedCountry = 'US';
  Map<String, List<Map<String, dynamic>>> _allProviders = {};
  List<Movie> _recommendedMovies = [];
  final Logger logger = Logger();
  late ScrollController _scrollController;
  bool _showTitle = false;

  @override
  void dispose() {
    _reviewController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()
      ..addListener(() {
        setState(() {
          _showTitle = _scrollController.hasClients &&
              _scrollController.offset > (300 - kToolbarHeight);
        });
      });
    _initializeData().then((_) {
      _fetchAllProviders();
      _fetchFriendsReviews();
      _fetchRecommendedMovies();
    });

    _reviewController.addListener(_updateSubmitButton);
  }

  void _updateSubmitButton() {
    setState(() {
      _isSubmitButtonEnabled = _reviewController.text.trim().isNotEmpty;
    });
  }

  Tinymovie fromString(String string) {
    final List<String> split = string.split(',,,');
    return Tinymovie(
      id: int.parse(split[0]),
      title: split[1],
      posterPath: split[2],
      releaseDate: split[3],
    );
  }

  Future<void> _initializeData() async {
    try {
      final currentUser = await Provider.of<UserService>(context, listen: false)
          .getCurrentUser();
      if (currentUser != null) {
        _currentUser = currentUser;
        _fetchUserWatchlists();
        _fetchLikedMovies();
        _fetchSeenMovies();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error initializing data: $e')),
        );
      }
    }
  }

  Future<void> _fetchLikedMovies() async {
    if (_currentUser == null) return;
    List<String> likedMovies =
        await Provider.of<UserService>(context, listen: false)
            .getLikedMovieIds(_currentUser!.id);
    if (mounted) {
      setState(() {
        _likedMovies = likedMovies;
      });
    }
  }

  Future<void> _fetchSeenMovies() async {
    if (_currentUser == null) return;
    List<String> seenMovies =
        await Provider.of<UserService>(context, listen: false)
            .getSeenMovieIds(_currentUser!.id);
    if (mounted) {
      setState(() {
        _seenMovies = seenMovies;
      });
    }
  }

  Future<void> _fetchFriendsReviews() async {
    if (_currentUser == null) return;
    List<MovieReview> reviews =
        await Provider.of<UserService>(context, listen: false)
            .getFriendsReviews(_currentUser!.id, widget.movie.id);
    if (mounted) {
      setState(() {
        _friendsReviews = reviews;
      });
    }
  }

  Future<void> _fetchUserWatchlists() async {
    final watchlistService =
        Provider.of<WatchlistService>(context, listen: false);
    if (_currentUser == null) return;
    try {
      List<WatchList> watchlists =
          await watchlistService.getOwnWatchLists(_currentUser!.id);
      List<WatchList> collabWatchlists =
          await watchlistService.getCollabWatchLists(_currentUser!.id);
      setState(() {
        _userWatchlists = watchlists + collabWatchlists;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to fetch watchlists: $e')));
      }
    }
  }

  Future<void> _fetchAllProviders() async {
    try {
      final providers =
          await Provider.of<TmdbApiService>(context, listen: false)
              .fetchAllProviders(widget.movie.id);
      setState(() {
        _allProviders = providers;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load providers: $e')),
        );
      }
    }
  }

  Future<void> _fetchRecommendedMovies() async {
    try {
      final recommendations =
          await Provider.of<TmdbApiService>(context, listen: false)
              .fetchRecommendedMovies(widget.movie.id);
      setState(() {
        _recommendedMovies = recommendations;
      });
    } catch (e) {
      logger.e('Error fetching recommended movies: $e');
    }
  }

  Future<void> _launchYouTubeVideo(String? videoId) async {
    if (videoId == null || videoId.isEmpty) return;

    final Uri youtubeUrl =
        Uri.parse('https://www.youtube.com/watch?v=$videoId');
    try {
      if (await canLaunchUrl(youtubeUrl)) {
        await launchUrl(youtubeUrl, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $youtubeUrl';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening YouTube: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.shortestSide >= 500;
    bool isHorizontal =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return BlocProvider(
      create: (context) =>
          FilmDetailsBloc(Provider.of<TmdbApiService>(context, listen: false))
            ..add(LoadFilmDetails(widget.movie.id)),
      child: BlocBuilder<FilmDetailsBloc, FilmDetailsState>(
        builder: (context, state) {
          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (bool didPop, Object? result) async {
              if (didPop) return;
              if (!_isDisposing) {
                setState(() => _isDisposing = true);
                _youtubePlayerController?.close();
                // Allow the frame to rebuild without the YouTube player
                await Future.microtask(() {});
                if (context.mounted) Navigator.of(context).pop();
              }
            },
            child: Stack(
              children: [
                (isTablet && isHorizontal)
                    ? Scaffold(body: _buildBodyTablet(context, state))
                    : Scaffold(
                        body: _buildBody(context, state),
                      ),
                if (_isDisposing)
                  Container(
                    color: Colors.black,
                    child: const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBodyTablet(BuildContext context, FilmDetailsState state) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final horizontalPadding = screenWidth * 0.02;

    if (state is FilmDetailsLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is FilmDetailsLoaded) {
      return Scaffold(
        appBar: AppBar(
          title: Text(state.movie.title),
          centerTitle: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SafeArea(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column - Profile Info
              Expanded(
                flex: isLandscape ? 55 : 50,
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile Header
                      ProfileHeaderWidget(
                        imagePath: state.movie.backdropPath != null
                            ? '${Constants.imageOriginalPath}${state.movie.backdropPath}'
                            : null,
                        useBackdropImage: true,
                        actionButton: _buildAddButton(state.movie, true),
                        additionalInfo: [
                          Text(state.movie.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 26,
                                  )),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                color: Colors.white70,
                                size: 20,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _formatReleaseDate(state.movie.releaseDate),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                        fontSize: 16, color: Colors.white),
                              ),
                              const SizedBox(width: 8),
                              Text('•',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                          fontSize: 16, color: Colors.white)),
                              const SizedBox(width: 8),
                              if (state.movie.runtime != null) ...[
                                const Icon(
                                  Icons.access_time,
                                  color: Colors.white70,
                                  size: 20,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _formatRuntime(state.movie.runtime),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                          fontSize: 16, color: Colors.white),
                                ),
                              ],
                              const SizedBox(width: 8),
                              Text('•',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                          fontSize: 16, color: Colors.white)),
                              const SizedBox(width: 8),
                              if (state.movie.voteAverage > 0) ...[
                                const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 20,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${(state.movie.voteAverage * 10).toStringAsFixed(0)}%',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                ),
                              ],
                            ],
                          ),
                        ],
                        size: isLandscape
                            ? screenWidth * 0.4
                            : screenWidth * 0.55,
                      ),

                      const SizedBox(height: 12),
                      _buildGenres(state.movie),
                      const SizedBox(height: 12),
                      _buildQuoteCard(state.movie),

                      const SizedBox(height: 12),
                      _buildOverview(state.movie),
                      const SizedBox(height: 12),
                      _buildCast(state.cast),
                      const SizedBox(height: 12),
                      _buildRecommendedMoviesCard(),
                    ],
                  ),
                ),
              ),
              // Vertical Divider
              if (isLandscape) const VerticalDivider(width: 1),

              // Right Column - Known For Section
              Expanded(
                flex: isLandscape ? 45 : 50,
                child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                    ),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTrailer(context, state.trailerKey),
                          const SizedBox(height: 12),
                          _buildProvidersSection(),
                          const SizedBox(height: 12),
                          _buildFriendReviews(),
                          const SizedBox(height: 12),
                          _buildAddYourReview(),
                        ])),
              ),
            ],
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildBody(BuildContext context, FilmDetailsState state) {
    if (state is FilmDetailsLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is FilmDetailsLoaded) {
      return SafeArea(
          child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildAppBar(state.movie),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildGenres(state.movie),
                  const SizedBox(height: 16),
                  _buildQuoteCard(state.movie),
                  const SizedBox(height: 16),
                  _buildOverview(state.movie),
                  const SizedBox(height: 16),
                  _buildProvidersSection(),
                  const SizedBox(height: 16),
                  _buildCast(state.cast),
                  const SizedBox(height: 16),
                  if (_showYoutubePlayer)
                    _buildTrailer(context, state.trailerKey),
                  const SizedBox(height: 16),
                  _buildFriendReviews(),
                  const SizedBox(height: 16),
                  _buildAddYourReview(),
                  const SizedBox(height: 16),
                  _buildRecommendedMoviesCard(),
                ],
              ),
            ),
          ),
        ],
      ));
    } else if (state is FilmDetailsError) {
      return Center(child: Text('Error: ${state.message}'));
    }
    return const SizedBox.shrink();
  }

  Widget _buildAppBar(Movie movie) {
    final bool isTablet = MediaQuery.of(context).size.shortestSide >= 500;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    return SliverAppBar(
      expandedHeight: isTablet ? 450 : 350.0,
      pinned: true,
      //stretch: true,
      title: AnimatedOpacity(
        opacity: _showTitle ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: Text(widget.movie.title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                )),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Backdrop image
            movie.backdropPath != null
                ? Image.network(
                    '${Constants.imageOriginalPath}${movie.backdropPath}',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(color: Colors.grey);
                    },
                  )
                : Container(color: colorScheme.surface),
            // Gradient overlay for fade effect
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
            // Content overlay
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  isTablet
                      ? Text(movie.title,
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 26,
                                  ))
                      : Text(movie.title,
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  )),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: Colors.white70,
                        size: isTablet ? 20 : 16,
                      ),
                      const SizedBox(width: 4),
                      isTablet
                          ? Text(
                              _formatReleaseDate(movie.releaseDate),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(fontSize: 16, color: Colors.white),
                            )
                          : Text(
                              _formatReleaseDate(movie.releaseDate),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Colors.white,
                                  ),
                            ),
                      const SizedBox(width: 8),
                      isTablet
                          ? Text('•',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(fontSize: 16))
                          : Text('•',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Colors.white,
                                  )),
                      const SizedBox(width: 8),
                      if (movie.runtime != null) ...[
                        Icon(
                          Icons.access_time,
                          color: Colors.white70,
                          size: isTablet ? 20 : 16,
                        ),
                        const SizedBox(width: 4),
                        isTablet
                            ? Text(
                                _formatRuntime(movie.runtime),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                        fontSize: 16, color: Colors.white),
                              )
                            : Text(
                                _formatRuntime(movie.runtime),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: Colors.white),
                              ),
                      ],
                      const SizedBox(width: 8),
                      isTablet
                          ? Text('•',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(fontSize: 16, color: Colors.white))
                          : Text('•',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Colors.white,
                                  )),
                      const SizedBox(width: 8),
                      if (movie.voteAverage > 0) ...[
                        Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: isTablet ? 20 : 16,
                        ),
                        const SizedBox(width: 4),
                        isTablet
                            ? Text(
                                '${(movie.voteAverage * 10).toStringAsFixed(0)}%',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                              )
                            : Text(
                                '${(movie.voteAverage * 10).toStringAsFixed(0)}%',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Colors.white,
                                    ),
                              ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            _buildAddButton(movie, isTablet),
          ],
        ),
        stretchModes: const [StretchMode.zoomBackground],
        collapseMode: CollapseMode.pin,
      ),
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            color: _showTitle
                ? Colors.transparent
                : colorScheme.surface.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_back,
                color: _showTitle
                    ? isDark
                        ? Colors.white
                        : Colors.black
                    : Colors.white),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
      ),
    );
  }

  String _formatReleaseDate(String? releaseDate) {
    if (releaseDate == null || releaseDate.isEmpty) {
      return 'Release date unknown';
    }
    final date = DateTime.tryParse(releaseDate);
    if (date == null) return releaseDate;
    return DateFormat.yMMMMd().format(date);
  }

  String _formatRuntime(int? runtime) {
    if (runtime == null) return 'Runtime unknown';
    final hours = runtime ~/ 60;
    final minutes = runtime % 60;
    return '${hours}h ${minutes}m';
  }

  Widget _buildAddButton(Movie movie, bool isTablet) {
    return Positioned(
        right: 8,
        bottom: 8,
        child: IconButton(
          color: Colors.white,
          icon: const Icon(Icons.add),
          iconSize: isTablet ? 50 : 40,
          onPressed: () {
            _showWatchlistModal();
          },
        ));
  }

  // New method to build the quote card
  Widget _buildQuoteCard(Movie movie) {
    if (movie.tagline == null || movie.tagline!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Wrap(
          children: [
            const Icon(Icons.format_quote),
            const SizedBox(width: 12),
            Text(
              movie.tagline!,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(fontStyle: FontStyle.italic, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenres(Movie movie) {
    return movie.genres!.isNotEmpty
        ? Wrap(
            spacing: 8,
            children:
                movie.genres!.map((genre) => Chip(label: Text(genre))).toList(),
          )
        : const Text('Genres: Unknown',
            style: TextStyle(fontSize: 16, color: Colors.grey));
  }

  Widget _buildOverview(Movie movie) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Overview',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              movie.overview.isNotEmpty
                  ? movie.overview
                  : 'No overview available.',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCast(List<Map<String, dynamic>>? cast) {
    if (cast == null || cast.isEmpty) {
      return const Card(
        elevation: 4,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No cast information available.'),
        ),
      );
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cast',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 150,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: cast.length,
                itemBuilder: (context, index) {
                  final actor = cast[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PersonDetailsPage(
                              person: Person(
                                adult: false,
                                alsoKnownAs: [],
                                gender: 0,
                                id: actor['id'],
                                knownForDepartment:
                                    actor['known_for_department'] ?? '',
                                name: actor['name'] ?? '',
                                popularity: actor['popularity'] ?? 0.0,
                                profilePath: actor['profile_path'],
                                knownFor: [],
                              ),
                            ),
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundImage: actor['profile_path'] != null
                                ? NetworkImage(
                                    'https://image.tmdb.org/t/p/w185${actor['profile_path']}')
                                : null,
                            child: actor['profile_path'] == null
                                ? Text(actor['name'][0])
                                : null,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            constraints: const BoxConstraints(
                              maxWidth: 120,
                            ),
                            child: Text(
                              actor['name'],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            constraints: const BoxConstraints(
                              maxWidth: 120,
                            ),
                            child: Text(
                              actor['character'] ?? '',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrailer(BuildContext context, String? trailerKey) {
    bool isTablet = MediaQuery.of(context).size.shortestSide >= 500;
    bool isHorizontal =
        MediaQuery.of(context).orientation == Orientation.landscape;
    if (trailerKey == null || trailerKey.isEmpty) {
      return const SizedBox.shrink();
    }

    _youtubePlayerController = YoutubePlayerController.fromVideoId(
      videoId: trailerKey,
      autoPlay: false,
      params: const YoutubePlayerParams(
        mute: false,
        showControls: true,
        showFullscreenButton: false,
        //pointerEvents: PointerEvents.none,
      ),
    );

    return Card(
      elevation: 4,
      child: Padding(
        padding: (isTablet && isHorizontal)
            ? const EdgeInsets.only(bottom: 16, right: 16, left: 16)
            : const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Trailer',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            YoutubePlayerScaffold(
              controller: _youtubePlayerController!,
              aspectRatio: 16 / 9,
              enableFullScreenOnVerticalDrag: false,
              autoFullScreen: false,
              //gestureRecognizers: const {},
              fullscreenOrientations: const [
                DeviceOrientation.portraitDown,
                DeviceOrientation.portraitUp
              ],
              defaultOrientations:
                  MediaQuery.of(context).size.shortestSide < 500
                      ? const [
                          DeviceOrientation.portraitDown,
                          DeviceOrientation.portraitUp
                        ]
                      : DeviceOrientation.values,
              builder: (context, player) => player,
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () => _launchYouTubeVideo(trailerKey),
              icon: const Icon(Icons.open_in_new),
              label: const Text('Watch on YouTube'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildFriendReviews() {
    if (_friendsReviews.isEmpty) {
      return const Card(
        elevation: 4,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'No reviews from followed users available.',
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    final reviewsToShow =
        _showAllReviews ? _friendsReviews : _friendsReviews.take(2).toList();

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Friends Reviews',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...reviewsToShow.map((review) {
              return ListTile(
                leading: CircleAvatar(
                  child: Text(
                      review.username.isNotEmpty ? review.username[0] : '?'),
                ),
                title: Text(review.username),
                subtitle: Text(review.text),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, color: Colors.amber),
                    Text(review.rating.toStringAsFixed(1)),
                  ],
                ),
              );
            }),
            if (_friendsReviews.length > 2)
              TextButton(
                  onPressed: () {
                    setState(() {
                      _showAllReviews = !_showAllReviews;
                    });
                  },
                  child: Text(_showAllReviews
                      ? 'Show less reviews'
                      : 'Show all friends reviews'))
          ],
        ),
      ),
    );
  }

  Widget _buildAddYourReview() {
    final releaseDate = widget.movie.releaseDate != null
        ? DateTime.tryParse(widget.movie.releaseDate!)
        : null;
    final currentDate = DateTime.now();

    final isBeforeReleaseDate =
        releaseDate != null && currentDate.isBefore(releaseDate);

    if (isBeforeReleaseDate) {
      return Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add your review',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(
                height: 8,
              ),
              Text(
                'You cannot leave a review until the movie is released on ${DateFormat.yMMMMd().format(releaseDate)}.',
                style: const TextStyle(fontSize: 16),
              )
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add your review',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (int i = 1; i <= 5; i++)
                  IconButton(
                    icon: IconTheme(
                      data: IconThemeData(
                        color:
                            _selectedRating >= i ? Colors.amber : Colors.grey,
                      ),
                      child: const Icon(
                        Icons.star,
                        size: 32,
                      ),
                    ),
                    onPressed: () => setState(() => _selectedRating = i),
                  ),
              ],
            ),
            TextField(
              controller: _reviewController,
              maxLines: 4,
              maxLength: 160,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Write your review here...',
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _isSubmitButtonEnabled
                  ? () {
                      if (_reviewController.text.isNotEmpty) {
                        _submitReview();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Please enter a review')),
                        );
                      }
                    }
                  : null,
              child: const Text(
                'Submit your review',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProvidersSection() {
    final providers = _allProviders[_selectedCountry] ?? [];

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Available On',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                SizedBox(
                  width: 100,
                  child: DropdownButton<String>(
                    value: _selectedCountry,
                    isExpanded: true,
                    items: _countries
                        .map((country) => DropdownMenuItem(
                              value: country,
                              child: Text(country),
                            ))
                        .toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedCountry = newValue;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (providers.isNotEmpty)
              SizedBox(
                height: 110,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: providers.length,
                  itemBuilder: (context, index) {
                    final provider = providers[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundImage: provider['logo_path'] != null
                                ? NetworkImage(
                                    'https://image.tmdb.org/t/p/w92${provider['logo_path']}')
                                : null,
                            child: provider['logo_path'] == null
                                ? Text(provider['provider_name'][0])
                                : null,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            constraints: const BoxConstraints(
                              maxWidth: 80,
                            ),
                            child: Text(
                              provider['provider_name'],
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              )
            else
              const Text('No providers available for this country',
                  style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendedMoviesCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You may also like',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: _recommendedMovies.isNotEmpty
                  ? ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _recommendedMovies.length,
                      itemBuilder: (context, index) {
                        final movie = _recommendedMovies[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      FilmDetailsPage(movie: movie),
                                ),
                              );
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    '${Constants.imagePath}${movie.posterPath}',
                                    height: 150,
                                    width: 100,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        height: 150,
                                        width: 100,
                                        color: Colors.grey,
                                        child: const Icon(Icons.error),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 4),
                                SizedBox(
                                  width: 100,
                                  child: Text(
                                    movie.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                  : const Center(child: CircularProgressIndicator()),
            ),
          ],
        ),
      ),
    );
  }

  void _submitReview() async {
    final userService = Provider.of<UserService>(context, listen: false);
    final currentUser = await userService.getCurrentUser();
    if (currentUser == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('You need to be logged in to submit a review')),
        );
      }
      return;
    }

    final int movieId = widget.movie.id;
    final String title = widget.movie.title;
    final String name = currentUser.username;
    final String reviewText = _reviewController.text.trim();
    final int rating = _selectedRating;

    if (reviewText.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a review')),
        );
      }
      return;
    }
    if (_selectedRating == 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Please select a star rating before submitting your review')),
        );
        return;
      }
    }

    try {
      await userService.addMovieReview(
          currentUser.id, movieId, rating, reviewText, title, name);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review submitted successfully')),
        );
      }
      _reviewController.clear();
      setState(() => _selectedRating = 0);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit review: $e')),
        );
      }
    }
  }

  void _showWatchlistModal() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter modalsetState) {
            final bool isLiked =
                _likedMovies.contains(widget.movie.toTinyMovie().toString());
            final bool isSeen =
                _seenMovies.contains(widget.movie.toTinyMovie().toString());
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16.0),
                  child: const Text(
                    'My Lists',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                ListTile(
                  title: const Text('Liked movies'),
                  trailing: IconButton(
                    key: const Key('like_button'),
                    icon: Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      color: isLiked ? Colors.red : Colors.grey,
                    ),
                    onPressed: () async {
                      if (isLiked) {
                        await _removeFromLiked(_likedMovies, modalsetState);
                      } else {
                        await _addToLiked(_likedMovies, modalsetState);
                      }
                    },
                  ),
                ),
                ListTile(
                  title: const Text('Seen movies'),
                  trailing: IconButton(
                    icon: Icon(
                      isSeen ? Icons.check_box : Icons.check_box_outline_blank,
                      color: isSeen ? Colors.green : Colors.grey,
                    ),
                    onPressed: () async {
                      if (isSeen) {
                        await _removeFromSeen(_seenMovies, modalsetState);
                      } else {
                        await _addToSeen(_seenMovies, modalsetState);
                      }
                    },
                  ),
                ),
                const Divider(),
                Expanded(
                    child: ListView.builder(
                  itemCount: _userWatchlists.length,
                  itemBuilder: (context, index) {
                    final watchlist = _userWatchlists[index];
                    final bool isInWatchlist = watchlist.movies
                        .contains(widget.movie.toTinyMovie().toString());

                    return ListTile(
                        title: Text(watchlist.name),
                        trailing: IconButton(
                            icon: Icon(
                              isInWatchlist ? Icons.check : Icons.add,
                              color: isInWatchlist ? Colors.green : Colors.grey,
                            ),
                            onPressed: () async {
                              if (isInWatchlist) {
                                await _removeMovieFromWatchlist(
                                    watchlist, modalsetState);
                              } else {
                                await _addMovieInWatchlist(
                                    watchlist, modalsetState);
                              }
                            }));
                  },
                ))
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _addToLiked(
      List<String> likedMovies, StateSetter modalSetState) async {
    if (_currentUser == null) return;
    try {
      await Provider.of<UserService>(context, listen: false).addToLikedMovies(
          _currentUser!.id, widget.movie.toTinyMovie().toString());
      setState(() {});
      modalSetState(() {
        likedMovies.add(widget.movie.toTinyMovie().toString());
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add to liked: $e')),
        );
      }
    }
  }

  Future<void> _removeFromLiked(
      List<String> likedMovies, StateSetter modalSetState) async {
    if (_currentUser == null) return;
    try {
      await Provider.of<UserService>(context, listen: false)
          .removeFromLikedMovies(
              _currentUser!.id, widget.movie.toTinyMovie().toString());
      setState(() {});
      modalSetState(() {
        likedMovies.remove(widget.movie.toTinyMovie().toString());
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to remove from liked: $e')),
        );
      }
    }
  }

  Future<void> _addToSeen(
      List<String> seenMovies, StateSetter modalSetState) async {
    if (_currentUser == null) return;
    try {
      await Provider.of<UserService>(context, listen: false).addToSeenMovies(
          _currentUser!.id, widget.movie.toTinyMovie().toString());
      setState(() {});
      modalSetState(() {
        seenMovies.add(widget.movie.toTinyMovie().toString());
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add to seen: $e')),
        );
      }
    }
  }

  Future<void> _removeFromSeen(
      List<String> seenMovies, StateSetter modalSetState) async {
    if (_currentUser == null) return;
    try {
      await Provider.of<UserService>(context, listen: false)
          .removeFromSeenMovies(
              _currentUser!.id, widget.movie.toTinyMovie().toString());
      setState(() {});
      modalSetState(() {
        seenMovies.remove(widget.movie.toTinyMovie().toString());
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to remove from seen: $e')),
        );
      }
    }
  }

  Future<void> _addMovieInWatchlist(
      WatchList watchlist, StateSetter modalSetState) async {
    try {
      await Provider.of<WatchlistService>(context, listen: false)
          .addMovieToWatchlist(
              watchlist.userID, watchlist.id, widget.movie.toTinyMovie());
      setState(() {});
      modalSetState(() {
        watchlist.movies.add(widget.movie.toTinyMovie().toString());
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Movie added to watchlist')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add movie to watchlist: $e')),
        );
      }
    }
  }

  Future<void> _removeMovieFromWatchlist(
      WatchList watchlist, StateSetter modalSetState) async {
    try {
      await Provider.of<WatchlistService>(context, listen: false)
          .removeMovieFromWatchlist(
              watchlist.userID, watchlist.id, widget.movie.toTinyMovie());
      setState(() {});
      modalSetState(() {
        watchlist.movies.remove(widget.movie.toTinyMovie().toString());
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Movie removed from watchlist')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to remove movie from watchlist: $e')),
        );
      }
    }
  }
}
