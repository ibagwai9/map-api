const { postAccount, getId, getNumber } = require("../controllers/account");
const { postSector } = require("../controllers/sector");

module.exports = (app) => {
  
    app.post("/sector", postSector)
    app.post("/account", postAccount)
    app.get("/getId/:id?", getId);
    app.get('/getNumber',getNumber)
    // app.get("/getSector/:query_type", user.GetSector)
  }