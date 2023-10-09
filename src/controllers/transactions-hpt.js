const db = require("../models");
const request = require("request-promise");
const moment = require("moment");

module.exports.addTransactionsApi = async (item) => {
  //   console.log(item);
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
          paymentdate: moment(paymentdate).format("YYYY-MM-DD hh:mm:ss"),
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
  const _noCount = await db.sequelize.query(
    "select ifnull(max(transactioncount),0)  as startcount from transactions; "
  );
  const options = {
    method: "POST",
    url: "https://kano.hirms.net/apiresource/allpayments.php",
    headers: {},
    formData: {
      userkey: process.env.userkey,
      privatekey: process.env.privatekey,
      hashkey: process.env.hashkey,
      startcount: _noCount[0][0].startcount,
    },
    json: true, // Automatically parse response as JSON
  };
  try {
    let returndata = 1;

    while (returndata) {
      await new Promise((resolve) => setTimeout(resolve, 7000));
      const response = await request(options);
      //   console.log(response.returndata);
      if (response.returndata === 0) {
        returndata = 0; // Update returndata to zero or exit the loop
        console.log("Break");
        break; // Exit the while loop
      } else if (
        response.payload &&
        Array.isArray(response.payload) &&
        response.payload.length > 0
      ) {
        // console.log("add");
        const arr = [];
        response.payload.forEach((_item) => {
          //   console.log(_item);
          if (_item.items && Array.isArray(_item.items)) {
            _item.items.forEach((item) => {
              arr.push(
                module.exports
                  .addTransactionsApi({
                    ..._item,
                    ...item,
                  })
                  .catch((error) => {
                    console.error("Error in addTransactionsApi:", error);
                    throw error; // Re-throw the error to propagate it
                  })
              );
            });
          } else {
            console.error("Invalid items property:", _item.items);
          }
        });

        await Promise.all(arr)
          .then((results) => console.log(results))
          .catch((error) => {
            console.error("Error in addTransactionsApi:", error);
            throw error; // Re-throw the error to propagate it
          }); // Use await to wait for all promises to resolve
      } else {
        console.error("Invalid response payload:", response.payload);
      }
    }
  } catch (error) {
    console.error(error);
    throw new Error("Error in addHospitalData: " + JSON.stringify(error));
  }
};
