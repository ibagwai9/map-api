import {
  pvCollection
} from "../controllers/pv_collection";

module.exports = (app) => {
  app.post("/post_pv_collection", pvCollection);
};
