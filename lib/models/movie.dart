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

  Movie({
    required this.id,
    required this.title,
    required this.overview,
    this.posterPath,
    this.backdropPath,
    required this.voteAverage,
    this.releaseDate,
    required this.genres,
    this.cast,
    this.trailer,
  });

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
    };
  }
}
