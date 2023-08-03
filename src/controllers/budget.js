const db = require("../models");

export const PostBudget = (req, res) => {
  const { query_type = "" } = req.query;
  const arr = [];
  req.body.forEach((item) => {
    const {
      id = 0,
      budget_year = "",
      admin_code = "",
      admin_description = "",
      economic_code = "",
      economic_description = "",
      program_code = "",
      program_description = "",
      function_code = "",
      function_description = "",
      fund_code = "",
      fund_description = "",
      geo_code = "",
      geo_description = "",
      budget_amount = "",
      actual_amount = "",
      budget_type = "",
      start_date = "",
      end_date = "",
      status = "",
      transaction_type = "",
    } = item;
    arr.push(
      db.sequelize.query(
        `CALL PerformBudgetOperation(:query_type,:id,:budget_year,:admin_code,:admin_description,:economic_code,:economic_description,:program_code,:program_description,:function_code,:function_description,:fund_code,:fund_description,:geo_code,:geo_description,:budget_amount,:actual_amount,:budget_type,:start_date,:end_date,:status,:transaction_type)`,
        {
          replacements: {
            query_type,
            id,
            budget_year,
            admin_code,
            admin_description,
            economic_code,
            economic_description,
            program_code,
            program_description,
            function_code,
            function_description,
            fund_code,
            fund_description,
            geo_code,
            geo_description,
            budget_amount,
            actual_amount,
            budget_type,
            start_date,
            end_date,
            status,
            transaction_type,
          },
        }
      )
    );
  });

  Promise.all(arr)
    .then((results) => {
      res.json({ results, success: true });
    })
    .catch((error) => {
      res.status(500).json({ error });
      console.log(error);
    });
};

export const budgetCeiling = (req, res) => {
  const {
    head = "",
    subhead = "",
    description = "",
    type = "",
    amt = 0,
    total_amt = 0,
  } = req.query;
  const { query_type = "" } = req.query;
  console.log(req.body);
  db.sequelize
    .query(
      `call budget_ceiling(:query_type,:head, :subhead, :description, :type, :amt, :total_amt)`,
      {
        replacements: {
          query_type,
          head,
          subhead,
          description,
          type,
          amt,
          total_amt,
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

export const insertBudgetCeiling = (req, res) => {
  const { data = [] } = req.query;
  const { query_type = "" } = req.query;
  console.log(req.body);

  data.forEach((item) => {
    db.sequelize
      .query(
        `call budget_ceiling(:query_type,:head, :subhead, :description, :type, :amt, :total_amt)`,
        {
          replacements: {
            query_type,
            head: item.head,
            subhead: item.subhead,
            description: item.description,
            type: item.type,
            amt: item.amount,
            total_amt: item.total_amt,
          },
        }
      )
      .then((results) => {})
      .catch((err) => {
        console.log(err);
        res.status(500).json({ success: false, err });
      });
  });

  res.json({ success: true, message: "Successfully sent" });
};
