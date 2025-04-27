const express = require('express');
const router = express.Router();
const reseauController = require('../controllers/reseauController');
const { protect } = require('../middleware/auth');

// Apply protect middleware to all routes
router.use(protect);

// Reseau routes
router.post('/', reseauController.createReseau);
router.get('/', reseauController.getAllReseaux);
router.get('/:id', reseauController.getReseauById);
router.put('/:id', reseauController.updateReseau);
router.delete('/:id', reseauController.deleteReseau);

module.exports = router; 