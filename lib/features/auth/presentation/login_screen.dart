import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme_tokens.dart';
import '../domain/auth_repository.dart';
import 'auth_providers.dart';

/// Porte d'entrée : connexion ou inscription (email + mot de passe). En mode
/// inscription, un code de maison optionnel permet de rejoindre un foyer.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _displayName = TextEditingController();
  final _joinCode = TextEditingController();
  bool _isRegister = false;

  @override
  void dispose() {
    for (final c in [_email, _password, _displayName, _joinCode]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final controller = ref.read(sessionControllerProvider.notifier);
    try {
      if (_isRegister) {
        await controller.register(
          email: _email.text.trim(),
          password: _password.text,
          displayName: _displayName.text.trim(),
          joinCode: _joinCode.text.trim(),
        );
      } else {
        await controller.login(_email.text.trim(), _password.text);
      }
    } on AuthException catch (e) {
      if (mounted) _showError(e.message);
    }
  }

  void _showError(String message) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));

  @override
  Widget build(BuildContext context) {
    final loading = ref.watch(sessionControllerProvider).isLoading;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: _form(loading),
            ),
          ),
        ),
      ),
    );
  }

  Widget _form(bool loading) {
    final theme = Theme.of(context);
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Home Sweet Home',
              style: theme.textTheme.headlineMedium,
              textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.sm),
          Text(
            _isRegister
                ? 'Crée ton foyer — ou rejoins-en un avec son code'
                : 'Bon retour à la maison',
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: AppColors.inkSoft),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          if (_isRegister) ...[
            _field(_displayName, 'Prénom', TextInputType.name,
                validator: _required),
            const SizedBox(height: AppSpacing.md),
          ],
          _field(_email, 'Email', TextInputType.emailAddress,
              validator: _emailRule),
          const SizedBox(height: AppSpacing.md),
          _field(_password, 'Mot de passe', TextInputType.text,
              obscure: true, validator: _passwordRule),
          if (_isRegister) ...[
            const SizedBox(height: AppSpacing.md),
            // Rempli → rejoint le foyer du code ; vide → crée un foyer.
            _field(_joinCode, 'Code du foyer à rejoindre (optionnel)',
                TextInputType.text, onChanged: (_) => setState(() {})),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Le code est affiché dans les Réglages du membre qui a créé le foyer.',
              style:
                  theme.textTheme.bodySmall?.copyWith(color: AppColors.inkSoft),
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          _submitButton(loading),
          const SizedBox(height: AppSpacing.sm),
          _toggle(loading),
        ],
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label,
    TextInputType keyboard, {
    bool obscure = false,
    String? Function(String?)? validator,
    ValueChanged<String>? onChanged,
  }) =>
      TextFormField(
        controller: controller,
        keyboardType: keyboard,
        obscureText: obscure,
        autocorrect: false,
        enableSuggestions: !obscure,
        textInputAction: TextInputAction.next,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadii.button),
          ),
        ),
        validator: validator,
      );

  Widget _submitButton(bool loading) => SizedBox(
        height: 52,
        child: FilledButton(
          onPressed: loading ? null : _submit,
          child: loading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.4),
                )
              : Text(_isRegister
                  ? (_joinCode.text.trim().isEmpty
                      ? 'Créer mon foyer'
                      : 'Rejoindre le foyer')
                  : 'Se connecter'),
        ),
      );

  Widget _toggle(bool loading) => TextButton(
        onPressed: loading
            ? null
            : () => setState(() => _isRegister = !_isRegister),
        child: Text(_isRegister
            ? 'J\'ai déjà un compte — me connecter'
            : 'Nouveau ici ? Créer ou rejoindre un foyer'),
      );

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Requis' : null;

  String? _emailRule(String? v) {
    if (v == null || !v.contains('@')) return 'Email invalide';
    return null;
  }

  String? _passwordRule(String? v) {
    if (v == null || v.length < 6) return '6 caractères minimum';
    return null;
  }
}
