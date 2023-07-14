const moment = require('moment')
const db = require('../models')
const today =moment().format("YYYY-MM-DD")


export const postcoa = (req,res) => {

    const {
        segment_code=0,name="",type="",sector=0,org=0,sub_org=0,sub_sub_org=0,sub_sub_sub_org=0,functions=0,remark="",sub_org_name="",sub_sub_name="",sub_sub_sub_name="",sector_name=""

    } =req.body;
    console.log(req.body);
    const {query_type=''} =req.query
    db.sequelize
    .query(
        `call coa(:segment_code,:name,:type,:sector,:org,:sub_org,:sub_sub_org,:sub_sub_sub_org,:functions,:remark,:sub_org_name,:sub_sub_name,:sub_sub_sub_name,:sector_name,:query_type)`,
        {
            replacements:{
                segment_code,
                name,
                type,
                sector,
                org,
                sub_org,
                sub_sub_org,
                sub_sub_sub_org,
                functions,
                remark,
                sub_org_name,
                sub_sub_name,
                sub_sub_sub_name,
                sector_name,
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