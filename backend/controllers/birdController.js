const Bird = require('../models/bird');
const asyncHandler = require('express-async-handler');

// @desc    Get all birds
// @route   GET /api/birds
// @access  Private
const getBirds = asyncHandler(async (req, res) => {
  const birds = await Bird.find({ user: req.user.id });
  res.status(200).json(birds);
});

// @desc    Create a bird
// @route   POST /api/birds
// @access  Private
const createBird = asyncHandler(async (req, res) => {
  const bird = await Bird.create({
    ...req.body,
    user: req.user.id
  });
  res.status(201).json(bird);
});

// @desc    Update a bird
// @route   PUT /api/birds/:id
// @access  Private
const updateBird = asyncHandler(async (req, res) => {
  const bird = await Bird.findById(req.params.id);

  if (!bird) {
    res.status(404);
    throw new Error('Bird not found');
  }

  // Make sure the logged in user matches the bird user
  if (bird.user.toString() !== req.user.id) {
    res.status(401);
    throw new Error('User not authorized');
  }

  const updatedBird = await Bird.findByIdAndUpdate(req.params.id, req.body, {
    new: true,
    runValidators: true
  });

  res.status(200).json(updatedBird);
});

// @desc    Delete a bird
// @route   DELETE /api/birds/:id
// @access  Private
const deleteBird = asyncHandler(async (req, res) => {
  const bird = await Bird.findById(req.params.id);

  if (!bird) {
    res.status(404);
    throw new Error('Bird not found');
  }

  // Make sure the logged in user matches the bird user
  if (bird.user.toString() !== req.user.id) {
    res.status(401);
    throw new Error('User not authorized');
  }

  await Bird.deleteOne({ _id: req.params.id });
  res.status(200).json({ id: req.params.id });
});

// @desc    Sell a bird
// @route   PUT /api/birds/:id/sell
// @access  Private
const sellBird = asyncHandler(async (req, res) => {
  const bird = await Bird.findById(req.params.id);

  if (!bird) {
    res.status(404);
    throw new Error('Bird not found');
  }

  // Make sure the logged in user matches the bird user
  if (bird.user.toString() !== req.user.id) {
    res.status(401);
    throw new Error('User not authorized');
  }

  const { price, buyerInfo } = req.body;
  const buyer = await User.findOne({ nationalId: buyerInfo.nationalId });
  if (!buyer) {
    res.status(404);
    throw new Error('Puyer not found');
  }

  if (!buyerInfo || !buyerInfo.nationalId || !buyerInfo.fullName) {
    res.status(400);
    throw new Error('Price and buyer information (nationalId, fullName) are required');
  }

  // Update the bird's status to sold
  const updatedBird = await Bird.findByIdAndUpdate(
    req.params.id,
    {
      sold: true,
      soldDate: new Date(),
      soldPrice: price,
      status: 'sold',
      buyerInfo: {
        nationalId: buyerInfo.nationalId,
        fullName: buyerInfo.fullName,
        phone: buyerInfo.phone || ''
      }
    },
    { new: true }
  );

  res.status(200).json(updatedBird);
});

// @desc    Get all sold birds for the current user
// @route   GET /api/birds/sold
// @access  Private
const getSelledBirds = asyncHandler(async (req, res) => {
  const birds = await Bird.find({ 
    user: req.user.id,
    sold: true 
  });
  res.status(200).json(birds);
});

// @desc    Get all birds marked for sale
// @route   GET /api/birds/for-sale
// @access  Private
const getBirdsForSale = asyncHandler(async (req, res) => {
  const birds = await Bird.find({  
    forSale: true,
    sold: false // Only get birds that are not sold yet
  });
  res.status(200).json(birds);
});

// @desc    Get all birds that are not sold yet
// @route   GET /api/birds/available
// @access  Private
const getBirdsNotSold = asyncHandler(async (req, res) => {
  const birds = await Bird.find({ 
    user: req.user.id,
    sold: false // Only get birds that are not sold yet
  });
  res.status(200).json(birds);
});

// @desc    Mark a bird for sale
// @route   PUT /api/birds/:id/mark-for-sale
// @access  Private
const markBirdForSale = asyncHandler(async (req, res) => {
  const bird = await Bird.findById(req.params.id);

  if (!bird) {
    res.status(404);
    throw new Error('Bird not found');
  }

  // Check if bird is already sold
  if (bird.sold) {
    res.status(400);
    throw new Error('Cannot mark a sold bird for sale');
  }

  // Prepare update data
  const updateData = {
    forSale: true
  };

  // If askingPrice is provided, add it to the update data
  if (req.body.askingPrice !== undefined) {
    updateData.askingPrice = req.body.askingPrice;
  }

  // Update the bird's forSale status and askingPrice if provided
  const updatedBird = await Bird.findByIdAndUpdate(
    req.params.id,
    updateData,
    { new: true }
  );

  res.status(200).json(updatedBird);
});

module.exports = {
  getBirds,
  createBird,
  updateBird,
  deleteBird,
  sellBird,
  getSelledBirds,
  getBirdsForSale,
  getBirdsNotSold,
  markBirdForSale
}; 