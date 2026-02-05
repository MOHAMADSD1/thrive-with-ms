const express = require("express");
const exerciseController = require("../controllers/Exercise.controllers");

const router = express.Router();

router
  .route("/")
  .post(exerciseController.createExercise)
  .get(exerciseController.getExercises);

router
  .route("/:exerciseId")
  .get(exerciseController.getExercise)
  .patch(exerciseController.updateExercise)
  .delete(exerciseController.deleteExercise);

module.exports = router;
