const { 
  tsa_code,
   kigra_get_account_list,
   getAccChart,
   getKigrTaxes,
   postKigrTaxes,
   getLGAs,
   getLGARevenues
} = require("../controllers/tsa");

module.exports = (app) => {
  app.get("/tsa-code",
   tsa_code);
  app.get("/kigra_get_account_list",
   kigra_get_account_list);
  app.get('/get-kigra-accounts',
   getAccChart)
  app.get('/kigra-taxes',
   getKigrTaxes)
  app.post('/kigra-taxes',
   postKigrTaxes)
   app.get('/get/lga-list', getLGAs)
   // /get/lga-revenues is deprecated (Use /get/kigra-taxes)
   app.get('/get/lga-revenues', getLGARevenues)
};
