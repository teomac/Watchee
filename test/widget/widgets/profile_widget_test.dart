import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dima_project/widgets/profile_widget.dart';
import 'package:dima_project/models/user.dart';
import 'package:network_image_mock/network_image_mock.dart';

void main() {
  late MyUser testUser;

  setUp(() {
    testUser = MyUser(
      id: '123',
      username: 'testuser',
      name: 'Test User',
      email: 'test@example.com',
    );
  });

  group('ProfileMenu Widget Tests', () {
    testWidgets('renders all basic components', (WidgetTester tester) async {
      bool manageAccountTapped = false;
      bool appSettingsTapped = false;
      bool signOutTapped = false;
      bool userTapped = false;
      bool notificationsTapped = false;

      final userWithPicture = MyUser(
        id: '123',
        username: 'testuser',
        name: 'Test User',
        email: 'test@example.com',
        profilePicture: 'https://example.com/profile.jpg',
      );

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: ProfileMenu(
              user: userWithPicture,
              onManageAccountTap: () {
                manageAccountTapped = true;
              },
              onAppSettingsTap: () {
                appSettingsTapped = true;
              },
              onSignOutTap: () {
                signOutTapped = true;
              },
              onUserTap: () {
                userTapped = true;
              },
              onNotificationsTap: () {
                notificationsTapped = true;
              },
              unreadCount: 0,
            ),
          ),
        ));

        // Check that the CircleAvatar widget is displayed
        expect(find.byType(CircleAvatar), findsOneWidget);

        // Retrieve the CircleAvatar widget and verify its backgroundImage is a NetworkImage
        final CircleAvatar avatar =
            tester.widget<CircleAvatar>(find.byType(CircleAvatar));
        expect(avatar.backgroundImage, isA<NetworkImage>());

        // Tap on the user avatar (should trigger onUserTap)
        await tester.tap(find.byType(CircleAvatar));
        await tester.pumpAndSettle();
        expect(userTapped, isTrue);

        // Tap on "Manage Account" ListTile
        await tester.tap(find.text('Manage Account'));
        await tester.pumpAndSettle();
        expect(manageAccountTapped, isTrue);

        // Tap on "App Settings" ListTile
        await tester.tap(find.text('App Settings'));
        await tester.pumpAndSettle();
        expect(appSettingsTapped, isTrue);

        // Tap on "Sign Out" ListTile
        await tester.tap(find.text('Sign Out'));
        await tester.pumpAndSettle();
        expect(signOutTapped, isTrue);

        // Tap on "Notifications" ListTile
        await tester.tap(find.text('Notifications'));
        await tester.pumpAndSettle();
        expect(notificationsTapped, isTrue);
      });
    });

    testWidgets('displays profile picture when available',
        (WidgetTester tester) async {
      final userWithPicture = MyUser(
        id: '123',
        username: 'testuser',
        name: 'Test User',
        email: 'test@example.com',
        profilePicture: 'https://example.com/profile.jpg',
      );

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: ProfileMenu(
              user: userWithPicture,
              onManageAccountTap: () {},
              onAppSettingsTap: () {},
              onSignOutTap: () {},
              onUserTap: () {},
              onNotificationsTap: () {},
              unreadCount: 0,
            ),
          ),
        ));

        expect(find.byType(CircleAvatar), findsOneWidget);

        final CircleAvatar avatar =
            tester.widget<CircleAvatar>(find.byType(CircleAvatar));
        expect(avatar.backgroundImage, isA<NetworkImage>());
      });
    });

    testWidgets('displays notification badge when unread count > 0',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ProfileMenu(
            user: testUser,
            onManageAccountTap: () {},
            onAppSettingsTap: () {},
            onSignOutTap: () {},
            onUserTap: () {},
            onNotificationsTap: () {},
            unreadCount: 5,
          ),
        ),
      ));

      expect(find.text('5'), findsOneWidget);
      expect(
          find.byType(Container), findsWidgets); // Notification badge container
    });

    testWidgets('all tap callbacks work correctly',
        (WidgetTester tester) async {
      bool manageAccountTapped = false;
      bool appSettingsTapped = false;
      bool signOutTapped = false;
      bool userTapped = false;
      bool notificationsTapped = false;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ProfileMenu(
            user: testUser,
            onManageAccountTap: () => manageAccountTapped = true,
            onAppSettingsTap: () => appSettingsTapped = true,
            onSignOutTap: () => signOutTapped = true,
            onUserTap: () => userTapped = true,
            onNotificationsTap: () => notificationsTapped = true,
            unreadCount: 0,
          ),
        ),
      ));

      // Test each tap callback
      await tester.tap(find.text('Manage Account'));
      expect(manageAccountTapped, true);

      await tester.tap(find.text('App Settings'));
      expect(appSettingsTapped, true);

      await tester.tap(find.text('Sign Out'));
      expect(signOutTapped, true);

      await tester.tap(find.text('Notifications'));
      expect(notificationsTapped, true);

      await tester.tap(find.byType(CircleAvatar));
      expect(userTapped, true);
    });

    testWidgets('shows divider in correct position',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ProfileMenu(
            user: testUser,
            onManageAccountTap: () {},
            onAppSettingsTap: () {},
            onSignOutTap: () {},
            onUserTap: () {},
            onNotificationsTap: () {},
            unreadCount: 0,
          ),
        ),
      ));

      expect(find.byType(Divider), findsOneWidget);

      // Verify divider is after user info and before menu items
      final dividerFinder = find.byType(Divider);
      final usernameFinder = find.text(testUser.name);
      final notificationsFinder = find.text('Notifications');

      expect(tester.getTopLeft(dividerFinder).dy,
          greaterThan(tester.getBottomLeft(usernameFinder).dy));
      expect(tester.getBottomLeft(dividerFinder).dy,
          lessThan(tester.getTopLeft(notificationsFinder).dy));
    });

    testWidgets('handles long text gracefully', (WidgetTester tester) async {
      final userWithLongText = MyUser(
        id: '123',
        username: 'testuserwithalongusername',
        name: 'Test User With A Very Long Name That Might Overflow',
        email: 'testuserwithaverylong.email@verylongdomain.com',
      );

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ProfileMenu(
              user: userWithLongText,
              onManageAccountTap: () {},
              onAppSettingsTap: () {},
              onSignOutTap: () {},
              onUserTap: () {},
              onNotificationsTap: () {},
              unreadCount: 0,
            ),
          ),
        ),
      ));

      // Verify no errors occur with long text
      expect(find.text(userWithLongText.name), findsOneWidget);
      expect(find.text(userWithLongText.email), findsOneWidget);
    });
  });
}
