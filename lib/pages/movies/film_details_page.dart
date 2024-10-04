import 'package:dima_project/api/tmdb_api.dart';
import 'package:dima_project/models/movie_review.dart';
import 'package:dima_project/models/user_model.dart';
import 'package:dima_project/models/watchlist.dart';
import 'package:dima_project/services/user_service.dart';
import 'package:dima_project/services/watchlist_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dima_project/models/movie.dart';
import 'package:intl/intl.dart';
import 'package:dima_project/pages/movies/film_details_bloc.dart';
import 'package:dima_project/api/constants.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:url_launcher/url_launcher.dart';

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
  final UserService _userService = UserService();
  List<MovieReview> _friendsReviews = [];
  final WatchlistService _watchlistService = WatchlistService();
  List<WatchList> _userWatchlists = [];
  List<int> _likedMovies = [];
  List<int> _seenMovies = [];
  bool _isSubmitButtonEnabled = false;
  YoutubePlayerController? _youtubePlayerController;
  bool _showAllReviews = false;
  final List<String> _countries = ['US', 'IT', 'UK', 'FR', 'DE', 'CH', 'ES'];
  String _selectedCountry = 'US';
  Map<String, List<Map<String, dynamic>>> _allProviders = {};

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _initializeData().then((_) {
      _fetchAllProviders();
      _fetchFriendsReviews();
    });

    _reviewController.addListener(_updateSubmitButton);
  }

  void _updateSubmitButton() {
    setState(() {
      _isSubmitButtonEnabled = _reviewController.text.trim().isNotEmpty;
    });
  }

  Future<void> _initializeData() async {
    try {
      final currentUser = await _userService.getCurrentUser();
      if (currentUser != null) {
        _currentUser = currentUser;
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
    List<int> likedMovies =
        await _userService.getLikedMovieIds(_currentUser!.id);
    if (mounted) {
      setState(() {
        _likedMovies = likedMovies;
      });
    }
  }

  Future<void> _fetchSeenMovies() async {
    if (_currentUser == null) return;
    List<int> seenMovies = await _userService.getSeenMovieIds(_currentUser!.id);
    if (mounted) {
      setState(() {
        _seenMovies = seenMovies;
      });
    }
  }

  Future<void> _fetchFriendsReviews() async {
    if (_currentUser == null) return;
    List<MovieReview> reviews =
        await _userService.getFriendsReviews(_currentUser!.id, widget.movie.id);
    if (mounted) {
      setState(() {
        _friendsReviews = reviews;
      });
    }
  }

  Future<void> _fetchUserWatchlists() async {
    if (_currentUser == null) return;
    try {
      List<WatchList> watchlists =
          await _watchlistService.getOwnWatchLists(_currentUser!.id);
      setState(() {
        _userWatchlists = watchlists;
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
      final providers = await fetchAllProviders(widget.movie.id);
      setState(() {
        _allProviders = providers;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load providers: $e')),
      );
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
    return BlocProvider(
      create: (context) =>
          FilmDetailsBloc()..add(LoadFilmDetails(widget.movie.id)),
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
                Scaffold(
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

  Widget _buildBody(BuildContext context, FilmDetailsState state) {
    if (state is FilmDetailsLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is FilmDetailsLoaded) {
      return SafeArea(
          child: CustomScrollView(
        slivers: [
          _buildAppBar(state.movie),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitleAndButtons(state.movie),
                  const SizedBox(height: 8),
                  _buildReleaseDate(state.movie),
                  const SizedBox(height: 8),
                  _buildGenres(state.movie),
                  const SizedBox(height: 16),
                  _buildRating(state.movie),
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
    return SliverAppBar(
      expandedHeight: 200.0,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: movie.backdropPath != null
            ? Image.network(
                '${Constants.imagePath}${movie.backdropPath}',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(color: Colors.grey);
                },
              )
            : Container(color: Colors.grey),
      ),
    );
  }

  Widget _buildTitleAndButtons(Movie movie) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            movie.title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add),
          iconSize: 25,
          onPressed: () async {
            await _fetchUserWatchlists();
            await _fetchLikedMovies();
            await _fetchSeenMovies();
            _showWatchlistModal();
          },
        ),
      ],
    );
  }

  Widget _buildReleaseDate(Movie movie) {
    if (movie.releaseDate != null && movie.releaseDate!.isNotEmpty) {
      final releaseDate = DateTime.tryParse(movie.releaseDate!); // Parse safely
      if (releaseDate != null) {
        final formattedDate = DateFormat.yMMMMd().format(releaseDate);
        return Text(
          'Release Date: $formattedDate',
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        );
      }
    }
    // Return a fallback in case release date is null or can't be parsed
    return const Text(
      'Release Date: Unknown',
      style: TextStyle(fontSize: 16, color: Colors.grey),
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

  Widget _buildRating(Movie movie) {
    String rating = movie.voteAverage.toStringAsFixed(1);
    rating = rating.isNotEmpty ? '$rating/10' : 'N/A';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'TMDb Rating',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber),
                const SizedBox(width: 4),
                Text(
                  rating,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverview(Movie movie) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Overview',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No cast information available.'),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cast',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                        Text(
                          actor['name'],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          actor['character'],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
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
      ),
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Trailer',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            YoutubePlayerScaffold(
              controller: _youtubePlayerController!,
              aspectRatio: 16 / 9,
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
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No reviews from friends available.'),
        ),
      );
    }

    final reviewsToShow =
        _showAllReviews ? _friendsReviews : _friendsReviews.take(2).toList();

    return Card(
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add your review',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add your review',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
              child: const Text('Submit your review'),
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
                const Text(
                  'Available On',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                              maxLines: 2, // Allow up to 2 lines
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12),
                              textAlign: TextAlign.center, // Center text
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              )
            else
              const Text('No providers available for this country'),
          ],
        ),
      ),
    );
  }

  void _submitReview() async {
    // Retrieve the current logged-in user
    final currentUser = await _userService.getCurrentUser();
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

    // Submit the review using UserService
    try {
      await _userService.addMovieReview(
          currentUser.id, movieId, rating, reviewText, title, name);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review submitted successfully')),
        );
      }
      // Clear the review input after submission
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
            final bool isLiked = _likedMovies.contains(widget.movie.id);
            final bool isSeen = _seenMovies.contains(widget.movie.id);
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
                    final bool isInWatchlist =
                        watchlist.movies.contains(widget.movie.id);

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
      List<int> likedMovies, StateSetter modalSetState) async {
    if (_currentUser == null) return;
    try {
      await _userService.addToLikedMovies(_currentUser!.id, widget.movie.id);
      setState(() {});
      modalSetState(() {
        likedMovies.add(widget.movie.id);
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
      List<int> likedMovies, StateSetter modalSetState) async {
    if (_currentUser == null) return;
    try {
      await _userService.removeFromLikedMovies(
          _currentUser!.id, widget.movie.id);
      setState(() {});
      modalSetState(() {
        likedMovies.remove(widget.movie.id);
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
      List<int> seenMovies, StateSetter modalSetState) async {
    if (_currentUser == null) return;
    try {
      await _userService.addToSeenMovies(_currentUser!.id, widget.movie.id);
      setState(() {});
      modalSetState(() {
        seenMovies.add(widget.movie.id);
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
      List<int> seenMovies, StateSetter modalSetState) async {
    if (_currentUser == null) return;
    try {
      await _userService.removeFromSeenMovies(
          _currentUser!.id, widget.movie.id);
      setState(() {});
      modalSetState(() {
        seenMovies.remove(widget.movie.id);
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
      await _watchlistService.addMovieToWatchlist(
          watchlist.userID, watchlist.id, widget.movie.id);
      setState(() {});
      modalSetState(() {
        watchlist.movies.add(widget.movie.id);
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
      await _watchlistService.removeMovieFromWatchlist(
          watchlist.userID, watchlist.id, widget.movie.id);
      setState(() {});
      modalSetState(() {
        watchlist.movies.remove(widget.movie.id);
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
