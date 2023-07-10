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
      res.status(500).json(err);
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

const kigra_account_chart =  (data, success=f=>f, error=f=>f) => {
  const { query_type = null, head = null, sub_head = null, description=null, remarks=null, type=null } = data;

  db.sequelize
    .query(`CALL account_chart(:query_type ,:head,:sub_head,:description,:remarks,:type)`, {
      replacements: {
        query_type,
        head,
        sub_head,
        description,
        remarks,
        type
      },
    })
    .then((result) => {
       success(result)
    })
    .catch((err) => {
     error(err)
    });
}

export function getAccChart (req, res){
  kigra_account_chart(req.query, (resp)=>{
    res.json({success:true, result:resp})
  },
  (err)=>{
    res.status(500).json({success:false, error:err})
  }
  )
}

export function postAccChart (req, res){
  kigra_account_chart(req.body, (resp)=>{
    res.json({success:true, result:resp})
  },
  (err)=>{
    res.status(500).json({success:false, error:err})
  }
  )
}

export function kigraTaxes  (data, success=f=>f, error=f=>f){
  const { query_type=null,id=null,description=null,parent_code=null,tax_code=null,tax_fee=null } = data;

  db.sequelize
    .query(`CALL kigra_taxes(:query_type,:id,:parent_code,:tax_code,:description,:tax_fee)`, {
      replacements: {
        query_type,
        id,
        description,
        parent_code,
        tax_code,
        tax_fee        
      },
    })
    .then((result) => {
       success(result)
    })
    .catch((err) => {
     error(err)
    });
}

export const postKigrTaxes = (req, res)=>{
  kigraTaxes(req.body, (resp)=>{
    res.json({success:true, result:resp})
  },
  (err)=>{
    res.status(500).json({success:false, error:err})
  }
  )
}

export const getKigrTaxes = (req, res)=>{
  kigraTaxes(req.query, (resp)=>{
    res.json({success:true, result:resp})
  },
  (err)=>{
    res.status(500).json({success:false, error:err})
  }
  )
}


