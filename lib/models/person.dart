import 'package:dima_project/models/movie.dart';
import 'package:flutter/foundation.dart';

class Person {
  final bool adult;
  final List<String> alsoKnownAs;
  final String? biography;
  final String? birthday;
  final String? deathday;
  final int gender;
  final String? homepage;
  final int id;
  final String knownForDepartment;
  final String name;
  final String? placeOfBirth;
  final double popularity;
  final String? profilePath;
  final List<Movie> knownFor;

  Person({
    required this.adult,
    required this.alsoKnownAs,
    this.biography,
    this.birthday,
    this.deathday,
    required this.gender,
    this.homepage,
    required this.id,
    required this.knownForDepartment,
    required this.name,
    this.placeOfBirth,
    required this.popularity,
    this.profilePath,
    required this.knownFor,
  });

  Person copyWith({
    bool? adult,
    List<String>? alsoKnownAs,
    String? biography,
    String? birthday,
    String? deathday,
    int? gender,
    String? homepage,
    int? id,
    String? knownForDepartment,
    String? name,
    String? placeOfBirth,
    double? popularity,
    String? profilePath,
    List<Movie>? knownFor,
  }) {
    return Person(
      adult: adult ?? this.adult,
      alsoKnownAs: alsoKnownAs ?? this.alsoKnownAs,
      biography: biography,
      birthday: birthday ?? this.birthday,
      deathday: deathday ?? this.deathday,
      gender: gender ?? this.gender,
      homepage: homepage ?? this.homepage,
      id: id ?? this.id,
      knownForDepartment: knownForDepartment ?? this.knownForDepartment,
      name: name ?? this.name,
      placeOfBirth: placeOfBirth ?? this.placeOfBirth,
      popularity: popularity ?? this.popularity,
      profilePath: profilePath ?? this.profilePath,
      knownFor: knownFor ?? this.knownFor,
    );
  }

  factory Person.fromJson(Map<String, dynamic> json) {
    List<Movie> parseKnownFor(List<dynamic> knownForJson) {
      return knownForJson.map((item) => Movie.fromJson(item)).toList();
    }

    List<Movie> knownForMovies;
    if (json.containsKey('movie_credits')) {
      var castMovies = json['known_for'] as List<dynamic>;
      knownForMovies = parseKnownFor(castMovies);
    } else {
      knownForMovies = parseKnownFor(json['known_for'] as List<dynamic>? ?? []);
    }

    return Person(
      adult: json['adult'] ?? false,
      alsoKnownAs: List<String>.from(json['also_known_as'] ?? []),
      biography: json['biography'],
      birthday: json['birthday'],
      deathday: json['deathday'],
      gender: json['gender'] ?? 0,
      homepage: json['homepage'],
      id: json['id'],
      knownForDepartment: json['known_for_department'] ?? '',
      name: json['name'] ?? '',
      placeOfBirth: json['place_of_birth'],
      popularity: (json['popularity'] ?? 0).toDouble(),
      profilePath: json['profile_path'],
      knownFor: knownForMovies,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'adult': adult,
      'also_known_as': alsoKnownAs,
      'biography': biography,
      'birthday': birthday,
      'deathday': deathday,
      'gender': gender,
      'homepage': homepage,
      'id': id,
      'known_for_department': knownForDepartment,
      'name': name,
      'place_of_birth': placeOfBirth,
      'popularity': popularity,
      'profile_path': profilePath,
      'known_for': knownFor.map((movie) => movie.toJson()).toList(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Person &&
        other.adult == adult &&
        listEquals(other.alsoKnownAs, alsoKnownAs) &&
        other.biography == biography &&
        other.birthday == birthday &&
        other.deathday == deathday &&
        other.gender == gender &&
        other.homepage == homepage &&
        other.id == id &&
        other.knownForDepartment == knownForDepartment &&
        other.name == name &&
        other.placeOfBirth == placeOfBirth &&
        other.popularity == popularity &&
        other.profilePath == profilePath &&
        listEquals(other.knownFor, knownFor);
  }

  @override
  int get hashCode {
    int alsoKnownAsHash = Object.hashAll(alsoKnownAs);
    int knownForHash = Object.hashAll(knownFor);

    return Object.hash(
      adult,
      alsoKnownAsHash,
      biography,
      birthday,
      deathday,
      gender,
      homepage,
      id,
      knownForDepartment,
      name,
      placeOfBirth,
      popularity,
      profilePath,
      knownForHash,
    );
  }
}
