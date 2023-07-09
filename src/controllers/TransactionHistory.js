
const db = require("../models");

export const TransactionHistory = (req,res)=>{
    
    const {transaction_id='', description='', date='', amount='', status=''}=req.body;
    const {query_type=''}=req.query;

    db.sequelize.query(`CALL  ManageTransaction(:transaction_id,:description,:date,:amount,:status,:query_type)`,{
        replacements:{
            transaction_id:1, description, date, amount, status,query_type
        }
    })
    .then((results) => {
        res.json({
          success: true,
          results,
        });
      })
      .catch((err) => {
        console.log(err);
        res.status(500).json(err);
      });


}