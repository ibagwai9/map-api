const moment = require("moment");
const db = require("../models");
const { Model } = require("sequelize");
const today = moment().format("YYYY-MM-DD");

module.exports.postAccount = (req, res) => {
  const {
    head="",sub_head ="",description="",remarks="",type="",id=0
  } = req.body;
  console.log(req.body);
  const {query_type=''} = req.query
  db.sequelize
    .query(
      `call account_chart (:head,:sub_head,:description,:remarks,:type,:query_type)`,
      {
        replacements: {
            head,sub_head,description,remarks,type,id,query_type,
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
module.exports.getId = (req, res) => {
  console.log(req.params);
  let { id } = req.params;
  db.sequelize
    .query(`SELECT * FROM account_chart WHERE head = ${id}`)
    .then((results) => {
      res.json({ success: true, results });
    })
    .catch((err) => {
      console.log(err);
      res.status(500).json({ success: false, err });
    });
};


module.exports.getNumber =(req,res)=>{

const {id=0}=req.query;

db.sequelize.query(` SELECT sector + 1 as code  FROM chart_of_acct_setup WHERE id=${id}`)
.then((results) => {
  res.json({ success: true, results });
})
.catch((err) => {
  console.log(err);
  res.status(500).json({ success: false, err });
});
}











