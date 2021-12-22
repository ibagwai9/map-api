import {
  pvCollection,
  tsaFundingArray,
  fecthTsaFunding,
  updatePvCode,
  contractorScheduleArray,
  contractorSchedule,
  projectType,
  taxes,
  contractorDetails,
  contractor_bank_details,
  fetchNgfAccountChart
} from "../controllers/pv_collection";

module.exports = (app) => {
  app.post("/post_pv_collection", pvCollection);
   app.post("/post_tsa_funding", tsaFundingArray);
   app.post("/post_tsa_funding_s", fecthTsaFunding);
   app.post("/update_pv_code", updatePvCode);
   app.post("/post_contractor_schedule_array", contractorScheduleArray);
   app.post("/post_contractor_schedule", contractorSchedule);
   app.post("/post_project_type", projectType);
   app.post("/post_taxes", taxes);
   app.post("/post_contractor_details", contractorDetails);
    app.post("/post_contractor_bank_details", contractor_bank_details);
    app.post("/fetchNgfAccountChart", fetchNgfAccountChart);
};
