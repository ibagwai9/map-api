const { postcoa } = require("../controllers/coa")
const { postOrganization } = require("../controllers/organization")

module.exports = (app) => {

    app.post("/organization", postOrganization)
    app.post('/coa',postcoa)
    
  }