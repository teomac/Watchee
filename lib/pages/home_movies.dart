import 'package:dima_project/models/movie.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dima_project/api/tmdb_api.dart';
import 'package:dima_project/widgets/movies_slider.dart';
import 'package:dima_project/widgets/trending_slider.dart';
import 'package:dima_project/models/home_movies_data.dart';
import 'package:dima_project/widgets/profile_widget.dart';
import 'package:dima_project/models/user_model.dart';
import 'package:dima_project/services/user_service.dart';
import 'package:dima_project/theme/theme_provider.dart';

class HomeMovies extends StatefulWidget {
  @override
  State<HomeMovies> createState() => HomeMoviesState();
}

class HomeMoviesState extends State<HomeMovies> {
  HomeMoviesData _data = HomeMoviesData();
  MyUser? _currentUser;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      final trending = await fetchTrendingMovies();
      final topRated = await fetchTopRatedMovies();
      final upcoming = await fetchUpcomingMovies();
      final user = await UserService().getCurrentUser();

      if (mounted) {
        setState(() {
          _data = _data.copyWith(
            trendingMovies: trending,
            topRatedMovies: topRated,
            upcomingMovies: upcoming,
          );
          _currentUser = user;
        });
      }
    } catch (e) {
      print('Error initializing data: $e');
      // Handle error (e.g., show a snackbar or dialog)
    }
  }

  void _showProfileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.4,
          minChildSize: 0.2,
          maxChildSize: 0.75,
          expand: false,
          builder: (_, controller) {
            return SingleChildScrollView(
              controller: controller,
              child: ProfileMenu(
                user: _currentUser ??
                    MyUser(
                        id: '',
                        name: '',
                        username: '',
                        email: '',
                        birthdate: DateTime(1900, 01,
                            01)), // Provide a default value if _currentUser is null
                onManageAccountTap: () {
                  Navigator.pop(context);
                  // Add your navigation logic for Manage Account
                },
                onAppSettingsTap: () {
                  Navigator.pop(context);
                  // Add your navigation logic for App Settings
                },
                onAboutTap: () {
                  Navigator.pop(context);
                  // Add your navigation logic for About
                },
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(theme, isDarkMode),
                const SizedBox(height: 10),
                _buildMovieSection('Trending movies', _data.trendingMovies,
                    (movies) => TrendingSlider(trendingMovies: movies), theme),
                _buildMovieSection('Top rated movies', _data.topRatedMovies,
                    (movies) => MoviesSlider(movies: movies), theme),
                _buildMovieSection('Upcoming Movies', _data.upcomingMovies,
                    (movies) => MoviesSlider(movies: movies), theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, bool isDarkMode) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: SearchAnchor(
            builder: (BuildContext context, SearchController controller) {
              return SearchBar(
                controller: controller,
                onTap: () => controller.openView(),
                onChanged: (_) => controller.openView(),
                leading: Icon(Icons.search, color: theme.iconTheme.color),
                backgroundColor: WidgetStateProperty.all(
                    theme.brightness == Brightness.dark
                        ? Colors.grey[800]
                        : Colors.grey[200]),
                elevation: WidgetStateProperty.all(0),
              );
            },
            suggestionsBuilder:
                (BuildContext context, SearchController controller) {
              return List<ListTile>.generate(1, (int index) {
                const String item = 'test';
                return ListTile(
                  title: Text(item, style: theme.textTheme.bodyMedium),
                  tileColor: theme.brightness == Brightness.dark
                      ? Colors.grey[800]
                      : Colors.grey[200],
                );
              });
            },
          ),
        ),
        const SizedBox(width: 10),
        _buildProfileIcon(isDarkMode),
      ],
    );
  }

  Widget _buildMovieSection(String title, List<Movie>? movies,
      Function(List<Movie>) sliderBuilder, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          child: movies != null
              ? sliderBuilder(movies)
              : Center(
                  child: Text(
                    'Failed to load $title',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildProfileIcon(bool isDarkMode) {
    return FutureBuilder<MyUser?>(
      future: UserService().getCurrentUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          print('Error loading user data: ${snapshot.error}');
          return Icon(
            Icons.error,
            color: isDarkMode ? Colors.white : Colors.black,
          );
        }
        final user = snapshot.data;
        return InkWell(
          onTap: () => _showProfileMenu(context),
          child: CircleAvatar(
            radius: 20,
            backgroundColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
            child: user?.profilePicture != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: Image.network(
                      user!.profilePicture!,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        print('Error loading profile picture: $error');
                        return Icon(
                          Icons.person,
                          size: 24,
                          color: isDarkMode ? Colors.white : Colors.black,
                        );
                      },
                    ),
                  )
                : Icon(
                    Icons.person,
                    size: 24,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
          ),
        );
      },
    );
  }
}
