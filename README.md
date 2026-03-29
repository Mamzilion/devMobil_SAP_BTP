# 🏗️ SAP BTP - Gestion d'Approvisionnement Sécurisée

**Thème :** Digitalisation et sécurisation du flux d'achats dans le secteur du BTP.

Ce projet a été développé dans le cadre de ma formation en **Génie Informatique (Réseaux et Sécurité)** à l'IUT de Ngaoundéré.

---

## 🚀 Fonctionnalités Clés
- **Authentification JWT :** Accès sécurisé avec rôles (Admin, Dirigeant, Vérificateur, Employé).
- **Gestion des Achats :** Création, suivi et validation des demandes en temps réel.
- **Workflow de Validation :** Circuit d'approbation strict pour éviter les fraudes.
- **Interface Premium :** Design Dark & Gold optimisé pour une expérience utilisateur moderne.

## 🛠️ Stack Technique
- **Mobile (Frontend) :** Flutter (Dart) + Provider pour la gestion d'état.
- **Serveur (Backend) :** Node.js + Express.js.
- **Base de données :** MongoDB (NoSQL).
- **Réseau :** API REST sécurisée.

## 📦 Structure du Projet
- `/frontend` : Code source de l'application mobile Flutter.
- `/backend` : API REST, modèles de données et middlewares de sécurité.
- `.vscode` : Configurations de l'environnement de développement.

---

## 🔧 Installation et Lancement
1. **Backend :**
   - Naviguer dans `/backend`.
   - Lancer `npm install` (si node_modules absent).
   - Configurer le fichier `.env` (voir `.env.example`).
   - Lancer le serveur : `node server.js`.

2. **Frontend :**
   - Naviguer dans `/frontend`.
   - Lancer `flutter pub get`.
   - Modifier l'IP du serveur dans `lib/services/config.dart`.
   - Lancer l'app : `flutter run`.

---
*Développé par **Mamzi (Yerima)** - IUT de Ngaoundéré.*
