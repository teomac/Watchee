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

    test('fromJson handles movie_credits format correctly', () {
      final json = {
        'adult': false,
        'also_known_as': [],
        'id': 123,
        'known_for_department': 'Acting',
        'name': 'John Smith',
        'popularity': 7.8,
        'movie_credits': {},
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
      expect(person.knownFor, isA<List<Movie>>());
      expect(person.knownFor.length, 1);
    });

    test('fromJson handles null and empty values correctly', () {
      final json = {
        'id': 123,
        'name': null,
        'known_for_department': null,
        'known_for': null,
      };

      final person = Person.fromJson(json);
      expect(person.adult, false);
      expect(person.alsoKnownAs, isEmpty);
      expect(person.biography, null);
      expect(person.birthday, null);
      expect(person.deathday, null);
      expect(person.gender, 0);
      expect(person.homepage, null);
      expect(person.id, 123);
      expect(person.knownForDepartment, '');
      expect(person.name, '');
      expect(person.placeOfBirth, null);
      expect(person.popularity, 0.0);
      expect(person.profilePath, null);
      expect(person.knownFor, isEmpty);
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

    test('copyWith creates new instance with updated values', () {
      final original = Person(
        adult: false,
        alsoKnownAs: ['John'],
        biography: 'Original bio',
        birthday: '1990-01-01',
        deathday: null,
        gender: 2,
        homepage: 'https://example.com',
        id: 123,
        knownForDepartment: 'Acting',
        name: 'John Smith',
        placeOfBirth: 'New York',
        popularity: 7.8,
        profilePath: '/path.jpg',
        knownFor: [],
      );

      final updated = original.copyWith(
        adult: true,
        alsoKnownAs: ['Johnny'],
        biography: 'Updated bio',
        birthday: '1990-01-02',
        gender: 1,
        homepage: 'https://new.com',
        id: 456,
        knownForDepartment: 'Directing',
        name: 'Johnny Smith',
        placeOfBirth: 'LA',
        popularity: 8.9,
        profilePath: '/new.jpg',
        knownFor: [
          Movie(
            id: 1,
            title: 'New Movie',
            overview: 'Overview',
            posterPath: '/poster.jpg',
            voteAverage: 7.5,
            genres: ['Action'],
          )
        ],
      );

      expect(updated.adult, true);
      expect(updated.alsoKnownAs, ['Johnny']);
      expect(updated.biography, 'Updated bio');
      expect(updated.birthday, '1990-01-02');
      expect(updated.gender, 1);
      expect(updated.homepage, 'https://new.com');
      expect(updated.id, 456);
      expect(updated.knownForDepartment, 'Directing');
      expect(updated.name, 'Johnny Smith');
      expect(updated.placeOfBirth, 'LA');
      expect(updated.popularity, 8.9);
      expect(updated.profilePath, '/new.jpg');
      expect(updated.knownFor.length, 1);
      expect(updated.knownFor[0].title, 'New Movie');

      // Test that original remains unchanged
      expect(original.adult, false);
      expect(original.name, 'John Smith');
    });

    group('equality and hashCode', () {
      test('identical objects are equal and have same hashCode', () {
        final person1 = Person(
          adult: false,
          alsoKnownAs: ['John Doe'],
          id: 123,
          knownForDepartment: 'Acting',
          name: 'John Smith',
          popularity: 7.8,
          knownFor: [],
          gender: 0,
        );

        final person2 = Person(
          adult: false,
          alsoKnownAs: ['John Doe'],
          id: 123,
          knownForDepartment: 'Acting',
          name: 'John Smith',
          popularity: 7.8,
          knownFor: [],
          gender: 0,
        );

        expect(person1, equals(person2));
        expect(person1.hashCode, equals(person2.hashCode));
      });

      test('different objects are not equal and have different hashCodes', () {
        final person1 = Person(
          adult: false,
          alsoKnownAs: ['John Doe'],
          id: 123,
          knownForDepartment: 'Acting',
          name: 'John Smith',
          popularity: 7.8,
          knownFor: [],
          gender: 0,
        );

        final person2 = Person(
          adult: true,
          alsoKnownAs: ['John Doe'],
          id: 123,
          knownForDepartment: 'Acting',
          name: 'John Smith',
          popularity: 7.8,
          knownFor: [],
          gender: 0,
        );

        expect(person1, isNot(equals(person2)));
        expect(person1.hashCode, isNot(equals(person2.hashCode)));
      });

      test('identical references are equal', () {
        final person = Person(
          adult: false,
          alsoKnownAs: ['John Doe'],
          id: 123,
          knownForDepartment: 'Acting',
          name: 'John Smith',
          popularity: 7.8,
          knownFor: [],
          gender: 0,
        );

        expect(identical(person, person), isTrue);
        expect(person, equals(person));
      });
    });
  });
}
