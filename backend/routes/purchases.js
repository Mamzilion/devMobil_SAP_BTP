const router = require('express').Router();
const Purchase = require('../models/Purchase');
const checkRole = require('../middleware/roleCheck');
const multer = require('multer');
const path = require('path');

// --- CONFIGURATION MULTER ---
const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, 'uploads/'); 
    },
    filename: (req, file, cb) => {
        cb(null, Date.now() + path.extname(file.originalname));
    }
});

const upload = multer({ storage: storage });

// --- ROUTES ---

// 1. CRÉER UNE DEMANDE D'ACHAT
router.post('/create', async (req, res) => {
    try {
        const newPurchase = new Purchase(req.body);
        const savedPurchase = await newPurchase.save();
        res.status(201).json(savedPurchase);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// 2. VOIR MES ACHATS (Pour l'Employé)
router.get('/mes-achats/:userId', async (req, res) => {
    try {
        const achats = await Purchase.find({ id_demandeur: req.params.userId }).sort({ createdAt: -1 });
        res.status(200).json(achats);
    } catch (err) {
        res.status(500).json(err);
    }
});

// 3. VOIR TOUS LES ACHATS (Pour Dirigeant/Admin/Vérificateur)
router.get('/tous', checkRole(['DIRIGEANT', 'ADMIN', 'VERIFICATEUR']), async (req, res) => {
    try {
        const achats = await Purchase.find().populate('id_demandeur', 'nom email').sort({ createdAt: -1 });
        res.status(200).json(achats);
    } catch (err) {
        res.status(500).json(err);
    }
});

// 4. METTRE À JOUR LE STATUT (Approuver/Refuser par Dirigeant)
router.put('/update-status/:id', async (req, res) => {
    try {
        const updatedPurchase = await Purchase.findByIdAndUpdate(
            req.params.id, 
            { $set: { statut: req.body.statut } }, 
            { new: true }
        );
        res.status(200).json(updatedPurchase);
    } catch (err) {
        res.status(500).json(err);
    }
});

// 5. UPLOADER LE REÇU (Par l'Employé)
router.put('/upload-receipt/:id', upload.single('photo'), async (req, res) => {
    try {
        const purchase = await Purchase.findByIdAndUpdate(
            req.params.id,
            { 
                photo_recu: req.file.path,
                statut: 'EFFECTUE' 
            },
            { new: true }
        );
        res.status(200).json(purchase);
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
});

// 6. MODIFIER UNE DEMANDE (EN_ATTENTE uniquement)
router.put('/update/:id', async (req, res) => {
    try {
        const achat = await Purchase.findById(req.params.id);
        if (achat.statut !== 'EN_ATTENTE') {
            return res.status(403).json("Modification impossible.");
        }
        const updatedPurchase = await Purchase.findByIdAndUpdate(req.params.id, { $set: req.body }, { new: true });
        res.status(200).json(updatedPurchase);
    } catch (err) {
        res.status(500).json(err);
    }
});

// 7. SUPPRIMER UNE DEMANDE
router.delete('/delete/:id', async (req, res) => {
    try {
        const achat = await Purchase.findById(req.params.id);
        if (achat.statut !== 'EN_ATTENTE') {
            return res.status(403).json("Suppression impossible.");
        }
        await Purchase.findByIdAndDelete(req.params.id);
        res.status(200).json("Supprimée.");
    } catch (err) {
        res.status(500).json(err);
    }
});

// 8. RÉCUPÉRER LES ACHATS À VÉRIFIER
router.get('/a-verifier', async (req, res) => {
    try {
        const purchases = await Purchase.find({ statut: 'EFFECTUE' }).sort({ updatedAt: -1 });
        res.status(200).json(purchases);
    } catch (err) {
        res.status(500).json(err);
    }
});

// 9. REJETER UNE PREUVE (Image floue -> retour à l'employé)
router.put('/rejeter-preuve/:id', async (req, res) => {
    try {
        await Purchase.findByIdAndUpdate(req.params.id, { 
            statut: 'AUTORISE', 
            photo_recu: '' 
        });
        res.json({ message: "Preuve rejetée. L'employé doit renvoyer une photo." });
    } catch (e) {
        res.status(500).send(e.message);
    }
});

// 10. MARQUER COMME FRAUDE
router.put('/fraude/:id', async (req, res) => {
    try {
        await Purchase.findByIdAndUpdate(req.params.id, { statut: 'REFUSE' });
        res.json({ message: "Achat marqué comme frauduleux." });
    } catch (e) {
        res.status(500).send(e.message);
    }
});

module.exports = router;