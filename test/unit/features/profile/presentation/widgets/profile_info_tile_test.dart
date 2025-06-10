import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobsit/features/auth/domain/entities/user.dart';
import 'package:jobsit/features/auth/presentation/providers/auth_provider.dart';
import 'package:jobsit/features/profile/presentation/widgets/profile_info_tile.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

void main() {
  group('SimpleTile Widget Tests', () {
    testWidgets('should display title and icon correctly', (
      final tester,
    ) async {
      const title = 'Test Title';
      const icon = Icons.star;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SimpleTile(
              title: title,
              icon: icon,
            ),
          ),
        ),
      );

      expect(find.text(title), findsOneWidget);
      expect(find.byIcon(icon), findsOneWidget);
    });

    testWidgets('should apply custom spacing', (final tester) async {
      const spacing = 24.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SimpleTile(
              title: 'Test',
              icon: Icons.star,
              spacing: spacing,
            ),
          ),
        ),
      );

      final row = tester.widget<Row>(find.byType(Row));
      expect(row.spacing, spacing);
    });

    testWidgets('should apply custom padding', (final tester) async {
      const padding = EdgeInsets.all(16);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SimpleTile(
              title: 'Test',
              icon: Icons.star,
              padding: padding,
            ),
          ),
        ),
      );

      final paddingWidget = tester.widget<Padding>(find.byType(Padding));
      expect(paddingWidget.padding, padding);
    });

    testWidgets('should have correct text style', (final tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            textTheme: const TextTheme(
              titleSmall: TextStyle(fontSize: 14),
            ),
            colorScheme: const ColorScheme.light(),
          ),
          home: const Scaffold(
            body: SimpleTile(
              title: 'Test',
              icon: Icons.star,
            ),
          ),
        ),
      );

      final text = tester.widget<Text>(find.text('Test'));
      expect(text.style?.fontWeight, FontWeight.bold);
    });
  });

  group('JobTile Widget Tests', () {
    testWidgets('should display title and child widget', (final tester) async {
      const title = 'Job Title';
      const childText = 'Child Content';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: JobTile(
              title: title,
              child: Text(childText),
            ),
          ),
        ),
      );

      expect(find.text(title), findsOneWidget);
      expect(find.text(childText), findsOneWidget);
    });

    testWidgets('should have correct layout structure', (final tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: JobTile(
              title: 'Test Title',
              child: Text('Test Child'),
            ),
          ),
        ),
      );

      expect(find.byType(Padding), findsOneWidget);
      expect(find.byType(Column), findsOneWidget);

      final column = tester.widget<Column>(find.byType(Column));
      expect(column.crossAxisAlignment, CrossAxisAlignment.start);
      expect(column.spacing, 4);
    });
  });

  group('CarouselJobTile Widget Tests', () {
    testWidgets('should display empty builder when count is 0', (
      final tester,
    ) async {
      const emptyText = 'No items';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CarouselJobTile(
              title: 'Test Carousel',
              count: 0,
              builder: (final context, final index) => Text('Item $index'),
              emptyBuilder: (final context) => const Text(emptyText),
            ),
          ),
        ),
      );

      expect(find.text('Test Carousel'), findsOneWidget);
      expect(find.text(emptyText), findsOneWidget);
      expect(find.byType(ListView), findsNothing);
    });

    testWidgets('should display ListView when count > 0', (final tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CarouselJobTile(
              title: 'Test Carousel',
              count: 3,
              builder: (final context, final index) => Text('Item $index'),
              emptyBuilder: (final context) => const Text('Empty'),
            ),
          ),
        ),
      );

      expect(find.text('Test Carousel'), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);
      expect(find.text('Item 0'), findsOneWidget);
      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 2'), findsOneWidget);
      expect(find.text('Empty'), findsNothing);
    });

    testWidgets('should have correct ListView properties', (
      final tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CarouselJobTile(
              title: 'Test',
              count: 2,
              builder: (final context, final index) => SizedBox(
                width: 100,
                child: Text('Item $index'),
              ),
              emptyBuilder: (final context) => const Text('Empty'),
            ),
          ),
        ),
      );

      final listView = tester.widget<ListView>(find.byType(ListView));
      expect(listView.scrollDirection, Axis.horizontal);

      final sizedBox = tester.widget<SizedBox>(
        find.ancestor(
          of: find.byType(ListView),
          matching: find.byType(SizedBox),
        ),
      );
      expect(sizedBox.height, 32);
    });
  });
  group('AvatarSection Widget Tests', () {
    testWidgets('should display CachedNetworkImage when avatar is not null', (
      final tester,
    ) async {
      const mockState = AuthAuthorized(
        User(
          userId: 1,
          role: 'CANDIDATE',
          userInfo: UserInformation(
            email: 'test@example.com',
            firstName: 'John',
            lastName: 'Doe',
            phone: '+1234567890',
            gender: true,
            mailReceive: true,
            avatar: 'test_avatar.jpg',
          ),
          jobInfo: JobInformation(
            positions: [],
            majors: [],
            schedules: [],
            searchable: false,
          ),
        ),
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AvatarSection(state: mockState),
          ),
        ),
      );

      expect(find.byType(CachedNetworkImage), findsOneWidget);
      expect(find.byType(ClipOval), findsOneWidget);
      expect(find.byType(DecoratedBox), findsAtLeastNWidgets(1));

      final cachedImage = tester.widget<CachedNetworkImage>(
        find.byType(CachedNetworkImage),
      );
      expect(cachedImage.width, 86);
      expect(cachedImage.height, 86);
      expect(cachedImage.fit, BoxFit.cover);
    });

    testWidgets('should display shimmer placeholder while loading', (
      final tester,
    ) async {
      const mockState = AuthAuthorized(
        User(
          userId: 1,
          role: 'CANDIDATE',
          userInfo: UserInformation(
            email: 'test@example.com',
            firstName: 'John',
            lastName: 'Doe',
            phone: '+1234567890',
            gender: true,
            mailReceive: true,
            avatar: 'test_avatar.jpg',
          ),
          jobInfo: JobInformation(
            positions: [],
            majors: [],
            schedules: [],
            searchable: false,
          ),
        ),
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AvatarSection(state: mockState),
          ),
        ),
      );

      // Find the CachedNetworkImage and trigger its placeholder
      final cachedImage = tester.widget<CachedNetworkImage>(
        find.byType(CachedNetworkImage),
      );

      // Build the placeholder widget
      final placeholderWidget = cachedImage.placeholder!(
        tester.element(find.byType(CachedNetworkImage)),
        'test_url',
      );

      expect(placeholderWidget, isA<Shimmer>());
    });

    testWidgets('should display error widget on image load failure', (
      final tester,
    ) async {
      const mockState = AuthAuthorized(
        User(
          userId: 1,
          role: 'CANDIDATE',
          userInfo: UserInformation(
            email: 'test@example.com',
            firstName: 'John',
            lastName: 'Doe',
            phone: '+1234567890',
            gender: true,
            mailReceive: true,
            avatar: 'test_avatar.jpg',
          ),
          jobInfo: JobInformation(
            positions: [],
            majors: [],
            schedules: [],
            searchable: false,
          ),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            primaryColor: Colors.blue,
          ),
          home: const Scaffold(
            body: AvatarSection(state: mockState),
          ),
        ),
      );

      // Find the CachedNetworkImage and trigger its error widget
      final cachedImage = tester.widget<CachedNetworkImage>(
        find.byType(CachedNetworkImage),
      );

      // Build the error widget
      final errorWidget = cachedImage.errorWidget!(
        tester.element(find.byType(CachedNetworkImage)),
        'test_url',
        Exception('Load failed'),
      );

      expect(errorWidget, isA<DecoratedBox>());
    });

    testWidgets('should have correct decoration properties', (
      final tester,
    ) async {
      const mockState = AuthAuthorized(
        User(
          userId: 1,
          role: 'CANDIDATE',
          userInfo: UserInformation(
            email: 'test@example.com',
            firstName: 'John',
            lastName: 'Doe',
            phone: '+1234567890',
            gender: true,
            mailReceive: true,
            avatar: 'test_avatar.jpg',
          ),
          jobInfo: JobInformation(
            positions: [],
            majors: [],
            schedules: [],
            searchable: false,
          ),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            primaryColor: Colors.red,
          ),
          home: const Scaffold(
            body: AvatarSection(state: mockState),
          ),
        ),
      );

      final decoratedBox = tester.widget<DecoratedBox>(
        find.byType(DecoratedBox).first,
      );
      final decoration = decoratedBox.decoration as BoxDecoration;

      expect(decoration.color, Colors.transparent);
      expect(decoration.shape, BoxShape.circle);
      expect(decoration.border, isA<Border>());
    });
  });

  group('_NoAvatar Widget Tests', () {
    testWidgets('should display correct icon and properties', (
      final tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            colorScheme: const ColorScheme.light(),
          ),
          home: const Scaffold(
            body: AvatarSection(
              state: AuthAuthorized(
                User(
                  userId: 1,
                  role: 'test',
                  userInfo: UserInformation(
                    email: 'test@test.com',
                    firstName: 'Test',
                    lastName: 'User',
                    phone: '123456789',
                    gender: true,
                    mailReceive: true,
                  ),
                  jobInfo: JobInformation(
                    positions: [],
                    majors: [],
                    schedules: [],
                    searchable: false,
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      // The CachedNetworkImage should display error widget containing _NoAvatar
      final cachedImage = tester.widget<CachedNetworkImage>(
        find.byType(CachedNetworkImage),
      );

      // Build the error widget which contains _NoAvatar
      final errorWidget =
          cachedImage.errorWidget!(
                tester.element(find.byType(CachedNetworkImage)),
                'test_url',
                Exception('Load failed'),
              )
              as DecoratedBox;

      // The child should be _NoAvatar which contains an Icon
      expect(
        errorWidget.child.runtimeType.toString().contains('NoAvatar'),
        isTrue,
      );
    });
  });

  group('Widget Integration Tests', () {
    testWidgets('should render complete profile info tile structure', (
      final tester,
    ) async {
      const mockAuthState = AuthAuthorized(
        User(
          userId: 1,
          role: 'CANDIDATE',
          userInfo: UserInformation(
            email: 'test@example.com',
            firstName: 'John',
            lastName: 'Doe',
            phone: '+1234567890',
            gender: true,
            mailReceive: true,
            address: '123 Test Street',
            avatar: 'test_avatar.jpg',
          ),
          jobInfo: JobInformation(
            positions: [],
            majors: [],
            schedules: [],
            searchable: true,
            desiredJob: 'Software Engineer',
          ),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                const AvatarSection(state: mockAuthState),
                SimpleTile(
                  title: mockAuthState.user.userInfo.email,
                  icon: IconlyLight.message,
                ),
                SimpleTile(
                  title: mockAuthState.user.userInfo.phone,
                  icon: IconlyLight.calling,
                ),
                JobTile(
                  title: 'Desired Job',
                  child: Text(mockAuthState.user.jobInfo.desiredJob ?? 'N/A'),
                ),
                CarouselJobTile(
                  title: 'Skills',
                  count: 0,
                  builder: (final context, final index) => Text('Skill $index'),
                  emptyBuilder: (final context) => const Text(
                    'No skills added',
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      // Verify all components are rendered
      expect(find.byType(AvatarSection), findsOneWidget);
      expect(find.byType(SimpleTile), findsNWidgets(2));
      expect(find.byType(JobTile), findsNWidgets(2));
      expect(find.byType(CarouselJobTile), findsOneWidget);

      // Verify content
      expect(find.text('test@example.com'), findsOneWidget);
      expect(find.text('+1234567890'), findsOneWidget);
      expect(find.text('Desired Job'), findsOneWidget);
      expect(find.text('Software Engineer'), findsOneWidget);
      expect(find.text('Skills'), findsOneWidget);
      expect(find.text('No skills added'), findsOneWidget);
    });

    testWidgets('should handle null values gracefully', (final tester) async {
      const mockAuthState = AuthAuthorized(
        User(
          userId: 1,
          role: 'CANDIDATE',
          userInfo: UserInformation(
            email: 'test@example.com',
            firstName: 'John',
            lastName: 'Doe',
            phone: '+1234567890',
            gender: true,
            mailReceive: true,
          ),
          jobInfo: JobInformation(
            positions: [],
            majors: [],
            schedules: [],
            searchable: false,
          ),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                const AvatarSection(state: mockAuthState),
                JobTile(
                  title: 'Desired Job',
                  child: Text(
                    mockAuthState.user.jobInfo.desiredJob ?? 'Not specified',
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Not specified'), findsOneWidget);
      expect(find.byType(CachedNetworkImage), findsOneWidget);
    });
  });

  group('Error Handling Tests', () {
    testWidgets('should handle malformed avatar URL', (final tester) async {
      const mockAuthState = AuthAuthorized(
        User(
          userId: 1,
          role: 'CANDIDATE',
          userInfo: UserInformation(
            email: 'test@example.com',
            firstName: 'John',
            lastName: 'Doe',
            phone: '+1234567890',
            gender: true,
            mailReceive: true,
            avatar: 'invalid-url',
          ),
          jobInfo: JobInformation(
            positions: [],
            majors: [],
            schedules: [],
            searchable: false,
          ),
        ),
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AvatarSection(state: mockAuthState),
          ),
        ),
      );

      // Should render without throwing
      expect(find.byType(AvatarSection), findsOneWidget);
      expect(find.byType(CachedNetworkImage), findsOneWidget);
    });
    testWidgets('should handle empty strings gracefully', (final tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SimpleTile(
              title: '', // empty title
              icon: Icons.star,
            ),
          ),
        ),
      );

      expect(find.byType(SimpleTile), findsOneWidget);
      expect(find.text(''), findsOneWidget);
    });
  });

  group('Accessibility Tests', () {
    testWidgets('should be accessible with screen readers', (
      final tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SimpleTile(
              title: 'Email Address',
              icon: IconlyLight.message,
            ),
          ),
        ),
      );

      // Verify semantic information
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.byIcon(IconlyLight.message), findsOneWidget);

      // Test that the widgets are accessible
      expect(tester.getSemantics(find.text('Email Address')), isNotNull);
    });
  });
}
