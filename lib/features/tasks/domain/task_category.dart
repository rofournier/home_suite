/// Catégories de tâches ménagères (fixes en V1). Représentées par un **emoji**
/// (choix produit : plus compact et plus joyeux que des icônes — exception
/// assumée à la règle « icônes vectorielles »). Les 8 premières existaient
/// avant l'extension : ne pas renommer (compat JSON des pins déjà posés).
enum TaskCategory {
  vaisselle('Vaisselle', '🍽️'),
  litiere('Litière', '🐱'),
  aspi('Aspirateur', '🧹'),
  poussiere('Poussière', '✨'),
  chaussettes('Chaussettes', '🧦'),
  fourmis('Fourmis', '🐜'),
  linge('Linge', '🧺'),
  autre('Autre', '📌'),
  poubelle('Poubelle', '🗑️'),
  vitres('Vitres', '🪟'),
  plantes('Plantes', '🪴'),
  nettoyage('Nettoyage', '🧽');

  const TaskCategory(this.label, this.emoji);

  final String label;
  final String emoji;
}
