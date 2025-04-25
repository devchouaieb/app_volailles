// backend/middleware/auth.js
const jwt = require('jsonwebtoken');
const User = require('../models/user');

// Protéger les routes
exports.protect = async (req, res, next) => {
  let token;
  console.log('Headers d\'autorisation:', req.headers.authorization);

  // Obtenir le token depuis l'en-tête d'autorisation
  if (req.headers.authorization && req.headers.authorization.startsWith('Bearer')) {
    token = req.headers.authorization.split(' ')[1];
    console.log('Token extrait:', token);
  }

  // Vérifier si le token existe
  if (!token) {
    console.log('Pas de token fourni');
    return res.status(401).json({
      success: false,
      message: "Non autorisé à accéder à cette ressource"
    });
  }

  try {
    // Vérifier le token
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    console.log('Token décodé:', decoded);
    
    req.user = await User.findById(decoded.id);
    console.log('Utilisateur trouvé:', req.user ? 'Oui' : 'Non');
    
    next();
  } catch (err) {
    console.error('Erreur vérification token:', err.message);
    return res.status(401).json({
      success: false,
      message: "Non autorisé à accéder à cette ressource"
    });
  }
};

// Vérifier les rôles utilisateur
exports.authorize = (...roles) => {
  return (req, res, next) => {
    if (!roles.includes(req.user.role)) {
      return res.status(403).json({
        success: false,
        message: `Le rôle ${req.user.role} n'est pas autorisé à accéder à cette ressource`
      });
    }
    next();
  };
};