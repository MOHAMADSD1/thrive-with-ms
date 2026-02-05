const httpstatus = require("http-status");
const userService = require("./user.services");
const tokenService = require("./token.services");
const Token = require("../models/Token.model");
const ApiError = require("../utils/ApiError");
const { tokenTypes } = require("../config/tokens");

const loginUserWithEmailAndPassword = async (email, password) => {
  const user = await userService.getUserByEmail(email);
  if (!user || !(await user.isPasswordMatch(password))) {
    throw new ApiError(httpstatus.UNAUTHORIZED, "Incorrect email or password");
  }
  return user;
};

const logout = async (refreshToken) => {
  const refreshTkenDoc = await Token.findOne({
    token: refreshToken,
    type: tokenTypes.REFRESH,
    blackListed: false,
  });
  if (!refreshTkenDoc) {
    throw new ApiError(httpstatus.NOT_FOUND, "Not found");
  }
  await refreshTkenDoc.deleteOne();
};

const refreshAuth = async(refreshToken) => {
    try {
        const refreshTokenDoc = await tokenService.verifyToken(refreshToken, tokenTypes.REFRESH);
        const user = await userService.getUserById(refreshTokenDoc.user);
        if(!user) {
            throw new Error();
        }
        await refreshTokenDoc.deleteOne();
        return tokenService.generateAuthToken(user);
    } catch (error) {
        throw new ApiError(httpstatus.UNAUTHORIZED, 'Please authenticate');
    }
};

const resetPassword = async(resetPasswordToken, newPassword) => {
 try {
    const resetPasswordTokenDoc = await tokenService.verifyToken(resetPasswordToken, tokenTypes.RESET_PASSWORD);
    const user = await userService.getUserById(resetPasswordTokenDoc.user);
    if(!user) {
        throw new Error();
    }
    await userService.updatedUserById(user.id, {password: newPassword});
    await Token.deleteMany({user: user.id, type: tokenTypes.RESET_PASSWORD});
} catch (error) {
    throw new ApiError(httpstatus.UNAUTHORIZED, "Password reset failed!");
}
};

const changePassword = async (userId, currentPassword, newPassword) => {
  const user = await userService.getUserById(userId);
  if (!user) {
    throw new ApiError(httpstatus.NOT_FOUND, "User not found");
  }

  if (!(await user.isPasswordMatch(currentPassword))) {
    throw new ApiError(httpstatus.UNAUTHORIZED, "Current password is incorrect");
  }

  await userService.updatedUserById(userId, { password: newPassword });
};



const verifyEmail = async(verifyEmailToken) => {
    try {
        const verifyEmailTokenDoc = await tokenService.verifyToken(verifyEmailToken, tokenTypes.VERFIY_EMAIL);
        const user = await userService.getUserById(verifyEmailTokenDoc.user);
        if(!user) {
            throw new Error();
        }
        await Token.deleteMany({ user: user.id, type: tokenTypes.VERFIY_EMAIL});
        await userService.updatedUserById(user.id, { isEmailVerified: true} );
    } catch (error) {
        throw new ApiError (httpstatus.UNAUTHORIZED, "Email verification failed");
    }
};

module.exports = {
    loginUserWithEmailAndPassword,
    logout,
    refreshAuth,
    resetPassword,
    verifyEmail,
    changePassword,
}; 
