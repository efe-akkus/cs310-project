import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ledger.dart';

const efeId = 'efe.akkus@sabanciuniv.edu';
const emirId = 'emir@example.com';
const yunusId = 'yunus@example.com';

class AppState extends ChangeNotifier {
  final SharedPreferences? preferences;
  String userId = efeId;
  bool signedIn = false;
  bool dark = false;
  String? storageError;
  Map<String, Map<String, String>> profiles = {
    efeId: {'name': 'Efe Çağan Akkuş', 'iban': '', 'photo': ''},
    emirId: {'name': 'Emir Keskin', 'iban': '', 'photo': ''},
    yunusId: {'name': 'Yunus Emre Yolal', 'iban': '', 'photo': ''},
  };
  List<ExpenseGroup> groups = [];
  Set<String> favorites = {};
  AppState([this.preferences]) {
    _seed();
    _restore();
  }
  void _seed() {
    final people = {
      efeId: 'Efe Çağan Akkuş',
      emirId: 'Emir Keskin',
      yunusId: 'Yunus Emre Yolal',
    };
    groups = [
      ExpenseGroup(
        id: 'trip',
        name: 'Weekend trip',
        currency: 'TRY',
        owner: efeId,
        code: 'TRIP-7K2M',
        members: {...people},
        expenses: [
          Expense(
            id: 'dinner',
            creator: efeId,
            description: 'Dinner together',
            payer: efeId,
            cents: 30000,
            date: DateTime(2026, 11, 18),
            participants: people.keys.toList(),
            location: const ExpenseLocation(
              'Karaköy, Istanbul',
              41.024,
              28.977,
            ),
          ),
          Expense(
            id: 'coffee',
            creator: emirId,
            description: 'Coffee stop',
            payer: emirId,
            cents: 15000,
            date: DateTime(2026, 11, 19),
            participants: people.keys.toList(),
          ),
        ],
      ),
      ExpenseGroup(
        id: 'flat',
        name: 'Flatmates',
        currency: 'TRY',
        owner: emirId,
        code: 'FLAT-8P3Q',
        members: {...people},
      ),
    ];
  }

  Map<String, String> get profile => profiles[userId]!;
  String get name => profile['name']!;
  List<ExpenseGroup> get myGroups {
    final result = groups.where((g) => g.members.containsKey(userId)).toList();
    result.sort((a, b) {
      final v = (isFavorite(b.id) ? 1 : 0) - (isFavorite(a.id) ? 1 : 0);
      return v != 0 ? v : a.name.compareTo(b.name);
    });
    return result;
  }

  void _restore() {
    final raw = preferences?.getString('splitmate.v1');
    if (raw == null) return;
    try {
      final j = jsonDecode(raw) as Map<String, dynamic>;
      profiles = (j['profiles'] as Map).map(
        (k, v) => MapEntry(k.toString(), Map<String, String>.from(v)),
      );
      groups = (j['groups'] as List)
          .map((g) => ExpenseGroup.fromJson(g))
          .toList();
      dark = j['dark'] == true;
      favorites = Set<String>.from(j['favorites'] ?? []);
    } catch (_) {
      storageError =
          'Saved preview data could not be loaded. Sample data is shown.';
      _seed();
    }
  }

  Future<void> save() async {
    notifyListeners();
    try {
      final ok = await preferences?.setString(
        'splitmate.v1',
        jsonEncode({
          'profiles': profiles,
          'groups': groups.map((g) => g.toJson()).toList(),
          'dark': dark,
          'favorites': favorites.toList(),
        }),
      );
      if (ok == false) throw StateError('write failed');
      storageError = null;
    } catch (_) {
      storageError =
          'Changes are available this session but could not be saved on this device.';
      notifyListeners();
    }
  }

  void signIn(String email, {String? fullName}) {
    userId = email.trim().toLowerCase();
    profiles.putIfAbsent(
      userId,
      () => {
        'name': fullName ?? email.split('@').first,
        'iban': '',
        'photo': '',
      },
    );
    if (fullName != null) profiles[userId]!['name'] = fullName.trim();
    signedIn = true;
    save();
  }

  void signOut() {
    signedIn = false;
    notifyListeners();
  }

  void setDark(bool value) {
    dark = value;
    save();
  }

  bool isFavorite(String id) => favorites.contains('$userId/$id');
  void toggleFavorite(String id) {
    final key = '$userId/$id';
    favorites.contains(key) ? favorites.remove(key) : favorites.add(key);
    save();
  }

  String inviteCode() =>
      'SM-${List.generate(6, (_) => 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'[Random.secure().nextInt(31)]).join()}';
  ExpenseGroup createGroup(String name, String currency) {
    final g = ExpenseGroup(
      id: newId(),
      name: name.trim(),
      currency: currency,
      owner: userId,
      code: inviteCode(),
      members: {userId: this.name},
    );
    groups.add(g);
    save();
    return g;
  }

  ExpenseGroup? findCode(String code) {
    for (final g in groups) {
      if (g.code == code.trim().toUpperCase()) return g;
    }
    return null;
  }

  void join(ExpenseGroup group) {
    group.members[userId] = name;
    save();
  }

  void updateProfile(String name, String iban, String photo) {
    profile.addAll({
      'name': name.trim(),
      'iban': iban.replaceAll(' ', '').toUpperCase(),
      'photo': photo.trim(),
    });
    for (final g in myGroups) {
      g.members[userId] = name.trim();
    }
    save();
  }

  void upsertExpense(ExpenseGroup group, Expense expense) {
    if (!group.members.containsKey(userId)) {
      throw StateError('Join this group first.');
    }
    if (expense.cents <= 0 ||
        expense.participants.isEmpty ||
        !group.members.containsKey(expense.payer) ||
        expense.participants.any((p) => !group.members.containsKey(p))) {
      throw StateError('Check amount and members.');
    }
    final i = group.expenses.indexWhere((e) => e.id == expense.id);
    if (i >= 0) {
      if (group.expenses[i].creator != userId) {
        throw StateError('Only the creator can edit this expense.');
      }
      group.expenses[i] = expense;
    } else {
      group.expenses.add(expense);
    }
    save();
  }

  void deleteExpense(ExpenseGroup group, Expense expense) {
    if (expense.creator != userId) {
      throw StateError('Only the creator can delete this expense.');
    }
    group.expenses.removeWhere((e) => e.id == expense.id);
    save();
  }

  void settle(ExpenseGroup group, String to, int cents) {
    final outstanding = group.repayments
        .where((r) => r.from == userId && r.to == to)
        .fold<int>(0, (s, r) => s + r.cents);
    if (cents <= 0 || cents > outstanding) {
      throw StateError('Check the remaining repayment.');
    }
    group.settlements.add(Settlement(newId(), userId, to, cents));
    save();
  }
}

class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child})
    : super(notifier: state);
  static AppState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;
}
