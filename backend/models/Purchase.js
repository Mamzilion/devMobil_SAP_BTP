const mongoose = require('mongoose');

const PurchaseSchema = new mongoose.Schema({
    libelle: { type: String, required: true },
    montant_estime: { type: Number, required: true },
    description: { type: String }, // Optionnel mais utile
    id_demandeur: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    // AJOUT DES CHAMPS MANQUANTS
    statut: { 
        type: String, 
        enum: ['EN_ATTENTE', 'AUTORISE', 'REFUSE', 'VERIFIE', 'EFFECTUE'], 
        default: 'EN_ATTENTE' 
    },
    photo_recu: { type: String, default: '' },
    date_creation: { type: Date, default: Date.now }
}, { timestamps: true }); // Ajoute automatiquement createdAt et updatedAt

module.exports = mongoose.model('Purchase', PurchaseSchema);