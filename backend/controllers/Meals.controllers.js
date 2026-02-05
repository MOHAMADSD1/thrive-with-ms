const httpstatus = require("http-status");
const ApiError = require("../utils/ApiError");
const catchAsync = require("../utils/catchAsync");
const mealsService = require("../services/meals.services");

const createMeal = catchAsync(async (req, res) => {
  const meal = await mealsService.createMeal(req.body);
  res.status(201).send(meal);
});

const getMeal = catchAsync(async (req, res) => {
  const meal = await mealsService.getMealById(req.params.mealId);
  if (!meal) {
    throw new ApiError(httpstatus.NOT_FOUND, "Meal not found!");
  }
  res.send(meal);
});

const getMeals = catchAsync(async (req, res) => {
  const { category } = req.query;
  const meals = await mealsService.getAllMeals(category);
  res.status(200).send(meals);
});

const updateMeals = catchAsync(async (req, res) => {
  const meal = await mealsService.updateMealsById(req.params.mealId, req.body);
  res.status(200).send(meal);
});

const deleteMeal = catchAsync(async (req, res) => {
  const meal = await mealsService.deleteMealById(req.params.mealId);
  res.status(204).send();
});

module.exports = {
  createMeal,
  getMeal,
  getMeals,
  updateMeals,
  deleteMeal,
};
