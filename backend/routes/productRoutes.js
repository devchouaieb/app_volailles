const express = require('express');
const router = express.Router();
const productController = require('../controllers/productController');
const { protect } = require('../middleware/auth');
router.use(protect);

router.post('/',  productController.createProduct);
router.get('/',  productController.getProducts);
router.get('/total-value',  productController.getTotalProductValue);

module.exports = router;
