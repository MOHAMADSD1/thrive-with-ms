const express = require("express");
const supplementsController = require("../controllers/Supplements.controller");

const router = express.Router();

router
  .route("/")
  .post(supplementsController.createSupplement)
  .get(supplementsController.getSupplements);

router
  .route("/:supplementId")
  .get(supplementsController.getSupplement)
  .patch(supplementsController.updateSupplements)
  .delete(supplementsController.deleteSupplement);

module.exports = router;
