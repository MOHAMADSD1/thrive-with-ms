const httpStatus = require("http-status");
const Treatment = require("../models/Treatment.model");
const ApiError = require("../utils/ApiError");

/**
 * Create a treatment
 * @param {Object} treatmentBody
 * @returns {Promise<Treatment>}
 */
const createTreatment = async (treatmentBody) => {
  return Treatment.create(treatmentBody);
};

/**
 * Get all treatments for a user
 * @param {ObjectId} userId
 * @returns {Promise<Treatment[]>}
 */
const getUserTreatments = async (userId) => {
  return Treatment.find({ userId }).sort({ startDate: -1 });
};

/**
 * Get treatment by id
 * @param {ObjectId} id
 * @returns {Promise<Treatment>}
 */
const getTreatmentById = async (id) => {
  return Treatment.findById(id);
};

/**
 * Update treatment by id
 * @param {ObjectId} treatmentId
 * @param {Object} updateBody
 * @returns {Promise<Treatment>}
 */
const updateTreatmentById = async (treatmentId, updateBody) => {
  const treatment = await getTreatmentById(treatmentId);
  if (!treatment) {
    throw new ApiError(httpStatus.NOT_FOUND, "Treatment not found");
  }
  Object.assign(treatment, updateBody);
  await treatment.save();
  return treatment;
};

/**
 * Delete treatment by id
 * @param {ObjectId} treatmentId
 * @returns {Promise<Treatment>}
 */
const deleteTreatmentById = async (treatmentId) => {
  const treatment = await getTreatmentById(treatmentId);
  if (!treatment) {
    throw new ApiError(httpStatus.NOT_FOUND, "Treatment not found");
  }
  await treatment.deleteOne();
  return treatment;
};

module.exports = {
  createTreatment,
  getUserTreatments,
  getTreatmentById,
  updateTreatmentById,
  deleteTreatmentById,
};
