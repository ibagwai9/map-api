import { getTrx, postTrx } from "../controllers/transactions";
const {requireAuth} = require("../config/config.js")

  module.exports = (app) => {
    app.post('/tansactions/execute', postTrx)
    app.get('/tansactions/retrieve', getTrx)
  };
  