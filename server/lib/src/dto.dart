import 'db.dart';

/// Projections DB → JSON d'API. Le contrat correspond aux modèles freezed de
/// l'app (Member, Household) : mêmes clés, l'app les désérialise tel quel.

Map<String, dynamic> userDto(Map<String, Object?> row) => {
      'id': row['id'],
      'email': row['email'],
      'displayName': row['display_name'],
      'householdId': row['household_id'],
    };

Map<String, dynamic> memberDto(Map<String, Object?> row) => {
      'id': row['id'],
      'displayName': row['display_name'],
    };

Map<String, dynamic> householdDto(Map<String, Object?> household, Db db) => {
      'id': household['id'],
      'name': household['name'],
      'joinCode': household['join_code'],
      'members': [
        for (final m in db.membersOf(household['id'] as String)) memberDto(m),
      ],
    };
