const {
  getTransaction,
  handleInvoice,
  handleLgaInvoice,
} = require("../controllers/interswitch");
const land = require("../controllers/land-interswitch");
const tax = require("../controllers/tax-interswitch");
const nontax = require("../controllers/nontax-interswitch");

module.exports = (app) => {
  app.post(
    "/getTransaction",
    // passport.authenticate("jwt", { session: false }),
    getTransaction
  );
  app.post("/invoice", handleInvoice); //Tax/None tax, Motor Lisense
  app.post("/tax/invoices", tax.handleInvoice); //Tax/None tax, Motor Lisense
  app.post("/nontax/invoices", nontax.handleInvoice); //Tax/None tax, Motor Lisense
  app.post("/lga-invoices", handleLgaInvoice);
  app.post("/land-use-charges", land.handleInvoice);
};
