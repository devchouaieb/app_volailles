const Nest = require('../models/Nest');
const Cage = require('../models/Cage');
const asyncHandler = require('express-async-handler');

// @desc    Get all nests
// @route   GET /api/nests
// @access  Private
const getNests = asyncHandler(async (req, res) => {
  try {
    const nests = await Nest.find({ user: req.user.id })
      .populate({
        path: 'cage',
        populate: [{ path: "male" }, { path: "female", }]
      })

      .sort('-createdAt');

    res.status(200).json({
      success: true,
      data: nests
    });
  } catch (error) {
    console.error('Error getting nests:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la récupération des nids'
    });
  }
});

// @desc    Get single nest
// @route   GET /api/nests/:id
// @access  Private
const getNest = asyncHandler(async (req, res) => {
  try {
    const nest = await Nest.findById(req.params.id).populate({
        path: 'cage',
        populate: [{ path: "male" }, { path: "female", }]
      });

    if (!nest) {
      return res.status(404).json({
        success: false,
        message: 'Nid non trouvé'
      });
    }

    // Check if the nest belongs to the user
    if (nest.user.toString() !== req.user.id) {
      return res.status(401).json({
        success: false,
        message: 'Non autorisé à accéder à ce nid'
      });
    }

    res.status(200).json({
      success: true,
      data: nest
    });
  } catch (error) {
    console.error('Error getting nest:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la récupération du nid'
    });
  }
});

// @desc    Create a nest
// @route   POST /api/nests
// @access  Private
const createNest = asyncHandler(async (req, res) => {
  try {
    const {
      cageNumber,
      numberOfEggs,
      fertilizedEggs,
      exclusionDate,
      extractedEggs,
      firstBirdExitDate,
      birdsExited,
      status,
      notes
    } = req.body;

    // Check if cage exists
    const cage = await Cage.findOne({ cageNumber, user: req.user.id });
    if (!cage) {
      return res.status(404).json({
        success: false,
        message: 'Cage non trouvée'
      });
    }

    // Create the nest
    const nest = await Nest.create({
      cageNumber,
      numberOfEggs,
      fertilizedEggs,
      exclusionDate,
      extractedEggs,
      firstBirdExitDate,
      birdsExited,
      status,
      notes,
      user: req.user.id,
      cage: cage._id
    });
    const createNest = await Nest.findById(nest._id).populate({
        path: 'cage',
        populate: [{ path: "male" }, { path: "female", }]
      });
    res.status(201).json({
      success: true,
      data: createNest
    });
  } catch (error) {
    console.error('Error creating nest:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la création du nid'
    });
  }
});

// @desc    Update a nest
// @route   PUT /api/nests/:id
// @access  Private
const updateNest = asyncHandler(async (req, res) => {
  try {
    let nest = await Nest.findById(req.params.id);

    if (!nest) {
      return res.status(404).json({
        success: false,
        message: 'Nid non trouvé'
      });
    }

    // Check if the nest belongs to the user
    if (nest.user.toString() !== req.user.id) {
      return res.status(401).json({
        success: false,
        message: 'Non autorisé à modifier ce nid'
      });
    }

    // If cageNumber is being updated, verify the new cage exists
    if (req.body.cageNumber && req.body.cageNumber !== nest.cageNumber) {
      const cage = await Cage.findOne({ cageNumber: req.body.cageNumber, user: req.user.id });
      if (!cage) {
        return res.status(404).json({
          success: false,
          message: 'Nouvelle cage non trouvée'
        });
      }
    }

    nest = await Nest.findByIdAndUpdate(req.params.id, req.body, {
      new: true,
      runValidators: true
    }).populate({
        path: 'cage',
        populate: [{ path: "male" }, { path: "female", }]
      });

    res.status(200).json({
      success: true,
      data: nest
    });
  } catch (error) {
    console.error('Error updating nest:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la mise à jour du nid'
    });
  }
});

// @desc    Delete a nest
// @route   DELETE /api/nests/:id
// @access  Private
const deleteNest = asyncHandler(async (req, res) => {
  try {
    const nest = await Nest.findById(req.params.id);

    if (!nest) {
      return res.status(404).json({
        success: false,
        message: 'Nid non trouvé'
      });
    }

    // Check if the nest belongs to the user
    if (nest.user.toString() !== req.user.id) {
      return res.status(401).json({
        success: false,
        message: 'Non autorisé à supprimer ce nid'
      });
    }

    await Nest.deleteOne({ _id: req.params.id });

    res.status(200).json({
      success: true,
      data: {}
    });
  } catch (error) {
    console.error('Error deleting nest:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la suppression du nid'
    });
  }
});

module.exports = {
  getNests,
  getNest,
  createNest,
  updateNest,
  deleteNest
}; 