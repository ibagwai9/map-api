const moment = require("moment");
const db = require("../models");
const today = moment().format("YYYY-MM-DD");

<<<<<<< HEAD
// module.exports =  postSegment = (req, res) => {
//   const {
//     segment_name="",segment_size ="",segmnt_type=""
//   } = req.body;
//   console.log(req.body);
//   const {query_type=''} = req.query
//   db.sequelize
//     .query(
//       `call segment (:segment_name,:segment_size,:segmnt_type,:query_type)`,
//       {
//         replacements: {
//             segment_name,segment_size,segmnt_type,query_type,
//         },
//       }
//     )
//     .then((results) => {
//       res.json({ success: true, results });
//     })
//     .catch((err) => {
//       console.log(err);
//       res.status(500).json({ success: false, err });
//     });
// };

module.exports.getTaxPayers = (req, res) => {
  const { query_type = "" } = req.query;
  db.sequelize
    .query(`select * from tax_payers`)
    .then((results) => {
      res.json({ success: true, results: results[0] });
=======
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
>>>>>>> 7d8bcd1966c3fc5a25e797673566c187f8181a6f
    })
    .catch((err) => {
      console.log(err);
      res.status(500).json({ success: false, err });
    });
};
<<<<<<< HEAD
=======


module.exports.getTaxPayer = (req, res) => {
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
>>>>>>> 7d8bcd1966c3fc5a25e797673566c187f8181a6f
