const Product = require('../models/Product');

exports.createProduct = async (req, res) => {
  try {
    const { name, prix } = req.body;
    const product = new Product({
      name,
      prix,
      user: req.user._id
    });
    await product.save();
    res.status(201).json({ success: true, data: product });
  } catch (error) {
    res.status(400).json({ success: false, message: error.message });
  }
};

exports.getProducts = async (req, res) => {
  try {
    const products = await Product.find({ user: req.user._id });
    res.status(200).json({ success: true, data: products });
  } catch (error) {
    res.status(400).json({ success: false, message: error.message });
  }
};

exports.getTotalProductValue = async (req, res) => {
  try {
    const totalValue = await Product.aggregate([
      { $match: { user: req.user._id } },
      { $group: { _id: null, total: { $sum: '$prix' } } }
    ]);
    res.status(200).json({ 
      success: true, 
      data: totalValue[0] ? totalValue[0].total : 0 
    });
  } catch (error) {
    res.status(400).json({ success: false, message: error.message });
  }
};
