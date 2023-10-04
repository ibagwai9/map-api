const { getTransaction, handleInvoice, handleLgaInvoice } = require("../controllers/interswitch");


module.exports = (app) => {
  app.post('/getTransaction',
  // passport.authenticate("jwt", { session: false }), 
  getTransaction);
  app.post('/invoice', handleInvoice)
  app.post('/lga-invoices', handleLgaInvoice)
  app.post('/land-use-charges', handleLgaInvoice)
}
