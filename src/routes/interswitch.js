const { getTransaction } = require("../controllers/interswitch");
const land = require("../controllers/land-interswitch");
const lga = require("../controllers/lga-interswitch");

module.exports = (app) => {
  app.post(
    "/getTransaction",
    // passport.authenticate("jwt", { session: false }),
    getTransaction
  );
  app.post("/invoice", land.handleInvoice); //Tax/None tax, Motor Lisense
  app.post("/lga-invoices", land.handleInvoice); // LGA INVOICE
  app.post("/land-use-charges", land.handleInvoice); // LAND INVOICE
};
