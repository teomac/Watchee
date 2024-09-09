import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dima_project/pages/dispatcher.dart';

class GenreSelectionPage extends StatefulWidget {
  const GenreSelectionPage({super.key});
  @override
  State<GenreSelectionPage> createState() => _GenreSelectionPageState();
}

class _GenreSelectionPageState extends State<GenreSelectionPage> {
  final List<String> genres = [
    'Action',
    'Adventure',
    'Animation',
    ' Comedy',
    'Crime',
    'Documentary',
    'Drama',
    ' Family',
    'Fantasy',
    'History',
    'Horror',
    'Music',
    'Mystery',
    'Romance',
    'Science Fiction',
    'Thriller',
    'TV Movie',
    'War',
    'Western'
  ];
  List<String> selectedGenres = [];

  void _toggleGenre(String genre) {
    setState(() {
      if (selectedGenres.contains(genre)) {
        selectedGenres.remove(genre);
      } else {
        selectedGenres.add(genre);
      }
    });
  }

  void _saveGenresAndNavigate() async {
    if (selectedGenres.length >= 3) {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'favoriteGenres': selectedGenres,
      });
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const Dispatcher()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Your Favorite Genres'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Choose at least 3 genres you like',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: genres.map((genre) {
                      final isSelected = selectedGenres.contains(genre);
                      return FilterChip(
                        label: Text(genre),
                        selected: isSelected,
                        onSelected: (_) => _toggleGenre(genre),
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        selectedColor:
                            Theme.of(context).colorScheme.primaryContainer,
                        checkmarkColor:
                            Theme.of(context).colorScheme.onPrimaryContainer,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Theme.of(context).colorScheme.onPrimaryContainer
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed:
                    selectedGenres.length >= 3 ? _saveGenresAndNavigate : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
