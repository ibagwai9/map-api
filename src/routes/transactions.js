const { 
  getTrx, 
  postTrx, 
  getQRCode, 
  getPaymentSummary 
} =  require("../controllers/transactions");

const {requireAuth} = require("../config/config.js")

  module.exports = (app) => {
    app.post('/transactions/execute', postTrx)
    app.get('/transactions/retrieve', getTrx)
    app.get('/transactions/get-qr-code', getQRCode)
    app.get('//get-payment-summary', getPaymentSummary)
  };
