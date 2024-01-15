const db = require("../models");

module.exports.reciept_logs = (req, res) => {
  const {
    ref_no = "",
    status = " ",
    remark = "",
    staff_name = "",
    staff_id = "",
  } = req.body;
  console.log(req.body);
  const { query_type = "" } = req.query;
  db.sequelize
    .query(
      `call reciept_logs (:query_type,:id,:ref_no,:status,:remark,:staff_name,:staff_id)`,
      {
        replacements: {
          query_type,
          id: null,
          ref_no,
          status,
          remark,
          staff_name,
          staff_id,
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
