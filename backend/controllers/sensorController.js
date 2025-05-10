const SensorData = require('../models/SensorData');
const asyncHandler = require('express-async-handler');

// @desc    Insert test sensor data
// @route   POST /api/sensor_data/test
// @access  Private
const insertTestData = asyncHandler(async (req, res) => {
  try {
    const testData = new SensorData({
      temperature1: 25.5,
      temperature2: 26.0,
      temperature3: 24.8,
      temperature4: 25.2,
      temperature5: 25.7,
      temperature6: 25.9,
      temperature7: 25.3,
      humidite1: 60,
      humidite2: 62,
      humidite3: 58,
      humidite4: 61,
      humidite5: 59,
      humidite6: 63,
      humidite7: 60,
      ldr1: 500,
      ldr2: 480
    });

    const savedData = await testData.save();
    console.log('Test data inserted:', savedData);

    res.status(201).json({
      success: true,
      data: savedData
    });
  } catch (error) {
    console.error('Error inserting test data:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur lors de l\'insertion des données de test'
    });
  }
});

// @desc    Get all sensor data
// @route   GET /api/sensor_data
// @access  Private
const getSensorData = asyncHandler(async (req, res) => {
  try {
    console.log('Attempting to fetch sensor data...');
    
    // Vérifier la connexion à la base de données
    const dbState = SensorData.db.readyState;
    console.log('Database connection state:', dbState);
    
    // Compter le nombre total de documents
    const count = await SensorData.countDocuments();
    console.log('Total documents in sensor_data collection:', count);

    const sensorData = await SensorData.find()
      .sort({ timestamp: -1 })
      .limit(100);

    console.log('Sensor data retrieved:', JSON.stringify(sensorData, null, 2));
    console.log('Number of records retrieved:', sensorData.length);

    if (sensorData.length === 0) {
      console.log('No sensor data found in the database');
    }

    res.status(200).json({
      success: true,
      data: sensorData
    });
  } catch (error) {
    console.error('Error getting sensor data:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la récupération des données des capteurs'
    });
  }
});

module.exports = {
  getSensorData,
  insertTestData
}; 