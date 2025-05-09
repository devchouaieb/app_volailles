// backend/models/Bird.js
const mongoose = require('mongoose');

const BirdSchema = new mongoose.Schema({
  identifier: {
    type: String,
    required: [true, "Identifier is required"],
    trim: true
  },
  species: {
    type: String,
    required: [true, "Species is required"],
    trim: true
  },
  gender: {
    type: String,
    enum: ['male', 'female', 'unknown'],
    default: 'unknown',
    set: function (value) {
      return value ? value.toLowerCase() : 'unknown';
    }
  },
  birthDate: {
    type: Date,
    required: [true, "Birth date is required"]
  },
  status: {
    type: String,
    default: 'active'
  },
  price: {
    type: Number,
    default: 0
  },
  details: {
    type: String
  },
  ring: {
    type: String
  },
  sold: {
    type: Boolean,
    default: false
  },
  forSale: {
    type: Boolean,
    default: false
  },
  soldDate: {
    type: Date
  },
  soldPrice: {
    type: Number
  },
  askingPrice: {
    type: Number
  },
  buyerInfo: {
    nationalId: {
      type: String,
      trim: true
    },
    fullName: {
      type: String,
      trim: true
    },
    phone: {
      type: String,
      trim: true
    }
  },
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  mother: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Bird',
    required: false
  },
  father: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Bird',
    required: false
  },
  seller: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: false
  },
  createdAt: {
    type: Date,
    default: Date.now
  }
});

module.exports = mongoose.model('Bird', BirdSchema);