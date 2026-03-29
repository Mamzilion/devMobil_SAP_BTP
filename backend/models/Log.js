const express = require('express');
const router = express.Router();
const Log = require('../models/Log');
const checkRole = require('../middleware/roleCheck');

// Récupérer tous les logs (Admin seulement)
router.get('/', checkRole(['ADMIN']), async (req, res) => {
    try {
        const logs = await Log.find().sort({ date: -1 }).limit(100);
        res.status(200).json(logs);
    } catch (err) {
        res.status(500).json(err);
    }
});

module.exports = router;