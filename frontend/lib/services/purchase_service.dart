import 'dart:convert';
import 'package:http/http.dart' as http;

class PurchaseService {
  final String baseUrl = "http://10.207.5.169:5000/api/purchases";

  // --- 1. CRÉER UNE DEMANDE (OU ÉMETTRE REQUÊTE) ---
  Future<bool> createPurchase({
    required String token,
    required String userId,
    required String titre,
    required String montant,
    required String description,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/create"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "libelle": titre,
          "montant_estime": double.tryParse(montant) ?? 0,
          "description": description,
          "id_demandeur": userId, // L'ID de l'employé qui doit agir
          "statut": "EN_ATTENTE",
        }),
      );
      return response.statusCode == 201;
    } catch (e) {
      print("🔥 Erreur création: $e");
      return false;
    }
  }

  // --- 2. RÉCUPÉRER TOUS LES ACHATS (POUR LE DIRIGEANT) ---
  Future<List<dynamic>> getAllPurchasesForAdmin(String token) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/tous"), 
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
          "role": "DIRIGEANT", // Header crucial pour ton middleware actuel
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print("Erreur Serveur: ${response.statusCode} - ${response.body}");
        return [];
      }
    } catch (e) {
      print("🔥 Erreur getAllPurchases: $e");
      return [];
    }
  }

  // --- 3. RÉCUPÉRER MES DEMANDES (POUR L'EMPLOYÉ) ---
  Future<List<dynamic>> getMyPurchases(String token, String userId) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/mes-achats/$userId"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      print("🔥 Erreur récupération: $e");
      return [];
    }
  }

  // --- 4. RÉCUPÉRER LES ACHATS À VÉRIFIER (POUR LE VÉRIFICATEUR) ---
  Future<List<dynamic>> getPurchasesToVerify(String token) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/a-verifier"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      print("🔥 Erreur getPurchasesToVerify: $e");
      return [];
    }
  }

  // --- 5. METTRE À JOUR LE STATUT (AUTORISER, REFUSER, VERIFIER) ---
  Future<bool> updateStatus({
    required String token,
    required String purchaseId,
    required String newStatus,
  }) async {
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/update-status/$purchaseId"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"statut": newStatus}),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("🔥 Erreur updateStatus: $e");
      return false;
    }
  }

  // --- 6. UPLOADER LE REÇU ---
  Future<bool> uploadReceipt({
    required String token,
    required String purchaseId,
    required String filePath,
  }) async {
    try {
      var request = http.MultipartRequest('PUT', Uri.parse("$baseUrl/upload-receipt/$purchaseId"));
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(await http.MultipartFile.fromPath('photo', filePath));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      return response.statusCode == 200;
    } catch (e) {
      print("🔥 Erreur Service Upload: $e");
      return false;
    }
  }

  // --- 7. MODIFIER UNE DEMANDE ---
  Future<bool> updatePurchase({
    required String token,
    required String purchaseId,
    required String titre,
    required String montant,
    required String description,
  }) async {
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/update/$purchaseId"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "libelle": titre,
          "montant_estime": double.tryParse(montant) ?? 0,
          "description": description,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("🔥 Erreur service update: $e");
      return false;
    }
  }

  // --- 8. REJETER UNE PREUVE ---
  Future<bool> rejeterPreuve(String token, String purchaseId) async {
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/rejeter-preuve/$purchaseId"),
        headers: {"Authorization": "Bearer $token"},
      );
      return response.statusCode == 200;
    } catch (e) {
      print("🔥 Erreur Rejet: $e");
      return false;
    }
  }

  // --- 9. MARQUER FRAUDE ---
  Future<bool> marquerFraude(String token, String purchaseId) async {
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/fraude/$purchaseId"),
        headers: {"Authorization": "Bearer $token"},
      );
      return response.statusCode == 200;
    } catch (e) {
      print("🔥 Erreur Fraude: $e");
      return false;
    }
  }
} // Fin de la classe PurchaseService