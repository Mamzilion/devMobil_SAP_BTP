const express = require('express');
const router = express.Router();
const User = require('../models/User');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const checkRole = require('../middleware/roleCheck');

// 1. INSCRIPTION (Register)
router.post('/register', async (req, res) => {
    try {
        const { nom, email, mot_de_passe, role } = req.body;
        
        // Vérifier si l'utilisateur existe déjà
        const userExists = await User.findOne({ email });
        if (userExists) return res.status(400).json("Cet email est déjà utilisé.");

        // Cryptage du mot de passe
        const salt = await bcrypt.genSalt(10);
        const hashedPsw = await bcrypt.hash(mot_de_passe, salt);

        const newUser = new User({ 
            nom, 
            email, 
            mot_de_passe: hashedPsw, 
            role: role || 'EMPLOYE' // Par défaut EMPLOYE si non précisé
        });

        await newUser.save();
        res.status(201).json({ message: "Utilisateur créé avec succès !" });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// 2. CONNEXION (Login)
router.post('/login', async (req, res) => {
    try {
        const user = await User.findOne({ email: req.body.email });
        if (!user) return res.status(404).json("Utilisateur non trouvé");

        const validPsw = await bcrypt.compare(req.body.mot_de_passe, user.mot_de_passe);
        if (!validPsw) return res.status(400).json("Mot de passe incorrect");

        // Création du Token JWT (Contient ID et Rôle)
        const token = jwt.sign(
            { id: user._id, role: user.role }, 
            process.env.JWT_SECRET || 'MON_CODE_SECRET_SECRET',
            { expiresIn: '24h' }
        );

        // On renvoie le token et les infos de l'utilisateur (sans le mot de passe)
        const { mot_de_passe, ...autresInfos } = user._doc;
        res.status(200).json({ token, user: autresInfos });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// 3. LISTER LES UTILISATEURS (Admin uniquement)
// Cette route permet à l'Admin de superviser les comptes comme demandé
router.get('/users', checkRole(['ADMIN']), async (req, res) => {
    try {
        const users = await User.find().select('-mot_de_passe'); // On cache les mots de passe
        res.status(200).json(users);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

module.exports = router;