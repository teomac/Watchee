import 'package:flutter/material.dart';
import 'package:dima_project/api/constants.dart';
import 'package:dima_project/models/person.dart';
import 'package:dima_project/pages/movies/film_details_page.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:dima_project/api/tmdb_api.dart';

class PersonDetailsPage extends StatefulWidget {
  final Person person;

  const PersonDetailsPage({super.key, required this.person});

  @override
  State<PersonDetailsPage> createState() => _PersonDetailsPageState();
}

class _PersonDetailsPageState extends State<PersonDetailsPage> {
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

  final Logger logger = Logger();

  @override
  void initState() {
    super.initState();
    _loadPersonDetails();
  }

  Future<void> _loadPersonDetails() async {
    try {
      final updatedPerson = await fetchPersonDetails(widget.person.id);
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
    return SafeArea(
        child: Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                _buildSilverAppBar(),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildNameAndDepartment(),
                        const SizedBox(height: 8),
                        _buildPersonalInfoCard(),
                        const SizedBox(height: 8),
                        _buildBiographyCard(),
                        const SizedBox(height: 8),
                        _buildKnownForSection(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    ));
  }

  Widget _buildSilverAppBar() {
    final colorScheme = Theme.of(context).colorScheme;
    return SliverAppBar(
      expandedHeight: 200.0,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: _person.profilePath != null
            ? Image.network(
                '${Constants.imagePath}${_person.profilePath}',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(color: Colors.grey);
                },
              )
            : Container(color: colorScheme.surface),
      ),
      leading: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(8.0),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
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
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            _buildInfoRow('Born', _formatDate(_person.birthday ?? '    -')),
            if (widget.person.deathday != null)
              _buildInfoRow('Died', _formatDate(_person.deathday!)),
            _buildInfoRow('Place of Birth', _person.placeOfBirth ?? '    -'),
            _buildInfoRow('Known For', _person.knownForDepartment),
          ],
        ),
      ),
    );
  }

  Widget _buildNameAndDepartment() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _person.name,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          _person.knownForDepartment,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ],
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
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
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

  Widget _buildKnownForSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Known For',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.7,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: _person.knownFor.length,
              itemBuilder: (context, index) {
                final movie = _person.knownFor[index];
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
                            child: movie.posterPath != null
                                ? Image.network(
                                    '${Constants.imagePath}${movie.posterPath}',
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return _buildPlaceholderPoster();
                                    },
                                  )
                                : _buildPlaceholderPoster(),
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

  String _formatDate(String date) {
    if (date == 'Unknown') return date;
    try {
      final DateTime parsedDate = DateTime.parse(date);
      return DateFormat.yMMMMd().format(parsedDate);
    } catch (e) {
      return date;
    }
  }
}
