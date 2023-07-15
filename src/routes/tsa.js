import { 
  tsa_code,
   kigra_get_account_list,
   getAccChart,
   getKigrTaxes,
   postKigrTaxes
} from "../controllers/tsa";

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
  
};
