const express = require('express');
const router = express.Router();
const { getSensorData, insertTestData } = require('../controllers/sensorController');
const { protect } = require('../middleware/auth');

// Apply auth middleware to all routes
router.use(protect);

// Routes
router.get('/', getSensorData);
router.post('/test', insertTestData);

module.exports = router; 