import 'package:flutter_test/flutter_test.dart';
import 'package:dima_project/models/person.dart';
import 'package:dima_project/models/movie.dart';

void main() {
  group('Person', () {
    test('fromJson creates Person object correctly', () {
      final json = {
        'adult': false,
        'also_known_as': ['John Doe', 'JD'],
        'biography': 'A talented actor',
        'birthday': '1990-01-01',
        'deathday': null,
        'gender': 2,
        'homepage': 'https://example.com',
        'id': 123,
        'known_for_department': 'Acting',
        'name': 'John Smith',
        'place_of_birth': 'New York, USA',
        'popularity': 7.8,
        'profile_path': '/path/to/profile.jpg',
        'known_for': [
          {
            'id': 456,
            'title': 'Famous Movie',
            'overview': 'A great movie',
            'poster_path': '/path/to/poster.jpg',
            'vote_average': 8.5
          }
        ]
      };

      final person = Person.fromJson(json);

      expect(person.adult, false);
      expect(person.alsoKnownAs, ['John Doe', 'JD']);
      expect(person.biography, 'A talented actor');
      expect(person.birthday, '1990-01-01');
      expect(person.deathday, null);
      expect(person.gender, 2);
      expect(person.homepage, 'https://example.com');
      expect(person.id, 123);
      expect(person.knownForDepartment, 'Acting');
      expect(person.name, 'John Smith');
      expect(person.placeOfBirth, 'New York, USA');
      expect(person.popularity, 7.8);
      expect(person.profilePath, '/path/to/profile.jpg');
      expect(person.knownFor, isA<List<Movie>>());
      expect(person.knownFor.length, 1);
      expect(person.knownFor[0].title, 'Famous Movie');
    });

    test('toJson converts Person object to JSON correctly', () {
      final person = Person(
          adult: false,
          alsoKnownAs: ['John Doe', 'JD'],
          biography: 'A talented actor',
          birthday: '1990-01-01',
          deathday: null,
          gender: 2,
          homepage: 'https://example.com',
          id: 123,
          knownForDepartment: 'Acting',
          name: 'John Smith',
          placeOfBirth: 'New York, USA',
          popularity: 7.8,
          profilePath: '/path/to/profile.jpg',
          knownFor: [
            Movie(
                id: 456,
                title: 'Famous Movie',
                overview: 'A great movie',
                posterPath: '/path/to/poster.jpg',
                voteAverage: 8.5,
                genres: ['Action', 'Drama'])
          ]);

      final json = person.toJson();

      expect(json['adult'], false);
      expect(json['also_known_as'], ['John Doe', 'JD']);
      expect(json['biography'], 'A talented actor');
      expect(json['birthday'], '1990-01-01');
      expect(json['deathday'], null);
      expect(json['gender'], 2);
      expect(json['homepage'], 'https://example.com');
      expect(json['id'], 123);
      expect(json['known_for_department'], 'Acting');
      expect(json['name'], 'John Smith');
      expect(json['place_of_birth'], 'New York, USA');
      expect(json['popularity'], 7.8);
      expect(json['profile_path'], '/path/to/profile.jpg');
      expect(json['known_for'], isA<List>());
      expect(json['known_for'].length, 1);
      expect(json['known_for'][0]['title'], 'Famous Movie');
    });

    test('equality check works correctly', () {
      final person1 = Person(
          adult: false,
          alsoKnownAs: ['John Doe'],
          id: 123,
          knownForDepartment: 'Acting',
          name: 'John Smith',
          popularity: 7.8,
          knownFor: [],
          gender: 0);

      final person2 = Person(
          adult: false,
          alsoKnownAs: ['John Doe'],
          id: 123,
          knownForDepartment: 'Acting',
          name: 'John Smith',
          popularity: 7.8,
          knownFor: [],
          gender: 0);

      final person3 = Person(
          adult: false,
          alsoKnownAs: ['Jane Doe'],
          id: 456,
          knownForDepartment: 'Acting',
          name: 'Jane Smith',
          popularity: 8.2,
          knownFor: [],
          gender: 0);

      expect(person1, equals(person2));
      expect(person1, isNot(equals(person3)));
    });
  });
}
