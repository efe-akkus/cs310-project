import 'package:flutter/material.dart';
import '../models/ledger.dart';
import '../theme/app_theme.dart';

void toast(BuildContext context, String text) =>
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
Future<bool> confirm(
  BuildContext context,
  String title,
  String body, {
  String action = 'Confirm',
  bool destructive = false,
}) async =>
    await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: destructive
                ? FilledButton.styleFrom(
                    backgroundColor: Theme.of(c).colorScheme.error,
                    foregroundColor: Theme.of(c).colorScheme.onError,
                  )
                : null,
            onPressed: () => Navigator.pop(c, true),
            child: Text(action),
          ),
        ],
      ),
    ) ??
    false;
Future<T?> openSheet<T>(BuildContext context, Widget child) =>
    showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => child,
    );

class PageBody extends StatelessWidget {
  final List<Widget> children;
  const PageBody({super.key, required this.children});
  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 680),
      child: ListView(padding: Space.content, children: children),
    ),
  );
}

class SheetBody extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const SheetBody({super.key, required this.title, required this.children});
  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: BoxConstraints(
      maxHeight: MediaQuery.sizeOf(context).height * .88,
    ),
    child: SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        24 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              IconButton(
                tooltip: 'Close',
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    ),
  );
}

class PrimaryAction extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  const PrimaryAction(this.label, {super.key, this.onPressed, this.icon});
  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: icon == null
        ? FilledButton(onPressed: onPressed, child: Text(label))
        : FilledButton.icon(
            onPressed: onPressed,
            icon: Icon(icon),
            label: Text(label),
          ),
  );
}

class SectionLabel extends StatelessWidget {
  final String label;
  const SectionLabel(this.label, {super.key});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 20, bottom: 12),
    child: Text(
      label,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
    ),
  );
}

class EmptyState extends StatelessWidget {
  final String title, subtitle;
  const EmptyState(this.title, this.subtitle, {super.key});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 24),
    child: Column(
      children: [
        Image.asset(
          'assets/images/shared_receipt.png',
          height: 110,
          semanticLabel: 'A shared receipt',
        ),
        const SizedBox(height: 16),
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(subtitle, textAlign: TextAlign.center),
      ],
    ),
  );
}

class Avatar extends StatelessWidget {
  final String name, url;
  final double radius;
  const Avatar(this.name, {super.key, this.url = '', this.radius = 24});
  @override
  Widget build(BuildContext context) {
    final fallback = CircleAvatar(radius: radius, child: Text(initials(name)));
    if (url.isEmpty) return fallback;
    return ClipOval(
      child: Image.network(
        url,
        width: radius * 2,
        height: radius * 2,
        fit: BoxFit.cover,
        errorBuilder: (_, error, stack) => fallback,
        loadingBuilder: (_, child, progress) =>
            progress == null ? child : fallback,
      ),
    );
  }
}

String? requiredText(String? value) =>
    value == null || value.trim().isEmpty ? 'Please fill in this field.' : null;
String? emailError(String? value) =>
    RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value?.trim() ?? '')
    ? null
    : 'Enter a valid email address.';
String? amountError(String? value) => (parseMoney(value ?? '') ?? 0) > 0
    ? null
    : 'Enter an amount greater than zero (up to 2 decimals).';
String? ibanError(String? raw) {
  final v = (raw ?? '').replaceAll(' ', '').toUpperCase();
  if (v.isEmpty) return null;
  if (!RegExp(r'^[A-Z]{2}\d{2}[A-Z0-9]{11,30}$').hasMatch(v)) {
    return 'Enter a valid IBAN, or leave it blank.';
  }
  final lengths = {
    'TR': 26,
    'DE': 22,
    'GB': 22,
    'FR': 27,
    'NL': 18,
    'ES': 24,
    'IT': 27,
  };
  if (lengths.containsKey(v.substring(0, 2)) &&
      lengths[v.substring(0, 2)] != v.length) {
    return 'Check the IBAN length.';
  }
  final rotated = v.substring(4) + v.substring(0, 4);
  int remainder = 0;
  for (final char in rotated.codeUnits) {
    final digits = char >= 65
        ? (char - 55).toString()
        : String.fromCharCode(char);
    for (final digit in digits.codeUnits) {
      remainder = (remainder * 10 + digit - 48) % 97;
    }
  }
  return remainder == 1 ? null : 'The IBAN checksum is invalid.';
}
