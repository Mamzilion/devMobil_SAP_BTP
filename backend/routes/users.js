const express = require('express');
const router = express.Router();
const User = require('../models/User');
const bcrypt = require('bcryptjs');
const checkRole = require('../middleware/roleCheck');

// --- 1. LISTE POUR L'ADMIN (Tous les rôles) ---
// Utilisée par ManageUsersScreen (Flutter) -> GET /api/users/all
router.get('/all', checkRole(['ADMIN']), async (req, res) => {
    try {
        const users = await User.find().select('-mot_de_passe');
        res.status(200).json(users);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// --- 2. LISTE POUR LE DIRIGEANT (Uniquement EMPLOYE) ---
// Utilisée pour émettre une requête -> GET /api/users/
router.get('/', checkRole(['DIRIGEANT', 'ADMIN']), async (req, res) => {
    try {
        const employes = await User.find({ role: 'EMPLOYE' }).select('nom _id');
        res.status(200).json(employes);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// --- 3. CRÉATION (Register) ---
// POST /api/users/register
router.post('/register', async (req, res) => {
    try {
        const { nom, email, mot_de_passe, role } = req.body;
        
        const userExists = await User.findOne({ email });
        if (userExists) return res.status(400).json("Email déjà utilisé.");

        const salt = await bcrypt.genSalt(10);
        const hashedPsw = await bcrypt.hash(mot_de_passe, salt);

        const newUser = new User({ 
            nom, email, mot_de_passe: hashedPsw, role 
        });

        await newUser.save();
        res.status(201).json(newUser);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// --- 4. MODIFICATION ---
// PUT /api/users/update/:id
router.put('/update/:id', checkRole(['ADMIN']), async (req, res) => {
    try {
        const updatedUser = await User.findByIdAndUpdate(
            req.params.id, 
            { $set: req.body }, 
            { new: true }
        ).select('-mot_de_passe');
        res.status(200).json(updatedUser);
    } catch (err) {
        res.status(500).json(err);
    }
});

// --- 5. SUPPRESSION ---
// DELETE /api/users/:id
router.delete('/:id', checkRole(['ADMIN']), async (req, res) => {
    try {
        await User.findByIdAndDelete(req.params.id);
        res.status(200).json("Utilisateur supprimé");
    } catch (err) {
        res.status(500).json(err);
    }
});

module.exports = router;