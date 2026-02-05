const joi = require("joi");
const { password } = require("./custom.validation");

const register = {
  body: joi.object().keys({
    firstname: joi.string().required(),
    lastname: joi.string().required(),
    email: joi.string().required().email(),
    password: joi.string().required().custom(password),
  }),
};

const login = {
  body: joi.object().keys({
    email: joi.string().required(),
    password: joi.string().required(),
  }),
};

const logout = {
  body: joi.object().keys({
    refreshToken: joi.string().required(),
  }),
};

const refreshToken = {
  body: joi.object().keys({
    refreshToken: joi.string().required(),
  }),
};

const forgotPassword = {
  body: joi.object().keys({
    email: joi.string().email().required(),
  }),
};

const resetPassword = {
  query: joi.object().keys({
    token: joi.string().required(),
  }),
  body: joi.object().keys({
    token: joi.string().required().custom(password),
  }),
};

const changePassword = {
  body: joi.object().keys({
    currentPassword: joi.string().required(),
    newPassword: joi.string().required().min(8)
      .custom((value, helpers) => {
        if (!value.match(/\d/) || !value.match(/[a-zA-Z]/)) {
          return helpers.message('password must contain at least 1 letter and 1 number');
        }
        return value;
      }),
  }),
};

const verifyEmail = {
  body: joi.object().keys({
    token: joi.string().required(),
  }),
};

module.exports = {
  register,
  login,
  logout,
  refreshToken,
  forgotPassword,
  resetPassword,
  changePassword,
  verifyEmail,
};
