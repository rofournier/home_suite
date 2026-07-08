import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/destinations.dart';
import '../../../app/theme_tokens.dart';

/// Écran « en construction » partagé, ouvert au tap d'un objet du hub
/// tant que la mini-app n'existe pas. Thème lofi, soigné.
class UnderConstructionScreen extends StatelessWidget {
  const UnderConstructionScreen({super.key, required this.destination});

  final AppDestination destination;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(destination.icon,
                    size: 72, color: theme.colorScheme.primary),
                const SizedBox(height: AppSpacing.lg),
                Text(destination.label, style: theme.textTheme.headlineMedium),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Bientôt disponible',
                  style: theme.textTheme.bodyLarge
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: AppSpacing.xl),
                FilledButton.tonal(
                  onPressed: () => context.pop(),
                  child: const Text('Retour à la maison'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
