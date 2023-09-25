const { postcoa } = require("../controllers/coa")
const { postOrganization } = require("../controllers/organization")
const passport = require("passport");
module.exports = (app) => {

    app.post("/organization",passport.authenticate("jwt", { session: false }), postOrganization)
    app.post('/coa',passport.authenticate("jwt", { session: false }),postcoa)
    
  }