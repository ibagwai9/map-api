const passport = require("passport");
const { reciept_logs, getTransaction, getTransactionReq } = require("../controllers/reciept_logs");
module.exports = (app) => {
  app.post(
    "/reciept_logs",
    passport.authenticate("jwt", { session: false }),
    reciept_logs
  );
  app.get(
    "/adjust-transactions",
    passport.authenticate("jwt", { session: false }),
    getTransaction
  );
  app.get(
    "/get-trans-req",
    passport.authenticate("jwt", { session: false }),
    getTransactionReq
  );
  
  
};
