const express = require('express');
const router = express.Router();
const { protect } = require('../middleware/auth');
const {
  getBird,
  getBirds,
  createBird,
  updateBird,
  deleteBird,
  sellBird,
  getSelledBirds,
  getBirdsForSale,
  getBirdsNotSold,
  markBirdForSale,
  purchaseBird,
  getTotalSold
} = require('../controllers/birdController');

// All routes are protected and require authentication
router.use(protect);

// Routes pour les oiseaux
router.route('/')
  .get(getBirds)
  .post(createBird);
  // Route pour vendre un oiseau
router.put('/:id/sell', sellBird);

// Route pour marquer un oiseau en vente
router.put('/:id/mark-for-sale', markBirdForSale);

// Route pour acherter un oiseau
router.put('/:id/purchase',purchaseBird);

// Route pour obtenir les oiseaux vendus
router.get('/sold', getSelledBirds);

// Route pour obtenir les oiseaux en vente
router.get('/for-sale', getBirdsForSale);

// Route pour obtenir les oiseaux disponibles (non vendus)
router.get('/available', getBirdsNotSold);

router.get('/totalSold',getTotalSold);


router.route('/:id')
  .get(getBird)
  .put(updateBird)
  .delete(deleteBird);



module.exports = router; 