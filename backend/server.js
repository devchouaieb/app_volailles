// backend/server.js

const express = require('express');
const dotenv = require('dotenv');
dotenv.config();
const cors = require('cors');
const connectDB = require('./config/db');
const authRoutes = require('./routes/auth');
const birdRoutes = require('./routes/birds');
const cagesRoutes = require('./routes/cagesRoutes');
const nestsRoutes = require('./routes/nestsRoutes');
const reseauRoutes = require('./routes/reseauRoutes');
const associationRoutes = require('./routes/associationRoutes');
const sensorRoutes = require('./routes/sensorRoutes');
const productRoutes = require('./routes/productRoutes');

// Charger les variables d'environnement
dotenv.config({ path: './config/config.env' });

// Connecter à la base de données
connectDB();

// Initialiser l'application
const app = express();

// Body parser
app.use(express.json());

// Configuration CORS plus permissive
app.use(cors({
  origin: '*', // Autorise toutes les origines
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/birds', birdRoutes);
app.use('/api/cages', cagesRoutes);
app.use('/api/nests', nestsRoutes);
app.use('/api/reseaux', reseauRoutes);
app.use('/api/associations', associationRoutes);
app.use('/api/sensor_data', sensorRoutes);
app.use('/api/products',productRoutes);

// Gestion des erreurs 404
app.use((req, res, next) => {
  res.status(404).json({
    success: false,
    message: 'Ressource non trouvée'
  });
});

const PORT = process.env.PORT || 5000;
const HOST = '0.0.0.0'; // Permet d'écouter sur toutes les interfaces réseau

const server = app.listen(PORT, HOST, () => {
  console.log(`Serveur lancé sur http://${HOST}:${PORT}`);
});

// Gestion des erreurs non gérées
process.on('unhandledRejection', (err, promise) => {
  console.log(`Erreur: ${err.message}`);
  // Fermer le serveur & quitter le processus
  server.close(() => process.exit(1));
});