import {
  paymentSchedule,
  updateBudget,
  postBudget,
  budget_summary,
  mda_bank_details,
  select_mda_bank_details
} from "../controllers/payment_schedule";

module.exports = (app) => {
  app.post("/post_payment_schedule", paymentSchedule);
  app.post("/update_budgets", updateBudget);
  app.post("/post_budgets", postBudget);
  app.post("/budget_summary", budget_summary);
  app.post("/mda_bank_details", mda_bank_details);
  app.post("/select_mda_bank_details", select_mda_bank_details);
};
