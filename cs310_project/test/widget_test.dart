import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cs310_project/main.dart';
import 'package:cs310_project/state/app_state.dart';

void main() {
  testWidgets('Login validates fields and opens the groups screen', (
    tester,
  ) async {
    await tester.pumpWidget(SplitMateApp(state: AppState()));
    await tester.ensureVisible(find.text('Log in').last);
    await tester.tap(find.text('Log in').last);
    await tester.pump();
    expect(find.text('Use at least 8 characters.'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).last, 'preview123');
    await tester.ensureVisible(find.text('Log in').last);
    await tester.tap(find.text('Log in').last);
    await tester.pumpAndSettle();
    expect(find.text('Your groups'), findsOneWidget);
  });
  for (final size in [const Size(320, 568), const Size(430, 932)]) {
    testWidgets('Core forms fit portrait ${size.width}', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(SplitMateApp(state: AppState()));
      await tester.pumpAndSettle();
      expect(tester.takeException(), null);
      await tester.scrollUntilVisible(
        find.text('New here? Create an account'),
        180,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('New here? Create an account'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), null);
      expect(find.text('Full name'), findsOneWidget);
    });
  }
}
