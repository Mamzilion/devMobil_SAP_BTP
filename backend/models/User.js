const mongoose = require('mongoose');

const UserSchema = new mongoose.Schema({
    nom: { type: String, required: true },
    email: { type: String, required: true, unique: true },
    mot_de_passe: { type: String, required: true },
    role: { 
        type: String, 
        enum: ['EMPLOYE', 'VERIFICATEUR', 'DIRIGEANT', 'ADMIN'], 
        required: true 
    }
}, { timestamps: true });

module.exports = mongoose.model('User', UserSchema);