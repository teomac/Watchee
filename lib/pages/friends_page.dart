import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dima_project/models/user_model.dart';
import 'package:dima_project/services/user_service.dart';
import 'package:dima_project/services/user_menu_manager.dart';
import 'package:rxdart/rxdart.dart';
import 'package:logger/logger.dart';
import 'package:dima_project/pages/user_profile_page.dart';

// Events
abstract class FriendsEvent {}

class LoadFriends extends FriendsEvent {}

class SearchUsers extends FriendsEvent {
  final String query;
  SearchUsers(this.query);
}

// States
abstract class FriendsState {}

class FriendsInitial extends FriendsState {}

class FriendsLoading extends FriendsState {}

class RefreshFriends extends FriendsEvent {}

class FriendsLoaded extends FriendsState {
  final List<MyUser> friends;
  FriendsLoaded(this.friends);
}

class FriendsError extends FriendsState {
  final String message;
  FriendsError(this.message);
}

class SearchResults extends FriendsState {
  final List<MyUser> users;
  SearchResults(this.users);
}

// BLoC
class FriendsBloc extends Bloc<FriendsEvent, FriendsState> {
  final UserService _userService;

  FriendsBloc(this._userService) : super(FriendsInitial()) {
    on<LoadFriends>(_onLoadFriends);
    on<SearchUsers>(_onSearchUsers,
        transformer: (events, mapper) => events
            .debounceTime(const Duration(milliseconds: 300))
            .switchMap(mapper));
    on<RefreshFriends>(_onRefreshFriends);
  }

  Future<void> _onLoadFriends(
      LoadFriends event, Emitter<FriendsState> emit) async {
    await _loadFriends(emit);
  }

  Future<void> _onRefreshFriends(
      RefreshFriends event, Emitter<FriendsState> emit) async {
    await _loadFriends(emit);
  }

  Future<void> _loadFriends(Emitter<FriendsState> emit) async {
    emit(FriendsLoading());
    try {
      final currentUser = await _userService.getCurrentUser();
      if (currentUser != null) {
        final friendIds = currentUser.friendList;
        final friends = await Future.wait(
          friendIds.map((id) => _userService.getUser(id)),
        );
        emit(FriendsLoaded(friends.whereType<MyUser>().toList()));
      } else {
        emit(FriendsError("User not found"));
      }
    } catch (e) {
      emit(FriendsError(e.toString()));
    }
  }

  Future<void> _onSearchUsers(
      SearchUsers event, Emitter<FriendsState> emit) async {
    if (event.query.length < 3) {
      emit(FriendsLoaded([]));
      return;
    }

    emit(FriendsLoading());
    try {
      final users = await _userService.searchUsers(event.query);
      emit(SearchResults(users));
    } catch (e) {
      emit(FriendsError(e.toString()));
    }
  }
}

class FriendsPage extends StatelessWidget {
  const FriendsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FriendsBloc(UserService())..add(LoadFriends()),
      child: FriendsView(),
    );
  }
}

class FriendsView extends StatelessWidget {
  FriendsView({super.key});

  final Logger logger = Logger();

  //final TextEditingController _searchController = TextEditingController();
  static const String defaultProfilePicture = 'images/default_profile.png';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, theme, isDarkMode),
              const SizedBox(height: 16),
              Text(
                'All your friends',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: BlocBuilder<FriendsBloc, FriendsState>(
                  builder: (context, state) {
                    if (state is FriendsLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is FriendsLoaded) {
                      return state.friends.isEmpty
                          ? _buildEmptyState(context)
                          : _buildFriendsList(state.friends);
                    } else if (state is SearchResults) {
                      return _buildSearchResults(state.users);
                    } else if (state is FriendsError) {
                      return Center(child: Text('Error: ${state.message}'));
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme, bool isDarkMode) {
    return Row(
      children: [
        Expanded(
          child: SearchAnchor(
            builder: (BuildContext context, SearchController controller) {
              return SearchBar(
                controller: controller,
                onTap: () => controller.openView(),
                onChanged: (query) {
                  context.read<FriendsBloc>().add(SearchUsers(query));
                },
                leading: Icon(Icons.search, color: theme.iconTheme.color),
                hintText: 'Search friends...',
                hintStyle: WidgetStateProperty.all(
                  TextStyle(color: theme.hintColor),
                ),
                backgroundColor: WidgetStateProperty.all(
                  isDarkMode ? Colors.grey[900] : Colors.grey[200],
                ),
                elevation: WidgetStateProperty.all(0),
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                padding: const WidgetStatePropertyAll<EdgeInsets>(
                  EdgeInsets.symmetric(horizontal: 16),
                ),
                constraints: const BoxConstraints(
                  minHeight: 48,
                  maxHeight: 48,
                ),
              );
            },
            suggestionsBuilder:
                (BuildContext context, SearchController controller) {
              // TODO: Implement search suggestions
              return [];
            },
          ),
        ),
        const SizedBox(width: 16),
        const UserInfo(),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return const Center(
      child: Text('No friends yet. Use the search bar to find users.'),
    );
  }

  Widget _buildFriendsList(List<MyUser> friends) {
    return ListView.builder(
      itemCount: friends.length,
      itemBuilder: (context, index) {
        return _buildUserListTile(context, friends[index]);
      },
    );
  }

  Widget _buildSearchResults(List<MyUser> users) {
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        return _buildUserListTile(context, users[index]);
      },
    );
  }

  Widget _buildUserListTile(BuildContext context, MyUser user) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => UserProfilePage(user: user)),
        );
        if (result == true) {
          // Friend status changed, refresh the list
          context.read<FriendsBloc>().add(RefreshFriends());
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0),
        child: SizedBox(
          height: 55,
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundImage: user.profilePicture?.isNotEmpty == true
                    ? NetworkImage(user.profilePicture!)
                    : const AssetImage('lib/images/default_profile.jpg')
                        as ImageProvider,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      user.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      user.username,
                      style: const TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
