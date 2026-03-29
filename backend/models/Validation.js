const mongoose = require('mongoose');

const ValidationSchema = new mongoose.Schema({
    // Lien vers l'achat concerné
    id_achat: { 
        type: mongoose.Schema.Types.ObjectId, 
        ref: 'Purchase', 
        required: true 
    },
    // On limite les choix pour éviter les erreurs de saisie
    statut_actuel: { 
        type: String, 
        required: true,
        enum: ['EN_ATTENTE', 'APPROUVE', 'REJETE'],
        default: 'EN_ATTENTE'
    },
    // Qui a effectué cette action (Admin ou Gestionnaire)
    id_acteur: { 
        type: mongoose.Schema.Types.ObjectId, 
        ref: 'User', 
        required: true 
    },
    // Le chemin du fichier (ex: uploads/17123456.jpg)
    image_preuve_url: { 
        type: String,
        default: "" 
    },
    // Date de l'étape actuelle
    date_etat: { 
        type: Date, 
        default: Date.now 
    }
}, { timestamps: true }); // Ajoute automatiquement createdAt et updatedAt

module.exports = mongoose.model('Validation', ValidationSchema);