const { postAccount, getId, getNumber } = require("../controllers/account");
const { postSector } = require("../controllers/sector");
const passport = require("passport");

module.exports = (app) => {
  app.post(
    "/sector",
    passport.authenticate("jwt", { session: false }),
    postSector
  );
  app.post(
    "/account",
    passport.authenticate("jwt", { session: false }),
    postAccount
  );
  app.get(
    "/getId/:id?",
    passport.authenticate("jwt", { session: false }),
    getId
  );
  app.get(
    "/getNumber",
    passport.authenticate("jwt", { session: false }),
    getNumber
  );
  // app.get("/getSector/:query_type", user.GetSector)
};
