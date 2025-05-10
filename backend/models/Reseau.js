const mongoose = require('mongoose');

const reseauSchema = new mongoose.Schema({
    name: {
        type: String,
        required: true,
        trim: true
    },
    matricule: {
        type: String,
        required: true,
        trim: true,
        unique: true
    },
    address: {
        type: String,
        required: true,
        trim: true
    },
    telephone: {
        type: String,
        required: true,
        trim: true
    },
    mail: {
        type: String,
        required: true,
        trim: true,
        lowercase: true
    },
    president: {
        type: String,
        required: true,
        trim: true
    },
    siteWeb: {
        type: String,
        trim: true
    },
    comite: {
        type: String,
        required: true,
        trim: true
    },
    registrationYear: {
        type: String,
        required: true,
        trim: true
    },
    user: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true
    }
}, {
    timestamps: true
});

const Reseau = mongoose.model('Reseau', reseauSchema);

module.exports = Reseau; 