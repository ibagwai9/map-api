const { getTaxPayers } = require("../controllers/segment");
const passport = require("passport");

module.exports = (app) => {
  // app.post("/segment", postSegment);
  app.get(
    "/get-tax-payer",
    passport.authenticate("jwt", { session: false }),
    getTaxPayers
  );
};
