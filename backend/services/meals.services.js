const httpstatus = require("http-status");
const Meals = require("../models/Meals.model");
const ApiError = require("../utils/ApiError");

const createMeal = async (mealbody) => {
  return Meals.create(mealbody);
};

const getMealById = async (mealId) => {
  return Meals.findById(mealId);
};

const getAllMeals = async (category) => {
  const query = {};
  if (category) {
    query.category = category;
  }
  return Meals.find(query);
};

const updateMealsById = async (mealId, updatebody) => {
  const meal = await getMealById(mealId);
  if (!meal) {
    throw new ApiError(httpstatus.NOT_FOUND, "Meal not found!");
  }
  Object.assign(meal, updatebody);
  await meal.save();
  return meal;
};

const deleteMealById = async (mealId) => {
  const meal = await getMealById(mealId);
  if (!meal) {
    throw new ApiError(httpstatus.NOT_FOUND, "meal not found!");
  }
  await meal.deleteOne();
  return meal;
};

module.exports = {
  createMeal,
  getMealById,
  getAllMeals,
  updateMealsById,
  deleteMealById,
};
