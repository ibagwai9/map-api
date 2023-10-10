const {
  getTransaction,
  handleInvoice,
  handleLgaInvoice,
} = require("../controllers/interswitch");
const land = require("../controllers/land-interswitch");
const tax = require("../controllers/tax-interswitch");
const lga = require("../controllers/lga-interswitch");

module.exports = (app) => {
  app.post(
    "/getTransaction",
    // passport.authenticate("jwt", { session: false }),
    getTransaction
  );
  app.post("/invoice", handleInvoice); //Tax/None tax, Motor Lisense
  app.post("/tax/invoices", handleInvoice); //Tax/None tax, Motor Lisense
  app.post("/nontax/invoices", handleInvoice); //Tax/None tax, Motor Lisense
  app.post("/lga-invoices", lga.handleInvoice); // LGA INVOICE
  app.post("/land-use-charges", handleInvoice);
};
