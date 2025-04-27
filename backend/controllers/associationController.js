const Association = require('../models/Association');

// Create a new association
exports.createAssociation = async (req, res) => {
    try {

        const association = await Association.create({ 
            ...req.body, 
            user: req.user.id });

        res.status(201).json(association);
    } catch (error) {
        res.status(400).json({ message: error.message });
    }
};

// Get all associations
exports.getAllAssociations = async (req, res) => {
    try {
        const associations = await Association.find({ user: req.user.id });
        res.status(200).json(associations);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// Get a single association by ID
exports.getAssociationById = async (req, res) => {
    try {
        const association = await Association.findById(req.params.id);
        if (!association) {
            return res.status(404).json({ message: 'Association not found' });
        }
        res.json(association);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// Update an association
exports.updateAssociation = async (req, res) => {
    try {
        const association = await Association.findByIdAndUpdate(
            req.params.id,
            req.body,
            { new: true, runValidators: true }
        );
        if (!association) {
            return res.status(404).json({ message: 'Association not found' });
        }
        res.json(association);
    } catch (error) {
        res.status(400).json({ message: error.message });
    }
};

// Delete an association
exports.deleteAssociation = async (req, res) => {
    try {
        const association = await Association.findByIdAndDelete(req.params.id);
        if (!association) {
            return res.status(404).json({ message: 'Association not found' });
        }
        res.json({ id: req.params.id });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
}; 