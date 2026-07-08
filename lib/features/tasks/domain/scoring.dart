/// Barème du leaderboard : logique pure, testée.
///
/// Terminer une tâche rapporte sa sévérité en points (l'urgent paie plus).
int pointsForSeverity(int severity) => severity.clamp(1, 3);

/// Titre affiché sur le leaderboard selon le total de points.
String titleForPoints(int points) => switch (points) {
      < 10 => 'Apprenti balai',
      < 25 => 'Fée du logis',
      < 50 => 'Chef de chantier',
      _ => 'Légende du foyer',
    };
