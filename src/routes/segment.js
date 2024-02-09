const {
  getMdaList,
  postMdaList,
  verifyMda,
  getPaynowByreferenceNum,
} = require("../controllers/sector");
const {
  postContactUs,
  getTaxPayers,
  addDepartment,
} = require("../controllers/segment");
const passport = require("passport");

module.exports = (app) => {
  app.get(
    "/get-tax-payer",
    passport.authenticate("jwt", { session: false }),
    getTaxPayers
  );
  app.post(
    "/post-contact-us",
    passport.authenticate("jwt", { session: false }),
    postContactUs
  );

  app.get("/get-mda-list", getMdaList);
  app.get("/verify-mda", verifyMda);
  app.post("/post-mda-list", postMdaList);
  app.get("/verify-paynow-by-reference", getPaynowByreferenceNum);

  // app.post(
  //   "/add-departments",
  //   passport.authenticate("jwt", { session: false }),
  //   addDepartment
  // );
};
