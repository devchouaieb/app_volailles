// backend/models/User.js
const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const crypto = require('crypto');

const UserSchema = new mongoose.Schema({
  nationalId: {
    type: String,
    required: [true, "CIN est obligatoire"],
    unique: true,
    trim: true,
    minlength: [8, "CIN doit contenir 8 chiffres"],
    maxlength: [8, "CIN doit contenir 8 chiffres"]
  },
  fullName: {
    type: String,
    required: [true, "Nom complet est obligatoire"],
    trim: true
  },
  email: {
    type: String,
    required: [true, "Email est obligatoire"],
    unique: true,
    match: [
      /^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/,
      "Veuillez fournir un email valide"
    ]
  },
  password: {
    type: String,
    required: [true, "Mot de passe est obligatoire"],
    minlength: [6, "Mot de passe doit avoir au moins 6 caractères"],
    select: false // Ne pas renvoyer le mot de passe dans les requêtes
  },
  role: {
    type: String,
    enum: ['user', 'admin'],
    default: 'user'
  },
  createdAt: {
    type: Date,
    default: Date.now
  },
  resetPasswordToken: String,
  resetPasswordExpire: Date
});

// Hacher le mot de passe avant de sauvegarder
UserSchema.pre('save', async function(next) {
  if (!this.isModified('password')) {
    next();
  }
  
  const salt = await bcrypt.genSalt(10);
  this.password = await bcrypt.hash(this.password, salt);
});

// Comparer le mot de passe saisi avec celui de la base de données
UserSchema.methods.matchPassword = async function(enteredPassword) {
  return await bcrypt.compare(enteredPassword, this.password);
};

// Générer un token JWT
UserSchema.methods.getSignedJwtToken = function() {
  return jwt.sign(
    { id: this._id },
    process.env.JWT_SECRET,
    { expiresIn: process.env.JWT_EXPIRE || '30d' }
  );
};

// Generate reset password token
UserSchema.methods.getResetPasswordToken = function() {
  // Generate token
  const resetToken = crypto.randomBytes(20).toString('hex');

  // Hash token and set to resetPasswordToken field
  this.resetPasswordToken = crypto
    .createHash('sha256')
    .update(resetToken)
    .digest('hex');

  // Set expire
  this.resetPasswordExpire = Date.now() + 10 * 60 * 1000; // 10 minutes

  return resetToken;
};

module.exports = mongoose.models.User || mongoose.model('User', UserSchema);
