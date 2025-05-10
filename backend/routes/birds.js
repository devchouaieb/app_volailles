const express = require('express');
const router = express.Router();
const { protect } = require('../middleware/auth');
const {
  getBirds,
  createBird,
  updateBird,
  deleteBird,
  sellBird,
  getSelledBirds,
  getBirdsForSale,
  getBirdsNotSold,
  markBirdForSale
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

// Route pour marquer un oiseau en vente
router.put('/:id/mark-for-sale', markBirdForSale);

// Route pour obtenir les oiseaux vendus
router.get('/sold', getSelledBirds);

// Route pour obtenir les oiseaux en vente
router.get('/for-sale', getBirdsForSale);

// Route pour obtenir les oiseaux disponibles (non vendus)
router.get('/available', getBirdsNotSold);

module.exports = router; 