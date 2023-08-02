const { budgetCeiling } = require("../controllers/budget");

module.exports = (app) => {
  app.get("/budgetCeiling", budgetCeiling);
};
