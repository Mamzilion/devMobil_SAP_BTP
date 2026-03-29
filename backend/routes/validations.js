const router = require('express').Router();
const multer = require('multer');
const path = require('path');
const Validation = require('../models/Validation');
const Purchase = require('../models/Purchase');
const checkRole = require('../middleware/roleCheck');

// 1. CONFIGURATION DU STOCKAGE DES IMAGES
const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, 'uploads/'); 
    },
    filename: (req, file, cb) => {
        // Nom unique pour éviter d'écraser des fichiers
        cb(null, Date.now() + path.extname(file.originalname));
    }
});

const upload = multer({ storage: storage });

// 2. ROUTE DE VALIDATION FUSIONNÉE
// Seuls les Dirigeants et Vérificateurs peuvent accéder à cette route
router.post('/valider', checkRole(['DIRIGEANT', 'VERIFICATEUR']), upload.single('image'), async (req, res) => {
    try {
        // Récupération de l'achat concerné
        const achat = await Purchase.findById(req.body.id_achat);
        
        if (!achat) {
            return res.status(404).json({ error: "Achat non trouvé" });
        }

        // --- TA CONTRAINTE DE SÉCURITÉ ---
        // Vérifie si la personne qui valide est la même que celle qui a demandé l'achat
        if (achat.id_demandeur.toString() === req.body.id_acteur.toString()) {
            return res.status(403).json({
                error: "Sécurité : Un utilisateur ne peut pas vérifier sa propre demande d'achat !"
            });
        }

        // Création de l'entrée de validation
        const nouvelleValidation = new Validation({
            id_achat: req.body.id_achat,
            id_acteur: req.body.id_acteur,
            statut_actuel: req.body.statut_actuel,
            image_preuve_url: req.file ? req.file.path : "" // Chemin du fichier si présent
        });

        // MISE À JOUR DU STATUT DE L'ACHAT
        // On synchronise l'état dans la collection 'purchases'
        achat.statut = req.body.statut_actuel; 
        await achat.save();

        // Sauvegarde de la validation
        const validationSauvegardee = await nouvelleValidation.save();
        
        res.status(200).json({
            message: "Validation enregistrée et statut d'achat mis à jour !",
            data: validationSauvegardee
        });

    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

module.exports = router;