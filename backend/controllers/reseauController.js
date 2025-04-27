const Reseau = require('../models/Reseau');

// Create a new reseau
exports.createReseau = async (req, res) => {
    try {
        const reseau = new Reseau({
            ...req.body,
            user: req.user._id // Link to the authenticated user
        });
        await reseau.save();
        res.status(201).json(reseau);
    } catch (error) {
        res.status(400).json({ message: error.message });
    }
};

// Get all reseaux for the authenticated user
exports.getAllReseaux = async (req, res) => {
    try {
        const reseaux = await Reseau.find({ user: req.user._id });
        res.json(reseaux);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// Get a single reseau by ID
exports.getReseauById = async (req, res) => {
    try {
        const reseau = await Reseau.findOne({ _id: req.params.id, user: req.user._id });
        if (!reseau) {
            return res.status(404).json({ message: 'Reseau not found' });
        }
        res.json(reseau);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// Update a reseau
exports.updateReseau = async (req, res) => {
    try {
        const reseau = await Reseau.findOneAndUpdate(
            { _id: req.params.id, user: req.user._id },
            req.body,
            { new: true, runValidators: true }
        );
        if (!reseau) {
            return res.status(404).json({ message: 'Reseau not found' });
        }
        res.json(reseau);
    } catch (error) {
        res.status(400).json({ message: error.message });
    }
};

// Delete a reseau
exports.deleteReseau = async (req, res) => {
    try {
        const reseau = await Reseau.findOneAndDelete({ _id: req.params.id, user: req.user._id });
        if (!reseau) {
            return res.status(404).json({ message: 'Reseau not found' });
        }
        res.json({ id: req.params.id });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
}; 