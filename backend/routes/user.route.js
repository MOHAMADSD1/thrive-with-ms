const express = require("express");
const userController = require("../controllers/Users.controllers");

const router = express.Router();

router.post("/register", userController.createUser);


router
  .route("/:userId")
  .get(userController.getUser)
  .patch(userController.updateUser)
  .delete(userController.deleteUser);

module.exports = router;
