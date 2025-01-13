import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/services/user_service.dart';
import 'package:dima_project/services/user_menu_manager.dart';
import 'package:logger/logger.dart';
import 'package:dima_project/pages/account/user_profile_page.dart';
import 'package:dima_project/widgets/user_search_bar_widget.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

// Events
abstract class FollowEvent {}

class LoadFollowData extends FollowEvent {}

class SearchUsers extends FollowEvent {
  final String query;
  SearchUsers(this.query);
}

class UnfollowUser extends FollowEvent {
  final MyUser user;
  UnfollowUser(this.user);
}

class RemoveFollower extends FollowEvent {
  final MyUser user;
  RemoveFollower(this.user);
}

// States
abstract class FollowState {}

class FollowInitial extends FollowState {}

class FollowLoading extends FollowState {}

class FollowDataLoaded extends FollowState {
  final List<MyUser> following;
  final List<MyUser> followers;
  FollowDataLoaded(this.following, this.followers);
}

class FollowError extends FollowState {
  final String message;
  FollowError(this.message);
}

class SearchResultsLoaded extends FollowState {
  final List<MyUser> users;
  SearchResultsLoaded(this.users);
}

class SearchPerformedWithNoResults extends FollowState {}

// BLoC
class FollowBloc extends Bloc<FollowEvent, FollowState> {
  final Logger logger = Logger();
  final UserService userService;

  FollowBloc(this.userService) : super(FollowInitial()) {
    on<LoadFollowData>(
        (event, emit) => _onLoadFollowData(event, emit, userService));
    on<SearchUsers>((event, emit) => _onSearchUsers(event, emit, userService));

    on<UnfollowUser>(
        (event, emit) => _onUnfollowUser(event, emit, userService));
    on<RemoveFollower>(
        (event, emit) => _onRemoveFollower(event, emit, userService));
  }

  Future<void> _onLoadFollowData(LoadFollowData event,
      Emitter<FollowState> emit, UserService userService) async {
    emit(FollowLoading());
    try {
      final currentUser = await userService.getCurrentUser();
      if (currentUser != null) {
        final following = await userService.getFollowing(currentUser.id);
        final followers = await userService.getFollowers(currentUser.id);
        emit(FollowDataLoaded(following, followers));
      } else {
        emit(FollowError("User not found"));
      }
    } catch (e) {
      logger.e("Error loading follow data: $e");
      emit(FollowError(e.toString()));
    }
  }

  Future<void> _onSearchUsers(SearchUsers event, Emitter<FollowState> emit,
      UserService userService) async {
    if (event.query.length < 3) {
      emit(SearchResultsLoaded([]));
      return;
    }

    try {
      final users = await userService.searchUsers(event.query);
      if (users.isEmpty) {
        emit(SearchPerformedWithNoResults());
      } else {
        emit(SearchResultsLoaded(users));
      }
    } catch (e) {
      logger.e("Error searching users: $e");
      emit(FollowError(e.toString()));
    }
  }

  Future<void> _onUnfollowUser(UnfollowUser event, Emitter<FollowState> emit,
      UserService userService) async {
    try {
      final currentState = state;
      if (currentState is FollowDataLoaded) {
        final currentUser = await userService.getCurrentUser();
        if (currentUser != null) {
          await userService.unfollowUser(currentUser.id, event.user.id);

          // Update the local list of following users without reloading everything
          final updatedFollowing = List<MyUser>.from(currentState.following)
            ..remove(event.user);

          // Emit the new state with updated following list
          emit(FollowDataLoaded(updatedFollowing, currentState.followers));
        }
      }
    } catch (e) {
      logger.e("Error unfollowing user: $e");
      emit(FollowError(e.toString()));
    }
  }

  Future<void> _onRemoveFollower(RemoveFollower event,
      Emitter<FollowState> emit, UserService userService) async {
    try {
      final currentUser = await userService.getCurrentUser();
      if (currentUser != null) {
        await userService.removeFollower(currentUser.id, event.user.id);
        add(LoadFollowData());
      }
    } catch (e) {
      logger.e("Error removing follower: $e");
      emit(FollowError(e.toString()));
    }
  }
}

class FollowView extends StatefulWidget {
  final FollowBloc? followBloc;

  const FollowView({
    super.key,
    this.followBloc, // Make it optional to maintain backward compatibility
  });

  @override
  State<FollowView> createState() => _FollowViewState();
}

class _FollowViewState extends State<FollowView> {
  bool isSearchExpanded = false;
  late FollowBloc _followBloc;
  bool isLoadingNecessary = true;

  @override
  void initState() {
    super.initState();
    _followBloc = widget.followBloc ??
        FollowBloc(Provider.of<UserService>(context, listen: false));
    if (isLoadingNecessary) {
      _followBloc.add(LoadFollowData());
    }
  }

  @override
  void dispose() {
    _followBloc.close();
    super.dispose();
  }

  void _reloadFollowData() {
    setState(() {
      isSearchExpanded = false;
      isLoadingNecessary = true;
    });
    _followBloc.add(LoadFollowData());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return BlocProvider.value(
        value: _followBloc,
        child: Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(context, theme, isDarkMode),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: isSearchExpanded
                        ? _buildSearchResults()
                        : _buildFollowTabs(),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Widget _buildHeader(BuildContext context, ThemeData theme, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0, left: 12.0, right: 12.0),
      child: Row(
        children: [
          Expanded(
            child: SearchBarWidget(
              theme: theme,
              isDarkMode: isDarkMode,
              onSearchChanged: (query) {
                if (query.isNotEmpty) {
                  _followBloc.add(SearchUsers(query));
                }
              },
              onExpandChanged: (expanded) {
                if (!expanded) {
                  _reloadFollowData();
                } else {
                  setState(() {
                    isSearchExpanded = expanded;
                    isLoadingNecessary = false;
                  });
                }
              },
            ),
          ),
          if (!isSearchExpanded) ...[
            const SizedBox(width: 16),
            const UserInfo(),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return BlocBuilder<FollowBloc, FollowState>(
      builder: (context, state) {
        if (state is SearchPerformedWithNoResults) {
          return _buildEmptySearchState();
        } else if (state is SearchResultsLoaded) {
          return _buildSearchResultsList(context, state.users);
        } else if (state is FollowError) {
          return Center(child: Text('Error: ${state.message}'));
        } else if (state is FollowLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        return const Center(child: Text(''));
      },
    );
  }

  Widget _buildEmptySearchState() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 275,
              height: 275,
              child: Lottie.asset(
                'lib/assets/lottie_tumbleweed.json',
                fit: BoxFit.contain,
                repeat: true,
                reverse: false,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No users found',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Try a different search term',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResultsList(BuildContext context, List<MyUser> users) {
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        NetworkImage? proPic;
        try {
          if (user.profilePicture?.isNotEmpty == true) {
            proPic = NetworkImage(user.profilePicture!);
          }
        } catch (e) {
          proPic = null;
        }
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: proPic,
            child: proPic == null
                ? Icon(Icons.person,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black)
                : null,
          ),
          title: Text(user.username),
          subtitle: Text(user.name),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UserProfilePage(user: user),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFollowTabs() {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(child: Text('Following', style: TextStyle(fontSize: 16))),
              Tab(child: Text('Followers', style: TextStyle(fontSize: 16))),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildFollowList(true),
                _buildFollowList(false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFollowList(bool isFollowing) {
    return BlocBuilder<FollowBloc, FollowState>(
      builder: (context, state) {
        if (state is FollowLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is FollowDataLoaded) {
          final users = isFollowing ? state.following : state.followers;
          return users.isEmpty
              ? _buildEmptyState(isFollowing)
              : ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) =>
                      _buildUserListTile(context, users[index], isFollowing),
                );
        } else if (state is FollowError) {
          return Center(child: Text('Error: ${state.message}'));
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildEmptyState(bool isFollowing) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'lib/assets/lottie_ghost.json',
            width: 200,
            height: 200,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 20),
          Text(
            key: const Key('empty_state_text'),
            isFollowing
                ? 'You are not following anyone yet'
                : 'No followers yet',
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildUserListTile(
      BuildContext context, MyUser user, bool isFollowing) {
    final theme = Theme.of(context).colorScheme;

    NetworkImage? proPic;
    try {
      if (user.profilePicture?.isNotEmpty == true) {
        proPic = NetworkImage(user.profilePicture!);
      }
    } catch (e) {
      proPic = null;
    }

    return ListTile(
      leading: CircleAvatar(
        backgroundImage: proPic,
        child: proPic == null
            ? Icon(Icons.person,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black)
            : null,
      ),
      title: Text(user.username, style: const TextStyle(fontSize: 16)),
      subtitle: Text(user.name, style: const TextStyle(fontSize: 14)),
      trailing: ElevatedButton(
        onPressed: () => isFollowing
            ? context.read<FollowBloc>().add(UnfollowUser(user))
            : context.read<FollowBloc>().add(RemoveFollower(user)),
        style: ElevatedButton.styleFrom(
          foregroundColor: theme.primary,
          backgroundColor: theme.surface,
          side: BorderSide(
            color: theme.primary,
            width: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        child: Text(isFollowing ? 'Unfollow' : 'Remove'),
      ),
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => UserProfilePage(user: user)),
        );
        if (result == true) {
          _reloadFollowData();
        }
      },
    );
  }
}
