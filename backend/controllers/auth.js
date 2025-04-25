// backend/controllers/auth.js
const User = require('../models/user');

// @desc    Inscrire un utilisateur
// @route   POST /api/auth/register
// @access  Public
exports.register = async (req, res, next) => {
  try {
    console.log('Tentative d\'inscription:', req.body);
    const { fullName, nationalId, email, password } = req.body;

    // Vérifier si l'utilisateur existe déjà
    const existingUser = await User.findOne({ 
      $or: [{ email }, { nationalId }] 
    });

    if (existingUser) {
      console.log('Utilisateur existe déjà');
      return res.status(400).json({ 
        success: false, 
        message: "L'email ou la CIN est déjà utilisé(e)"
      });
    }

    // Créer l'utilisateur
    const user = await User.create({
      fullName,
      nationalId,
      email,
      password
    });

    console.log('Inscription réussie');
    res.status(201).json({
      success: true,
      message: "Inscription réussie"
    });
  } catch (err) {
    console.error('Erreur lors de l\'inscription:', err);
    res.status(500).json({
      success: false,
      message: "Erreur lors de l'inscription"
    });
  }
};

// @desc    Connecter un utilisateur
// @route   POST /api/auth/login
// @access  Public
exports.login = async (req, res, next) => {
  try {
    const { nationalId, password } = req.body;
    console.log('Tentative de connexion de:', nationalId);

    // Valider les entrées
    if (!nationalId || !password) {
      console.log('Données manquantes');
      return res.status(400).json({
        success: false,
        message: "Veuillez fournir la CIN et le mot de passe"
      });
    }

    // Vérifier si l'utilisateur existe
    const user = await User.findOne({ nationalId }).select('+password');
    console.log('Utilisateur trouvé:', user ? 'Oui' : 'Non');
    
    if (!user) {
      return res.status(401).json({
        success: false,
        message: "Identifiants invalides"
      });
    }

    // Vérifier si le mot de passe correspond
    const isMatch = await user.matchPassword(password);
    console.log('Mot de passe correct:', isMatch ? 'Oui' : 'Non');
    
    if (!isMatch) {
      return res.status(401).json({
        success: false,
        message: "Identifiants invalides"
      });
    }

    // Créer un token
    const token = user.getSignedJwtToken();
    console.log('Token généré');

    // Préparer la réponse utilisateur sans le mot de passe
    const userData = {
      id: user._id,
      nationalId: user.nationalId,
      fullName: user.fullName,
      email: user.email,
      role: user.role,
      createdAt: user.createdAt
    };

    res.status(200).json({
      success: true,
      token,
      user: userData
    });
  } catch (err) {
    console.error('Erreur de connexion:', err);
    res.status(500).json({
      success: false,
      message: "Erreur lors de la connexion"
    });
  }
};

// @desc    Obtenir l'utilisateur actuellement connecté
// @route   GET /api/auth/me
// @access  Private
exports.getMe = async (req, res, next) => {
  try {
    const user = await User.findById(req.user.id);

    res.status(200).json({
      success: true,
      data: user
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({
      success: false,
      message: "Erreur lors de la récupération du profil"
    });
  }
};

// @desc    Déconnexion / effacer le cookie
// @route   GET /api/auth/logout
// @access  Private
exports.logout = async (req, res, next) => {
  res.status(200).json({
    success: true,
    message: "Déconnexion réussie"
  });
};

// @desc    Mettre à jour les informations de l'utilisateur
// @route   PUT /api/auth/updatedetails
// @access  Private
exports.updateDetails = async (req, res, next) => {
  try {
    const fieldsToUpdate = {
      fullName: req.body.fullName,
      email: req.body.email
    };

    const user = await User.findByIdAndUpdate(req.user.id, fieldsToUpdate, {
      new: true,
      runValidators: true
    });

    res.status(200).json({
      success: true,
      data: user
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({
      success: false,
      message: "Erreur lors de la mise à jour du profil"
    });
  }
};

// @desc    Changer le mot de passe
// @route   PUT /api/auth/updatepassword
// @access  Private
exports.updatePassword = async (req, res, next) => {
  try {
    const user = await User.findById(req.user.id).select('+password');

    // Vérifier le mot de passe actuel
    const isMatch = await user.matchPassword(req.body.currentPassword);

    if (!isMatch) {
      return res.status(401).json({
        success: false,
        message: "Mot de passe actuel incorrect"
      });
    }

    user.password = req.body.newPassword;
    await user.save();

    // Créer un nouveau token
    const token = user.getSignedJwtToken();

    res.status(200).json({
      success: true,
      token
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({
      success: false,
      message: "Erreur lors du changement de mot de passe"
    });
  }
};