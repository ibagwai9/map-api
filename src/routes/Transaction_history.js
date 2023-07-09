const { TransactionHistory } = require("../controllers/TransactionHistory");

module.exports = (app) => {
  app.get("/transaction-history", TransactionHistory);

};
