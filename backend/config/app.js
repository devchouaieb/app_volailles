require('dotenv').config();
const express = require('express');
const app = express();
const cors = require('cors');
const authRoutes = require('./routes/auth');

// Middleware
app.use(express.json());
app.use(cors());

// Connexion à la base de données
const connectDB = require('./config/db');
connectDB();

// Routes
app.use('/api/auth', authRoutes);

// Démarrage du serveur
const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`Serveur en cours d'exécution sur le port ${PORT}`);
});