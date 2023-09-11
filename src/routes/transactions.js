const { getTrx, postTrx } =  require("../controllers/transactions");
const {requireAuth} = require("../config/config.js")

  module.exports = (app) => {
    app.post('/transactions/execute', postTrx)
    app.get('/transactions/retrieve', getTrx)
  };
  