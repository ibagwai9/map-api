import {
  paymentSchedule,
  paymentScheduleArray,
  updateBudget,
  postBudget,
  budget_summary,
  mda_bank_details,
  select_mda_bank_details,
  get_budget_summary,
  get_batch_list
} from "../controllers/payment_schedule";

module.exports = (app) => {
  app.post("/post_payment_schedule", paymentSchedule);
  app.post("/post_payment_schedule_array", paymentScheduleArray);
  app.post("/update_budgets", updateBudget);
  app.post("/post_budgets", postBudget);
  app.post("/budget_summary", budget_summary);
  app.post("/mda_bank_details", mda_bank_details);
  app.post("/select_mda_bank_details", select_mda_bank_details);
  app.post("/select_mda_bank_details/:id", select_mda_bank_details);
  app.get('/get-budget-summary', get_budget_summary)
  app.post('/get-budget-summary1', get_budget_summary)
  app.post("/get_batch_list", get_batch_list);
};
