const httpstatus = require("http-status");
const ApiError = require("../utils/ApiError");
const pick = require("../utils/pick");
const catchAsync = require("../utils/catchAsync");
const userService = require("../services/user.services");

const createUser = catchAsync(async (req, res) => {
  const user = await userService.createUser(req.body);
  res.status(201).json(user.toObject());
});

const getUsers = catchAsync(async (req, res) => {
  const filter = pick(req.query, ["name", "role"]);
  const options = pick(req.query, ["sortBy", "limit", "page"]);
  const user = await userService.queryUsers(filter, options);
  res.send(result);
});

const getUser = catchAsync(async (req, res) => {
  const user = await userService.getUserById(req.params.userId); //get user by his ID.
  if (!user) {
    throw new ApiError(httpstatus.NOT_FOUND, "User is not defined");
  }
  res.send(user);
});

const updateUser = catchAsync(async (req, res) => {
  const user = await userService.updatedUserById(req.params.userId, req.body);
  res.send(user);
});

const deleteUser = catchAsync(async (req, res) => {
  const user = await userService.deleteUserById(req.params.userId);
  res.status(204).send();
});

module.exports = {
  createUser,
  getUsers,
  getUser,
  updateUser,
  deleteUser,
};
