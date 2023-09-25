const { budgetCeiling, insertBudgetCeiling } = require("../controllers/budget");
const passport = require("passport");
module.exports = (app) => {
  app.post("/budgetCeiling",passport.authenticate("jwt", { session: false }), budgetCeiling);
  app.post("/insert-budgetCeiling",passport.authenticate("jwt", { session: false }), insertBudgetCeiling);
};
