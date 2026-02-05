const express = require("express");
const treatmentController = require("../controllers/treatment.controller");

const router = express.Router();

router
  .route("/")
  .post(treatmentController.createTreatment)
  .get(treatmentController.getTreatments);

router
  .route("/:treatmentId")
  .get(treatmentController.getTreatment)
  .patch(treatmentController.updateTreatment)
  .delete(treatmentController.deleteTreatment);

module.exports = router;
