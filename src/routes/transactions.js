const { 
  getTrx, 
  postTrx, 
  getQRCode, 
  getPaymentSummary 
} =  require("../controllers/transactions");

const {requireAuth} = require("../config/config.js")

  module.exports = (app) => {
    app.post('/transactions/execute',passport.authenticate("jwt", { session: false }), postTrx)
    app.get('/transactions/retrieve',passport.authenticate("jwt", { session: false }), getTrx)
    app.get('/transactions/get-qr-code',passport.authenticate("jwt", { session: false }), getQRCode)
    app.get('/get-payment-summary',passport.authenticate("jwt", { session: false }), getPaymentSummary)
  };
