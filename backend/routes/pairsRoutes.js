const express = require('express');
const router = express.Router();
const { getPairs, createPair, deletePair } = require('../controllers/pairsController');
const { protect } = require('../middleware/auth');

// Apply auth middleware to all routes
router.use(protect);

// Routes
router.get('/', getPairs);
router.post('/', createPair);
router.delete('/:id', deletePair);

module.exports = router; 