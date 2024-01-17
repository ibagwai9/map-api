const db = require("../models");

module.exports.reciept_logs = (req, res) => {
  const {
    ref_no = "",
    status = " ",
    invoice_status = "",
    remark = "",
    staff_name = "",
    staff_id = "",
    interswitch_ref_no = "",
    logId = "",
  } = req.body;
  console.log(req.body);
  const { query_type = "" } = req.query;
  db.sequelize
    .query(
      `call reciept_logs (:query_type,:id,:ref_no,:status,:invoice_status,:remark,:staff_name,:staff_id,:interswitch_ref_no,:logId)`,
      {
        replacements: {
          query_type,
          id: null,
          ref_no,
          status,
          invoice_status,
          remark,
          staff_name,
          staff_id,
          interswitch_ref_no,
          logId,
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
