import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cs310_project/state/app_state.dart';
import 'package:cs310_project/theme/app_theme.dart';
import 'package:cs310_project/screens/group_screens.dart';
import 'package:cs310_project/screens/profile_screen.dart';
import 'package:cs310_project/screens/expense_screens.dart';

void main() {
  for (final size in [const Size(320, 568), const Size(430, 932)]) {
    for (final dark in [false, true]) {
      for (final route in ['create', 'join', 'group', 'profile', 'expense']) {
        testWidgets(
          '$route fits ${size.width} ${dark ? 'dark' : 'light'} with keyboard',
          (tester) async {
            tester.view.physicalSize = size;
            tester.view.devicePixelRatio = 1;
            addTearDown(tester.view.resetPhysicalSize);
            addTearDown(tester.view.resetDevicePixelRatio);
            addTearDown(tester.view.resetViewInsets);
            final state = AppState();
            final g = state.groups.first;
            final screen = switch (route) {
              'create' => const CreateGroupScreen(),
              'join' => const JoinGroupScreen(),
              'group' => GroupScreen(group: g),
              'profile' => const ProfileScreen(),
              _ => ExpenseForm(group: g),
            };
            await tester.pumpWidget(
              AppScope(
                state: state,
                child: MaterialApp(
                  theme: AppTheme.build(
                    dark ? Brightness.dark : Brightness.light,
                  ),
                  home: screen,
                ),
              ),
            );
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
            if (route == 'group') {
              await tester.tap(find.text('Balances'));
              await tester.pumpAndSettle();
              expect(tester.takeException(), isNull);
              await tester.tap(find.text('Members'));
              await tester.pumpAndSettle();
              expect(tester.takeException(), isNull);
            }
            if (route == 'expense' || route == 'create' || route == 'join') {
              await tester.tap(find.byType(TextFormField).first);
              await tester.pumpAndSettle();
              tester.view.viewInsets = const FakeViewPadding(bottom: 250);
              await tester.pumpAndSettle();
              expect(tester.takeException(), isNull);
            }
          },
        );
      }
    }
  }
}
