const db = require("../models");

const UUIDV4 = require("uuid").v4;

exports.tsa_code = (req, res) => {
  const { types = "FAAC" } = req.query;
  db.sequelize
    .query(`CALL tsa_code(:types)`, {
      replacements: {
        types,
      },
    })
    .then((results) => {
      res.json({
        success: true,
        results,
      });
    })
    .catch((err) => {
      console.log(err);
      error(err);
    });
};

export function kigra_get_account_list(req, res) {
  const { query_type = null, head = null, search = null } = req.query;

  db.sequelize
    .query(`CALL kigra_account_list(:query_type,:head,:search)`, {
      replacements: {
        query_type,
        head,
        search,
      },
    })
    .then((result) => {
      res.json({
        success: true,
        result,
      });
    })
    .catch((err) => {
      console.log(err);
      res.json({
        success: false,
        err,
      });
    });
}

function transactionFuc(data, callback, error) {
  const {
    query_type = null,
    receipt_no = "",
    descr = "",
    ministry_name = "",
    acct_code = "",
    payee_name = "",
    mode_of_payment = "",
    payee_id = "",
    payment_status = "",
    amount = 0.0,
    trans_date,
    facility_id = "",
  } = data;

  db.sequelize
    .query(
      `CALL transaction(:query_type,:receipt_no,:descr,:ministry_name,:acct_code,:payee_name,:mode_of_payment,:payee_id,:payment_status,:amount,:trans_date,:facility_id)`,
      {
        replacements: {
          query_type,
          receipt_no,
          descr,
          ministry_name,
          acct_code,
          payee_name,
          mode_of_payment,
          payee_id,
          payment_status,
          amount,
          trans_date,
          facility_id,
        },
      }
    )
    .then((result) => {
      callback(result);
    })
    .catch((err) => {
      error(err);
    });
}

export function postTransaction(req, res) {
  const { data } = req.body;
  data.forEach((element) => {
    transactionFuc(
      element,
      (d) => {
        console.log(d);
      },
      (err) => {
        res.json({
          success: false,
          err,
        });
      }
    );
  });
  res.json({
    success: true,
  });
}
