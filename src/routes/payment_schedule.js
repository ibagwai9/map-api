const { upload } = require('../config/multer.js')

import {
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
  postNextCode
} from '../controllers/payment_schedule'

module.exports = (app) => {
  app.post('/post_payment_schedule', paymentSchedule)
  app.post('/post_approval_collection', approvalCollection)
  app.post('/post_check_details', postChequeDetails)
  app.post('/post_payment_schedule_array', paymentScheduleArray)
  app.post('/update_budgets', updateBudget)
  app.post('/batch-upload-budget', batchUpload)
  app.post('/post_budgets', postBudget)
  app.post('/budget_summary', budget_summary)
  app.post('/mda_bank_details', mda_bank_details)
  app.post('/select_mda_bank_details', select_mda_bank_details)
  app.post('/select_mda_bank_details/:id', select_mda_bank_details)
  app.get('/get-budget-summary', get_budget_summary)
  app.post('/get-budget-summary1', get_budget_summary)
  app.post('/get_batch_list', get_batch_list)
  app.post('/update-budget-code', updateBudgetCode)
  app.get('/get_mdabank_details', getMdaBankDetails)
  app.post('/fetch_approval_images', fetchApprovalImages)
  app.post('/post_images', upload.array('files'), fileUploader)

  app.get('/get-reports', getReports)

  app.get('/number-generator', getNextCode)
  app.post('/number-generator', postNextCode)
}
