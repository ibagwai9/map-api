const db = require("../models");
const QRCode = require("qrcode");
const moment = require("moment");

const crypto = require("crypto");
const axios = require("axios");
require("dotenv").config();
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
      `SELECT 
  a.user_id,
  a.phone,
  a.reference_number,
  a.item_code,
  a.dr AS dr,
  a.cr AS cr,
  a.description,
  a.tax_payer,
  a.tax_payer as name
FROM
  kirmasDB.tax_transactions a
WHERE
a.reference_number='${refNo}'  `);
    console.log(reqData[0]);
    // and a.status NOT  IN ('paid', 'success')
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
        :phone,
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
        :invoice_status,
        "",
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
    // throw new Error("Error executing stored procedure: " + JSON.stringify(err));
  }
};

const generateCommonRefNo = (sector) => {
  let refNo = String(moment().format("YYMMDDhhmm"));
  refNo = refNo.slice(0, 9 - refNo.length) + Math.floor(Math.random() * 1000);
  let code = null;

  switch (sector) {
    case "TAX":
      code = "112";
      break;
    case "NON TAX":
      code = "224";
      break;
    case "LAND":
      code = "336";
      break;
    case "VEHICLE":
      code = "448";
      break;
    case "LGA":
      code = "565";
      break;
    default:
      code = "100";
  }
  return code + refNo;
};

const postTrx = async (req, res) => {
  const {
    user_id = null,
    agent_id = null,
    tax_list = [],
    transaction_date,
    nin_id = null,
    tin = null,
    paid_by = null,
    phone = null,
    confirmed_by = null,
    payer_acct_no = null,
    payer_bank_name = null,
    start_date = null,
    end_date = null,
    tax_station = null,
    tax_payer = "",
    invoice_status = "",
  } = req.body;

  const commonRefNo = generateCommonRefNo(tax_list[0].sector);
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
      sector = null,
      mda_var = null,
      mda_val = null,
    } = tax;

    const params = {
      query_type: `insert_${transaction_type}`,
      item_code,
      user_id,
      agent_id,
      description,
      tax_station,
      amount,
      transaction_date,
      transaction_type,
      status: "saved",
      reference_number: commonRefNo,
      rev_code: economic_code,
      mda_code: mda_code,
      nin_id,
      tin,
      phone,
      org_name: mda_name,
      paid_by,
      tax_payer,
      confirmed_by,
      payer_acct_no,
      payer_bank_name,
      department,
      service_category: service_category ? service_category : tax_parent_code,
      sector,
      mda_var,
      mda_val,
      start_date,
      end_date,
      invoice_status,
      // tracking_status: tracking_status ? tracking_status : "",
    };

    try {
      const results = await callHandleTaxTransaction(params);
      // if (commonRefNo && params.query_type.includes('insert')) {
      //   db.sequelize.query(`CALL update_invoice('add-budget-code', '${item_code}',  '${commonRefNo}');`)
      // }
      return { success: true, data: results, ref_no: commonRefNo };
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
    item_code = null,
    status = null,
    description = null,
    amount = null,
    tax_payer = null,
    transaction_date = null,
    transaction_type = null,
    rev_code = null,
    mda_code = null,
    nin_id = null,
    tin = null,
    phone = null,
    org_name = null,
    paid_by = null,
    confirmed_by = null,
    payer_acct_no = null,
    payer_bank_name = null,
    query_type = null,
    start_date = null,
    end_date = null,
    department = null,
    service_category = null,
    ref_no = null,
    sector = null,
    reference_number = null,
    tax_station = null,
    mda_var = null,
    mda_val = null,
    invoice_status = "",
    tracking_status = "",
  } = req.query;

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
    phone,
    org_name,
    tax_payer: paid_by,
    confirmed_by,
    payer_acct_no,
    payer_bank_name,
    tax_payer,
    query_type,
    start_date,
    end_date,
    department,
    service_category,
    tax_station,
    mda_var,
    mda_val,
    sector,
    invoice_status,
    tracking_status: tracking_status ? tracking_status : "",
  };

  try {
    const data = await callHandleTaxTransaction(params);
    res.json({ success: true, data });
  } catch (error) {
    console.error("Error executing stored procedure:", error);
    res.status(500).json({
      success: false,
      message: "Error executing stored procedure: " + JSON.stringify(error),
    });
  }
};

// klklklklklklkl

async function getQRCode(req, res) {
  // Get the reference number from the query parameter

  // Create the URL with the reference number parameter
  const refno = req.query.ref_no || "";
  try {
    const payment = await db.sequelize.query(
      `SELECT * FROM tax_transactions WHERE reference_number =${refno} LIMIT 1;`
    );

    const transaction_date =
      payment[0] && payment[0].length
        ? payment[0][0].transaction_date
        : "Invalid";

    const status =
      payment[0] && payment[0].length ? payment[0][0].status : "Invalid";
    console.log(payment);
    console.log(payment[0][0]);
    const user = await db.User.findOne({
      where: { taxID: payment[0][0]?.user_id },
    });

    const name = user.dataValues.name || "Invslid";
    const phoneNumber = user.dataValues.phone || "Invalid";
    console.log({ user: user.dataValues.id });

    const url = `https://kirmas.kn.gov.ng/payment-${status === "saved" ? "invoice" : status == "Paid" ? "receipt" : "404"
      }?ref_no=${refno}`;
    // Create a payload string with the payer's information
    const payload = `Date:${moment(transaction_date).format(
      "DD/MM/YYYY"
    )}\nName: ${name}\nPhone: ${phoneNumber}\n${status === "saved" ? "Invoice" : status === "Paid" ? "Receipt" : "Invalid"
      } ID: ${refno}\nUrl: ${url}`;
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
  const { from = today, to = today, query_type = "", mda_code = null, sector = null } = req.query;
  // console.log(req.user);
  db.sequelize
    .query(`CALL selectTransactions(:query_type,:from,:to,:mda_code,:sector)`, {
      replacements: {
        from,
        to,
        query_type,
        mda_code,
        sector: sector ? sector : req.user[0].sector,
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
  // console.log(req.user[0].id);
  const {
    ref_no = "",
    user_id = "",
    user_name = "",
    mda_code = "",
    from = today,
    to = today,
    query_type = "",
    view = "all",
    sector = "",
    offset = 0,
    limit = 200,
  } = req.body;
  // const { sector = "" } = req.query;
  db.sequelize
    .query(
      `CALL print_report (:query_type, :ref_no, :user_id, :user_name, :from, :to, :mda_code, :sector, :view, :offset, :limit)`,
      {
        replacements: {
          ref_no,
          user_id,
          user_name: user_name ? user_name : req.user[0].name,
          from,
          to,
          query_type,
          mda_code,
          sector,
          view,
          offset,
          limit,
        },
      }
    )
    .then((resp) => {
      res.json({ success: true, data: resp });
    })
    .catch((err) => {
      console.error(err);
      res.json({ success: false, msg: "Error occurred" });
    });
};
const validatePayment = async (req, res) => {
  try {
    const merchantSecretKey =
      "E187B1191265B18338B5DEBAF9F38FEC37B170FF582D4666DAB1F098304D5EE7F3BE15540461FE92F1D40332FDBBA34579034EE2AC78B1A1B8D9A321974025C4";

    const {
      ref_no = "",
      sector = "",
      amount = "0",
      item_code = "",
    } = req.query;

    const timestamp = Math.floor(Date.now() / 1000);

    const hashv = merchantSecretKey + ref_no + timestamp;
    const thash = crypto.createHash("sha512").update(hashv).digest("hex");
    let code = null;
    switch (sector) {
      case "TAX":
        code = "6576";
        break;
      case "NON TAX":
        code = "6601";
        break;
      case "LAND":
        code = "6913";
        break;
      case "LGA":
        code = "8285";
        break;
      default:
        code = "6405";
    }

    let maxRetries = 3;
    let currentRetry = 0;

    while (currentRetry < maxRetries) {
      try {
        const response = await axios.get(
          `http://sandbox.interswitchng.com/webpay/api/v1/gettransaction.json?productid=${code}&transactionreference=${ref_no}&amount=${amount * 100
          }`,
          {
            headers: {
              GET: "/HTTP/1.1",
              Host: "sandbox.interswitchng.com",
              "User-Agent":
                "Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.9.0.1) Gecko/2008070208 Firefox/3.0.1",
              Accept: "*/*",
              "Accept-Language": "en-us,en;q=0.5",
              "Keep-Alive": 300,
              Connection: "keep-alive",
              Hash: thash,
            },
          }
        );

        console.log({ response });

        if (response.data.status === "APPROVED") {
          res.status(200).json({ message: "Payment successful" });
        } else {
          res.status(400).json({ message: response.data.error });
        }

        break; // Break out of the loop if the request is successful
      } catch (error) {
        if (error.code === "ECONNRESET") {
          currentRetry++;
          console.warn(
            `Retrying request. Retry ${currentRetry} of ${maxRetries}`
          );
        } else {
          // Handle other errors
          console.error(error);
          res.status(500).json({ message: "Error validating payment", error });
          break; // Break out of the loop if it's not a connection reset error
        }
      }
    }
  } catch (error) {
    console.error("Error validating payment:", error);
    res.status(500).json({ message: "Error validating payment", error });
  }
};

module.exports = {
  validatePayment,
  getQRCode,
  getTrx,
  postTrx,
  getInvoiceDetails,
  getInvoiceDetailsLGA,
  getPaymentSummary,
  getInvoiceDetails,
  getTertiary,
  printReport,
  callTransactionList,
};
