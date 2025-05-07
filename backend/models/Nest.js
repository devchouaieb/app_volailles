const mongoose = require('mongoose');

const NestSchema = new mongoose.Schema({
  cageNumber: {
    type: String,
    required: [true, "Le numéro de la cage est obligatoire"],
    trim: true
  },
  numberOfEggs: {
    type: Number,
    required: [true, "Le nombre d'œufs est obligatoire"],
    min: [0, "Le nombre d'œufs ne peut pas être négatif"]
  },
  fertilizedEggs: {
    type: Number,
    required: [true, "Le nombre d'œufs fécondés est obligatoire"],
    min: [0, "Le nombre d'œufs fécondés ne peut pas être négatif"],
   
  },
  exclusionDate: {
    type: Date,
    required: [true, "La date d'exclusion est obligatoire"]
  },
  extractedEggs: {
    type: Number,
    required: [true, "Le nombre d'œufs extraits est obligatoire"],
    min: [0, "Le nombre d'œufs extraits ne peut pas être négatif"],
  },
  firstBirdExitDate: {
    type: Date
  },
  birdsExited: {
    type: Number,
    default: 0,
    min: [0, "Le nombre d'oiseaux sortis ne peut pas être négatif"]
  },
  status: {
    type: String,
    enum: ['active', 'completed', 'cancelled'],
    default: 'active'
  },
  notes: {
    type: String,
    trim: true
  },
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  }
}, {
  timestamps: true
});

module.exports = mongoose.models.Nest || mongoose.model('Nest', NestSchema); 