class Tinymovie {
  final int id;
  final String title;
  final String? posterPath;
  final String? releaseDate;

  Tinymovie(
      {required this.id,
      required this.title,
      this.posterPath,
      this.releaseDate});

  factory Tinymovie.fromJson(Map<String, dynamic> json) {
    return Tinymovie(
      id: json['id'],
      title: json['title'],
      posterPath: json['poster_path'],
      releaseDate: json['release_date']?.toString() ?? 'null',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'poster_path': posterPath,
      'release_date': releaseDate,
    };
  }

  @override
  String toString() {
    return '$id,,,$title,,,$posterPath,,,$releaseDate';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Tinymovie && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode =>
      id.hashCode ^ title.hashCode ^ posterPath.hashCode ^ releaseDate.hashCode;
}
