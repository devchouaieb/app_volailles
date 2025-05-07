const Bird = require('../models/bird');
const Cage = require('../models/Cage');
const asyncHandler = require('express-async-handler');

// @desc    Get all cages
// @route   GET /api/cages
// @access  Private
const getCages = asyncHandler(async (req, res) => {
  try {
    const cages = await Cage.find({ user: req.user.id })
      .populate('male')
      .populate('female')
      .sort('-createdAt');

    res.status(200).json({
      success: true,
      data: cages
    });
  } catch (error) {
    console.error('Error getting cages:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la récupération des cages'
    });
  }
});

// @desc    Create a cage
// @route   POST /api/cages
// @access  Private
const createCage = asyncHandler(async (req, res) => {
  try {
    const { cageNumber, male, female, species, notes } = req.body;
    const maleId = male._id;
    const femaleId = female._id;
    // Verify both birds exist and belong to the user
    console.log(maleId, femaleId);
    const maleBird = await Bird.findOne({ _id: maleId, user: req.user.id });
    const femaleBird = await Bird.findOne({ _id: femaleId, user: req.user.id });
    console.log(maleBird, femaleBird);
    console.log(req.user.id);
    if (!male || !female) {
      return res.status(404).json({
        success: false,
        message: 'Un ou plusieurs oiseaux non trouvés'
      });
    }

    // Check if cage number already exists
    const existingCage = await Cage.findOne({ cageNumber });
    if (existingCage) {
      return res.status(400).json({
        success: false,
        message: 'Ce numéro de cage existe déjà'
      });
    }

    // Create the cage
    const cage = await Cage.create({
      cageNumber,
      male: maleBird,
      female: femaleBird,
      species,
      notes,
      user: req.user.id
    });

    // Populate the cage with bird details
    const populatedCage = await Cage.findById(cage._id)
      .populate('male')
      .populate('female');

    res.status(201).json({
      success: true,
      data: populatedCage
    });
  } catch (error) {
    console.error('Error creating cage:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la création de la cage'
    });
  }
});

// @desc    Delete a cage
// @route   DELETE /api/cages/:id
// @access  Private
const deleteCage = asyncHandler(async (req, res) => {
  try {
    const cage = await Cage.findById(req.params.id);

    if (!cage) {
      return res.status(404).json({
        success: false,
        message: 'Cage non trouvée'
      });
    }

    // Check if the cage belongs to the user
    if (cage.user.toString() !== req.user.id) {
      return res.status(401).json({
        success: false,
        message: 'Non autorisé à supprimer cette cage'
      });
    }

    await Cage.deleteOne({ _id: req.params.id });


    res.status(200).json({
      success: true,
      data: {}
    });
  } catch (error) {
    console.error('Error deleting cage:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la suppression de la cage'
    });
  }
});

module.exports = {
  getCages,
  createCage,
  deleteCage
}; 