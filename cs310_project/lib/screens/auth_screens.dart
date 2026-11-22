import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';

class AuthScreen extends StatefulWidget {
  final bool register;
  const AuthScreen({super.key, this.register = false});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final form = GlobalKey<FormState>();
  final name = TextEditingController();
  final email = TextEditingController(text: efeId);
  final password = TextEditingController();
  bool hidden = true;
  @override
  void dispose() {
    name.dispose();
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (!form.currentState!.validate()) return;
    if (widget.register &&
        !await confirm(
          context,
          'Create preview account?',
          'Continue as ${name.text.trim()}? Your data stays on this device.',
          action: 'Create account',
        )) {
      return;
    }
    if (!mounted) return;
    AppScope.of(
      context,
    ).signIn(email.text, fullName: widget.register ? name.text : null);
    if (widget.register) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: widget.register
        ? AppBar(title: const Text('Create account'))
        : null,
    body: SafeArea(
      child: PageBody(
        children: [
          Image.asset('assets/images/shared_receipt.png', height: 135),
          const SizedBox(height: 24),
          Text(
            widget.register ? 'Make sharing simpler.' : 'Welcome back.',
            style: Theme.of(
              context,
            ).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            widget.register
                ? 'A name, an email, and you’re ready.'
                : 'Your people. Your expenses. All together.',
          ),
          const SizedBox(height: 28),
          Form(
            key: form,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (widget.register) ...[
                  TextFormField(
                    controller: name,
                    decoration: const InputDecoration(labelText: 'Full name'),
                    textCapitalization: TextCapitalization.words,
                    validator: requiredText,
                  ),
                  const SizedBox(height: 16),
                ],
                TextFormField(
                  controller: email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email'),
                  autocorrect: false,
                  validator: emailError,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: password,
                  obscureText: hidden,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    suffixIcon: IconButton(
                      tooltip: hidden ? 'Show password' : 'Hide password',
                      icon: Icon(
                        hidden
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () => setState(() => hidden = !hidden),
                    ),
                  ),
                  validator: (v) => (v?.length ?? 0) >= 8
                      ? null
                      : 'Use at least 8 characters.',
                  onFieldSubmitted: (_) => submit(),
                ),
                const SizedBox(height: 24),
                PrimaryAction(
                  widget.register ? 'Create account' : 'Log in',
                  onPressed: submit,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (!widget.register)
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => const AuthScreen(register: true),
                ),
              ),
              child: const Text('New here? Create an account'),
            ),
          if (widget.register)
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Already registered? Log in'),
            ),
          const SizedBox(height: 24),
          const Text(
            'Course preview • No real authentication yet.\nUse any valid email and an 8-character password. Changes stay on this device.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    ),
  );
}
