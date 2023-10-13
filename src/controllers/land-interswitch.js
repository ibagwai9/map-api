// controllers/transactionController.js
const axios = require("axios");
const crypto = require("crypto");
var parseString = require("xml2js").parseString;
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
      default:
        code = "6405";
    }
    console.log({ sector }, "tedr");

    // reqJson.customerinformationrequest.merchantreference[0];

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

            const formattedRange = isWithinOneMonth
              ? startFormatted
              : `${startFormatted} - ${endFormatted}`;

            // let firstName = results[0].name;
            console.log(results[0]);
            let firstName =
              results[0].account_type === "org"
                ? results[0].org_name
                : results[0].name;
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
              console.log(results);
              const xmlString = `
              <PaymentItems>
                ${results
                  .filter((item) => item.cr > 0)
                  .map(
                    (product) => `
                  <Item>
                    <ProductName>${firstName} ${product.description} ${formattedRange}</ProductName>
                    <ProductCode>${product.item_code}</ProductCode>
                    <Quantity>1</Quantity>
                    <Price>${product.cr}</Price>
                    <Subtotal>${product.cr}</Subtotal>
                    <Tax>0</Tax>
                    <Total>${product.cr}</Total>
                  </Item>
                `
                  )
                  .join("")}
              </PaymentItems>
              `;
              // let lastName = results[0].name.split(" ")[1]
              let responseData = `<CustomerInformationResponse>
        <MerchantReference>${merchantreference}</MerchantReference>
        <Customers>
            <Customer>
                <Status>0</Status>
                <CustReference>${custreference}</CustReference>
                <FirstName>${firstName}</FirstName>
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

// const proc

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

const handleInvoice = (req, res) => {
  // let sampleRequest = `<customerinformationrequest>
  //     <ServiceUsername></ServiceUsername>
  //     <ServicePassword></ServicePassword>
  //     <MerchantReference>6405</MerchantReference>
  //     <CustReference>12</CustReference>
  //     <PaymentItemCode>20230822023219864</PaymentItemCode>
  //     <ThirdPartyCode></ThirdPartyCode>
  //   </customerinformationrequest>`

  const reqJson = req.body;

  // parseString(sampleRequest, function (err, reqJson) {
  // console.log(reqJson, 'cccccccccccc')
  // console.log(JSON.stringify(reqJson))

  if (reqJson.customerinformationrequest) {
    handleInvoiceValidation(reqJson, res);
  } else if (reqJson.paymentnotificationrequest) {
    const asyncRequestList = [];
    // const paymentList =
    const referenceNo =
      reqJson.paymentnotificationrequest.payments.length &&
      reqJson.paymentnotificationrequest.payments[0].payment.length
        ? reqJson.paymentnotificationrequest.payments[0].payment[0]
            .custreference
        : null;
    // console.log(referenceNo)
    // console.log(reqJson.paymentnotificationrequest.payments[0].payment[0].custreference)
    if (referenceNo) {
      const amountPaid =
        reqJson.paymentnotificationrequest.payments[0].payment[0].amount[0];
      const logId =
        reqJson.paymentnotificationrequest.payments[0].payment[0]
          .paymentlogid[0];
      console.log(amountPaid);
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
                            <PaymentLogId>${logId}</PaymentLogId>
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
                        <CustReference>${referenceNo}</CustReference>
                            <PaymentLogId>${logId}</PaymentLogId>
                            <Status>1</Status>
                            <StatusMessage>Invalid Customer Reference</StatusMessage>
                        </Payment>
                    </Payments>
                </PaymentNotificationResponse>`);
                }
              } else {
                // console.log(resp)
                reqJson.paymentnotificationrequest.payments.forEach((p) => {
                  p.payment.forEach((pp) => {
                    // console.log(pp)
                    // const invoiceId = pp.custreference[0]
                    const interswitchRef = pp.paymentreference[0];
                    const modeOfPayment = pp.paymentmethod[0];
                    const paymentDate = pp.paymentdate[0];
                    const dateSettled = pp.settlementdate[0];
                    const isReversal = pp.isreversal[0];

                    if (isReversal === "False") {
                      asyncRequestList.push(
                        db.sequelize.query(`UPDATE tax_transactions 
                SET status="PAID", interswitch_ref="${interswitchRef}", logId="${logId}", dateSettled="${moment(
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
                    // pp.paymentitems.forEach((ppaymentItem) => {
                    //   ppaymentItem.forEach((pppp) => {})
                    // })
                  });
                });

                Promise.all(asyncRequestList)
                  .then((ok) => {
                    console.log("ok", ok);
                    // let logId =
                    //   reqJson?.paymentnotificationrequest?.payments[0][0]
                    //     ?.paymentlogid || Date.now()
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
                  <CustReference>${referenceNo}</CustReference>
                      <Status>1</Status>
                  </Payment>
              </Payments>
          </PaymentNotificationResponse>`);
                  });
                // res.send(reqJson)
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
                  <PaymentLogId>0</PaymentLogId>
                  <Status>1</Status>
                  <PaymentLogId>${logId}</PaymentLogId>
                  <CustReference>${referenceNo}</CustReference>
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
                  <PaymentLogId>0</PaymentLogId>
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
  // })
};

// const handleLgaInvoice = (req, res) => {
//   // let sampleRequest = `<customerinformationrequest>
//   //     <ServiceUsername></ServiceUsername>
//   //     <ServicePassword></ServicePassword>
//   //     <MerchantReference>6405</MerchantReference>
//   //     <CustReference>12</CustReference>
//   //     <PaymentItemCode>20230822023219864</PaymentItemCode>
//   //     <ThirdPartyCode></ThirdPartyCode>
//   //   </customerinformationrequest>`

//   const reqJson = req.body;

//   // parseString(sampleRequest, function (err, reqJson) {
//   // console.log(reqJson, 'cccccccccccc')
//   // console.log(JSON.stringify(reqJson))

//   if (reqJson.customerinformationrequest) {
//     handleInvoiceValidation(reqJson, res);
//   } else if (reqJson.paymentnotificationrequest) {
//     const asyncRequestList = [];
//     // const paymentList =
//     const referenceNo =
//       reqJson.paymentnotificationrequest.payments.length &&
//       reqJson.paymentnotificationrequest.payments[0].payment.length
//         ? reqJson.paymentnotificationrequest.payments[0].payment[0]
//             .custreference
//         : null;
//     // console.log(referenceNo)
//     // console.log(reqJson.paymentnotificationrequest.payments[0].payment[0].custreference)
//     if (referenceNo) {
//       const amountPaid =
//         reqJson.paymentnotificationrequest.payments[0].payment[0].amount[0];
//       const logId =
//         reqJson.paymentnotificationrequest.payments[0].payment[0]
//           .paymentlogid[0];
//       console.log(amountPaid);
//       if (
//         amountPaid &&
//         amountPaid !== "0" &&
//         amountPaid !== "0.00" &&
//         amountPaid !== 0 &&
//         amountPaid !== 0.0
//       ) {
//         db.sequelize
//           .query(
//             `SELECT x.*, IFNULL(SUM(x.dr), 0) AS dr
//             FROM (SELECT * FROM tax_transactions WHERE reference_number='${referenceNo}' AND status='saved' AND transaction_type='invoice') AS x
//             LEFT JOIN (SELECT SUM(dr) AS dr_total FROM tax_transactions WHERE reference_number='${referenceNo}' AND status='saved' AND transaction_type='invoice') AS y
//             ON 1=1
//             GROUP BY x.reference_number;`
//           )
//           .then((resp) => {
//             if (resp && resp.length && resp[0].length) {
//               console.log({ amountPaid, amount: resp[0][0].dr });
//               const createdAt = resp[0][0].created_at;
//               console.log({ createdAt });
//               console.log("createdAt");
//               console.log("createdAt here");
//               if (
//                 createdAt &&
//                 moment(createdAt).isBefore(moment().subtract(1, "months"))
//               ) {
//                 res.set("Content-Type", "text/xml");
//                 res.send(`
//                 <PaymentNotificationResponse>
//                     <Payments>
//                         <Payment>
//                             <PaymentLogId>${logId}</PaymentLogId>
//                             <Status>2</Status>
//                             <StatusMessage>Customer Reference Expired.</StatusMessage>
//                         </Payment>
//                     </Payments>
//                 </PaymentNotificationResponse>`);
//               } else if (resp[0][0].dr !== amountPaid) {
//                 res.set("Content-Type", "text/xml");
//                 res.send(`
//                 <PaymentNotificationResponse>
//                     <Payments>
//                         <Payment>
//                         <PaymentLogId>${logId}</PaymentLogId>
//                         <CustReference>${referenceNo}</CustReference>
//                             <PaymentLogId>${logId}</PaymentLogId>
//                             <Status>1</Status>
//                             <StatusMessage>The amount is not correct.</StatusMessage>
//                         </Payment>
//                     </Payments>
//                 </PaymentNotificationResponse>`);
//               } else if (resp[0][0].status === "PAID") {
//                 if (logId === resp[0][0].logId) {
//                   res.set("Content-Type", "text/xml");
//                   res.send(`
//                     <PaymentNotificationResponse>
//                         <Payments>
//                             <Payment>
//                             <PaymentLogId>${logId}</PaymentLogId>
//                             <CustReference>${referenceNo}</CustReference>
//                                 <PaymentLogId>${logId}</PaymentLogId>
//                                 <Status>0</Status>
//                             </Payment>
//                         </Payments>
//                     </PaymentNotificationResponse>`);
//                 } else {
//                   res.set("Content-Type", "text/xml");
//                   res.send(`
//                 <PaymentNotificationResponse>
//                     <Payments>
//                         <Payment>
//                         <PaymentLogId>${logId}</PaymentLogId>
//                         <CustReference>${referenceNo}</CustReference>
//                             <PaymentLogId>${logId}</PaymentLogId>
//                             <Status>1</Status>
//                             <StatusMessage>Invalid Customer Reference</StatusMessage>
//                         </Payment>
//                     </Payments>
//                 </PaymentNotificationResponse>`);
//                 }
//               } else {
//                 // console.log(resp)
//                 reqJson.paymentnotificationrequest.payments.forEach((p) => {
//                   p.payment.forEach((pp) => {
//                     // console.log(pp)
//                     // const invoiceId = pp.custreference[0]
//                     const interswitchRef = pp.paymentreference[0];
//                     const modeOfPayment = pp.paymentmethod[0];

//                     const paymentDate = pp.paymentdate[0];
//                     const dateSettled = pp.settlementdate[0];
//                     const isReversal = pp.isreversal[0];

//                     if (isReversal === "False") {
//                       asyncRequestList.push(
//                         db.sequelize.query(`UPDATE tax_transactions
//                 SET status="PAID", interswitch_ref="${interswitchRef}", logId="${logId}", dateSettled="${moment(
//                   dateSettled
//                 ).format("YYYY-MM-DD")}",
//                 paymentdate="${paymentDate}", modeOfPayment="${modeOfPayment}",
//                 paymentAmount="${amountPaid}"
//                 WHERE reference_number='${referenceNo}'`)
//                       );
//                     } else {
//                       asyncRequestList.push(
//                         db.sequelize.query(`UPDATE tax_transactions
//                     SET status="REVERSED", interswitch_ref="${interswitchRef}", logId="${logId}", dateSettled="${dateSettled}",
//                     paymentdate="${moment(paymentDate).format(
//                       "YYYY-MM-DD"
//                     )}", modeOfPayment="${modeOfPayment}",
//                   paymentAmount="${amountPaid}"
//                   WHERE reference_number="${referenceNo}"`)
//                       );
//                     }
//                     // pp.paymentitems.forEach((ppaymentItem) => {
//                     //   ppaymentItem.forEach((pppp) => {})
//                     // })
//                   });
//                 });

//                 Promise.all(asyncRequestList)
//                   .then((ok) => {
//                     console.log("ok", ok);
//                     // let logId =
//                     //   reqJson?.paymentnotificationrequest?.payments[0][0]
//                     //     ?.paymentlogid || Date.now()
//                     res.set("Content-Type", "text/xml");
//                     res.send(`
//           <PaymentNotificationResponse>
//               <Payments>
//                   <Payment>
//                   <PaymentLogId>${logId}</PaymentLogId>
//                   <CustReference>${referenceNo}</CustReference>
//                       <Status>0</Status>
//                   </Payment>
//               </Payments>
//           </PaymentNotificationResponse>`);
//                   })
//                   .catch((err) => {
//                     console.log(err);

//                     res.set("Content-Type", "text/xml");
//                     res.send(`
//           <PaymentNotificationResponse>
//               <Payments>
//                   <Payment>
//                   <PaymentLogId>${logId}</PaymentLogId>
//                   <CustReference>${referenceNo}</CustReference>
//                       <PaymentLogId>0</PaymentLogId>
//                       <Status>1</Status>
//                   </Payment>
//               </Payments>
//           </PaymentNotificationResponse>`);
//                   });
//                 // res.send(reqJson)
//               }
//             } else {
//               res.set("Content-Type", "text/xml");
//               res.send(`
//                 <PaymentNotificationResponse>
//                     <Payments>
//                         <Payment>
//                         <PaymentLogId>${logId}</PaymentLogId>
//                         <CustReference>${referenceNo}</CustReference>
//                             <Status>1</Status>
//                             <StatusMessage>Customer Reference not found or invalid</StatusMessage>
//                         </Payment>
//                     </Payments>
//                 </PaymentNotificationResponse>`);
//             }
//           });
//       } else {
//         res.set("Content-Type", "text/xml");
//         res.send(`
//       <PaymentNotificationResponse>
//           <Payments>
//               <Payment>
//                   <PaymentLogId>0</PaymentLogId>
//                   <Status>1</Status>
//                   <PaymentLogId>${logId}</PaymentLogId>
//                   <CustReference>${referenceNo}</CustReference>
//                   <StatusMessage>Please provide a valid amount</StatusMessage>
//               </Payment>
//           </Payments>
//       </PaymentNotificationResponse>`);
//       }
//     } else {
//       res.set("Content-Type", "text/xml");
//       res.send(`
//       <PaymentNotificationResponse>
//           <Payments>
//               <Payment>
//                   <PaymentLogId>0</PaymentLogId>
//                   <Status>1</Status>
//                   <StatusMessage>Please provide a valid Customer Reference</StatusMessage>
//               </Payment>
//           </Payments>
//       </PaymentNotificationResponse>`);
//     }
//   } else {
//     res.set("Content-Type", "text/xml");
//     res.send(`<Response>
//       <MerchantReference>NA</MerchantReference>
//       <Customers>
//           <Customer>
//               <Status>1</Status>
//               <CustReference>NA</CustReference>
//               <CustomerReferenceAlternate></CustomerReferenceAlternate>
//               <ThirdPartyCode></ThirdPartyCode>
//               <Amount>0</Amount>
//           </Customer>
//       </Customers>
//   </Response>`);
//   }
//   // })
// };

module.exports = {
  getTransaction,
  handleInvoice,
  // handleLgaInvoice,
};
