const db = require("../models");
const QRCode = require("qrcode");
const moment = require("moment");
const { default: axios } = require("axios");
require("dotenv").config();
const today = moment().format("YYYY-MM-DD");

const getInvoiceDetails = async (refNo) => {
  try {
    const reqData = await db.sequelize.query(
      `SELECT a.user_id,b.org_name,b.account_type, b.email, b.phone, a.reference_number, a.item_code, SUM(a.dr) AS dr,GROUP_CONCAT(a.description) , b.name FROM tax_transactions a 
      JOIN tax_payers b on a.user_id=b.taxID
       where   a.reference_number='${refNo}' AND a.transaction_type='invoice'`
    );
    console.log(reqData[0]);
    return reqData[0];
  } catch (error) {
    return error;
  }
};

const getInvoiceDetailsLGA = async (refNo) => {
  try {
    const reqData = await db.sequelize.query(
      `SELECT a.user_id,b.org_name,b.account_type,  b.email, b.phone, a.reference_number, a.item_code, a.dr AS dr,a.cr AS cr,a.description ,a.tax_payer, b.name FROM tax_transactions a 
      JOIN tax_payers b on a.user_id=b.taxID
       where   a.reference_number='${refNo}'`
    );
    console.log(reqData[0]);
    return reqData[0];
  } catch (error) {
    return error;
  }
};

const callHandleTaxTransaction = async (replacements) => {
  try {
    const results = await db.sequelize.query(
      `CALL HandleTaxTransaction( :query_type, 
        :user_id, 
        :agent_id,
        :tax_payer,
        :org_name,
        :mda_code,
        :item_code,    
        :rev_code,
        :description,
        :nin_id,
        :tin,
        :amount,
        :transaction_date,
        :transaction_type,
        :status,
        :reference_number,
        :department,
        :service_category,
        :tax_station,
        :sector,
        :mda_var,
        :mda_val,
        :start_date, 
        :end_date
        )`,
      {
        replacements,
      }
    );
    return results;
  } catch (err) {
    console.error("Error executing stored procedure:", err);
    throw new Error("Error executing stored procedure: " + JSON.stringify(err));
  }
};

// This can serve create invoice or payment and nothing else
const postTrx = async (req, res) => {
  console.log(req.body);
  const {
    user_id = null,
    agent_id = null,
    tax_list = [],
    transaction_date,
    tax_station = null,
    nin_id = null,
    tin = null,
    paid_by = null,
    confirmed_by = null,
    payer_acct_no = null,
    bank_name = null,
    start_date = null,
    end_date = null,
    tax_payer = null,
  } = req.body;

  // Helper function to call the tax transaction asynchronously
  const callHandleTaxTransactionAsync = async (tax) => {
    const {
      item_code = null,
      tax_parent_code = null,
      department = null,
      description,
      amount,
      economic_code = null,
      mda_code = null,
      mda_name = null,
      service_category = null,
      transaction_type,
      ipis_no = null,
      sector = null,
      mda_var = null,
      mda_val = null,
    } = tax;
    const refNo = moment().format("YYMMDDhhssS");
    let code = null;

    switch (sector) {
      case "TAX":
        code = "112" + refNo;
        break;
      case "NON TAX":
        code = "224" + refNo;
        break;
      case "LAND":
        code = "336" + refNo;
        break;
      case "VEHICLE":
        code = "448" + refNo;
        break;
      case "LGA":
        code = "565" + refNo;
        break;
      default:
        code = "100" + refNo;
    }

    const params = {
      query_type: `insert_${transaction_type}`,
      item_code,
      user_id,
      agent_id: agent_id ? agent_id : null,
      tax_payer,
      description,
      amount,
      transaction_date,
      transaction_type,
      status: "saved",
      ipis_no,
      reference_number: code,
      rev_code: economic_code,
      mda_code: mda_code,
      nin_id,
      tin,
      org_name: mda_name,
      paid_by,
      confirmed_by,
      payer_acct_no,
      bank_name,
      department,
      service_category: service_category ? service_category : tax_parent_code,
      tax_station,
      sector,
      start_date,
      end_date,
      mda_var,
      mda_val,
    };

    try {
      console.log({ params });
      const results = await callHandleTaxTransaction(params);
      return { success: true, data: results, ref_no: code };
    } catch (error) {
      console.error("Error executing stored procedure:", error);
      return {
        success: false,
        message: "Error executing stored procedure: " + JSON.stringify(error),
      };
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
        message:
          "Error executing some stored procedures: " + JSON.stringify(error),
      });
    }

    // Return the output parameters in the response
    return res.status(200).json({ success: true, data: transactionResults });
  } catch (err) {
    console.error("Error executing stored procedure:", err);
    return res.status(500).json({
      success: false,
      message: "Error executing stored procedures:" + JSON.stringify(err),
    });
  }
};

// Update | Payment approval and others operations should use get
const getTrx = async (req, res) => {
  const {
    user_id = null,
    agent_id = null,
    tax_payer = null,
    item_code = null,
    status = null,
    description = null,
    amount = null,
    transaction_date = null,
    transaction_type = null,
    rev_code = null,
    mda_code = null,
    nin_id = null,
    tin = null,
    org_name = null,
    paid_by = null,
    confirmed_by = null,
    payer_acct_no = null,
    bank_name = null,
    query_type = null,
    start_date = null,
    end_date = null,
    department = null,
    service_category = null,
    ref_no = null,
    ipis_no = null,
    sector = null,
    tax_station = null,
    reference_number = null,
    mda_var = null,
    mda_val = null,
  } = req.query;

  // console.log(req.query)

  const params = {
    user_id,
    agent_id,
    item_code,
    status,
    description,
    amount,
    transaction_date,
    transaction_type,
    reference_number: ref_no ? ref_no : reference_number,
    rev_code,
    mda_code,
    nin_id,
    tin,
    org_name,
    paid_by,
    confirmed_by,
    payer_acct_no,
    query_type,
    start_date,
    end_date,
    ipis_no,
    tax_payer,
    department,
    tax_station,
    service_category,
    sector,
    mda_var,
    mda_val,
  };

  try {
    const data = await callHandleTaxTransaction(params);
    
    if(data && data.length){
      if(data[0].printed > 0 ) {
        // already printed at least once
        console.log("already printed at least once")
        const user = await db.sequelize.query(`SELECT * FROM users WHERE id=${user_id}`)
        if(user && user.length) {
          console.log(user, user_id)
          if(user[0].length){
            const userIsHOD = user[0][0].rank === 'Department Head';
            if(userIsHOD) {
              console.log("User is HOD")
              return res.json({ success: true, data });
            } else {
              console.log("User is not HOD")
              return res.json({ success: true, data: [], message: "Receipt already generated!" });
            }
          } else {
            return res.json({ success: true, data: [], message: "Cannot verify user!" });
          }
        } else {
          return res.json({
            success: true,
            data: [],
            message: "Cannot verify user!",
          });
        }
      } else {
        return res.json({ success: true, data });
      }
    } else {
      res.status(500).json({
        success: false,
        message: "Invoice not paid or not found.",
      });
    }
  } catch (error) {
    console.error("Error executing stored procedure:", error);
    res.status(500).json({
      success: false,
      message: "Error executing stored procedure",
    });
  }
};

async function getQRCode(req, res) {
  // Get the reference number from the query parameter

  // Create the URL with the reference number parameter
  const refno = req.query.ref_no || "";
  try {
    const payment = await db.sequelize.query(
      `SELECT * FROM tax_transactions WHERE reference_number =${refno} LIMIT 1;`
    );

    const transaction_date =
      payment[0] && payment[0].length ? payment[0][0].updated_at : "Invalid";
    const interswitch_ref =
      payment[0] && payment[0].length ? payment[0][0].interswitch_ref : "N/A";
    const description =
      payment[0] && payment[0].length ? payment[0][0].description : "";
    const status =
      payment[0] && payment[0].length ? payment[0][0].status : "Invalid";
    const paymentAmount =
      payment[0] && payment[0].length ? payment[0][0].paymentAmount : 0;
    const user = await db.sequelize.query(
      `SELECT * FROM tax_payers WHERE taxID = ${payment[0][0].user_id}`
    );

    const name =
      // user[0].account_type === "org" ? 
      user[0].org_name || user[0].name;

    const url = `https://kirmas.kn.gov.ng/payment-${
      status === "saved" ? "invoice" : status == "Paid" ? "receipt" : "404"
    }?ref_no=${refno}`;
    // Create a payload string with the payer's information
    const payload =
      status === "Paid" || status === "success"
        ? `${paymentAmount} was paid on ${moment(transaction_date).format(
            "DD/MM/YYYY HH:mm:ss"
          )}\nwith Transaction ID: ${refno}\nValidation No.: ${interswitch_ref}\nby TaxPayer : ${name}\nFor ${description}`
        : `This invoice is not yet paid`;
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

const getPaymentSummary = (req, res) => {
  const { start_date, end_date, query_type, mda_code } = req.query;
  db.sequelize
    .query(
      `CALL GetPaymentsSummary( :query_type,:start_date, :end_date, :mda_code)`,
      {
        replacements: {
          start_date: start_date,
          end_date: end_date,
          query_type: query_type,
          mda_code: mda_code,
        },
      }
    )
    .then((resp) => {
      res.json({ success: true, data: resp[0] });
    })
    .catch((err) => {
      console.error(err);
      res.json({ success: false, msg: "Error occurred" });
    });
};

const getTertiary = (inst_code) => {
  axios
    .get(
      `https://kanoacademic.igr.ng/api/v1/notifications?institute=${inst_code}`,
      {
        headers: {
          Authorization: `Bearer ${process.env.INST_API_TOKEN}`,
        },
      }
    )
    .then((resp) => {
      // const responseData = JSON.parse(resp.data);
      console.log(resp.data);
      if (resp.status === 200) {
        let arr = [];
        console.log(resp.data);
        resp.data.data.forEach((item) => {
          console.log(item);
          arr.push(
            db.sequelize.query(
              "CALL institution_transactions( :query_type,:id,:refno,:institutionName,:institutionCode,:accountNumber,:datetime,:amount,:narration,:anyOtherData,:payerName,:phone)",
              {
                replacements: {
                  ...item,
                  id: item._id,
                  query_type: "insert",
                  datetime: moment(item.datetime).format("YYYY-MM-DD hh:mm:ss"),
                  institutionCode: inst_code,
                },
              }
            )
          );
        });
        Promise.all(arr)
          .then((results) => {
            console.log(results);
            // res.json({ results, success: true });
          })
          .catch((error) => {
            // res.status(500).json({ error });
            console.log(error);
          });
      }
    })
    .catch((error) => {
      console.log(error);
    });
};

const insertTertiaryData = async (inst) => {
  const {
    query_type,
    id,
    refno,
    institutionName,
    institutionCode,
    accountNumber,
    datetime,
    amount,
    narration,
    anyOtherData,
    payerName,
    phone,
  } = inst;
  try {
    const results = await db.sequelize.query(
      "call intitution_transaction( :query_type,:id,:refno,:institutionName,:institutionCode,:accountNumber,:datetime,:amount,:narration,:anyOtherData,:payerName,:phone)",
      {
        replacements: {
          query_type,
          id,
          refno,
          institutionName,
          institutionCode,
          accountNumber,
          datetime,
          amount,
          narration,
          anyOtherData,
          payerName,
          phone,
        },
      }
    );
    console.log(results);

    return results;
  } catch (error) {
    console.log(error);
    throw new Error(
      "Error executing stored procedure: " + JSON.stringify(error)
    );
  }
};

const callTransactionList = (req, res) => {
  const { from = today, to = today, query_type = "" } = req.query;

  db.sequelize
    .query(`CALL selectTransactions(:from,:to,:query_type)`, {
      replacements: {
        from,
        to,
        query_type,
      },
    })
    .then((resp) => {
      res.json({ success: true, data: resp });
    })
    .catch((err) => {
      console.error(err);
      res.json({ success: false, msg: "Error occurred" });
    });
};

const printReport = (req, res) => {
  const today = moment().format("YYYY-MM-DD");
  // console.log(req.body)
  const {
    ref_no = "",
    user_id = "",
    from = today,
    to = today,
    query_type = "",
  } = req.body;
  db.sequelize
    .query(`CALL print_report (:query_type, :ref_no, :user_id, :from, :to)`, {
      replacements: {
        ref_no,
        user_id,
        from,
        to,
        query_type,
      },
    })
    .then((resp) => {
      res.json({ success: true, data: resp });
    })
    .catch((err) => {
      console.error(err);
      res.json({ success: false, msg: "Error occurred" });
    });
};

module.exports = {
  getQRCode,
  getTrx,
  postTrx,
  getInvoiceDetails,
  getPaymentSummary,
  getInvoiceDetails,
  getTertiary,
  callTransactionList,
  getInvoiceDetailsLGA,
  printReport,
};
