// controllers/transactionController.js
const axios = require("axios");
const crypto = require("crypto");
const { getInvoiceDetailsLGA } = require("./transactions");
const db = require("../models");
const moment = require("moment");
const merchantMacKey =
  "E187B1191265B18338B5DEBAF9F38FEC37B170FF582D4666DAB1F098304D5EE7F3BE15540461FE92F1D40332FDBBA34579034EE2AC78B1A1B8D9A321974025C4";

const getTransaction = async (req, res) => {
  const subpdtid = req.body.item_code; //6204; // Your product ID
  const amount = req.body.amount;
  const txnref = req.body.txnref;

  const hashv = subpdtid + txnref + merchantMacKey;
  const thash = crypto.createHash("sha512").update(hashv).digest("hex");

  const params = {
    productid: subpdtid,
    transactionreference: txnref,
    amount: amount,
  };
  const ponmo = new URLSearchParams(params).toString();

  const url = `https://sandbox.interswitchng.com/webpay/api/v1/gettransaction.json?${ponmo}`;

  const headers = {
    GET: "/HTTP/1.1",
    Host: "sandbox.interswitchng.com",
    "User-Agent":
      "Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.9.0.1) Gecko/2008070208 Firefox/3.0.1",
    Accept: "*/*",
    "Accept-Language": "en-us,en;q=0.5",
    "Keep-Alive": 300,
    Connection: "keep-alive",
    Hash: thash,
  };

  try {
    const response = await axios.get(url, { headers });
    res.json(response.data);
  } catch (error) {
    console.error("Error fetching transaction data:", error);
    res
      .status(500)
      .json({ error: "An error occurred while fetching transaction data" });
  }
};

const handleInvoiceValidation = async (reqJson, res) => {
  const custreference = reqJson.customerinformationrequest.custreference[0];
  const merchantreference =
    reqJson.customerinformationrequest.merchantreference[0];

  const sector = await getInvoice(custreference);
  if (!sector) {
    res.set("Content-Type", "text/xml");
    res.send(`<CustomerInformationResponse>
  <MerchantReference>${merchantreference}</MerchantReference>
  <Customers>
      <Customer>
      <Status>1</Status>
      <StatusMessage>Customer Reference not found or invalid</StatusMessage>
          <CustReference>${custreference}</CustReference>
          <Amount>0</Amount>
      </Customer>
  </Customers>
  </CustomerInformationResponse>`);
  } else {
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

    if (merchantreference === code) {
      getInvoiceDetailsLGA(custreference)
        .then((results) => {
          console.log(results);
          if (results && results.length) {
            const startDate = moment(results[0].date_from);
            const endDate = moment(results[0].date_to);
            const taxList = results.filter((item) => item.dr > 0);
            const amount = parseFloat(
              taxList.reduce((a, b) => a + parseFloat(b.dr), 0).toFixed(2)
            ).toFixed(2);

            const startFormatted = startDate.format("MMM, YY");
            const endFormatted = endDate.format("MMM, YY");

            const isWithinOneMonth = startDate.isSame(endDate, "month");

            // const formattedRange = isWithinOneMonth
            //   ? startFormatted
            //   : `${startFormatted} - ${endFormatted}`;

            // let firstName = results[0].name;
            console.log(results[0]);
            let firstName =
              results[0].tax_payer || results[0].org_name || results[0].name;
            let user_id = results[0].user_id;

            if (user_id === null) {
              res.set("Content-Type", "text/xml");
              res.send(`<CustomerInformationResponse>
        <MerchantReference>${merchantreference}</MerchantReference>
        <Customers>
            <Customer>
            <Status>1</Status>
            <StatusMessage>Customer Reference not found or invalid</StatusMessage>
                <CustReference>${custreference}</CustReference>
                <Amount>0</Amount>
            </Customer>
        </Customers>
    </CustomerInformationResponse>`);
            } else {
              const xmlString = `<PaymentItems>
                ${results
                  .filter((item) => item.cr > 0)
                  .map(
                    (product) => `
                  <Item>
                    <ProductName>${product.description}</ProductName>
                    <ProductCode>${product.item_code}</ProductCode>
                    <Quantity>1</Quantity>
                    <Price>${product.cr}</Price>
                    <Subtotal>${product.cr}</Subtotal>
                    <Tax>0</Tax>
                    <Total>${product.cr}</Total>
                  </Item>`
                  )
                  .join("")}</PaymentItems>`;
              let responseData = `<CustomerInformationResponse>
        <MerchantReference>${merchantreference}</MerchantReference>
        <Customers>
            <Customer>
                <Status>0</Status>
                <CustReference>${custreference}</CustReference>
                <FirstName>${firstName.replace("&", "&amp;")}</FirstName>
                <Phone>${results[0].phone}</Phone>
                <Amount>${amount}</Amount>
                ${xmlString}
            </Customer>
        </Customers>
    </CustomerInformationResponse>`;
              res.set("Content-Type", "text/xml");
              res.send(responseData);
            }
          } else {
            res.set("Content-Type", "text/xml");
            res.send(`<CustomerInformationResponse>
        <MerchantReference>${merchantreference}</MerchantReference>
        <Customers>
            <Customer>
                <Status>1</Status>
                <CustReference>${custreference}</CustReference>
                <Amount>0</Amount>
            </Customer>
        </Customers>
    </CustomerInformationResponse>`);
          }
        })
        .catch((error) => {
          console.log(error);
          res.set("Content-Type", "text/xml");
          res.send(`<CustomerInformationResponse>
        <MerchantReference>${merchantreference}</MerchantReference>
        <Customers>
            <Customer>
                <Status>1</Status>
                <CustReference>${custreference}</CustReference>
                <Amount>0</Amount>
            </Customer>
        </Customers>
    </CustomerInformationResponse>`);
        });
    } else {
      res.set("Content-Type", "text/xml");
      res.send(`<CustomerInformationResponse>
      <MerchantReference>${merchantreference}</MerchantReference>
      <Customers>
          <Customer>
              <Status>1</Status>
              <CustReference>${custreference}</CustReference>
              <StatusMessage>Invalid Merchantreference</StatusMessage>
              <Amount>0</Amount>
          </Customer>
      </Customers>
  </CustomerInformationResponse>`);
    }
  }
};
const getInvoice = async (referenceNo) => {
  const sector = await db.sequelize.query(
    `SELECT  *  FROM tax_transactions WHERE reference_number = '${referenceNo}' LIMIT 1`
  );
  console.log(sector);
  if (sector[0].length) {
    return sector[0][0].sector;
  } else {
    return null;
  }
};
function formatIPv6MappedIPv4(ipv6MappedIPv4) {
  // Check if the input is in the "::ffff:" format
  if (ipv6MappedIPv4.startsWith("::ffff:")) {
    // Extract the IPv4 address part
    const ipv4Address = ipv6MappedIPv4.replace("::ffff:", "");
    return ipv4Address;
  } else {
    // Return the input as is (assuming it's already in IPv4 format)
    return ipv6MappedIPv4;
  }
}
const allowedList = ["41.223.145.174", "154.72.34.174"];
const handleInvoice = (req, res) => {
  const reqJson = req.body;
  // console.log(req);
  // const clientIP = req.ip;
  const clientIP =
    req.headers["x-forwarded-for"] || req.connection.remoteAddress; // Get the client's IP address

  const isAllowed = allowedList.includes(clientIP);
  if (isAllowed) {
    if (reqJson.customerinformationrequest) {
      handleInvoiceValidation(reqJson, res);
    } else if (reqJson.paymentnotificationrequest) {
      const asyncRequestList = [];
      const referenceNo =
        reqJson.paymentnotificationrequest.payments.length &&
        reqJson.paymentnotificationrequest.payments[0].payment.length
          ? reqJson.paymentnotificationrequest.payments[0].payment[0]
              .custreference
          : null;
      if (referenceNo) {
        const amountPaid =
          reqJson.paymentnotificationrequest.payments[0].payment[0].amount[0];
        const logId =
          reqJson.paymentnotificationrequest.payments[0].payment[0]
            .paymentlogid[0];
        const bank_branch =
          reqJson.paymentnotificationrequest.payments[0].payment[0]
            .branchname[0];

        const branch_address =
          reqJson.paymentnotificationrequest.payments[0].payment[0].location[0];
        const bank_name =
          reqJson.paymentnotificationrequest.payments[0].payment[0]
            .paymentitems[0].paymentitem[0].leadbankname[0];
        const bank_cbn_code =
          reqJson.paymentnotificationrequest.payments[0].payment[0]
            .paymentitems[0].paymentitem[0].leadbankcbncode[0];
        const payer_acct_no =
          reqJson.paymentnotificationrequest.payments[0].payment[0]
            .collectionsaccount[0];
        if (
          amountPaid &&
          amountPaid !== "0" &&
          amountPaid !== "0.00" &&
          amountPaid !== 0 &&
          amountPaid !== 0.0
        ) {
          db.sequelize
            .query(
              `SELECT x.*, IFNULL(SUM(x.dr), 0) AS dr
              FROM (SELECT * FROM tax_transactions WHERE reference_number='${referenceNo}' AND status IN ('saved','PAID') AND transaction_type='invoice') AS x
              LEFT JOIN (SELECT SUM(dr) AS dr_total FROM tax_transactions WHERE reference_number='${referenceNo}' AND status='saved' AND transaction_type='invoice') AS y
              ON 1=1
              GROUP BY x.reference_number;`
            )
            .then((resp) => {
              if (resp && resp.length && resp[0].length) {
                console.log({ amountPaid, amount: resp[0][0].dr });
                const createdAt = resp[0][0].created_at;
                if (
                  createdAt &&
                  moment(createdAt).isBefore(moment().subtract(1, "months"))
                ) {
                  res.set("Content-Type", "text/xml");
                  res.send(`
                  <PaymentNotificationResponse>
                      <Payments>
                          <Payment>
                              <PaymentLogId>${logId}</PaymentLogId>
                              <Status>2</Status>
                              <StatusMessage>Customer Reference Expired.</StatusMessage>
                          </Payment>
                      </Payments>
                  </PaymentNotificationResponse>`);
                } else if (resp[0][0].dr !== amountPaid) {
                  res.set("Content-Type", "text/xml");
                  res.send(`
                  <PaymentNotificationResponse>
                      <Payments>
                          <Payment>
                          <PaymentLogId>${logId}</PaymentLogId>
                          <CustReference>${referenceNo}</CustReference>
                              <Status>1</Status>
                              <StatusMessage>The amount is not correct.</StatusMessage>
                          </Payment>
                      </Payments>
                  </PaymentNotificationResponse>`);
                } else if (resp[0][0].status === "PAID") {
                  if (logId === resp[0][0].logId) {
                    res.set("Content-Type", "text/xml");
                    res.send(`
                      <PaymentNotificationResponse>
                          <Payments>
                              <Payment>
                              <PaymentLogId>${logId}</PaymentLogId>
                                  <Status>0</Status>
                              </Payment>
                          </Payments>
                      </PaymentNotificationResponse>`);
                  } else {
                    res.set("Content-Type", "text/xml");
                    res.send(`
                  <PaymentNotificationResponse>
                      <Payments>
                          <Payment>
                              <PaymentLogId>${logId}</PaymentLogId>
                              <Status>1</Status>
                              <StatusMessage>Invalid Customer Reference</StatusMessage>
                          </Payment>
                      </Payments>
                  </PaymentNotificationResponse>`);
                  }
                } else {
                  reqJson.paymentnotificationrequest.payments.forEach((p) => {
                    p.payment.forEach((pp) => {
                      const interswitchRef = pp.paymentreference[0];
                      const modeOfPayment = pp.paymentmethod[0];
                      const paymentDate = pp.paymentdate[0];
                      const dateSettled = pp.settlementdate[0];
                      const isReversal = pp.isreversal[0];
                      if (isReversal === "False") {
                        asyncRequestList.push(
                          db.sequelize.query(`UPDATE tax_transactions 
                  SET status="PAID", interswitch_ref="${interswitchRef}", payer_acct_no='${payer_acct_no}', bank_name='${bank_name}', bank_branch='${bank_branch}', branch_address='${branch_address}', bank_cbn_code='${bank_cbn_code}',  logId="${logId}", dateSettled="${moment(
                            dateSettled
                          ).format("YYYY-MM-DD")}", 
                  paymentdate="${paymentDate}", modeOfPayment="${modeOfPayment}", 
                  paymentAmount="${amountPaid}"
                  WHERE reference_number='${referenceNo}'`)
                        );
                      } else {
                        asyncRequestList.push(
                          db.sequelize.query(`UPDATE tax_transactions 
                      SET status="REVERSED", interswitch_ref="${interswitchRef}", logId="${logId}", dateSettled="${dateSettled}", 
                      paymentdate="${moment(paymentDate).format(
                        "YYYY-MM-DD"
                      )}", modeOfPayment="${modeOfPayment}", 
                    paymentAmount="${amountPaid}"
                    WHERE reference_number="${referenceNo}"`)
                        );
                      }
                    });
                  });

                  Promise.all(asyncRequestList)
                    .then((ok) => {
                      res.set("Content-Type", "text/xml");
                      res.send(`
            <PaymentNotificationResponse>
                <Payments>
                    <Payment>
                    <PaymentLogId>${logId}</PaymentLogId>
                        <Status>0</Status>
                    </Payment>
                </Payments>
            </PaymentNotificationResponse>`);
                    })
                    .catch((err) => {
                      console.log(err);
                      res.set("Content-Type", "text/xml");
                      res.send(`
            <PaymentNotificationResponse>
                <Payments>
                    <Payment>
                    <PaymentLogId>${logId}</PaymentLogId>
                        <Status>1</Status>
                    </Payment>
                </Payments>
            </PaymentNotificationResponse>`);
                    });
                }
              } else {
                res.set("Content-Type", "text/xml");
                res.send(`
                  <PaymentNotificationResponse>
                      <Payments>
                          <Payment>
                          <PaymentLogId>${logId}</PaymentLogId>
                              <Status>1</Status>
                              <StatusMessage>Customer Reference not found or invalid</StatusMessage>
                          </Payment>
                      </Payments>
                  </PaymentNotificationResponse>`);
              }
            });
        } else {
          res.set("Content-Type", "text/xml");
          res.send(`
        <PaymentNotificationResponse>
            <Payments>
                <Payment>
                    <Status>1</Status>
                    <PaymentLogId>${logId}</PaymentLogId>
                    <StatusMessage>Please provide a valid amount</StatusMessage>
                </Payment>
            </Payments>
        </PaymentNotificationResponse>`);
        }
      } else {
        res.set("Content-Type", "text/xml");
        res.send(`
        <PaymentNotificationResponse>
            <Payments>
                <Payment>
                    <Status>1</Status>
                    <StatusMessage>Please provide a valid Customer Reference</StatusMessage>
                </Payment>
            </Payments>
        </PaymentNotificationResponse>`);
      }
    } else {
      res.set("Content-Type", "text/xml");
      res.send(`<Response>
        <MerchantReference>NA</MerchantReference>
        <Customers>
            <Customer>
                <Status>1</Status>
                <CustReference>NA</CustReference>
                <Amount>0</Amount>
            </Customer>
        </Customers>
    </Response>`);
    }
  } else {
    console.log(`Denied IP: ${clientIP}`);
    res.status(403).send("Access Denied");
  }
};
const webHook = (req, res) => {
  const clientIP =
    req.headers["x-forwarded-for"] || req.connection.remoteAddress; // Get the client's IP address
  console.log(req.body);
  const {
    event = "TRANSACTION.COMPLETED",
    uuid = "112231208124418",
    timestamp = 1702039676910,
  } = req.body;
  const {
    paymentId = 1245447101,
    remittanceAmount = 985,
    amount = 1000,
    responseCode = "00",
    responseDescription = "Approved by Financial Institution",
    cardNumber = "",
    merchantReference = "112231208124418",
    paymentReference = "ABP|WEB|MX60969|08-12-2023|1245447101|146999",
    retrievalReferenceNumber = "869816042486",
    splitAccounts = [],
    transactionDate = 1702039676910,
    accountNumber = null,
    bankCode = "044",
    token = null,
    currencyCode = "566",
    channel = "WEB",
    merchantCustomerId = "134",
    merchantCustomerName = "mylikita health solution limited",
    escrow = false,
    nonCardProviderId = null,
    payableCode = "9969062",
  } = req.body.data;
  const isAllowed = allowedList.includes(clientIP);
  if (isAllowed) {
    if (event === "TRANSACTION.COMPLETED") {
      db.sequelize
        .query(
          `UPDATE tax_transactions 
      SET status="PAID", interswitch_ref="${paymentReference}", payer_acct_no='${retrievalReferenceNumber}',  logId="${paymentId}", dateSettled="${moment(
            timestamp
          ).format("YYYY-MM-DD")}", 
      paymentdate="${moment(transactionDate)}", modeOfPayment="${channel}", 
      paymentAmount="${amount / 100}"
      WHERE reference_number='${merchantReference}'`
        )
        .then((resp) => {
          console.log("hoookkkkkkkkkkkkk");
        })
        .catch((err) => {
          console.error(err);
        });
    }
  }
};

const interResponse = (req, res) => {
  const {
    Amount = 1000,
    CardNumber = "",
    MerchantReference = "112231208113578",
    PaymentReference = "ABP|WEB|MX60969|08-12-2023|1245384142|451712",
    RetrievalReferenceNumber = "170546023861",
    Stan = "023861",
    Channel = "WEB",
    TerminalId = "3IPG0001",
    SplitAccounts = [],
    TransactionDate = "2023-12-08T12:32:36",
    ResponseCode = "00",
    ResponseDescription = "Approved by Financial Institution",
    BankCode = "044",
    PaymentId = 1245384142,
    RemittanceAmount = 0,
    payRef = "ABP|WEB|MX60969|08-12-2023|1245393431|976704",
    txnref = "112231208114172",
    amount = 1000,
    apprAmt = 1000,
    resp = "00",
    desc = "Approved by Financial Institution",
    retRef = "836352001016",
    cardNum = "",
    mac = "",
  } = req.body;
  db.sequelize
    .query(
      `UPDATE tax_transactions 
                      SET status="PAID", interswitch_ref="${PaymentReference}", logId="${PaymentId}", dateSettled="${TransactionDate}", 
                      paymentdate="${moment().format(
                        "YYYY-MM-DD"
                      )}", modeOfPayment="${Channel}", 
                    paymentAmount="${Amount / 100}"
                    WHERE reference_number="${MerchantReference}"`
    )
    .then((resp) => {
      res.json({ success: true, data: resp });
    })
    .catch((err) => {
      console.error(err);
      res.json({ success: false, msg: "Error occurred" });
    });
};
module.exports = {
  webHook,
  getTransaction,
  handleInvoice,
  interResponse,
};
