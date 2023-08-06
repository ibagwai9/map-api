const { budgetCeiling, insertBudgetCeiling } = require("../controllers/budget");

module.exports = (app) => {
  app.post("/budgetCeiling", budgetCeiling);
  app.post("/insert-budgetCeiling", insertBudgetCeiling);
};
