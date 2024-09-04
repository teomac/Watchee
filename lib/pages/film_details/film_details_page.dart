import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dima_project/models/movie.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:intl/intl.dart';
import 'package:dima_project/models/genres.dart';
import 'package:dima_project/pages/film_details/film_details_bloc.dart';

class FilmDetailsPage extends StatefulWidget {
  final Movie movie;

  const FilmDetailsPage({required this.movie, super.key});

  @override
  State<FilmDetailsPage> createState() => _FilmDetailsPageState();
}

class _FilmDetailsPageState extends State<FilmDetailsPage> {
  bool _isDisposing = false;
  final bool _showYoutubePlayer = true;

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
                if (mounted) {
                  Navigator.of(context).pop();
                }
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
      return CustomScrollView(
        slivers: [
          _buildAppBar(state.movie),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitle(state.movie),
                  const SizedBox(height: 8),
                  _buildReleaseDate(state.movie),
                  const SizedBox(height: 8),
                  _buildGenres(state.movie),
                  const SizedBox(height: 16),
                  _buildRating(state.movie),
                  const SizedBox(height: 16),
                  _buildOverview(state.movie),
                  const SizedBox(height: 24),
                  _buildCast(state.cast),
                  const SizedBox(height: 24),
                  if (_showYoutubePlayer)
                    _buildTrailer(context, state.trailerKey),
                  const SizedBox(height: 24),
                  _buildFriendReviews(),
                ],
              ),
            ),
          ),
        ],
      );
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
        background: Image.network(
          'https://image.tmdb.org/t/p/w500${movie.backdropPath}',
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildTitle(Movie movie) {
    return Text(
      movie.title,
      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildReleaseDate(Movie movie) {
    final releaseDate = DateTime.parse(movie.releaseDate);
    final formattedDate = DateFormat.yMMMMd().format(releaseDate);
    return Text(
      'Release Date: $formattedDate',
      style: const TextStyle(fontSize: 16, color: Colors.grey),
    );
  }

  Widget _buildGenres(Movie movie) {
    final MovieGenres movieGenres = MovieGenres();
    final genres = movie.genres
            ?.map((genreId) => movieGenres.getGenre(genreId))
            .toList() ??
        [];

    return Wrap(
      spacing: 8,
      children: genres.map((genre) => Chip(label: Text(genre))).toList(),
    );
  }

  Widget _buildRating(Movie movie) {
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
                  '${movie.voteAverage.toStringAsFixed(1)}/10',
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
              movie.overview,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCast(List<Map<String, dynamic>>? cast) {
    if (cast == null || cast.isEmpty) {
      return const SizedBox.shrink();
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
    // TODO: Implement actual friend reviews fetching
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Friend Reviews',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            ListTile(
              leading: CircleAvatar(child: Text('JD')),
              title: Text('John Doe'),
              subtitle: Text('Great movie! Loved the plot twists.'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star, color: Colors.amber),
                  Text('4.5'),
                ],
              ),
            ),
            ListTile(
              leading: CircleAvatar(child: Text('JS')),
              title: Text('Jane Smith'),
              subtitle:
                  Text('Visually stunning, but the pacing was a bit slow.'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star, color: Colors.amber),
                  Text('3.5'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
