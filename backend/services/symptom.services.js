const httpstatus = require("http-status");
const ApiError = require("../utils/ApiError");
const Symptom = require("../models/Symptom.model");

const createSymptom = async (symptomBody) => {
  return Symptom.create(symptomBody);
};

const getSymptomById = async (symptomId) => {
  return Symptom.findById(symptomId);
};

const getSymptomByUser = async (userId) => {
  return Symptom.find({ userId });
};

const updateSymptomById = async (symptomId, updateBody) => {
  const symptom = await getSymptomById(symptomId);
  if (!symptom) {
    throw new ApiError(httpstatus.NOT_FOUND, "Symptom not found!");
  }
  Object.assign(symptom, updateBody);
  await symptom.save();
  return symptom;
};

const deleteSymptomById = async (symptomId) => {
  const symptom = await getSymptomById(symptomId);
  if (!symptom) {
    throw new ApiError(httpstatus.NOT_FOUND, "Symptom not found!");
  }
  await symptom.deleteOne();
  return symptom;
};

module.exports = {
  createSymptom,
  getSymptomById,
  getSymptomByUser,
  updateSymptomById,
  deleteSymptomById,
};
