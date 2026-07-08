import 'package:freezed_annotation/freezed_annotation.dart';

part 'household.freezed.dart';
part 'household.g.dart';

/// Une maison partagée par plusieurs membres. Modélisé dès la V1 (même en
/// solo) pour rendre le multi-user naturel. Sérialisable = futur DTO serveur.
@freezed
abstract class Household with _$Household {
  const factory Household({
    required String id,
    required String name,
    @Default(<Member>[]) List<Member> members,
    // Code d'invitation (fourni par le serveur ; absent en repli solo local).
    String? joinCode,
  }) = _Household;

  factory Household.fromJson(Map<String, dynamic> json) =>
      _$HouseholdFromJson(json);
}

@freezed
abstract class Member with _$Member {
  const factory Member({
    required String id,
    required String displayName,
    String? avatarUrl,
  }) = _Member;

  factory Member.fromJson(Map<String, dynamic> json) => _$MemberFromJson(json);
}
