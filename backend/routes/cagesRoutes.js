const express = require('express');
const router = express.Router();
const { getCages, createCage, updateCage, deleteCage } = require('../controllers/cageController');
const { protect } = require('../middleware/auth');

// Apply auth middleware to all routes
router.use(protect);

// Routes
router.get('/', getCages);
router.post('/', createCage);
router.route('/:id')
.put(updateCage)
.delete(deleteCage);

module.exports = router; 