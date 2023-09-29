const passport = require("passport");
const config = require("../config/config");
const { allowOnly } = require("../services/routesHelper");
const {
  create,
  login,
  findAllUsers,
  findById,
  update,
  deleteUser,
  verifyAuth,
} = require("../controllers/user");
// const passport = require("passport");

module.exports = (app) => {
  // create a new user
  app.post("/api/users/create", create);

  // user login
  app.post("/api/users/login", login);

  //retrieve all users
  app.get(
    "/api/users",
    passport.authenticate("jwt", {
      session: false,
    }),
    // allowOnly(config.accessLevels.admin,
    findAllUsers
    // )
  );

  // retrieve user by id
  app.get(
    "/api/users/:userId",
    passport.authenticate("jwt", {
      session: false,
    }),
    allowOnly(config.accessLevels.admin, findById)
  );
  // retrieve user by id
  app.get(
    "/api/user/verify",
    passport.authenticate("jwt", {
      session: false,
    }),
    verifyAuth
  );

  // update a user with id
  app.put(
    "/api/users/:userId",
    passport.authenticate("jwt", {
      session: false,
    }),
    allowOnly(config.accessLevels.user, update)
  );

  // delete a user
  app.delete(
    "/api/users/:userId",
    passport.authenticate("jwt", {
      session: false,
    }),
    allowOnly(config.accessLevels.admin, deleteUser)
  );
};
