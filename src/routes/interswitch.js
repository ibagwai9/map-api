const { getTransaction } = require("../controllers/interswitch");


module.exports = (app) => {
  app.post('/getTransaction', getTransaction);
}
