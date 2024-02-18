const db = require("../models");
const moment = require("moment");
const queryClearance = async function (
  {
    id = "",
    query_type = "insert",
    date_issued = null,
    tin = null,
    tcc_ref = null,
    tax_file_no = null,
    taxID = null,
    tax_payer = null,
    income_source = null,
    year = null,
    first_amount = null,
    second_amount = null,
    third_amount = null,
    first_income = null,
    second_income = null,
    third_income = null,
    first_year = null,
    second_year = null,
    third_year = null,
    status = null,
    remark = null,
    raised_by = null,
    recommended_by = null,
    recommendation = null,
    approved_by = null,
    rejection = null,
    printed = null,
    printed_by = null,
    staff_name = null,
    from = null,
    to = null,
    limit = 50,
    offset = 0,
    org_name = "",
    org_id = "",
    type = "",
    address = "",
    identifier = "",
  },
  res
) {
  try {
    const data = await db.sequelize.query(
      `CALL TaxClearance(:query_type,:id,:date_issued,:tin,:tcc_ref,:tax_file_no,:taxID,:tax_payer,:income_source,
            :year,:first_amount,:second_amount,:third_amount,:first_income,:second_income,:third_income,
            :first_year,:second_year,:third_year,:status,:remark,:raised_by,:recommendation,:recommended_by,:rejection,
            :approved_by,:printed,:printed_by,:staff_name,:from,:to,:limit,:offset,:org_name,:org_id,:type,:address)`,
      {
        replacements: {
          id,
          query_type,
          date_issued: date_issued ? date_issued : null,
          tin,
          tcc_ref:
            tcc_ref || `KN|${identifier}|${moment().format("YYYYMMDD")}|`,
          tax_file_no,
          taxID,
          tax_payer,
          income_source,
          year,
          first_amount,
          second_amount,
          third_amount,
          first_income,
          second_income,
          third_income,
          first_year,
          second_year,
          third_year,
          status,
          remark,
          raised_by,
          recommendation,
          recommended_by,
          approved_by,
          rejection,
          printed,
          printed_by,
          staff_name,
          from,
          to,
          limit,
          offset,
          org_name,
          org_id,
          type,
          address,
        },
      }
    );
    res.json({ success: true, data });
  } catch (err) {
    console.error(err);
    res.status(500).json({ err });
  }
};

module.exports.getTaxClearance = async (req, res) => {
  const {
    id = null,
    query_type = "select",
    date_issued = null,
    tin = null,
    tcc_ref = null,
    tax_file_no = null,
    taxID = null,
    tax_payer = null,
    income_source = null,
    year = null,
    first_amount = null,
    second_amount = null,
    third_amount = null,
    first_income = null,
    second_income = null,
    third_income = null,
    first_year = null,
    second_year = null,
    third_year = null,
    status = null,
    remark = null,
    raised_by = null,
    recommended_by = null,
    recommendation = null,
    approved_by = null,
    rejection = null,
    printed = null,
    printed_by = null,
    staff_name = null,
    from = null,
    to = null,
    limit = 50,
    offset = 0,
    identifier = "",
  } = req.query;
  try {
    await queryClearance(
      {
        id,
        query_type,
        date_issued,
        tin,
        tcc_ref,
        tax_file_no,
        taxID,
        tax_payer,
        income_source,
        year,
        first_amount,
        second_amount,
        third_amount,
        first_income,
        second_income,
        third_income,
        first_year,
        second_year,
        third_year,
        status,
        remark,
        raised_by,
        recommended_by,
        recommendation,
        approved_by,
        rejection,
        printed,
        printed_by,
        staff_name,
        from,
        to,
        limit,
        offset,
        identifier,
      },
      res
    );
  } catch (err) {
    console.error(err);
    res.status(500).json({ err, success: false });
  }
};

module.exports.postTaxClearance = async (req, res) => {
  const {
    id = null,
    query_type = "insert",
    date_issued = null,
    tin = null,
    tcc_ref = null,
    tax_file_no = null,
    taxID = null,
    tax_payer = null,
    income_source = null,
    year = null,
    first_amount = null,
    second_amount = null,
    third_amount = null,
    first_income = null,
    second_income = null,
    third_income = null,
    first_year = null,
    second_year = null,
    third_year = null,
    status = null,
    remark = null,
    raised_by = null,
    recommended_by = null,
    recommendation = null,
    approved_by = null,
    rejection = null,
    printed = null,
    printed_by = null,
    staff_name = null,
    from = null,
    to = null,
    limit = 50,
    offset = 0,
    org_name = "",
    org_id = 0,
    type = "",
    address = "",
	identifier=""
  } = req.body;
  console.log(req.body);
  try {
    await queryClearance(
      {
        id,
        query_type,
        date_issued,
        tin,
        tcc_ref,
        tax_file_no,
        taxID,
        tax_payer,
        income_source,
        year,
        first_amount,
        second_amount,
        third_amount,
        first_income,
        second_income,
        third_income,
        first_year,
        second_year,
        third_year,
        status,
        remark,
        raised_by: raised_by ? raised_by : req.user[0].name,
        recommended_by: recommended_by ? recommended_by : req.user[0].name,
        recommendation,
        approved_by: approved_by ? approved_by : req.user[0].name,
        rejection,
        printed,
        printed_by: printed_by ? printed_by : req.user[0].name,
        staff_name: staff_name ? staff_name : req.user[0].name,
        from,
        to,
        limit,
        offset,
        org_name,
        org_id,
        type,
        address,
		identifier
      },
      res
    );
  } catch (err) {
    console.error(err);
    res.status(500).json({ err, success: false });
  }
};

module.exports.verifyTaxClearance = (req, res) => {
  const { tcc_ref = "" } = req.query;
  db.sequelize
    .query(
      `SELECT * FROM tax_clearance where status="printed" and tcc_ref=:tcc_ref;`,
      {
        replacements: {
          tcc_ref,
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


