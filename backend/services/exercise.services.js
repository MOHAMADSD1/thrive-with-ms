const httpstatus = require("http-status");
const Exercise = require("../models/Exercises.model");
const ApiError = require("../utils/ApiError");

const createExercise = async (exerciseBody) => {
  return Exercise.create(exerciseBody);
};

const getExerciseById = async (exerciseId) => {
  return Exercise.findById(exerciseId);
};

const getAllExercises = async (category) => {
  const query = {};
  if (category) {
    query.category = category;
  }
  return Exercise.find(query);
};

const updateExerciseById = async (exerciseId, updateBody) => {
  const exercise = await getExerciseById(exerciseId);
  if (!exercise) {
    throw new ApiError(httpstatus.NOT_FOUND, "Exercise not found!");
  }
  Object.assign(exercise, updateBody);
  await exercise.save();
  return exercise;
};

const deleteExerciseById = async (exerciseId) => {
  const exercise = await getExerciseById(exerciseId);
  if (!exercise) {
    throw new ApiError(httpstatus.NOT_FOUND, "Exercise not found!");
  }
  await exercise.deleteOne();
  return exercise;
};

module.exports = {
  createExercise,
  getExerciseById,
  getAllExercises,
  updateExerciseById,
  deleteExerciseById,
};
