import 'package:freezed_annotation/freezed_annotation.dart';

import '../../household/domain/household.dart';
import 'auth_user.dart';

part 'session.freezed.dart';
part 'session.g.dart';

/// Session authentifiée : jeton d'accès + utilisateur + sa maison (avec ses
/// membres). Sérialisable = miroir du contrat serveur.
@freezed
abstract class Session with _$Session {
  const factory Session({
    required String token,
    required AuthUser user,
    required Household household,
  }) = _Session;

  factory Session.fromJson(Map<String, dynamic> json) =>
      _$SessionFromJson(json);
}
