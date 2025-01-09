import 'package:flutter/material.dart';
import 'package:dima_project/api/constants.dart';
import 'package:dima_project/models/person.dart';
import 'package:dima_project/pages/movies/film_details_page.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:dima_project/services/tmdb_api_service.dart';
import 'package:provider/provider.dart';
import 'package:dima_project/widgets/squared_header.dart';

class PersonDetailsPage extends StatefulWidget {
  final Person person;

  const PersonDetailsPage({super.key, required this.person});

  @override
  State<PersonDetailsPage> createState() => PersonDetailsPageState();
}

class PersonDetailsPageState extends State<PersonDetailsPage> {
  Person _person = Person(
      adult: false,
      alsoKnownAs: [],
      biography: '',
      birthday: '',
      gender: 0,
      homepage: '',
      id: 0,
      knownForDepartment: '',
      name: '',
      placeOfBirth: '',
      popularity: 0,
      profilePath: '',
      knownFor: []);
  bool _isLoading = true;
  bool _showFullBiography = false;
  late ScrollController _scrollController;
  bool _showName = false;
  late TmdbApiService _apiService;

  final Logger logger = Logger();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _apiService = Provider.of<TmdbApiService>(context, listen: false);
    _scrollController = ScrollController()
      ..addListener(() {
        setState(() {
          _showName = _scrollController.hasClients &&
              _scrollController.offset > (300 - kToolbarHeight);
        });
      });
    _loadPersonDetails();
  }

  Future<void> _loadPersonDetails() async {
    try {
      final updatedPerson =
          await _apiService.fetchPersonDetails(widget.person.id);
      setState(() {
        _person = updatedPerson;
        _isLoading = false;
      });
    } catch (e) {
      logger.e('Error loading person details: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.shortestSide >= 500;

    if (!isTablet) {
      return Scaffold(
          body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : CustomScrollView(
                key: const PageStorageKey('person_details_page'),
                controller: _scrollController,
                slivers: [
                  _buildSilverAppBar(),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildPersonalInfoCard(),
                          const SizedBox(height: 8),
                          _buildBiographyCard(),
                          const SizedBox(height: 8),
                          _buildKnownForSection(false),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ));
    } else {
      return _buildTabletView();
    }
  }

  Widget _buildTabletView() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final horizontalPadding = screenWidth * 0.02;

    return Scaffold(
      appBar: AppBar(
        title: Text(_person.name),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Column - Profile Info
            Expanded(
              flex: isLandscape ? 45 : 50,
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Header
                    ProfileHeaderWidget(
                      imagePath: _person.profilePath != null
                          ? '${Constants.imageOriginalPath}${_person.profilePath}'
                          : null,
                      title: _person.name,
                      subtitle: _person.knownForDepartment,
                      size:
                          isLandscape ? screenWidth * 0.4 : screenWidth * 0.55,
                    ),
                    const SizedBox(height: 12),

                    // Personal Information Card
                    _buildPersonalInfoCard(),
                    const SizedBox(height: 12),

                    // Reused Biography Card with tablet-specific styling
                    _buildBiographyCard(),
                  ],
                ),
              ),
            ),
            // Vertical Divider
            if (isLandscape) const VerticalDivider(width: 1),

            // Right Column - Known For Section
            Expanded(
              flex: isLandscape ? 55 : 50,
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                ),
                child: _buildKnownForSection(
                  true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSilverAppBar() {
    final colorScheme = Theme.of(context).colorScheme;
    final bool isTablet = MediaQuery.of(context).size.shortestSide >= 500;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    Image? profileImage;
    try {
      if (_person.profilePath != null) {
        profileImage = Image.network(
          '${Constants.imageOriginalPath}${_person.profilePath}',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(color: Colors.grey);
          },
        );
      } else {
        profileImage = null;
      }
    } catch (e) {
      profileImage = null;
    }
    return SliverAppBar(
      expandedHeight: isTablet ? 425 : 325.0,
      pinned: true,
      stretch: true,
      title: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: _showName ? 1.0 : 0.0,
        child: Text(_person.name,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                )),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Profile image
            profileImage ?? Container(color: colorScheme.surface),
            // Gradient overlay for fade effect
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
            // Content overlay
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _person.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _person.knownForDepartment,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white70,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
        stretchModes: const [StretchMode.zoomBackground],
        collapseMode: CollapseMode.pin,
      ),
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            color: _showName
                ? Colors.transparent
                : colorScheme.surface.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_back,
                color: _showName
                    ? isDark
                        ? Colors.white
                        : Colors.black
                    : Colors.white),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalInfoCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Personal Information',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            _buildInfoRow('Born', formatDate(_person.birthday ?? '    -')),
            if (widget.person.deathday != null)
              _buildInfoRow('Died', formatDate(_person.deathday!)),
            _buildInfoRow('Place of Birth', _person.placeOfBirth ?? '    -'),
            _buildInfoRow('Known For', _person.knownForDepartment),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildBiographyCard() {
    String biography = _person.biography ?? 'No biography available.';
    if (_person.biography!.isEmpty) biography = 'No biography available.';
    bool isBiographyLong = biography.length > 300;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Biography',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              style: const TextStyle(fontSize: 16),
              _showFullBiography
                  ? biography
                  : biography.substring(
                      0, isBiographyLong ? 300 : biography.length),
              maxLines: _showFullBiography ? null : 5,
              overflow: _showFullBiography
                  ? TextOverflow.visible
                  : TextOverflow.ellipsis,
            ),
            if (isBiographyLong)
              TextButton(
                onPressed: () {
                  setState(() {
                    _showFullBiography = !_showFullBiography;
                  });
                },
                child: Text(_showFullBiography ? 'Show Less' : 'Show More'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildKnownForSection(bool isTablet) {
    bool isHorizontal =
        MediaQuery.of(context).orientation == Orientation.landscape;
    return Card(
      key: const Key('known_for_card'),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Known For',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isTablet
                    ? isHorizontal
                        ? 4
                        : 2
                    : 3,
                childAspectRatio: 0.7,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: _person.knownFor.length,
              itemBuilder: (context, index) {
                final movie = _person.knownFor[index];
                Image? movieImage;
                try {
                  if (movie.posterPath != null) {
                    movieImage = Image.network(
                      '${Constants.imagePath}${movie.posterPath}',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildPlaceholderPoster();
                      },
                    );
                  } else {
                    movieImage = null;
                  }
                } catch (e) {
                  movieImage = null;
                }
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FilmDetailsPage(movie: movie),
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      Expanded(
                        child: AspectRatio(
                          aspectRatio:
                              2 / 3, // Standard movie poster aspect ratio
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: movieImage ?? _buildPlaceholderPoster(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        movie.title,
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderPoster() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: isDarkMode ? Colors.white : Colors.black,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Icon(
          Icons.movie,
          size: 40,
          color: isDarkMode ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  String formatDate(String? date) {
    if (date == null) return '';
    if (date == 'Unknown') return 'Unknown';
    try {
      final DateTime parsedDate = DateTime.parse(date);
      return DateFormat.yMMMMd().format(parsedDate);
    } catch (e) {
      return date;
    }
  }
}
