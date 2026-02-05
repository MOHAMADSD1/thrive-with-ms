const httpstatus = require("http-status");
const ApiError = require("../utils/ApiError");
const catchAsync = require("../utils/catchAsync");
const exerciseService = require("../services/exercise.services");

const createExercise = catchAsync(async (req, res) => {
  const exercise = await exerciseService.createExercise(req.body);
  res.status(201).send(exercise);
});

const getExercise = catchAsync(async (req, res) => {
  //get exercise by it's Id
  const exercise = await exerciseService.getExerciseById(req.params.exerciseId);
  if (!exercise) {
    throw new ApiError(httpstatus.NOT_FOUND, "Exercise not found!");
  }
  res.send(exercise);
});

const getExercises = catchAsync(async (req, res) => {
  const { category } = req.query;
  const exercises = await exerciseService.getAllExercises(category);
  res.status(200).send(exercises);
});

const updateExercise = catchAsync(async (req, res) => {
  const exercise = await exerciseService.updateExerciseById(
    req.params.exerciseId,
    req.body
  );
  res.status(200).send(exercise);
});

const deleteExercise = catchAsync(async (req, res) => {
  const exercise = await exerciseService.deleteExerciseById(
    req.params.exerciseId
  );
  res.status(204).send();
});

module.exports = {
  createExercise,
  getExercise,
  getExercises,
  updateExercise,
  deleteExercise,
};
