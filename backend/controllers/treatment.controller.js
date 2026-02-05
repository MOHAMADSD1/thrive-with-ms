const httpStatus = require("http-status");
const ApiError = require("../utils/ApiError");
const catchAsync = require("../utils/catchAsync");
const { treatmentService } = require("../services");

const createTreatment = catchAsync(async (req, res) => {
  const treatment = await treatmentService.createTreatment(req.body);
  res.status(201).send(treatment);
});

const getTreatments = catchAsync(async (req, res) => {
  const { userId } = req.query;
  if (!userId) {
    throw new ApiError(
      httpStatus.BAD_REQUEST,
      "userId query parameter is required"
    );
  }
  const treatments = await treatmentService.getUserTreatments(userId);
  res.send(treatments);
});

const getTreatment = catchAsync(async (req, res) => {
  const treatment = await treatmentService.getTreatmentById(
    req.params.treatmentId
  );
  if (!treatment) {
    throw new ApiError(httpStatus.NOT_FOUND, "Treatment not found");
  }
  res.send(treatment);
});

const updateTreatment = catchAsync(async (req, res) => {
  const treatment = await treatmentService.updateTreatmentById(
    req.params.treatmentId,
    req.body
  );
  res.send(treatment);
});

const deleteTreatment = catchAsync(async (req, res) => {
  await treatmentService.deleteTreatmentById(req.params.treatmentId);
  res.status(204).send();
});

module.exports = {
  createTreatment,
  getTreatments,
  getTreatment,
  updateTreatment,
  deleteTreatment,
};
