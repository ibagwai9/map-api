const { budgetCeiling, insertBudgetCeiling } = require("../controllers/budget");

module.exports = (app) => {
  app.post("/budgetCeiling",passport.authenticate("jwt", { session: false }), budgetCeiling);
  app.post("/insert-budgetCeiling",passport.authenticate("jwt", { session: false }), insertBudgetCeiling);
};
