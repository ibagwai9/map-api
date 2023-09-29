const { getTransaction, handleInvoice, handleLgaInvoice } = require("../controllers/interswitch");


module.exports = (app) => {
  app.post('/getTransaction', getTransaction);

  app.post('/invoice', handleInvoice)
  app.post('/lga-invoices', handleLgaInvoice)
}
