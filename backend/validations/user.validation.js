const joi = require("joi");
const { password, objectId } = require("./custom.validation");

const createUser = {
  body: joi.object().keys({
    firstname: joi.string().required(),
    lastname: joi.string().required(),
    email: joi.string().required().email(),
    password: joi.string().required().custom(password),
    role: joi.string().required().valid("user", "admin"),
  }),
};

const getUsers = {
  query: joi.object().keys({
    name: joi.string(),
    role: joi.string(),
    sortBy: joi.string(),
    limit: joi.number().integer(),
    page: joi.number().integer(),
  }),
};

const getUser = {
  params: joi.object().keys({
    userId: joi.string().custom(objectId),
  }),
};

const updateUser = {
  params: joi.object().keys({
    userId: joi.string().custom(objectId),
  }),
  body: joi
    .object()
    .keys({
      email: joi.string().email(),
      password: joi.string().custom(password),
      name: joi.string(),
    })
    .min(1),
};

const deleteUser = {
  params: joi.object().keys({
    userId: joi.string().custom(objectId),
  }),
};

module.exports = {
  createUser,
  getUsers,
  getUser,
  updateUser,
  deleteUser,
};
