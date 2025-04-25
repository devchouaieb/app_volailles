const express = require('express');
const router = express.Router();
const { protect } = require('../middleware/auth');
const {
  getBirds,
  createBird,
  updateBird,
  deleteBird,
  sellBird,
  getSelledBirds
} = require('../controllers/birdController');

// All routes are protected and require authentication
router.use(protect);

// Routes pour les oiseaux
router.route('/')
  .get(getBirds)
  .post(createBird);

router.route('/:id')
  .put(updateBird)
  .delete(deleteBird);

// Route pour vendre un oiseau
router.put('/:id/sell', sellBird);

// Route pour obtenir les oiseaux vendus
router.get('/sold', getSelledBirds);

module.exports = router; 