const { getTaxPayer } = require("../controllers/segment");

module.exports = (app) => {
  // app.post("/segment", postSegment);
  app.get("/get-tax-payer", getTaxPayer);
};
