// Tests for the group part of SplitMate:
// my groups list, creating a group, joining with a code, members and invites.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cs310_project/state/app_state.dart';
import 'package:cs310_project/screens/group_screens.dart';
import 'package:cs310_project/screens/group_members_view.dart';

const ayseId = 'ayse@example.com';

// Opens one screen in a phone sized window (390 x 844).
Future<void> openScreen(
  WidgetTester tester,
  AppState app,
  Widget screen,
) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    AppScope(
      state: app,
      child: MaterialApp(home: screen),
    ),
  );
  await tester.pumpAndSettle();
}

// Taps a button inside the open confirm dialog.
Future<void> tapInDialog(WidgetTester tester, String label) async {
  await tester.tap(
    find.descendant(of: find.byType(AlertDialog), matching: find.text(label)),
  );
  await tester.pumpAndSettle();
}

// The members view is shown inside a scrolling page in the app.
Widget membersPage(AppState app) => Scaffold(
  body: ListView(
    children: [GroupMembersView(group: app.findCode('TRIP-7K2M')!)],
  ),
);

void main() {
  group('Creating a group (state)', () {
    test('new group has a trimmed name, the currency and the owner', () {
      final app = AppState();
      app.signIn(emirId);
      final g = app.createGroup('  Dorm 4B  ', 'EUR');
      expect(g.name, 'Dorm 4B');
      expect(g.currency, 'EUR');
      expect(g.owner, emirId);
      expect(g.members, {emirId: 'Emir Keskin'});
      expect(app.myGroups.contains(g), true);
    });

    test('empty group name is not accepted', () {
      final app = AppState();
      app.signIn(emirId);
      final before = app.groups.length;
      expect(() => app.createGroup('   ', 'TRY'), throwsStateError);
      expect(app.groups.length, before);
    });
  });

  group('Invite codes (state)', () {
    test('codes look like SM-XXXXXX and every character can be used', () {
      final app = AppState();
      final used = <String>{};
      for (int i = 0; i < 2000; i++) {
        final code = app.inviteCode();
        // No I, O, 0 or 1 inside the code.
        expect(code, matches(RegExp(r'^SM-[A-HJ-NP-Z2-9]{6}$')));
        used.addAll(code.substring(3).split(''));
      }
      // The old code never used '9'.
      expect(used.contains('9'), true);
      expect(used.length, AppState.inviteCodeChars.length);
    });

    test('every new group gets a different code', () {
      final app = AppState();
      app.signIn(emirId);
      for (int i = 0; i < 200; i++) {
        app.createGroup('Group $i', 'TRY');
      }
      final codes = app.groups.map((g) => g.code).toSet();
      expect(codes.length, app.groups.length);
    });

    test('findCode ignores upper/lower case and spaces around the code', () {
      final app = AppState();
      expect(app.findCode('TRIP-7K2M')?.name, 'Weekend trip');
      expect(app.findCode('  trip-7k2m ')?.name, 'Weekend trip');
      expect(app.findCode('TRIP-0000'), null);
    });

    test('only the owner can reset; old code stops, members stay', () {
      final app = AppState();
      final trip = app.findCode('TRIP-7K2M')!; // Efe is the owner
      app.signIn(yunusId);
      expect(() => app.resetInviteCode(trip), throwsStateError);
      expect(trip.code, 'TRIP-7K2M');

      app.signIn(efeId);
      app.resetInviteCode(trip);
      expect(trip.code, isNot('TRIP-7K2M'));
      expect(app.findCode('TRIP-7K2M'), null);
      expect(app.findCode(trip.code), trip);
      expect(trip.members.length, 3);
    });
  });

  group('Joining a group (state)', () {
    test('new user joins with the code; joining twice adds only once', () {
      final app = AppState();
      app.signIn(ayseId, fullName: 'Ayşe Yılmaz');
      expect(app.myGroups, isEmpty);
      final trip = app.findCode('TRIP-7K2M')!;
      app.join(trip);
      app.join(trip);
      expect(trip.members.length, 4);
      expect(trip.members[ayseId], 'Ayşe Yılmaz');
      expect(app.myGroups.map((g) => g.name).toList(), ['Weekend trip']);
    });

    test(
      'members, the new code and favorites are kept after restart',
      () async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        final first = AppState(prefs);
        first.signIn(efeId);
        final trip = first.findCode('TRIP-7K2M')!;
        first.resetInviteCode(trip);
        final newCode = trip.code;
        first.signIn(ayseId, fullName: 'Ayşe Yılmaz');
        first.join(first.findCode(newCode)!);
        first.toggleFavorite(trip.id);
        await first.save();

        // A new AppState reads the saved data, like opening the app again.
        final second = AppState(prefs);
        second.signIn(ayseId);
        expect(second.myGroups.length, 1);
        expect(second.myGroups.first.code, newCode);
        expect(second.isFavorite(trip.id), true);
        expect(second.findCode('TRIP-7K2M'), null);
      },
    );
  });

  group('Order of my groups (state)', () {
    test(
      'favorites first, then names A-Z (upper/lower case does not matter)',
      () {
        final app = AppState();
        app.signIn(emirId);
        app.createGroup('apartment', 'TRY');
        final zoo = app.createGroup('Zoo day', 'TRY');
        expect(app.myGroups.map((g) => g.name).toList(), [
          'apartment',
          'Flatmates',
          'Weekend trip',
          'Zoo day',
        ]);
        app.toggleFavorite(zoo.id);
        expect(app.myGroups.first.name, 'Zoo day');
      },
    );

    test('a favorite belongs to one user only', () {
      final app = AppState();
      app.signIn(efeId);
      app.toggleFavorite('trip');
      expect(app.isFavorite('trip'), true);
      app.signIn(yunusId);
      expect(app.isFavorite('trip'), false);
      expect(app.myGroups.first.name, 'Flatmates');
    });
  });

  group('Create group screen', () {
    testWidgets('empty name shows an error that goes away after typing', (
      tester,
    ) async {
      final app = AppState();
      app.signIn(emirId);
      await openScreen(tester, app, const CreateGroupScreen());
      await tester.tap(find.widgetWithText(FilledButton, 'Create group'));
      await tester.pumpAndSettle();
      expect(find.text('Please fill in this field.'), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);

      await tester.enterText(find.byType(TextFormField), 'Dorm');
      await tester.pumpAndSettle();
      expect(find.text('Please fill in this field.'), findsNothing);
    });

    testWidgets('chosen currency is saved and the invite code is shown', (
      tester,
    ) async {
      final app = AppState();
      app.signIn(emirId);
      await openScreen(tester, app, const CreateGroupScreen());
      await tester.enterText(find.byType(TextFormField), 'Erasmus');
      await tester.tap(find.text('TRY'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('EUR').last);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Create group'));
      await tester.pumpAndSettle();
      expect(find.text('Erasmus · EUR'), findsOneWidget);
      await tapInDialog(tester, 'Create group');

      final g = app.groups.last;
      expect(g.name, 'Erasmus');
      expect(g.currency, 'EUR');
      expect(g.owner, emirId);
      // The new group opens with the invite sheet on top.
      expect(find.text('Copy invite code'), findsOneWidget);
      expect(find.text(g.code), findsOneWidget);
    });

    testWidgets('Cancel in the dialog does not create a group', (tester) async {
      final app = AppState();
      app.signIn(emirId);
      final before = app.groups.length;
      await openScreen(tester, app, const CreateGroupScreen());
      await tester.enterText(find.byType(TextFormField), 'Erasmus');
      await tester.tap(find.widgetWithText(FilledButton, 'Create group'));
      await tester.pumpAndSettle();
      await tapInDialog(tester, 'Cancel');
      expect(app.groups.length, before);
      expect(find.byType(CreateGroupScreen), findsOneWidget);
    });
  });

  group('Join group screen', () {
    testWidgets('unknown code shows an error', (tester) async {
      final app = AppState();
      app.signIn(ayseId, fullName: 'Ayşe Yılmaz');
      await openScreen(tester, app, const JoinGroupScreen());
      await tester.enterText(find.byType(TextFormField), 'ABCD-2345');
      await tester.tap(find.text('Preview group'));
      await tester.pumpAndSettle();
      expect(
        find.text('Code not found on this preview device.'),
        findsOneWidget,
      );
      expect(find.widgetWithText(FilledButton, 'Join group'), findsNothing);
    });

    testWidgets('empty code error goes away after typing', (tester) async {
      final app = AppState();
      app.signIn(ayseId, fullName: 'Ayşe Yılmaz');
      await openScreen(tester, app, const JoinGroupScreen());
      await tester.tap(find.text('Preview group'));
      await tester.pumpAndSettle();
      expect(find.text('Please fill in this field.'), findsOneWidget);
      await tester.enterText(find.byType(TextFormField), 'TRIP');
      await tester.pumpAndSettle();
      expect(find.text('Please fill in this field.'), findsNothing);
    });

    testWidgets('new user previews TRIP-7K2M and joins the group', (
      tester,
    ) async {
      final app = AppState();
      app.signIn(ayseId, fullName: 'Ayşe Yılmaz');
      await openScreen(tester, app, const JoinGroupScreen());
      await tester.enterText(find.byType(TextFormField), 'TRIP-7K2M');
      await tester.tap(find.text('Preview group'));
      await tester.pumpAndSettle();
      expect(find.text('Weekend trip'), findsOneWidget);
      expect(find.textContaining('3 members · TRY'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, 'Join group'));
      await tester.pumpAndSettle();
      await tapInDialog(tester, 'Join group');

      expect(app.findCode('TRIP-7K2M')!.members.containsKey(ayseId), true);
      // The group page (with the bottom tabs) is open now.
      expect(find.byType(NavigationBar), findsOneWidget);
    });

    testWidgets('a member who enters the code again only opens the group', (
      tester,
    ) async {
      final app = AppState();
      app.signIn(efeId);
      await openScreen(tester, app, const JoinGroupScreen());
      await tester.enterText(find.byType(TextFormField), 'TRIP-7K2M');
      await tester.tap(find.text('Preview group'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Open group'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(app.findCode('TRIP-7K2M')!.members.length, 3);
      expect(find.byType(NavigationBar), findsOneWidget);
    });
  });

  group('Invite sheet', () {
    testWidgets(
      'copy puts the code on the clipboard and says so in the sheet',
      (tester) async {
        // Remember what the app sends to the clipboard.
        String? clipboard;
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          (call) async {
            if (call.method == 'Clipboard.setData') {
              clipboard = (call.arguments as Map)['text'] as String;
            }
            return null;
          },
        );
        addTearDown(
          () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
            SystemChannels.platform,
            null,
          ),
        );

        final app = AppState();
        app.signIn(efeId); // Efe owns Weekend trip
        await openScreen(tester, app, membersPage(app));
        await tester.tap(find.text('Invite members'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Copy invite code'));
        await tester.pumpAndSettle();

        expect(clipboard, 'TRIP-7K2M');
        // The message must be inside the sheet, not hidden behind it.
        expect(
          find.descendant(
            of: find.byType(BottomSheet),
            matching: find.text('Invite code copied.'),
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets('reset shows a new code and the old one stops working', (
      tester,
    ) async {
      final app = AppState();
      app.signIn(efeId);
      final trip = app.findCode('TRIP-7K2M')!;
      await openScreen(tester, app, membersPage(app));
      await tester.tap(find.text('Invite members'));
      await tester.pumpAndSettle();
      expect(find.text('TRIP-7K2M'), findsOneWidget);

      await tester.tap(find.text('Reset invite code'));
      await tester.pumpAndSettle();
      await tapInDialog(tester, 'Reset code');

      expect(find.text('TRIP-7K2M'), findsNothing);
      expect(find.text(trip.code), findsOneWidget);
      expect(
        find.text('New code created. The old code no longer works.'),
        findsOneWidget,
      );
      expect(app.findCode('TRIP-7K2M'), null);
      expect(trip.members.length, 3);
    });
  });

  group('Members view', () {
    testWidgets('owner sees everyone and the invite button', (tester) async {
      final app = AppState();
      app.signIn(efeId);
      await openScreen(tester, app, membersPage(app));
      expect(find.text('3 joined members'), findsOneWidget);
      expect(find.text('Group owner · You'), findsOneWidget);
      expect(find.text('Member'), findsNWidgets(2));
      expect(find.text('Invite members'), findsOneWidget);
    });

    testWidgets('a normal member does not see the invite button', (
      tester,
    ) async {
      final app = AppState();
      app.signIn(yunusId);
      await openScreen(tester, app, membersPage(app));
      expect(find.text('Group owner'), findsOneWidget);
      expect(find.text('Member · You'), findsOneWidget);
      expect(find.text('Invite members'), findsNothing);
    });

    testWidgets('a group with one person says "1 joined member"', (
      tester,
    ) async {
      final app = AppState();
      app.signIn(ayseId, fullName: 'Ayşe Yılmaz');
      final g = app.createGroup('Erasmus', 'EUR');
      await openScreen(
        tester,
        app,
        Scaffold(
          body: ListView(children: [GroupMembersView(group: g)]),
        ),
      );
      expect(find.text('1 joined member'), findsOneWidget);
    });
  });

  group('My groups screen', () {
    testWidgets('a new group says "1 member", not "1 members"', (tester) async {
      final app = AppState();
      app.signIn(ayseId, fullName: 'Ayşe Yılmaz');
      app.createGroup('Erasmus', 'EUR');
      await openScreen(tester, app, const GroupsScreen());
      expect(find.textContaining('1 member · EUR'), findsOneWidget);
      expect(find.textContaining('1 members'), findsNothing);
    });

    testWidgets('tapping the star moves a group to the top', (tester) async {
      final app = AppState();
      app.signIn(efeId);
      await openScreen(tester, app, const GroupsScreen());
      double topOf(String name) => tester.getTopLeft(find.text(name)).dy;
      // Without favorites the list is A-Z.
      expect(topOf('Flatmates') < topOf('Weekend trip'), true);

      final tripCard = find.widgetWithText(Card, 'Weekend trip');
      await tester.tap(
        find.descendant(
          of: tripCard,
          matching: find.byTooltip('Favorite group'),
        ),
      );
      await tester.pumpAndSettle();
      expect(app.isFavorite('trip'), true);
      expect(topOf('Weekend trip') < topOf('Flatmates'), true);
    });
  });
}
