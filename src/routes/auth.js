const passport = require("passport");
const {
  SignIn,
  SignUp,
  verifyToken,
  getUsers,
  TreasuryAppSignIn,
  TreasuryAppSignUp,
  BudgetAppSignUp,
  verifyTokenTreasuryApp,
  searchUser,
  getAdmins,
  UpdateTaxPayer
}  = require ("../controllers/auth");

module.exports = (app) => {
  app.post("/sign_in", SignIn);
  app.post("/sign_up", SignUp);
  app.post("/treasury-app/sign_in", TreasuryAppSignIn);
  app.post("/treasury-app/sign_up", TreasuryAppSignUp);
  app.post("/budget-app/sign_in", TreasuryAppSignIn);
  app.post("/budget-app/sign_up", BudgetAppSignUp);
  app.get("/treasury-app/verify-token", verifyTokenTreasuryApp);
  app.post("/register-kigra");
  app.get("/users", passport.authenticate("jwt", { session: false }), getUsers);
  app.get(
    "/verify-token",
    passport.authenticate("jwt", { session: false }),
    verifyToken
  );
  app.get(
    "/users/serach",
    passport.authenticate("jwt", { session: false }),
    searchUser
  );
  app.get('/users/get-admins', passport.authenticate("jwt", { session: false }), getAdmins);
 app.post('/auths/-post-users',passport.authenticate("jwt", { session: false }), UpdateTaxPayer)
};
