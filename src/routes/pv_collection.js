import {
  pvCollection,
  tsaFundingArray,
  tsaFunding
} from "../controllers/pv_collection";

module.exports = (app) => {
  app.post("/post_pv_collection", pvCollection);
   app.post("/post_tsa_funding", tsaFundingArray);
   app.post("/post_tsa_funding_s", tsaFunding);
};
