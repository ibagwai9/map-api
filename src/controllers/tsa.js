const db = require("../models");

const UUIDV4 = require("uuid").v4;

exports.tsa_code = (req, res) => {
  const { types = "FAAC" } = req.query;
  db.sequelize
    .query(`CALL tsa_code(:types)`, {
      replacements: {
        types,
      },
    })
    .then((results) => {
      res.json({
        success: true,
        results,
      });
    })
    .catch((err) => {
      console.log(err);
      error(err);
    });
};
