const httpstatus = require("http-status");
const ApiError = require("../utils/ApiError");
const User = require("../models/Users.model");

const createUser = async (userBody) => {
  if (await User.isEmailTaken(userBody.email)) {
    throw new ApiError(httpstatus.BAD_REQUESTS, "Email is already taken");
  }
  return User.create(userBody);
};

const queryUsers = async(filter, options) => {
  const users = await User.paginate(filter, options);
  return users;
}

const getUserById = async (id) => {
  return User.findById(id);
};

const getUserByEmail = async (email) => {
  return User.findOne({ email });
};

// take userId and checks if it's excited or not "userId", take the updatedBody whether it's email,name,etc.. and check if it's taken or not.
const updatedUserById = async (userId, updateBody) => {
  //it took the user id and check if it's registerd or not.
  const user = await getUserById(userId);
  if (!user) {
    throw new ApiError(httpstatus.NOT_FOUND, "User not found!"); // Error, user is not registerd!
  }
  if (updateBody.email && (await user.isEmailTaken(updateBody.email, userId))) {
    //Will compare the updated email if it's stored before in DB.

    throw new ApiError(httpstatus.BAD_REQUESTS, "Email is already used!");
  }
  Object.assign(user, updateBody);
  await user.save();
  return user;
};

const deleteUserById = async (userId) => {
  const user = await getUserById(userId);
  if (!user) {
    throw new ApiError(httpstatus.NOT_FOUND, "User not found!");
  }
  await user.deleteOne();
  return user;
};

module.exports = {
  createUser,
  queryUsers,
  getUserById,
  getUserByEmail,
  updatedUserById,
  deleteUserById,
};
