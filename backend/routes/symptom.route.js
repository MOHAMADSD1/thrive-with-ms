const express = require("express");
const symptomController = require("../controllers/Symptom.controllers");

const router = express.Router();

router
  .route("/")
  .post(symptomController.createSymptom)
  .get(symptomController.getSymptomByUser);

router
  .route("/:symptomId")
  .get(symptomController.getSymptomById)
  .patch(symptomController.updateSymptom)
  .delete(symptomController.deleteSymptom);

module.exports = router;
