const { postContactUs, getTaxPayers } = require("../controllers/segment");
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
};
