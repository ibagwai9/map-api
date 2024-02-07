const passport = require("passport");
const { reciept_logs, getTransaction, getTransactionReq, getRemarks, reciept_logs_up, rejectReq } = require("../controllers/reciept_logs");
module.exports = (app) => {
  app.post(
    "/reciept_logs",
    passport.authenticate("jwt", { session: false }),
    reciept_logs
  );
  
  app.post(
    "/reject-req",
    passport.authenticate("jwt", { session: false }),
    rejectReq
  );
  app.post(
    "/reciept_logs_up",
    passport.authenticate("jwt", { session: false }),
    reciept_logs_up
  );
  
  app.get(
    "/get-remarks",
    passport.authenticate("jwt", { session: false }),
    getRemarks
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
