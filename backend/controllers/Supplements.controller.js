const httpstatus = require("http-status");
const ApiError = require("../utils/ApiError");
const catchAsync = require("../utils/catchAsync");
const supplementsService = require("../services/supplements.services");

const createSupplement = catchAsync(async (req, res) => {
  const supplement = supplementsService.createSupplement(req.body);
  res.status(201).send(supplement);
});

const getSupplement = catchAsync(async (req, res) => {
  const supplement = await supplementsService.getSupplementsById(
    req.params.supplementid
  );
  if (!supplement) {
    throw new ApiError(httpstatus.NOT_FOUND, "Supplement not found!");
  }
});

const getSupplements = catchAsync(async (req, res) => {
  const supplements = await supplementsService.getAllSupplements();
  res.status(200).json(supplements);
});

const updateSupplements = catchAsync(async (req, res) => {
  const supplemet = await supplementsService.updateSupplemetnsById(
    req.params.supplementid
  );
  res.status(200).send();
});

const deleteSupplement = catchAsync(async (req, res) => {
  const supplement = await supplementsService.deleteSupplementById(
    req.params.supplementid
  );
  res.status(200).send();
});

module.exports = {
  createSupplement,
  getSupplement,
  getSupplements,
  updateSupplements,
  deleteSupplement,
};
