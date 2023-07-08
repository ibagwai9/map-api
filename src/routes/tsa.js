<<<<<<< HEAD
import { tsa_code, kigra_get_account_list, getAccChart } from "../controllers/tsa";

module.exports = (app) => {
  app.get("/tsa-code", tsa_code);
  app.get("/kigra_get_account_list", kigra_get_account_list);
  app.get('/get-kigra-accounts', getAccChart)
};
=======
import { tsa_code, kigra_get_account_list } from '../controllers/tsa'

module.exports = (app) => {
  app.get('/tsa-code', tsa_code)
  app.get('/kigra_get_account_list', kigra_get_account_list)
}
>>>>>>> 8725857f9eacec4c5f9c0932bdf312078dfdfb22
