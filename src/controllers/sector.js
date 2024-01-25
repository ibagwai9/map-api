const moment = require("moment");
const db = require("../models");
const { uuid } = require("uuidv4");
const today = moment().format("YYYY-MM-DD");
const QRCode = require("qrcode");
module.exports.postSector = (req, res) => {
  const { sector_code = "", sector_name = "", remark = "" } = req.body;
  console.log(req.body);
  const { query_type = "" } = req.query;
  db.sequelize
    .query(`call sector (:sector_code,:sector_name,:remark,:query_type)`, {
      replacements: {
        sector_code,
        sector_name,
        remark,
        query_type,
      },
    })
    .then((results) => {
      res.json({ success: true, results });
    })
    .catch((err) => {
      console.log(err);
      res.status(500).json({ success: false, err });
    });
};

module.exports.getMdaList = (req, res) => {
  db.sequelize
    .query(`SELECT DISTINCT mda_name,mda_code FROM taxes where mda_name!='' `)
    .then((results) => {
      res.json({ success: true, results });
    })
    .catch((err) => {
      console.log(err);
      res.status(500).json({ success: false, err });
    });
};

module.exports.postMdaList = (req, res) => {
  let id = uuid();
  const { mda_name = "", mda_code = "" } = req.body;
  console.log(req.body);
  db.sequelize
    .query(
      `INSERT INTO mda_list(mda_name,mda_code,item_code) 
      VALUES ("${mda_name}", "${mda_code}","${id}")`
    )
    .then((results) => {
      res.json({ success: true, results, id: id });
    })
    .catch((err) => {
      console.log(err);
      res.status(500).json({ success: false, err });
    });
};

module.exports.verifyMda = (req, res) => {
  const { id } = req.query;
  console.log(req.query)
  db.sequelize
    .query(`SELECT *  from mda_list where item_code="${id}"`)
    .then((results) => {
      res.json({ success: true, results, id: id });
    })
    .catch((err) => {
      console.log(err);
      res.status(500).json({ success: false, err });
    });
};
// module.exports.GetSector = (req, res) => {
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
