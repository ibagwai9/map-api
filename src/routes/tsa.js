import { tsa_code } from "../controllers/tsa";

module.exports = (app) => {
  app.get("/tsa-code", tsa_code);
};
