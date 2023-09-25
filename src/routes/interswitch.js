const { getTransaction, handleInvoice } = require("../controllers/interswitch");
const passport = require("passport");

module.exports = (app) => {
  app.post('/getTransaction',passport.authenticate("jwt", { session: false }), getTransaction);

  app.post('/invoice', handleInvoice)
}
