import 'package:collection/collection.dart';
import 'package:dima_project/models/tiny_movie.dart';

class Movie {
  final int id;
  final String title;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final double voteAverage;
  final String? releaseDate;
  final List<String>? genres;
  List<Map<String, dynamic>>? cast;
  String? trailer;
  final int? runtime;
  final String? tagline;

  Movie(
      {required this.id,
      required this.title,
      required this.overview,
      this.posterPath,
      this.backdropPath,
      required this.voteAverage,
      this.releaseDate,
      required this.genres,
      this.cast,
      this.trailer,
      this.runtime,
      this.tagline});

  factory Movie.fromJson(Map<String, dynamic> json) {
    List<String> genreNames = [];
    if (json['genres'] != null) {
      genreNames = (json['genres'] as List)
          .map((genre) => genre['name'] as String)
          .toList();
    }

    return Movie(
      id: json['id'],
      title: json['title'],
      overview: json['overview'],
      posterPath: json['poster_path'],
      backdropPath: json['backdrop_path'],
      voteAverage: (json['vote_average'] != null)
          ? json['vote_average'].toDouble()
          : 0.0,
      releaseDate: json['release_date']?.toString() ?? 'null',
      genres: genreNames.isNotEmpty ? genreNames : [],
      cast: json['cast'] != null
          ? List<Map<String, dynamic>>.from(json['cast'])
          : null,
      trailer: json['trailer'],
      runtime: json['runtime'],
      tagline: json['tagline'],
    );
  }

  Tinymovie toTinyMovie() {
    return Tinymovie(
      id: id,
      title: title,
      posterPath: posterPath,
      releaseDate: releaseDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'overview': overview,
      'poster_path': posterPath,
      'backdrop_path': backdropPath,
      'vote_average': voteAverage,
      'release_date': releaseDate,
      'genres': genres ?? [],
      'cast': cast,
      'trailer': trailer,
      'runtime': runtime,
      'tagline': tagline,
    };
  }

  @override
  //override equals operator
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Movie && other.id == id;
  }

  @override
  int get hashCode {
    const listEquality = ListEquality();

    return id.hashCode ^
        title.hashCode ^
        overview.hashCode ^
        (posterPath?.hashCode ?? 0) ^
        (backdropPath?.hashCode ?? 0) ^
        voteAverage.hashCode ^
        (releaseDate?.hashCode ?? 0) ^
        listEquality.hash(genres ?? []) ^
        listEquality.hash(cast ?? []) ^
        (trailer?.hashCode ?? 0) ^
        (runtime?.hashCode ?? 0) ^
        (tagline?.hashCode ?? 0);
  }
}
