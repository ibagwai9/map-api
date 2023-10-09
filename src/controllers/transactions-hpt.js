const db = require("../models");
const request = require("request-promise");

module.exports.addTransactionsApi = async (item) => {
  console.log(item);
  const {
    paystatus = "",
    startcount = 0,
    returndata = 0,
    transactioncount = 0,
    status = "",
    surname = "",
    othernames = "",
    paymentdate = null,
    paymentmethod = "",
    localid = "",
    onlineid = null,
    bank_teller = "",
    hospital_invoice = "",
    total_amount = "",
    hospital = "",
    description = "",
    amount = 0,
    department = "",
    unit = "",
  } = item;
  try {
    const results = await db.sequelize.query(
      "call insert_transactions(:transactioncount,:status,:surname,:othernames,:paymentdate,:paymentmethod,:localid,:onlineid,:bank_teller,:hospital_invoice,:total_amount,:hospital,:description,:amount,:department,:unit)",
      {
        replacements: {
          paystatus,
          startcount,
          returndata,
          transactioncount,
          status,
          surname,
          othernames,
          paymentdate,
          paymentmethod,
          localid,
          onlineid,
          bank_teller,
          hospital_invoice,
          total_amount,
          hospital,
          description,
          amount,
          department,
          unit,
        },
      }
    );
    return results;
  } catch (error) {
    console.error(error);
    throw new Error(
      "Error executing stored procedure: " + JSON.stringify(error)
    );
  }
};

module.exports.addHospitalData = async () => {
  const options = {
    method: "POST",
    url: "https://kano.hirms.net/apiresource/allpayments.php",
    headers: {},
    formData: {
      userkey: process.env.userkey,
      privatekey: process.env.privatekey,
      hashkey: process.env.hashkey,
    },
    json: true, // Automatically parse response as JSON
  };

  try {
    let returndata = 1;
    console.log("herer");
    while (returndata) {
        const response = await request(options);
      console.log(response);

      if (!response.body  || response.body.returndata  === 0) {
        returndata = 0; // Update returndata to zero or exit the loop
        console.log("Break");
        break; // Exit the while loop
      }

      if (returndata) {
        const arr = [];
        response.body.payload.forEach((_item) => {
          _item.items.forEach((item) => {
            arr.push(
              module.exports.addTransactionsApi({
                ..._item,
                ...item,
              })
            );
          });
        });
        Promise.all(arr)
          .then((results) => {
            console.log(results);
          })
          .catch((error) => {
            console.log(error);
          });
        const results = await Promise.all(arr);
        console.log(results);
      }
    }
  } catch (error) {
    console.error(error);
    throw new Error("Error in addHospitalData: " + JSON.stringify(error));
  }
};
