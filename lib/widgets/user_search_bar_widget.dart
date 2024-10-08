import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dima_project/pages/follow/follow_page.dart';

class SearchBarWidget extends StatefulWidget {
  final ThemeData theme;
  final bool isDarkMode;
  final Function(bool) onExpandChanged;
  final Function(String) onSearchChanged;

  const SearchBarWidget({
    super.key,
    required this.theme,
    required this.isDarkMode,
    required this.onExpandChanged,
    required this.onSearchChanged,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
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
    widget.onSearchChanged(_searchController.text);
    if (_searchController.text.isNotEmpty && !_isExpanded) {
      _expandSearchBar();
    } else if (_searchController.text.isEmpty && _isExpanded) {
      _collapseSearchBar();
    }
    context.read<FollowBloc>().add(SearchUsers(_searchController.text));
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

  @override
  Widget build(BuildContext context) {
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
              hintText: 'Search users...',
              prefixIcon:
                  Icon(Icons.search, color: widget.theme.iconTheme.color),
              suffixIcon: _isExpanded
                  ? IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _searchController.clear();
                        _collapseSearchBar();
                        _focusNode.unfocus();
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor:
                  widget.isDarkMode ? Colors.grey[900] : Colors.grey[200],
            ),
          ),
        );
      },
    );
  }
}
