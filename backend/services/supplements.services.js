const httpstatus = require("http-status");
const Supplements = require("../models/Supplements.model");
const ApiError = require("../utils/ApiError");

const createSupplement = async (supplementBody) => {
  return Supplements.create(supplementBody);
};

const getSupplementsById = async (supplementId) => {
  return Supplements.findById(supplementId);
};

const getAllSupplements = async () => {
  const query = {};
  return Supplements.find(query);
};

const updateSupplemetnsById = async(supplementId, updateBody) => {
    const supplement = await getSupplementsById(supplementId);
    if(!supplement) {
        throw new ApiError(httpstatus.NOT_FOUND, "Supplement not found!");
    }
    Object.assign(supplement, updateBody);
    await supplement.save();
    return supplement;
};

const deleteSupplementById = async(supplementId) => {
    const supplement = getSupplementsById(supplementId);
    if(!supplement) {
        throw new ApiError(httpstatus.NOT_FOUND, "Supplement not found!");
    }
    await supplement.deleteOne();
    return supplement;
};

module.exports = {
    createSupplement,
    getSupplementsById,
    getAllSupplements,
    updateSupplemetnsById,
    deleteSupplementById,
};
