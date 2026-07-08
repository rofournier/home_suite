import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme_tokens.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../house/domain/house_version.dart';
import '../../house/presentation/house_providers.dart';

/// Réglages : identité, code d'invitation de la maison (à partager pour
/// rejoindre le foyer) et déconnexion.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionControllerProvider).asData?.value;
    return Scaffold(
      appBar: AppBar(title: const Text('Réglages')),
      body: session == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                _Tile(
                  icon: Icons.person_outline,
                  title: session.user.displayName,
                  subtitle: session.user.email,
                ),
                _Tile(
                  icon: Icons.home_outlined,
                  title: session.household.name,
                  subtitle: '${session.household.members.length} membre(s)',
                ),
                if (session.household.joinCode != null)
                  _JoinCode(code: session.household.joinCode!),
                const SizedBox(height: AppSpacing.lg),
                const _SectionTitle('Skin de la maison'),
                const _Hint('Personnel — visible seulement par toi.'),
                const SizedBox(height: AppSpacing.sm),
                const _HouseSkinPicker(),
                const SizedBox(height: AppSpacing.lg),
                FilledButton.tonalIcon(
                  onPressed: () =>
                      ref.read(sessionControllerProvider.notifier).logout(),
                  icon: const Icon(Icons.logout),
                  label: const Text('Se déconnecter'),
                ),
              ],
            ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.icon, required this.title, required this.subtitle});

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
      );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(
        text,
        style: Theme.of(context).textTheme.titleMedium,
      );
}

class _Hint extends StatelessWidget {
  const _Hint(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(
        text,
        style: Theme.of(context)
            .textTheme
            .bodySmall
            ?.copyWith(color: AppColors.inkSoft),
      );
}

/// Choix du skin de maison : aperçus tappables. Le choix est appliqué et
/// persisté localement ([houseVersionProvider]).
class _HouseSkinPicker extends ConsumerWidget {
  const _HouseSkinPicker();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(houseVersionProvider);
    return SizedBox(
      height: 148,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: HouseVersion.values.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (context, index) {
          final version = HouseVersion.values[index];
          return _SkinCard(
            version: version,
            selected: version == selected,
            onTap: () =>
                ref.read(houseVersionProvider.notifier).select(version),
          );
        },
      ),
    );
  }
}

class _SkinCard extends StatelessWidget {
  const _SkinCard({
    required this.version,
    required this.selected,
    required this.onTap,
  });

  final HouseVersion version;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final border = selected ? AppColors.terracotta : AppColors.sand;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.card),
      child: SizedBox(
        width: 120,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadii.card),
                  border: Border.all(color: border, width: selected ? 3 : 1.5),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadii.card - 3),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        version.asset,
                        fit: BoxFit.cover,
                        alignment: Alignment.bottomCenter,
                        cacheWidth: 300,
                        errorBuilder: (_, _, _) =>
                            const ColoredBox(color: AppColors.sand),
                      ),
                      if (selected)
                        const Positioned(
                          top: 6,
                          right: 6,
                          child: Icon(Icons.check_circle_rounded,
                              color: AppColors.terracotta, size: 22),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              version.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Code d'invitation copiable : les autres membres l'entrent à l'inscription.
class _JoinCode extends StatelessWidget {
  const _JoinCode({required this.code});

  final String code;

  @override
  Widget build(BuildContext context) => ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.qr_code_2_outlined),
        title: Text('Code de la maison : $code'),
        subtitle: const Text('À partager pour rejoindre le foyer'),
        trailing: IconButton(
          icon: const Icon(Icons.copy_outlined),
          tooltip: 'Copier',
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: code));
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Code copié')),
              );
            }
          },
        ),
      );
}
