const passport = require("passport");
const { getTransaction } = require("../controllers/interswitch");
const land = require("../controllers/land-interswitch");
module.exports = (app) => {
  app.post(
    "/getTransaction",
    // passport.authenticate("jwt", { session: false }),
    getTransaction
  );
  app.post("/invoice", land.handleInvoice); //Tax/Non tax, Motor Lisense
  app.post("/lga-invoices", land.handleInvoice); // LGA INVOICE
  app.post("/land-use-charges", land.handleInvoice); // LAND INVOICE
  app.post("/test-bank", land.handleInvoice); // LAND INVOICE
  app.post("/webhook", land.webHook);
  app.post(
    "/inter-response",
    passport.authenticate("jwt", { session: false }),
    land.interResponse
  );
};
