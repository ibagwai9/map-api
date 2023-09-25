const { upload } = require("../config/multer.js");

const {
  paymentSchedule,
  paymentScheduleArray,
  updateBudget,
  postBudget,
  budget_summary,
  mda_bank_details,
  select_mda_bank_details,
  get_budget_summary,
  get_batch_list,
  updateBudgetCode,
  postChequeDetails,
  approvalCollection,
  getMdaBankDetails,
  fileUploader,
  fetchApprovalImages,
  batchUpload,
  getReports,
  getNextCode,
  postNextCode,
  getApprovalAttachment,
  deleteApproveCol,
  getApproveCol,
  reportDashboard,
} = require("../controllers/payment_schedule");
const passport = require("passport");

module.exports = (app) => {
  app.post(
    "/post_payment_schedule",
    passport.authenticate("jwt", { session: false }),
    paymentSchedule
  );
  app.post(
    "/post_approval_collection",
    passport.authenticate("jwt", { session: false }),
    approvalCollection
  );
  app.post(
    "/post_check_details",
    passport.authenticate("jwt", { session: false }),
    postChequeDetails
  );
  app.post(
    "/post_payment_schedule_array",
    passport.authenticate("jwt", { session: false }),
    paymentScheduleArray
  );
  app.post(
    "/update_budgets",
    passport.authenticate("jwt", { session: false }),
    updateBudget
  );
  app.post(
    "/batch-upload-budget",
    passport.authenticate("jwt", { session: false }),
    batchUpload
  );
  app.post(
    "/post_budgets",
    passport.authenticate("jwt", { session: false }),
    postBudget
  );
  app.post(
    "/budget_summary",
    passport.authenticate("jwt", { session: false }),
    budget_summary
  );
  app.post(
    "/mda_bank_details",
    passport.authenticate("jwt", { session: false }),
    mda_bank_details
  );
  app.post(
    "/select_mda_bank_details",
    passport.authenticate("jwt", { session: false }),
    select_mda_bank_details
  );
  app.post(
    "/select_mda_bank_details/:id",
    passport.authenticate("jwt", { session: false }),
    select_mda_bank_details
  );
  app.get(
    "/get-budget-summary",
    passport.authenticate("jwt", { session: false }),
    get_budget_summary
  );
  app.post(
    "/get-budget-summary1",
    passport.authenticate("jwt", { session: false }),
    get_budget_summary
  );
  app.post(
    "/get_batch_list",
    passport.authenticate("jwt", { session: false }),
    get_batch_list
  );
  app.post(
    "/update-budget-code",
    passport.authenticate("jwt", { session: false }),
    updateBudgetCode
  );
  app.get(
    "/get_mdabank_details",
    passport.authenticate("jwt", { session: false }),
    getMdaBankDetails
  );
  app.post(
    "/fetch_approval_images",
    passport.authenticate("jwt", { session: false }),
    fetchApprovalImages
  );
  app.post(
    "/post_images",
    upload.array("files"),
    passport.authenticate("jwt", { session: false }),
    fileUploader
  );
  app.delete(
    "/delete-approve-collection",
    passport.authenticate("jwt", { session: false }),
    deleteApproveCol
  );
  app.get(
    "/get-approve-col",
    passport.authenticate("jwt", { session: false }),
    getApproveCol
  );

  app.get(
    "/get-reports",
    passport.authenticate("jwt", { session: false }),
    getReports
  );

  app.get(
    "/number-generator",
    passport.authenticate("jwt", { session: false }),
    getNextCode
  );
  app.post(
    "/number-generator",
    passport.authenticate("jwt", { session: false }),
    postNextCode
  );

  app.get(
    "/fetch-approval-images",
    passport.authenticate("jwt", { session: false }),
    getApprovalAttachment
  );

  // REPORTS
  app.get(
    "/reports/budget-report-ag",
    passport.authenticate("jwt", { session: false }),
    reportDashboard
  );
};
