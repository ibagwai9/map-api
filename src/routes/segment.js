const { postContactUs, getTaxPayers, addDepartment } = require("../controllers/segment");
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
  
  // app.post(
  //   "/add-departments",
  //   passport.authenticate("jwt", { session: false }),
  //   addDepartment
  // );
  

};
