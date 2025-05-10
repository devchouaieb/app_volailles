const mongoose = require('mongoose');

const SensorDataSchema = new mongoose.Schema({
  timestamp: {
    type: Date,
    required: true,
    default: Date.now
  },
  temperature1: {
    type: Number,
    default: 0
  },
  temperature2: {
    type: Number,
    default: 0
  },
  temperature3: {
    type: Number,
    default: 0
  },
  temperature4: {
    type: Number,
    default: 0
  },
  temperature5: {
    type: Number,
    default: 0
  },
  temperature6: {
    type: Number,
    default: 0
  },
  temperature7: {
    type: Number,
    default: 0
  },
  humidite1: {
    type: Number,
    default: 0
  },
  humidite2: {
    type: Number,
    default: 0
  },
  humidite3: {
    type: Number,
    default: 0
  },
  humidite4: {
    type: Number,
    default: 0
  },
  humidite5: {
    type: Number,
    default: 0
  },
  humidite6: {
    type: Number,
    default: 0
  },
  humidite7: {
    type: Number,
    default: 0
  },
  ldr1: {
    type: Number,
    default: 0
  },
  ldr2: {
    type: Number,
    default: 0
  }
}, {
  collection: 'sensor_data'
});

module.exports = mongoose.models.SensorData || mongoose.model('SensorData', SensorDataSchema); 