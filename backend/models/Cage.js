const mongoose = require('mongoose');

const CageSchema = new mongoose.Schema({
  cageNumber: {
    type: String,
    required: [true, "Le numéro de la cage est obligatoire"],
    unique: true,
    trim: true
  },
  male: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Bird',
    required: [true, "L'oiseau mâle est obligatoire"]
  },
  female: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Bird',
    required: [true, "L'oiseau femelle est obligatoire"]
  },
  species: {
    type: String,
    required: [true, "L'espèce est obligatoire"],
    trim: true
  },
  status: {
    type: String,
    enum: ['active', 'inactive'],
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
  timestamps: true // This will add createdAt and updatedAt fields
});

// Ensure that male and female birds are different
CageSchema.pre('save', async function(next) {
  if (this.male.toString() === this.female.toString()) {
    next(new Error("Le mâle et la femelle doivent être différents"));
  }
  next();
});

module.exports = mongoose.models.Cage || mongoose.model('Cage', CageSchema); 