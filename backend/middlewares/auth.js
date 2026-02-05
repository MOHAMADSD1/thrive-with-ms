const passport = require("passport");
const httpstatus = require("http-status");
const ApiError = require("../utils/ApiError");
const { roleRights } = require("../config/roles");

// req = the request object, resolve&reject they allow us to do either of them after passport's authentication checks
//requiredRight is an array of rights, defined in roles.js
const verifyCallBack =
  (req, resolve, reject, requiredRights) => async (err, user, info) => {
    if (err || info || !user) {
      return reject(
        new ApiError(httpstatus.UNAUTHORIZED, "Please authenticate")
      );
    }
    req.user = user;

    //console.log("Token payload:", payload);
    console.log("User from DB:", user);

    if (requiredRights.lenght) {
      const userRights = roleRights.get(user.role);
      const hasRequiredRights = requiredRights.every((requiredRight) =>
        userRights.includes(requiredRight)
      );
      if (!hasRequiredRights && req.params.id !== user.id) {
        return reject(new ApiError(httpstatus.FORBIDDERN, "Forbidden"));
      }
    }
    resolve();
  };

const auth =
  (...requiredRights) =>
  async (req, res, next) => {
    return new Promise((resolve, reject) => {
      passport.authenticate(
        "jwt",
        { session: false },
        verifyCallBack(req, resolve, reject, requiredRights)
      )(req, res, next);
      console.log("Bearer token from request:", req.headers.authorization);
    })
      .then(() => next())
      .catch((err) => next(err));
  };

module.exports = auth;
