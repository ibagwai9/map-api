import {
 SignIn,
 SignUp,
 verifyToken
} from "../controllers/auth";

module.exports = (app) => {
  app.post("/sign_in", SignIn);
  app.post("/sign_up", SignUp)
  app.get("/verify-token", verifyToken)
};
