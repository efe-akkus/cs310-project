import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/ledger.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';
import 'location_sheet.dart';

class ExpenseForm extends StatefulWidget {
  final ExpenseGroup group;
  final Expense? expense;
  const ExpenseForm({super.key, required this.group, this.expense});
  @override
  State<ExpenseForm> createState() => _ExpenseFormState();
}

class _ExpenseFormState extends State<ExpenseForm> {
  final form = GlobalKey<FormState>();
  late final TextEditingController description, amount;
  late DateTime date;
  late String payer;
  late Set<String> people;
  ExpenseLocation? location;
  String? peopleError;
  @override
  void initState() {
    super.initState();
    final e = widget.expense;
    description = TextEditingController(text: e?.description ?? '');
    amount = TextEditingController(
      text: e == null ? '' : (e.cents / 100).toStringAsFixed(2),
    );
    date = e?.date ?? DateTime.now();
    payer = e?.payer ?? widget.group.owner;
    people = (e?.participants ?? widget.group.members.keys.toList()).toSet();
    location = e?.location;
  }

  @override
  void dispose() {
    description.dispose();
    amount.dispose();
    super.dispose();
  }

  Future<void> save() async {
    final valid = form.currentState!.validate();
    setState(
      () => peopleError = people.isEmpty ? 'Select at least one person.' : null,
    );
    if (!valid || people.isEmpty) return;
    final app = AppScope.of(context);
    final cents = parseMoney(amount.text)!;
    if (!await confirm(
      context,
      widget.expense == null ? 'Save this expense?' : 'Save changes?',
      '${description.text.trim()} · ${money(cents, widget.group.currency)}\nPaid by ${widget.group.members[payer]}\nShared by ${people.length} ${people.length == 1 ? 'person' : 'people'}',
      action: 'Save expense',
    )) {
      return;
    }
    if (!mounted) return;
    try {
      app.upsertExpense(
        widget.group,
        Expense(
          id: widget.expense?.id ?? newId(),
          creator: widget.expense?.creator ?? app.userId,
          description: description.text.trim(),
          payer: payer,
          cents: cents,
          date: date,
          participants: people.toList(),
          location: location,
        ),
      );
      Navigator.pop(context);
      toast(context, 'Expense saved.');
    } on StateError catch (e) {
      toast(context, e.message.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final g = widget.group;
    final cents = parseMoney(amount.text);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.expense == null ? 'Add expense' : 'Edit expense'),
      ),
      body: PageBody(
        children: [
          Form(
            key: form,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: description,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'What was it for?',
                  ),
                  validator: requiredText,
                  maxLength: 70,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: amount,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Amount (${g.currency})',
                  ),
                  validator: amountError,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Date'),
                  subtitle: Text(dateLabel(date)),
                  trailing: const Icon(Icons.calendar_today_outlined),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: date,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) setState(() => date = picked);
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: payer,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Paid by'),
                  items: g.members.entries
                      .map(
                        (m) => DropdownMenuItem(
                          value: m.key,
                          child: Text(m.value, overflow: TextOverflow.ellipsis),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => payer = v!),
                ),
                const SectionLabel('Split equally with'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final m in g.members.entries)
                      FilterChip(
                        label: Text(m.value.split(' ').first),
                        selected: people.contains(m.key),
                        avatar: people.contains(m.key)
                            ? const Icon(Icons.check_circle, size: 20)
                            : const Icon(Icons.circle_outlined, size: 20),
                        showCheckmark: false,
                        onSelected: (value) => setState(() {
                          value ? people.add(m.key) : people.remove(m.key);
                          peopleError = null;
                        }),
                      ),
                  ],
                ),
                if (peopleError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      peopleError!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                if (people.isNotEmpty && cents != null && cents > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      'About ${money(cents ~/ people.length, g.currency)} per person. Any remaining cents are distributed consistently.',
                    ),
                  ),
                const SectionLabel('Location · optional'),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.place_outlined),
                    title: Text(location?.label ?? 'Add a place'),
                    subtitle: location == null
                        ? const Text('Pin the place on a map')
                        : Text(
                            '${location!.latitude.toStringAsFixed(4)}, ${location!.longitude.toStringAsFixed(4)}',
                          ),
                    trailing: location == null
                        ? const Icon(Icons.chevron_right)
                        : IconButton(
                            tooltip: 'Remove location',
                            onPressed: () => setState(() => location = null),
                            icon: const Icon(Icons.close),
                          ),
                    onTap: () async {
                      final result = await openSheet<ExpenseLocation>(
                        context,
                        LocationSheet(initial: location),
                      );
                      if (result != null) setState(() => location = result);
                    },
                  ),
                ),
                const SizedBox(height: 24),
                PrimaryAction('Save expense', onPressed: save),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ExpenseDetails extends StatelessWidget {
  final ExpenseGroup group;
  final Expense expense;
  const ExpenseDetails({super.key, required this.group, required this.expense});
  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final e = expense;
    return SheetBody(
      title: 'Expense details',
      children: [
        Text(
          e.description,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          money(e.cents, group.currency),
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 12),
        Text('${group.members[e.payer]} paid · ${dateLabel(e.date)}'),
        const SectionLabel('Shared equally'),
        for (final share in e.shares.entries)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(group.members[share.key]!),
            trailing: Text(money(share.value, group.currency)),
          ),
        if (e.location != null) ...[
          const SectionLabel('Location'),
          Text(e.location!.label),
          const SizedBox(height: 12),
          LocationMap(location: e.location!),
        ],
        if (e.creator == app.userId) ...[
          const SizedBox(height: 24),
          PrimaryAction(
            'Edit expense',
            onPressed: () {
              final nav = Navigator.of(context);
              nav.pop();
              nav.push(
                MaterialPageRoute<void>(
                  builder: (_) => ExpenseForm(group: group, expense: e),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () async {
              if (!await confirm(
                context,
                'Delete this expense?',
                '${e.description} will be removed and balances recalculated.',
                action: 'Delete expense',
                destructive: true,
              )) {
                return;
              }
              if (!context.mounted) return;
              app.deleteExpense(group, e);
              Navigator.pop(context);
              toast(context, 'Expense deleted.');
            },
            child: const Text('Delete expense'),
          ),
        ] else
          const Padding(
            padding: EdgeInsets.only(top: 16),
            child: Text(
              'Only the person who added this expense can edit or delete it.',
            ),
          ),
      ],
    );
  }
}

class PaymentSheet extends StatefulWidget {
  final ExpenseGroup group;
  const PaymentSheet({super.key, required this.group});
  @override
  State<PaymentSheet> createState() => _PaymentSheetState();
}

class _PaymentSheetState extends State<PaymentSheet> {
  final form = GlobalKey<FormState>();
  final amount = TextEditingController();
  String? to;
  @override
  void dispose() {
    amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final g = widget.group;
    final outgoing = g.repayments.where((r) => r.from == app.userId).toList();
    if (outgoing.isEmpty) {
      return const SheetBody(
        title: 'Record payment',
        children: [Text('You have no outstanding outgoing repayments.')],
      );
    }
    to ??= outgoing.first.to;
    final remaining = outgoing
        .where((r) => r.to == to)
        .fold<int>(0, (s, r) => s + r.cents);
    final iban = app.profiles[to]?['iban'] ?? '';
    return SheetBody(
      title: 'Record payment',
      children: [
        Text('From ${app.name} (you)'),
        const SizedBox(height: 20),
        Form(
          key: form,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                initialValue: to,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'To'),
                items: outgoing
                    .map(
                      (r) => DropdownMenuItem(
                        value: r.to,
                        child: Text(
                          g.members[r.to]!,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => to = v),
              ),
              const SizedBox(height: 16),
              if (iban.isEmpty)
                const ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.info_outline),
                  title: Text('IBAN not added'),
                  subtitle: Text('You can still record a payment.'),
                )
              else
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text('Recipient IBAN'),
                        SelectableText(iban),
                        TextButton.icon(
                          onPressed: () async {
                            await Clipboard.setData(ClipboardData(text: iban));
                            if (context.mounted) toast(context, 'IBAN copied.');
                          },
                          icon: const Icon(Icons.copy),
                          label: const Text('Copy IBAN'),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              TextFormField(
                controller: amount,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: 'Amount (${g.currency})',
                ),
                validator: (v) {
                  final error = amountError(v);
                  if (error != null) return error;
                  return parseMoney(v!)! > remaining
                      ? 'Maximum ${money(remaining, g.currency)}'
                      : null;
                },
              ),
              const SizedBox(height: 12),
              Text('Remaining: ${money(remaining, g.currency)}'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Record money already paid outside SplitMate. This does not transfer money.',
        ),
        const SizedBox(height: 24),
        PrimaryAction(
          'Record payment',
          onPressed: () async {
            if (!form.currentState!.validate()) return;
            final cents = parseMoney(amount.text)!;
            if (!await confirm(
              context,
              'Record this payment?',
              '${money(cents, g.currency)} to ${g.members[to]}',
              action: 'Record payment',
            )) {
              return;
            }
            if (!context.mounted) return;
            try {
              app.settle(g, to!, cents);
              Navigator.pop(context);
              toast(context, 'Payment recorded.');
            } on StateError catch (e) {
              toast(context, e.message.toString());
            }
          },
        ),
      ],
    );
  }
}
