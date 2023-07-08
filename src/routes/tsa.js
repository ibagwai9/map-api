import { tsa_code, kigra_get_account_list, getAccChart } from "../controllers/tsa";

module.exports = (app) => {
  app.get("/tsa-code", tsa_code);
  app.get("/kigra_get_account_list", kigra_get_account_list);
  app.get('/get-kigra-accounts', getAccChart)
};
