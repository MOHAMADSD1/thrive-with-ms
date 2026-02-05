const express = require("express");
const validate = require("../middlewares/validate");
const authValidation = require("../validations/auth.validation");
const authController = require("../controllers/Auth.controllers");
const auth = require("../middlewares/auth");

const router = express.Router();

router.post(
  "/register",
  (req, res, next) => {
    next();
  },
  validate(authValidation.register),
  authController.register
);
router.post("/login", validate(authValidation.login), authController.login);
router.post("/logout", validate(authValidation.logout), authController.logout);
router.post(
  "/refresh-token",
  validate(authValidation.refreshToken),
  authController.refreshTokens
);
router.post(
  "/forgot-password",
  validate(authValidation.forgotPassword),
  authController.forgotPassword
);
router.post(
  "/reset-password",
  validate(authValidation.resetPassword),
  authController.resetPassword
);
router.post(
  "/change-password",
  auth(),
  validate(authValidation.changePassword),
  authController.changePassword
);


router.post(
  "/send-verification-email",
  auth(),
  authController.sendVerificationEmail
);
router.post(
  "/verify-email",
  validate(authValidation.verifyEmail),
  authController.verifyEmail
);

module.exports = router;
