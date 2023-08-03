const { budgetCeiling } = require("../controllers/budget");

module.exports = (app) => {
  app.post("/budgetCeiling", budgetCeiling);
};
