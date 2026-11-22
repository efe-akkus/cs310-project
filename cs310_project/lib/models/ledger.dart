import 'dart:math';

String money(int cents, [String currency = 'TRY']) =>
    '$currency ${(cents / 100).toStringAsFixed(2)}';
int? parseMoney(String text) {
  final value = text.trim().replaceAll(',', '.');
  if (!RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(value)) return null;
  final parts = value.split('.');
  final whole = int.tryParse(parts[0]);
  if (whole == null || whole > 1000000000) return null;
  return whole * 100 +
      (parts.length == 1 ? 0 : int.parse(parts[1].padRight(2, '0')));
}

String newId() =>
    '${DateTime.now().microsecondsSinceEpoch}${Random().nextInt(99999)}';
String initials(String name) => name
    .trim()
    .split(RegExp(r'\s+'))
    .where((s) => s.isNotEmpty)
    .take(2)
    .map((s) => s[0])
    .join()
    .toUpperCase();
String dateLabel(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

class ExpenseLocation {
  final String label;
  final double latitude, longitude;
  const ExpenseLocation(this.label, this.latitude, this.longitude);
  Map<String, dynamic> toJson() => {
    'label': label,
    'lat': latitude,
    'lng': longitude,
  };
  factory ExpenseLocation.fromJson(Map<String, dynamic> j) => ExpenseLocation(
    j['label'],
    (j['lat'] as num).toDouble(),
    (j['lng'] as num).toDouble(),
  );
}

class Expense {
  final String id, creator, description, payer;
  final int cents;
  final DateTime date;
  final List<String> participants;
  final ExpenseLocation? location;
  const Expense({
    required this.id,
    required this.creator,
    required this.description,
    required this.payer,
    required this.cents,
    required this.date,
    required this.participants,
    this.location,
  });
  Map<String, int> get shares {
    if (participants.isEmpty) {
      throw StateError('An expense needs participants.');
    }
    final sorted = [...participants]..sort();
    return {
      for (int i = 0; i < sorted.length; i++)
        sorted[i]: cents ~/ sorted.length + (i < cents % sorted.length ? 1 : 0),
    };
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'creator': creator,
    'description': description,
    'payer': payer,
    'cents': cents,
    'date': date.toIso8601String(),
    'participants': participants,
    'location': location?.toJson(),
  };
  factory Expense.fromJson(Map<String, dynamic> j) => Expense(
    id: j['id'],
    creator: j['creator'],
    description: j['description'],
    payer: j['payer'],
    cents: j['cents'],
    date: DateTime.parse(j['date']),
    participants: List<String>.from(j['participants']),
    location: j['location'] == null
        ? null
        : ExpenseLocation.fromJson(j['location']),
  );
}

class Settlement {
  final String id, from, to;
  final int cents;
  const Settlement(this.id, this.from, this.to, this.cents);
  Map<String, dynamic> toJson() => {
    'id': id,
    'from': from,
    'to': to,
    'cents': cents,
  };
  factory Settlement.fromJson(Map<String, dynamic> j) =>
      Settlement(j['id'], j['from'], j['to'], j['cents']);
}

class Repayment {
  final String from, to;
  final int cents;
  const Repayment(this.from, this.to, this.cents);
}

class ExpenseGroup {
  final String id, name, currency, owner;
  String code;
  final Map<String, String> members;
  final List<Expense> expenses;
  final List<Settlement> settlements;
  ExpenseGroup({
    required this.id,
    required this.name,
    required this.currency,
    required this.owner,
    required this.code,
    required this.members,
    List<Expense>? expenses,
    List<Settlement>? settlements,
  }) : expenses = expenses ?? [],
       settlements = settlements ?? [];
  int get total => expenses.fold(0, (sum, e) => sum + e.cents);
  Map<String, int> get balances {
    final values = {for (final id in members.keys) id: 0};
    for (final expense in expenses) {
      values.update(expense.payer, (v) => v + expense.cents);
      for (final share in expense.shares.entries) {
        values.update(share.key, (v) => v - share.value);
      }
    }
    for (final p in settlements) {
      values.update(p.from, (v) => v + p.cents);
      values.update(p.to, (v) => v - p.cents);
    }
    return values;
  }

  List<Repayment> get repayments {
    final b = balances;
    final debtors = b.keys.where((k) => b[k]! < 0).toList()..sort();
    final creditors = b.keys.where((k) => b[k]! > 0).toList()..sort();
    final result = <Repayment>[];
    int d = 0, c = 0;
    while (d < debtors.length && c < creditors.length) {
      final from = debtors[d], to = creditors[c];
      final amount = min(-b[from]!, b[to]!);
      result.add(Repayment(from, to, amount));
      b[from] = b[from]! + amount;
      b[to] = b[to]! - amount;
      if (b[from] == 0) d++;
      if (b[to] == 0) c++;
    }
    return result;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'currency': currency,
    'owner': owner,
    'code': code,
    'members': members,
    'expenses': expenses.map((e) => e.toJson()).toList(),
    'settlements': settlements.map((p) => p.toJson()).toList(),
  };
  factory ExpenseGroup.fromJson(Map<String, dynamic> j) => ExpenseGroup(
    id: j['id'],
    name: j['name'],
    currency: j['currency'],
    owner: j['owner'],
    code: j['code'],
    members: Map<String, String>.from(j['members']),
    expenses: (j['expenses'] as List).map((e) => Expense.fromJson(e)).toList(),
    settlements: (j['settlements'] as List)
        .map((e) => Settlement.fromJson(e))
        .toList(),
  );
}
