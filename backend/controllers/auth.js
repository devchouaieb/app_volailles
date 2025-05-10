// backend/controllers/auth.js
const User = require('../models/user');
const sendEmail = require('../utils/sendEmail');
const crypto = require('crypto');

// @desc    Inscrire un utilisateur
// @route   POST /api/auth/register
// @access  Public
exports.register = async (req, res, next) => {
  try {
    console.log('Tentative d\'inscription:', req.body);
    const { fullName, nationalId, email, password, association } = req.body;

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
      password,
      association
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

// @desc    Mot de passe oublié
// @route   POST /api/auth/forgotpassword
// @access  Public
exports.forgotPassword = async (req, res) => {
  const { email } = req.body;

  try {
    const user = await User.findOne({ email });

    if (!user) {
      return res.status(404).json({
        success: false,
        message: "Aucun utilisateur trouvé avec cet email"
      });
    }

    // Générer le token de réinitialisation
    const resetToken = user.getResetPasswordToken();

    await user.save();

    // Créer l'URL de réinitialisation
    const resetUrl = `${process.env.APP_URL}/reset-password?resettoken=${resetToken}`;

    const message = `
      <h1>Demande de réinitialisation de mot de passe</h1>
      <p>Vous avez demandé la réinitialisation de votre mot de passe.</p>
      <p>Veuillez cliquer sur le lien ci-dessous pour réinitialiser votre mot de passe :</p>
      <a href="${resetUrl}" 
             style="background-color: #4CAF50; color: white; padding: 12px 20px; text-decoration: none; border-radius: 5px; display: inline-block;">
            Réinitialiser mon mot de passe
          </a>
      <p>Ce lien expirera dans 10 minutes.</p>`;

    try {
      await sendEmail({
        to: user.email,
        subject: 'Réinitialisation de mot de passe',
        text: message
      });

      res.status(200).json({
        success: true,
        message: "Email de réinitialisation envoyé avec succès"
      });
    } catch (err) {
      user.resetPasswordToken = undefined;
      user.resetPasswordExpire = undefined;

      await user.save();

      return res.status(500).json({
        success: false,
        message: "L'email n'a pas pu être envoyé"
      });
    }
  } catch (err) {
    return res.status(500).json({
      success: false,
      message: "Une erreur est survenue lors de la réinitialisation du mot de passe"
    });
  }
};

// @desc    Réinitialiser le mot de passe
// @route   PUT /api/auth/resetpassword/:resettoken
// @access  Public
exports.resetPassword = async (req, res) => {
  // Récupérer le token hashé
  const resetPasswordToken = crypto
    .createHash('sha256')
    .update(req.params.resettoken)
    .digest('hex');

  try {
    const user = await User.findOne({
      resetPasswordToken,
      resetPasswordExpire: { $gt: Date.now() }
    });

    if (!user) {
      return res.status(400).json({
        success: false,
        message: "Token invalide ou expiré"
      });
    }

    // Définir le nouveau mot de passe
    user.password = req.body.password;
    user.resetPasswordToken = undefined;
    user.resetPasswordExpire = undefined;
    await user.save();

    res.status(200).json({
      success: true,
      message: "Mot de passe réinitialisé avec succès"
    });
  } catch (err) {
    return res.status(500).json({
      success: false,
      message: "Une erreur est survenue lors de la réinitialisation du mot de passe"
    });
  }
};