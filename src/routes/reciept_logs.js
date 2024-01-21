const passport = require("passport");
const { reciept_logs } = require("../controllers/reciept_logs");
module.exports = (app) => {
  app.post(
    "/reciept_logs",
    passport.authenticate("jwt", { session: false }),
    reciept_logs
  );
};
