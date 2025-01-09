import 'package:flutter/material.dart';
import 'package:dima_project/models/movie.dart';
import 'package:dima_project/services/tmdb_api_service.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

class MovieSearchBarWidget extends StatefulWidget {
  final ThemeData theme;
  final bool isDarkMode;
  final Function(bool) onExpandChanged;
  final Function(List<Movie>) onSearchResults;

  const MovieSearchBarWidget({
    super.key,
    required this.theme,
    required this.isDarkMode,
    required this.onExpandChanged,
    required this.onSearchResults,
  });

  @override
  State<MovieSearchBarWidget> createState() => _MovieSearchBarWidgetState();
}

class _MovieSearchBarWidgetState extends State<MovieSearchBarWidget>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _animation;
  final Logger logger = Logger();
  late TmdbApiService _tmdbApiService;

  @override
  void initState() {
    super.initState();
    _tmdbApiService = Provider.of<TmdbApiService>(context, listen: false);
    _searchController.addListener(_onSearchChanged);
    _focusNode.addListener(_onFocusChanged);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _focusNode.removeListener(_onFocusChanged);
    _searchController.dispose();
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_searchController.text.isNotEmpty && !_isExpanded) {
      _expandSearchBar();
    } else if (_searchController.text.isEmpty && _isExpanded) {
      _collapseSearchBar();
    }
    _performSearch(_searchController.text);
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus && !_isExpanded) {
      _expandSearchBar();
    } else if (!_focusNode.hasFocus && _searchController.text.isEmpty) {
      _collapseSearchBar();
    }
  }

  void _expandSearchBar() {
    setState(() {
      _isExpanded = true;
    });
    _animationController.forward();
    widget.onExpandChanged(true);
  }

  void _collapseSearchBar() {
    setState(() {
      _isExpanded = false;
    });
    _animationController.reverse();
    widget.onExpandChanged(false);
  }

  Future<void> _performSearch(String query) async {
    if (query.isNotEmpty) {
      try {
        final results = await _tmdbApiService.searchMovie(query);
        widget.onSearchResults(results);
      } catch (e) {
        logger.d('Error searching movies: $e');
      }
    } else {
      widget.onSearchResults([]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return SizedBox(
          width: MediaQuery.of(context).size.width *
              (0.7 + 0.3 * _animation.value),
          child: TextField(
            controller: _searchController,
            focusNode: _focusNode,
            decoration: InputDecoration(
              hintText: 'Search movies...',
              prefixIcon:
                  Icon(Icons.search, color: widget.theme.iconTheme.color),
              suffixIcon: _isExpanded
                  ? IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _searchController.clear();
                        _collapseSearchBar();
                        _focusNode.unfocus();
                        widget.onSearchResults([]);
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide(color: colorScheme.outline),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide(color: colorScheme.outline),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide(color: colorScheme.primary, width: 2),
              ),
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest,
            ),
          ),
        );
      },
    );
  }
}
