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
    date_from = null,
    date_to = null,
    transactionData = [],
  } = req.body;
  console.log(req.body);
  const { query_type = "" } = req.query;
  db.sequelize
    .query(
      `call reciept_logs (:query_type,:id,:ref_no,:status,:invoice_status,:remark,:staff_name,:staff_id,:interswitch_ref_no,:logId,:date_from,:date_to)`,
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
          date_from: date_from || transactionData[0]?.date_from || null,
          date_to: date_to || transactionData[0]?.date_to || null,
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

module.exports.getTransaction = (req, res) => {
  const { reference_number = "" } = req.query;
  db.sequelize
    .query(
      `SELECT  DISTINCT reference_number,tax_payer,GROUP_CONCAT(description," ") as description,dr,date_from,date_to,status  FROM tax_transactions t  WHERE t.reference_number='${reference_number}' and dr>0`,
      {
        replacements: {
          reference_number,
        },
      }
    )
    .then((resp) => {
      res.json({ success: true, data: resp[0] });
    })
    .catch((error) => {
      console.error({ error });
      res.status(500).json({ error, msg: "Error occurred" });
    });
};

module.exports.getTransactionReq = (req, res) => {
  const { tracking_status = "" } = req.query;
  db.sequelize
    .query(
      `SELECT  DISTINCT reference_number,tax_payer,GROUP_CONCAT(description," ") as description,dr,date_from,date_to,status FROM tax_transactions   where tracking_status=:tracking_status and  dr>0 GROUP BY reference_number`,
      {
        replacements: {
          tracking_status,
        },
      }
    )
    .then((resp) => {
      res.json({ success: true, data: resp[0] });
    })
    .catch((error) => {
      console.error({ error });
      res.status(500).json({ error, msg: "Error occurred" });
    });
};
