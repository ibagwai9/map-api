const moment = require("moment");
const db = require("../models");
const today = moment().format("YYYY-MM-DD");

export const postSector = (req, res) => {
  const {
    sector_code="",
    sector_name="",
    remark="",
  } = req.body;
  console.log(req.body);
  const {query_type=''} = req.query
  db.sequelize
    .query(
      `call sector (:sector_code,:sector_name,:remark,:query_type)`,
      {
        replacements: {
          sector_code,
          sector_name,
          remark,
          query_type,
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

// export const GetSector = (req, res) => {
//     const {
//       sector_code,
//       sector_name,
//       remark,
      
//     } = req.body;
//     console.log(req.body);
//     const query_type='select'
//     db.sequelize
//       .query(
//         `call sector (:sector_code,:sector_name,:remark,:query_type)`,
//         {
//           replacements: {
//             sector_code,
//             sector_name,
//             remark,
//             query_type,
//           },
//         }
//       )
//       .then((results) => {
//         res.json({ success: true, results });
//       })
//       .catch((err) => {
//         console.log(err);
//         res.status(500).json({ success: false, err });
//       });
//   };