const express = require('express');
const router = express.Router();
const { protect } = require('../middleware/auth');
const associationController = require('../controllers/associationController');
router.use(protect);
// Association routes
router.post('/', associationController.createAssociation);
router.get('/', associationController.getAllAssociations);
router.get('/:id', associationController.getAssociationById);
router.put('/:id', associationController.updateAssociation);
router.delete('/:id', associationController.deleteAssociation);

module.exports = router;