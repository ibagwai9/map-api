const { getTransaction, handleInvoice } = require("../controllers/interswitch");


module.exports = (app) => {
  app.post('/getTransaction',passport.authenticate("jwt", { session: false }), getTransaction);

  app.post('/invoice', handleInvoice)
}
