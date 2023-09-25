const { TransactionHistory } = require("../controllers/TransactionHistory");
const passport = require("passport");
module.exports = (app) => {
  app.get("/transaction-history",passport.authenticate("jwt", { session: false }), TransactionHistory);

};
