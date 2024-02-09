const db = require("../models");

const queryClearance = async function ({
    id = null,
    query_type = "insert",
    date_issued = null,
    tin = null,
    tax_file_no = null,
    taxID = null,
    tax_payer = null,
    income_source = null,
    year = null,
    first_amount = null,
    second_amount = null,
    third_amount = null,
    first_year = null,
    second_year = null,
    third_year = null,
    status = null,
    remark = null,
    recommended_by = null,
    recommendation = null,
    approved_by = null,
    printed = null,
    printed_by = null,
    staff_name = null,
    from = null,
    to = null,
    limit = 50,
    offset = 0
}, res) {
    try {
        const data = await db.sequelize.query(
            `CALL TaxClearance(:query_type,:id,:date_issued,:tin,:tax_file_no,:taxID,:tax_payer,:income_source,
            :year,:first_amount,:second_amount,:third_amount,:first_year,:second_year,
            :third_year,:status,:remark,:recommendation,:recommended_by,:approved_by,
            :printed,:printed_by,:staff_name,:from,:to,:limit,:offset)`,
            {
                replacements: {
                    id,
                    query_type,
                    date_issued: date_issued ? date_issued : null,
                    tin,
                    tax_file_no,
                    taxID,
                    tax_payer,
                    income_source,
                    year,
                    first_amount,
                    second_amount,
                    third_amount,
                    first_year,
                    second_year,
                    third_year,
                    status,
                    remark,
                    recommendation,
                    recommended_by,
                    approved_by,
                    printed,
                    printed_by,
                    staff_name: req.user[0].name,
                    from,
                    to,
                    limit,
                    offset
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
        tax_file_no = null,
        taxID = null,
        tax_payer = null,
        income_source = null,
        year = null,
        first_amount = null,
        second_amount = null,
        third_amount = null,
        first_year = null,
        second_year = null,
        third_year = null,
        status = null,
        remark = null,
        recommended_by = null,
        recommendation = req.user[0].name,
        approved_by = null,
        printed = null,
        printed_by = null,
        staff_name = null,
        from = null,
        to = null,
        limit = 50,
        offset = 0
    } = req.query;

    try {
        await queryClearance({
            id,
            query_type,
            date_issued,
            tin,
            tax_file_no,
            taxID,
            tax_payer,
            income_source,
            year,
            first_amount,
            second_amount,
            third_amount,
            first_year,
            second_year,
            third_year,
            status,
            remark,
            recommended_by,
            recommendation,
            approved_by,
            printed,
            printed_by,
            staff_name,
            from,
            to,
            limit,
            offset
        }, res);
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
        tax_file_no = null,
        taxID = null,
        tax_payer = null,
        income_source = null,
        year = null,
        first_amount = null,
        second_amount = null,
        third_amount = null,
        first_year = null,
        second_year = null,
        third_year = null,
        status = null,
        remark = null,
        recommended_by = null,
        recommendation = null,
        approved_by = null,
        printed = null,
        printed_by = null,
        staff_name = null,
        from = null,
        to = null,
        limit = 50,
        offset = 0
    } = req.body;

    try {
        await queryClearance({
            id,
            query_type,
            date_issued,
            tin,
            tax_file_no,
            taxID,
            tax_payer,
            income_source,
            year,
            first_amount,
            second_amount,
            third_amount,
            first_year,
            second_year,
            third_year,
            status,
            remark,
            recommended_by: recommended_by ? recommended_by : req.user[0].name,
            recommendation,
            approved_by: approved_by ? approved_by : req.user[0].name,
            printed,
            printed_by: printed_by ? printed_by : req.user[0].name,
            staff_name,
            from,
            to,
            limit,
            offset
        }, res);
    } catch (err) {
        console.error(err);
        res.status(500).json({ err, success: false });
    }
};
