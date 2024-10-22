class GenreSelectionManager {
  final Set<String> _selectedGenres = {};
  static const int minimumGenres = 3;

  List<String> get selectedGenres => _selectedGenres.toList();

  void toggleGenre(String genre) {
    if (_selectedGenres.contains(genre)) {
      _selectedGenres.remove(genre);
    } else {
      _selectedGenres.add(genre);
    }
  }

  bool hasMinimumGenres() {
    return _selectedGenres.length >= minimumGenres;
  }

  void clearSelection() {
    _selectedGenres.clear();
  }

  bool isGenreSelected(String genre) {
    return _selectedGenres.contains(genre);
  }
}
