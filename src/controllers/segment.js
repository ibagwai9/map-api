const moment = require("moment");
const db = require("../models");
const today = moment().format("YYYY-MM-DD");

module.exports.postContactUs = (req, res) => {
  const {
    fullname = "",
    email = "",
    message = "",
    insert_by = null,
  } = req.body;
  const { query_type = "insert" } = req.query;
  db.sequelize
    .query(
      `call contact_us(:query_type, :fullname,:email,:message,:insert_by)`,
      {
        replacements: {
          fullname,
          email,
          message,
          query_type,
          insert_by,
        },
      }
    )
    .then((results) => {
      res.json({ success: true, results });
    })
    .catch((err) => {
      console.log(err);
      res.status(500).json({ success: false, err });
    });
};

module.exports.getTaxPayers = (req, res) => {
  const { query_type = "" } = req.query;
  db.sequelize
    .query(`select * from tax_payers`)
    .then((results) => {
      res.json({ success: true, results: results[0] });
    })
    .catch((err) => {
      console.log(err);
      res.status(500).json({ success: false, err });
    });
};

// module.exports.addDepartment = (req, res) => {
//   const { description = "", type = "" } = req.body;
//   const { query_type = "insert" } = req.query;
//   db.sequelize
//     .query(`call add_department(:query_type, :description,:type)`, {
//       replacements: {
//         description,
//         type,
//         query_type,
//       },
//     })
//     .then((results) => {
//       res.json({ success: true, results });
//     })
//     .catch((err) => {
//       console.log(err);
//       res.status(500).json({ success: false, err });
//     });
// };
