const { getTaxPayer, postContactUs } = require("../controllers/segment");
const passport = require("passport");

module.exports = (app) => {
  // app.post("/segment", postSegment);
  app.get(
    "/get-tax-payer",
    passport.authenticate("jwt", { session: false }),
    getTaxPayer
  );
  app.post(
    "/post-contact-us",
    passport.authenticate("jwt", { session: false }),
    postContactUs
  );
};
