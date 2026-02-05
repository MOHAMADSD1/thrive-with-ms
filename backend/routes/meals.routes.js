const express = require("express");
const mealsController = require("../controllers/Meals.controllers");

const router = express.Router();

router
  .route("/")
  .post(mealsController.createMeal)
  .get(mealsController.getMeals);

router
  .route("/:mealId")
  .get(mealsController.getMeal)
  .patch(mealsController.updateMeals)
  .delete(mealsController.deleteMeal);

module.exports = router;
