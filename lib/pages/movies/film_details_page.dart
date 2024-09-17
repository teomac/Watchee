import 'package:dima_project/models/movie_review.dart';
import 'package:dima_project/models/user_model.dart';
import 'package:dima_project/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dima_project/models/movie.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:intl/intl.dart';
import 'package:dima_project/pages/movies/film_details_bloc.dart';
import 'package:dima_project/api/constants.dart';

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
  bool _isLiked = false;

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _initializeData().then((_) {
      _fetchFriendsReviews();
    });
  }

  Future<void> _initializeData() async {
    try {
      final currentUser = await _userService.getCurrentUser();
      if (currentUser != null) {
        _currentUser = currentUser;
        _isLiked = await _userService.checkLikedMovies(
            _currentUser!.id, widget.movie.id);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error initializing data: $e')),
        );
      }
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

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          FilmDetailsBloc()..add(LoadFilmDetails(widget.movie.id)),
      child: BlocBuilder<FilmDetailsBloc, FilmDetailsState>(
        builder: (context, state) {
          return PopScope(
            canPop: false,
            onPopInvoked: (didPop) async {
              if (didPop) return;
              if (!_isDisposing) {
                setState(() => _isDisposing = true);
                context.read<FilmDetailsBloc>().add(DisposeYoutubePlayer());
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
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitleAndLikeButton(state.movie),
                  const SizedBox(height: 8),
                  _buildReleaseDate(state.movie),
                  const SizedBox(height: 8),
                  _buildGenres(state.movie),
                  const SizedBox(height: 16),
                  _buildRating(state.movie),
                  const SizedBox(height: 16),
                  _buildOverview(state.movie),
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

  Widget _buildTitleAndLikeButton(Movie movie) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            movie.title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.favorite,
            color: _isLiked ? Colors.red : Colors.grey,
          ),
          iconSize: 30,
          onPressed: _toggle,
          padding: EdgeInsets.zero,
          highlightColor: Colors.grey,
          color: _isLiked ? Colors.red : Colors.grey,
        )
      ],
    );
  }

  void _toggle() {
    setState(() {
      _isLiked = !_isLiked;
    });
    if (_isLiked) {
      try {
        _userService.addToLikedMovies(_currentUser!.id, widget.movie.id);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add movie to liked movies: $e')),
        );
      }
    } else {
      try {
        _userService.removeFromLikedMovies(_currentUser!.id, widget.movie.id);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to remove movie from liked movies: $e')),
        );
      }
    }
  }

  Widget _buildReleaseDate(Movie movie) {
    if (movie.releaseDate != null && movie.releaseDate!.isNotEmpty) {
      final releaseDate = DateTime.tryParse(movie.releaseDate!); // Parse safely
      if (releaseDate != null) {
        final formattedDate = DateFormat.yMMMMd().format(releaseDate);
        return Text(
          'Release Date: $formattedDate',
          style: const TextStyle(fontSize: 16, color: Colors.grey),
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
            YoutubePlayer(
              controller: YoutubePlayerController(
                initialVideoId: trailerKey,
                flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
              ),
              showVideoProgressIndicator: true,
            ),
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

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Friend Reviews',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ..._friendsReviews.map((review) {
              return ListTile(
                leading: CircleAvatar(
                  child: Text(review.username.isNotEmpty
                      ? review.username[0]
                      : '?'), // Placeholder for user initial
                ),
                title: Text(review.username), // Placeholder for user name
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
          ],
        ),
      ),
    );
  }

  Widget _buildAddYourReview() {
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
              onPressed: () {
                if (_reviewController.text.isNotEmpty) {
                  _submitReview();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a review')),
                  );
                }
              },
              child: const Text('Submit your review'),
            ),
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
}
