import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dima_project/api/tmdb_api.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:dima_project/models/movie.dart';

class FilmDetailsBloc extends Bloc<FilmDetailsEvent, FilmDetailsState> {
  YoutubePlayerController? _youtubeController;

  FilmDetailsBloc() : super(FilmDetailsInitial()) {
    on<LoadFilmDetails>(_onLoadFilmDetails);
    on<DisposeYoutubePlayer>(_onDisposeYoutubePlayer);
  }

  Future<void> _onLoadFilmDetails(
    LoadFilmDetails event,
    Emitter<FilmDetailsState> emit,
  ) async {
    emit(FilmDetailsLoading());
    try {
      final movie = await retrieveFilmInfo(event.movieId);
      final trailerKey = await retrieveTrailer(event.movieId);
      final cast = await retrieveCast(event.movieId);

      if (trailerKey.isNotEmpty) {
        _youtubeController = YoutubePlayerController(
          initialVideoId: trailerKey,
          flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
        );
      }

      emit(FilmDetailsLoaded(movie, trailerKey: trailerKey, cast: cast));
    } catch (e) {
      emit(FilmDetailsError(e.toString()));
    }
  }

  void _onDisposeYoutubePlayer(
    DisposeYoutubePlayer event,
    Emitter<FilmDetailsState> emit,
  ) {
    _youtubeController?.dispose();
    _youtubeController = null;
  }

  @override
  Future<void> close() {
    _youtubeController?.dispose();
    return super.close();
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
