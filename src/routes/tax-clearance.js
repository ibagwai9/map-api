const passport = require("passport");
const { postTaxClearance, getTaxClearance, verifyTaxClearance } = require("../controllers/tax-clearance");

module.exports = (app) => {
    app.post(
        "/post/tax-clearance",
        passport.authenticate("jwt", { session: false }),
        postTaxClearance
    );
    app.get(
        "/get/tax-clearance",
        passport.authenticate("jwt", { session: false }),
        getTaxClearance
    );
    app.get(
        "/verify-tax_clearance",
        // passport.authenticate("jwt", { session: false }),
        verifyTaxClearance
    );
    
}