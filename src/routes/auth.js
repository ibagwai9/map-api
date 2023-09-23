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
  getAdmins
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
  app.get("/users", getUsers);
  app.get("/verify-token", verifyToken);
  app.get("/users/serach", searchUser);
  app.get('/users/get-admins', getAdmins);
};
