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
    ticket_id = null,
  } = req.body;
  console.log(req.body);
  const { query_type = "" } = req.query;
  db.sequelize
    .query(
      `call reciept_logs(:query_type,:id,:ref_no,:status,:invoice_status,:remark,:staff_name,:staff_id,:interswitch_ref_no,:logId,:date_from,:date_to,:ticket_id)`,
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
          ticket_id: ticket_id,
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
      `SELECT DISTINCT 
      reference_number, 
      tax_payer, 
      GROUP_CONCAT(description, " ") AS description, 
      dr, 
      date_from, 
      date_to, 
      status 
  FROM 
      tax_transactions t 
  WHERE 
      t.reference_number = :reference_number
      AND dr > 0 and status in ("saved")
  GROUP BY 
      reference_number, 
      tax_payer, 
      dr, 
      date_from, 
      date_to, 
      status 
  HAVING 
      COUNT(description) > 0 LIMIT 1
  `,
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

module.exports.getRemarks = (req, res) => {
  const { ticket_id = "", ref_no = "" } = req.query;
  db.sequelize
    .query(
      `SELECT * FROM reciept_logs WHERE ticket_id=:ticket_id and ref_no=:ref_no;`,
      {
        replacements: {
          ticket_id,
          ref_no,
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


module.exports.rejectReq = (req, res) => {
  const { ref_no = "" } = req.query;
  db.sequelize
    .query(
      `update tax_transactions SET tracking_status ="REJECTED" where reference_number=:ref_no;`,
      {
        replacements: {
          ref_no,
        },
      }
    )
    .then((resp) => {
      res.json({ success: true,resp });
    })
    .catch((error) => {
      console.error({ error });
      res.status(500).json({ error, msg: "Error occurred" });
    });
};

module.exports.getTransactionReq = (req, res) => {
  const { tracking_status = "",in_sector="" } = req.query;
  db.sequelize
    .query(
      `SELECT  DISTINCT reference_number,ticket_id,interswitch_ref,tax_payer,GROUP_CONCAT(description," ") as description,dr,date_from,date_to,status FROM tax_transactions   where  FIND_IN_SET(sector, :in_sector) > 0 and tracking_status=:tracking_status and  dr>0 GROUP BY reference_number`,
      {
        replacements: {
          tracking_status,
          in_sector
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


module.exports.reciept_logs_up = (req, res) => {
  const {
    ref_no = "",
    status = " ",
    invoice_status = "",
    remark = "",
    staff_name = "",
    staff_id = "",
    interswitch_ref_no = "",
    ticket_id = null,
  } = req.body;
  console.log(req.body);
  const { query_type = "" } = req.query;
  db.sequelize
    .query(
      `call reciept_logs_up(:query_type,:ref_no,:interswitch_ref_no,:status,:invoice_status,:remark,:staff_name,:staff_id,:ticket_id )`,
      {
        replacements: {
          query_type,
          ref_no,
          interswitch_ref_no,
          status,
          invoice_status,
          remark,
          staff_name,
          staff_id,
          ticket_id
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
