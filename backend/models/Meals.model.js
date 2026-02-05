const { required } = require("joi");
const mongoose = require("mongoose");

const mealsSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
    trim: true,
  },

  description: {
    type: String,
    required: true,
    trim: true,
  },
  category: {
    type: String,
    enum: ["Breakfast", "Lunch", "Dinner"],
  },
  ingredients: {
    type: [String],
    required: true,
  },

  imageUrl: {
    type: String,
    required: true,
    trim: true,
  },
});
const Meals = mongoose.model("Meals", mealsSchema);

module.exports = Meals;
