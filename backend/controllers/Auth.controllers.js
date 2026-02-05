const httpstatus = require("http-status");
const catchAsync = require("../utils/catchAsync");
const {
  authService,
  userService,
  tokenService,
  emailService,
} = require("../services");

const register = catchAsync(async (req, res) => {
  const user = await userService.createUser(req.body);
  const tokens = await tokenService.generateAuthToken(user);
  res.status(201).send({ user, tokens });
});

const login = catchAsync(async (req, res) => {
  const { email, password } = req.body;
  const user = await authService.loginUserWithEmailAndPassword(email, password);
  const tokens = await tokenService.generateAuthToken(user);
  const userResponse = user.toObject();
  delete userResponse.password;
  res.send({ user: userResponse, tokens });
});

const logout = catchAsync(async (req, res) => {
  await authService.logout(req.body.refreshToken);
  res.status(204).send();
});

const refreshTokens = catchAsync(async (req, res) => {
  const tokens = await authService.refreshAuth(req.body.refreshToken);
  res.send({ ...tokens });
});

const forgotPassword = catchAsync(async (req, res) => {
  const resetPasswordToken = await tokenService.generateResetPasswordToken(
    req.body.email
  );
  await emailService.sendResetPasswordEmail(req.body.email, resetPasswordToken);
  res.status(204).send();
});

const resetPassword = catchAsync(async (req, res) => {
  await authService.resetPassword(req.query.token, req.body.password);
  res.status(204).send();
});

const changePassword = catchAsync(async (req, res) => {
  await authService.changePassword(
    req.user.id,
    req.body.currentPassword,
    req.body.newPassword
  );
  res.status(204).send();
});

const sendVerificationEmail = catchAsync(async (req, res) => {
  const verfiyEmailToken = await tokenService.generateVerifyEmailToken(
    req.user
  );
  await emailService.sendVereficationEmail(req.user.email, verfiyEmailToken);
  res.status(204).send();
});

const verifyEmail = catchAsync(async (req, res) => {
  await authService.verifyEmail(req.query.token);
  res.status(204).send();
});

module.exports = {
  register,
  login,
  logout,
  refreshTokens,
  forgotPassword,
  resetPassword,
  sendVerificationEmail,
  verifyEmail,
  changePassword,
};
