import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/auth_providers.dart';
import '../domain/household.dart';

/// Maison courante, issue de la session authentifiée. Un repli solo garde
/// l'app cohérente si un écran l'observe avant que la session soit résolue
/// (le gate empêche normalement d'atteindre le hub sans session).
const _fallbackHousehold = Household(
  id: 'local-household',
  name: 'Ma maison',
  members: [Member(id: 'me', displayName: 'Moi')],
);

final householdProvider = Provider<Household>((ref) {
  final session = ref.watch(sessionControllerProvider).asData?.value;
  return session?.household ?? _fallbackHousehold;
});

/// Le membre courant (celui qui édite) = l'utilisateur authentifié dans la
/// liste des membres de la maison.
final currentMemberProvider = Provider<Member>((ref) {
  final session = ref.watch(sessionControllerProvider).asData?.value;
  final household = ref.watch(householdProvider);
  final meId = session?.user.id;
  return household.members.firstWhere(
    (m) => m.id == meId,
    orElse: () => household.members.first,
  );
});
