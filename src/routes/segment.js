const { getTaxPayer } = require("../controllers/segment");

module.exports = (app) => {
  // app.post("/segment", postSegment);
  app.get("/get-tax-payer",passport.authenticate("jwt", { session: false }), getTaxPayer);
};
