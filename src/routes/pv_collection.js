const {
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
  fetchNgfAccountChart,
  getTsaAccount,
  getTaxes,
  contractorPaymentScheduleArray,
  getTaxSchedule,
} = require("../controllers/pv_collection");

module.exports = (app) => {
  app.post(
    "/post_pv_collection",
    passport.authenticate("jwt", { session: false }),
    pvCollection
  );
  app.get(
    "/tsa-account",
    passport.authenticate("jwt", { session: false }),
    getTsaAccount
  );
  app.post(
    "/post_tsa_funding",
    passport.authenticate("jwt", { session: false }),
    tsaFundingArray
  );
  app.post(
    "/post_tsa_funding_s",
    passport.authenticate("jwt", { session: false }),
    fecthTsaFunding
  );
  app.post(
    "/update_pv_code",
    passport.authenticate("jwt", { session: false }),
    updatePvCode
  );
  app.post(
    "/post_contractor_schedule_array",
    passport.authenticate("jwt", { session: false }),
    contractorScheduleArray
  );
  app.post(
    "/post_contractor_schedule",
    passport.authenticate("jwt", { session: false }),
    contractorSchedule
  );
  app.post(
    "/post_contractor_payment_schedule_array",
    passport.authenticate("jwt", { session: false }),
    contractorPaymentScheduleArray
  );
  app.post(
    "/post_project_type",
    passport.authenticate("jwt", { session: false }),
    projectType
  );
  app.post(
    "/post_taxes",
    passport.authenticate("jwt", { session: false }),
    taxes
  );
  app.get(
    "/get_taxes",
    passport.authenticate("jwt", { session: false }),
    getTaxes
  );
  app.get(
    "/tax-schedule",
    passport.authenticate("jwt", { session: false }),
    getTaxSchedule
  );
  app.post(
    "/post_contractor_details",
    passport.authenticate("jwt", { session: false }),
    contractorDetails
  );
  app.post(
    "/post_contractor_bank_details",
    passport.authenticate("jwt", { session: false }),
    contractor_bank_details
  );
  app.post(
    "/fetchNgfAccountChart",
    passport.authenticate("jwt", { session: false }),
    fetchNgfAccountChart
  );
};
