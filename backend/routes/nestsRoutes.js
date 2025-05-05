const express = require('express');
const router = express.Router();
const { 
  getNests, 
  getNest, 
  createNest, 
  updateNest, 
  deleteNest 
} = require('../controllers/nestController');
const { protect } = require('../middleware/auth');

// Apply auth middleware to all routes
router.use(protect);

// Routes
router.get('/', getNests);
router.get('/:id', getNest);
router.post('/', createNest);
router.put('/:id', updateNest);
router.delete('/:id', deleteNest);

module.exports = router; 