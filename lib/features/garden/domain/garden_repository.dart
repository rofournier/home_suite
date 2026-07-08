import '../../household/domain/room.dart';
import 'garden.dart';
import 'plant.dart';

/// Accès au jardin d'une maison. Local = source de vérité (offline-first) ;
/// photos uploadées best-effort, état synchronisé en temps réel (LWW).
abstract interface class GardenRepository {
  Stream<Garden> watch();

  /// Crée une plante ; copie/upload la photo si [photoSourcePath] est fourni.
  /// [feedEveryDays] null = pas de suivi d'engrais pour cette plante.
  Future<Plant> addPlant({
    required String name,
    required Room room,
    required int waterEveryDays,
    int? feedEveryDays,
    String note,
    String? photoSourcePath,
  });

  /// Met à jour nom/pièce/fréquence/note ; change la photo si
  /// [photoSourcePath] est fourni (l'ancienne est supprimée du disque).
  Future<void> updatePlant(Plant plant, {String? photoSourcePath});

  Future<void> deletePlant(String plantId);

  /// Arrose une plante ; renvoie son état **précédent** (pour Annuler).
  Future<Plant?> waterPlant(String plantId);

  /// Donne de l'engrais ; renvoie l'état **précédent** (pour Annuler).
  Future<Plant?> feedPlant(String plantId);

  /// Arrose toutes les plantes d'une pièce ; renvoie leurs états précédents.
  Future<List<Plant>> waterRoom(Room room);

  /// Restaure des plantes à leur état précédent (Annuler un arrosage).
  Future<void> restorePlants(List<Plant> previous);

  /// Applique un état reçu (temps réel). Ignoré si plus vieux (LWW).
  Future<void> applyRemote(Garden garden);

  /// Re-publie l'état local (réconciliation à la (re)connexion).
  Future<void> republish();
}
