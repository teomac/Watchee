//movie class to parse from json
class Movie {
  final int id;
  final String title;
  final String overview;
  final String posterPath;
  final String backdropPath;
  final double voteAverage;
  final String releaseDate;
  final List<int>? genres; // Lista di generi (opzionale)

  List<Map<String, dynamic>>? cast;
  String? trailer;

  Movie(
      {required this.id,
      required this.title,
      required this.overview,
      required this.posterPath,
      required this.backdropPath,
      required this.voteAverage,
      required this.releaseDate,
      required this.genres,
      this.cast,
      this.trailer});

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'],
      title: json['title'],
      overview: json['overview'],
      posterPath: json['poster_path'],
      backdropPath: json['backdrop_path'],
      voteAverage: json['vote_average'].toDouble(),
      releaseDate: json['release_date'].toString(),
      genres:
          json['genre_ids'] != null ? List<int>.from(json['genre_ids']) : null,
    );
  }
}
