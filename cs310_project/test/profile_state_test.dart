import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cs310_project/state/app_state.dart';

void main() {
  test(
    'Profile update persists and changes only the current member across groups',
    () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final app = AppState(preferences);
      app.signIn(efeId);

      final otherProfile = Map<String, String>.from(app.profiles[emirId]!);
      final otherNames = {
        for (final group in app.myGroups) group.id: group.members[emirId],
      };

      app.updateProfile(
        '  Efe Akkuş  ',
        'tr33 0006 1005 1978 6457 8413 26',
        '',
      );
      await app.save();

      // The profile and every group membership must show the same trimmed name.
      expect(app.profile['name'], 'Efe Akkuş');
      expect(app.profile['iban'], 'TR330006100519786457841326');
      expect(app.profile['photo'], isEmpty);
      for (final group in app.myGroups) {
        expect(group.members[efeId], 'Efe Akkuş');
        expect(group.members[emirId], otherNames[group.id]);
      }
      expect(app.profiles[emirId], otherProfile);

      // Reopening the state must preserve the update without affecting others.
      final restored = AppState(preferences);
      restored.signIn(efeId);
      expect(restored.profile, app.profile);
      expect(restored.profiles[emirId], otherProfile);
      for (final group in restored.myGroups) {
        expect(group.members[efeId], 'Efe Akkuş');
        expect(group.members[emirId], otherNames[group.id]);
      }
    },
  );
}
