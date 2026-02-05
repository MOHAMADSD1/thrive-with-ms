const httpstatus = require("http-status");
const ApiError = require("../utils/ApiError");
const catchAsync = require("../utils/catchAsync");
const symptomService = require("../services/symptom.services");

const createSymptom = catchAsync(async (req, res) => {
  const symptom = await symptomService.createSymptom(req.body);
  res.status(201).send(symptom);
});

const getSymptomById = catchAsync(async (req, res) => {
  const symptom = await symptomService.getSymptomById(req.params.symptomId); //get symptom by it's ID.
  if (!symptom) {
    throw new ApiError(httpstatus.NOT_FOUND, "Symptom not found!");
  }
  res.send(symptom);
});

const getSymptomByUser = catchAsync(async (req, res) => {
  const { userId } = req.query;
  if (!userId) {
    throw new ApiError(
      httpstatus.BAD_REQUEST,
      "userId query parameter is required"
    );
  }
  const symptom = await symptomService.getSymptomByUser(userId); //get symptom by user's ID.
  res.send(symptom);
});

const updateSymptom = catchAsync(async (req, res) => {
  const symptom = await symptomService.updateSymptomById(
    req.params.symptomId,
    req.body
  );
  res.status(200).send(symptom);
});

const deleteSymptom = catchAsync(async (req, res) => {
  const symptom = await symptomService.deleteSymptomById(req.params.symptomId);
  res.status(204).send();
});

module.exports = {
  createSymptom,
  getSymptomById,
  getSymptomByUser,
  updateSymptom,
  deleteSymptom,
};
