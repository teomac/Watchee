//movie class to parse from json
class Movie {
  final int id;
  final String title;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final double voteAverage;
  final String? releaseDate;
  final List<String>? genres; // Lista di generi (opzionale)

  List<Map<String, dynamic>>? cast;
  String? trailer;

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
      this.trailer});

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
      voteAverage: json['vote_average'].toDouble(),
      releaseDate: json['release_date'].toString(),
      genres: genreNames,
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
      'genres': genres,
      'cast': cast,
      'trailer': trailer,
    };
  }

  @override
  //override equals operator
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Movie && other.id == id;
  }

  @override
  //override hashcode
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        overview.hashCode ^
        posterPath.hashCode ^
        backdropPath.hashCode ^
        voteAverage.hashCode ^
        releaseDate.hashCode ^
        genres.hashCode ^
        cast.hashCode ^
        trailer.hashCode;
  }
}
