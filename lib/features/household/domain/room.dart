/// Pièces de la maison (fixes en V1 — celles du foyer).
enum Room {
  cuisine('Cuisine'),
  salon('Salon'),
  chambreSuleyman('Chambre Suleyman'),
  chambreParents('Chambre parents'),
  salleDeBains('Salle de bains / WC'),
  balcon('Balcon'),
  couloir('Couloir');

  const Room(this.label);

  final String label;
}
