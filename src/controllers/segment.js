const moment = require("moment");
const db = require("../models");
const today = moment().format("YYYY-MM-DD");

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


export const  getTaxPayer = (req, res) => {
  const {query_type=''} = req.query
  db.sequelize
    .query(
      `select * from tax_payers`
    )
    .then((results) => {
      res.json({ success: true, results:results[0] });
    })
    .catch((err) => {
      console.log(err);
      res.status(500).json({ success: false, err });
    });
};