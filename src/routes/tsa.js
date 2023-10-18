const {
  tsa_code,
  kigra_get_account_list,
  getAccChart,
  getKigrTaxes,
  postKigrTaxes,
  getLGAs,
  getLGARevenues,
  getMDAs,
  getMdaDepartments,
} = require("../controllers/tsa");
const passport = require("passport");

module.exports = (app) => {
  app.get(
    "/tsa-code",
    // passport.authenticate("jwt", { session: false }),
    tsa_code
  );
  app.get(
    "/kigra_get_account_list",
    passport.authenticate("jwt", { session: false }),
    kigra_get_account_list
  );
  app.get(
    "/get-kigra-accounts",
    passport.authenticate("jwt", { session: false }),
    getAccChart
  );
  app.get(
    "/kigra-taxes",
    passport.authenticate("jwt", { session: false }),
    getKigrTaxes
  );
  app.post(
    "/kigra-taxes",
    passport.authenticate("jwt", { session: false }),
    postKigrTaxes
  );
  app.get(
    "/get/lga-list",
    passport.authenticate("jwt", { session: false }),
    getLGAs
  );
  // /get/lga-revenues is deprecated (Use /get/kigra-taxes)
  app.get(
    "/get/lga-revenues",
    passport.authenticate("jwt", { session: false }),
    getLGARevenues
  );

  app.get(
    "/get/mdas",
    // passport.authenticate("jwt", { session: false }),
    getMDAs
  );

  app.get(
    "/get/mda-departments",
    passport.authenticate("jwt", { session: false }),
    getMdaDepartments
  );
};
