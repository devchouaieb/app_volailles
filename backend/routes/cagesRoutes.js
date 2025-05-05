const express = require('express');
const router = express.Router();
const { getCages, createCage, deleteCage } = require('../controllers/cageController');
const { protect } = require('../middleware/auth');

// Apply auth middleware to all routes
router.use(protect);

// Routes
router.get('/', getCages);
router.post('/', createCage);
router.delete('/:id', deleteCage);

module.exports = router; 