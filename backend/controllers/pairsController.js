const Bird = require('../models/bird');
const asyncHandler = require('express-async-handler');

// @desc    Get all pairs
// @route   GET /api/pairs
// @access  Private
const getPairs = asyncHandler(async (req, res) => {
  try {
    // Get all birds that are not sold
    const birds = await Bird.find({ 
      user: req.user.id,
      isSold: false 
    });

    // Group birds by species and gender
    const pairs = {};
    birds.forEach(bird => {
      if (!pairs[bird.species]) {
        pairs[bird.species] = {
          males: [],
          females: []
        };
      }
      
      if (bird.gender.toLowerCase() === 'male') {
        pairs[bird.species].males.push(bird);
      } else if (bird.gender.toLowerCase() === 'female') {
        pairs[bird.species].females.push(bird);
      }
    });

    res.status(200).json({
      success: true,
      data: pairs
    });
  } catch (error) {
    console.error('Error getting pairs:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la récupération des paires'
    });
  }
});

// @desc    Create a pair
// @route   POST /api/pairs
// @access  Private
const createPair = asyncHandler(async (req, res) => {
  try {
    const { maleId, femaleId, species, notes } = req.body;

    // Verify both birds exist and belong to the user
    const male = await Bird.findOne({ _id: maleId, user: req.user.id });
    const female = await Bird.findOne({ _id: femaleId, user: req.user.id });

    if (!male || !female) {
      return res.status(404).json({
        success: false,
        message: 'Un ou plusieurs oiseaux non trouvés'
      });
    }

    // Create the pair
    const pair = {
      male: male,
      female: female,
      species: species,
      notes: notes,
      status: 'active',
      createdAt: new Date().toISOString()
    };

    res.status(201).json({
      success: true,
      data: pair
    });
  } catch (error) {
    console.error('Error creating pair:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la création de la paire'
    });
  }
});

// @desc    Delete a pair
// @route   DELETE /api/pairs/:id
// @access  Private
const deletePair = asyncHandler(async (req, res) => {
  try {
    // Since we don't store pairs in the database, we just return success
    res.status(200).json({
      success: true,
      data: { id: req.params.id }
    });
  } catch (error) {
    console.error('Error deleting pair:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la suppression de la paire'
    });
  }
});

module.exports = {
  getPairs,
  createPair,
  deletePair
}; 