const { getTransaction, handleInvoice } = require("../controllers/interswitch");


module.exports = (app) => {
  app.post('/getTransaction', getTransaction);

  app.post('/invoice', handleInvoice)
}
