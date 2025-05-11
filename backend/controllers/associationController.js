const Association = require('../models/Association');

// Get selected association for the current user
exports.getSelectedAssociation = async (req, res) => {
    try {
        const association = await Association.findOne({ user: req.user.id });
        if (!association) {
            return res.status(404).json({ 
                success: false,
                message: 'Aucune association trouvée' 
            });
        }
        res.status(200).json({
            success: true,
            data: association
        });
    } catch (error) {
        res.status(500).json({ 
            success: false,
            message: error.message 
        });
    }
};

// Update year joined
exports.updateYearJoined = async (req, res) => {
    try {
        const { yearJoined } = req.body;
        const association = await Association.findOneAndUpdate(
            { user: req.user.id },
            { registrationYear: yearJoined.toString() },
            { new: true }
        );
        if (!association) {
            return res.status(404).json({ 
                success: false,
                message: 'Association non trouvée' 
            });
        }
        res.status(200).json({
            success: true,
            data: association
        });
    } catch (error) {
        res.status(500).json({ 
            success: false,
            message: error.message 
        });
    }
};

// Create a new association
exports.createAssociation = async (req, res) => {
    try {
        const association = await Association.create({ 
            ...req.body, 
            user: req.user.id 
        });
        res.status(201).json({
            success: true,
            data: association
        });
    } catch (error) {
        res.status(400).json({ 
            success: false,
            message: error.message 
        });
    }
};

// Get all associations
exports.getAllAssociations = async (req, res) => {
    try {
        const associations = await Association.find({ user: req.user.id });
        res.status(200).json({
            success: true,
            data: associations
        });
    } catch (error) {
        res.status(500).json({ 
            success: false,
            message: error.message 
        });
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