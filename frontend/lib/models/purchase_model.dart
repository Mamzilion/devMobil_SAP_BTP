class PurchaseModel {
  final String id;           // _id de l'achat
  final String libelle;      // ex: "PC Portable Test"
  final double montant;      // montant_estime
  final String idDemandeur;  // ID de l'auteur (pour la règle du Vérificateur)
  final String statut;       // Extrait de statut_actuel (ex: "APPROUVE")
  final String imageProof;   // image_preuve_url
  final String date;         // date_creation

  PurchaseModel({
    required this.id,
    required this.libelle,
    required this.montant,
    required this.idDemandeur,
    required this.statut,
    required this.imageProof,
    required this.date,
  });

  factory PurchaseModel.fromJson(Map<String, dynamic> json) {
    return PurchaseModel(
      id: json['_id'],
      libelle: json['libelle'] ?? "Sans description",
      montant: (json['montant_estime'] ?? 0).toDouble(),
      idDemandeur: json['id_demandeur'] ?? "",
      // Si ton JSON contient l'état imbriqué, on le récupère ici
      statut: json['statut_actuel'] ?? "EN_ATTENTE", 
      imageProof: json['image_preuve_url'] ?? "",
      date: json['date_creation'] ?? "",
    );
  }
}