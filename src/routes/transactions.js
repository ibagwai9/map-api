const {
  getTrx,
  postTrx,
  getQRCode,
  getPaymentSummary,
  callTransactionList,
  printReport,
} = require("../controllers/transactions");
const passport = require("passport");

const { requireAuth } = require("../config/config.js");

module.exports = (app) => {
  app.post(
    "/transactions/execute",
    passport.authenticate("jwt", { session: false }),
    postTrx
  );
  app.get(
    "/transactions/retrieve",
    passport.authenticate("jwt", { session: false }),
    getTrx
  );
  app.get(
    "/transactions/get-qr-code",
    passport.authenticate("jwt", { session: false }),
    getQRCode
  );
  app.get(
    "/get-payment-summary",
    passport.authenticate("jwt", { session: false }),
    getPaymentSummary
  );
  app.get(
    "/get-transaction-details",
    passport.authenticate("jwt", { session: false }),
    callTransactionList
  );
  app.post(
    "/transactions/update-print-count",
    passport.authenticate("jwt", { session: false }),
    printReport
  );

  // app.get('/get-tertiary-trx',
  // // passport.authenticate("jwt", { session: false }),
  //  getTertiary)
};
