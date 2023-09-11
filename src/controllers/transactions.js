const { json } = require("sequelize");
const db = require("../models");
const QRCode = require("qrcode");
const moment = require("moment");
require("dotenv").config();

const getInvoiceDetails = async (userId, refNo) => {
  try {
    const reqData = await db.sequelize.query(
      `SELECT a.user_id, a.reference_number, a.dr, a.description, b.name FROM tax_transactions a 
        JOIN users b on a.user_id=b.id 
        where 
        #a.user_id="${userId}" and 
        a.reference_number="${userId}" AND a.transaction_type='invoice'`
    );
    return reqData[0];
  } catch (error) {
    return error;
  }
};

const callHandleTaxTransaction = async (replacements) => {
  try {
    const results = await db.sequelize.query(
      `CALL HandleTaxTransaction(:query_type, :user_id, :agent_id,:org_code,
        :rev_code, :description, :nin_id, :org_name, :paid_by, :confirmed_by, 
        :payer_acct_no, :payer_bank_name, :cr, :dr, :transaction_date, 
        :transaction_type, :status, :reference_number, :start_date, :end_date)`,
      {
        replacements,
      }
    );
    return results;
  } catch (err) {
    console.error("Error executing stored procedure:", err);
    throw new Error("Error executing stored procedure: "+JSON.stringify(err));
  }
};

// This can serve create invoice or payment and nothing else
const postTrx = async (req, res) => {
  const {
    user_id = null,
    agent_id = null,
    sector_id = 1,
    tax_list = [],
    transaction_date,
    reference_number,
    nin_id = "",
    org_name = "",
    paid_by = "",
    confirmed_by = "",
    payer_acct_no = "",
    payer_bank_name = "",
    start_date = null,
    end_date = null,
  } = req.body;

  // Helper function to call the tax transaction asynchronously
  const callHandleTaxTransactionAsync = async (tax) => {
    const {
      description,
      amount,
      rev_code = null,
      org_code = null,
      transaction_type,
    } = tax;

    const params = {
      query_type: `insert_${transaction_type}`,
      user_id,
      agent_id,
      sector_id,
      description,
      cr: transaction_type === "payment" ? amount : 0,
      dr: transaction_type === "invoice" ? amount : 0,
      transaction_date,
      transaction_type,
      status: description === "invoice" ? "paid" : "saved",
      reference_number,
      rev_code,
      org_code,
      nin_id,
      org_name,
      paid_by,
      confirmed_by,
      payer_acct_no,
      payer_bank_name,
      start_date,
      end_date,
    };

    try {
      console.log({ params });
      const results = await callHandleTaxTransaction(params);
      return { success: true, data: results };
    } catch (error) {
      console.error("Error executing stored procedure:", error);
      return { success: false, message: "Error executing stored procedure: "+JSON.stringify(error) };
    }
  };

  try {
    // Execute all tax transactions asynchronously using Promise.all
    const transactionResults = await Promise.all(
      tax_list.map(callHandleTaxTransactionAsync)
    );

    // Check if any transaction failed
    const hasFailedTransaction = transactionResults.some(
      (result) => !result.success
    );

    if (hasFailedTransaction) {
      return res.status(500).json({
        success: false,
        message: "Error executing some stored procedures: "+JSON.stringify(error) ,
      });
    }

    // Return the output parameters in the response
    return res.status(200).json({ success: true, data: transactionResults });
  } catch (err) {
    console.error("Error executing stored procedure:", err);
    return res
      .status(500)
      .json({ success: false, message: "Error executing stored procedures:"+JSON.stringify(err)  });
  }
};

// Update | Payment approval and others operations should use get
const getTrx = async (req, res) => {
  const {
    user_id = null,
    agent_id = null,
    sector_id = 1,
    status = "",
    transaction_date = null,
    reference_number = "",
    nin_id = "",
    org_name = "",
    paid_by = "",
    confirmed_by = "",
    payer_acct_no = "",
    payer_bank_name = "",
    description = "",
    start_date = null,
    end_date = null,
    rev_code = "",
    org_code = "",
    transaction_type = "invoice",
    query_type = "",
  } = req.query;

  const params = {
    user_id,
    agent_id,
    sector_id,
    description,
    cr: 0,
    dr: 0,
    transaction_date,
    transaction_type,
    status,
    reference_number,
    rev_code,
    org_code,
    nin_id,
    org_name,
    paid_by,
    confirmed_by,
    payer_acct_no,
    payer_bank_name,
    query_type,
    start_date,
    end_date,
  };

  try {
    const data = await callHandleTaxTransaction(params);
    res.json({ success: true, data });
  } catch (error) {
    console.error("Error executing stored procedure:", error);
    res
      .status(500)
      .json({ success: false, message: "Error executing stored procedure: "+JSON.stringify(error)  });
  }
};

async function getQRCode(req, res) {
  // Get the reference number from the query parameter

  // Create the URL with the reference number parameter
  const refno = req.query.ref_no || "";
  const url = `${process.env.PUBLIC_URL}/receipt?ref_no=${refno}`;
  try {
    const payment = await db.sequelize.query(
      `SELECT * FROM tax_transactions WHERE reference_number =${refno} LIMIT 1;`
    );

    const transaction_date =
      payment[0] && payment[0].length
        ? payment[0][0].transaction_date
        : "Invalid";

      const status =
          payment[0] && payment[0].length
            ? payment[0][0].status
            : "Invalid";

    const user = await db.User.findOne({
      where: { id: payment[0][0].user_id },
    });

    const name = user.dataValues.name || "Invslid";
    const phoneNumber = user.dataValues.phone || "Invalid";
    console.log({ user: user.dataValues.id });

    // Create a payload string with the payer's information
    const payload = `Date:${moment(transaction_date).format('DD/MM/YYYY')}\nName: ${name}\nPhone: ${phoneNumber}\n${status==='saved'?'Invoice':status==='Paid'?'Receipt':'Invalid'} ID: ${refno}\nUrl: ${url}`;
    QRCode.toDataURL(payload, (err, dataUrl) => {
      if (err) {
        // Handle error, e.g., return an error response
        res.status(500).send("Error generating QR code");
      } else {
        // Set the response content type to PNG
        res.set("Content-Type", "image/png");

        // Send the QR code data URL as the response
        res.send(Buffer.from(dataUrl.split(",")[1], "base64"));
      }
    });
  } catch (e) {
    console.log("Error:", e);
    res.status(404).json({ success: false, msg: "Record not found" });
  }
}

module.exports = {
  getQRCode,
  getTrx,
  postTrx,
  getInvoiceDetails,
};
