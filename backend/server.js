const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const path = require('path');
require('dotenv').config();

// IMPORT DES ROUTES
const authRoute = require('./routes/auth'); // Authentification (Login)
const purchaseRoute = require('./routes/purchases'); // Gestion des achats
const validationRoute = require('./routes/validations'); // Approbations/Vérifications
const userRoute = require('./routes/users'); // LE FICHIER CRUD COMPLET (Register, All, Update, Delete)

const app = express();

// MIDDLEWARES
app.use(cors());
app.use(express.json());

// --- CONFIGURATION DES IMAGES ---
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// CONNEXION MONGODB
mongoose.connect(process.env.MONGO_URI)
  .then(() => console.log("✅ MongoDB est prêt !"))
  .catch(err => console.error("❌ Erreur MongoDB :", err));

// BRANCHEMENT DES ROUTES
app.use('/api/auth', authRoute);
app.use('/api/purchases', purchaseRoute);
app.use('/api/validations', validationRoute);
app.use('/api/users', userRoute); // Centralise tout ce qui concerne les utilisateurs ici

app.get('/', (req, res) => {
  res.send("API Gestion d'Achats - Dossier uploads actif 🚀");
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, '0.0.0.0', () => {
  console.log(`✅ Serveur écoute sur le port ${PORT}`);
  console.log(`🌍 URL API Users : http://10.110.105.169:${PORT}/api/users`);
});