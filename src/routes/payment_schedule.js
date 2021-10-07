import {
  paymentSchedule,
  updateBudget,
  postBudget
} from "../controllers/payment_schedule";

module.exports = (app) => {
  app.post("/post_payment_schedule", paymentSchedule);
  app.post("/update_budgets", updateBudget);
  app.post("/post_budgets", postBudget);
};
