const moment = require('moment')
const db = require('../models')
const today =moment().format("YYYY-MM-DD")


module.exports = postOrganization = (req,res) => {

    const {
        sector_name="",
        sector_code="8098798",
        org_name="",
        org_code = "",

    } =req.body;
    console.log(req.body);
    const {query_type=''} =req.query
    db.sequelize
    .query(
        `call organization(:sector_name,:sector_code,:org_name,:org_code,:query_type)`,
        {
            replacements:{
                sector_name,
                sector_code,
                org_name,
                org_code,
                query_type,
            }
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