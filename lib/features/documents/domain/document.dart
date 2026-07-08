import 'package:freezed_annotation/freezed_annotation.dart';

part 'document.freezed.dart';
part 'document.g.dart';

/// Un document = une photo partagée dans un onglet. Offline-first :
/// `imagePath` = copie locale (peut ne pas exister sur un autre appareil) ;
/// `fileId` = binaire uploadé au serveur (null tant que l'upload n'a pas
/// abouti). L'affichage préfère le local, sinon télécharge via `fileId`.
@freezed
abstract class Document with _$Document {
  const factory Document({
    required String id,
    required String tabId,
    required String title,
    required String imagePath,
    String? fileId,
    required String createdBy,
    required DateTime createdAt,
  }) = _Document;

  factory Document.fromJson(Map<String, dynamic> json) =>
      _$DocumentFromJson(json);
}
