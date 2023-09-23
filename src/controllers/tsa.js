const { Promise } = require("sequelize");
const db = require("../models");

module.exports.tsa_code = (req, res) => {
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

module.exports.kigra_get_account_list = (req, res)=> {
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

module.exports.getAccChart = (req, res)=>{
  kigra_account_chart(req.query, (resp)=>{
    res.json({success:true, result:resp})
  },
  (err)=>{
    res.status(500).json({success:false, error:err})
  }
  )
}

module.exports.postAccChart =  (req, res)=>{
  kigra_account_chart(req.body, (resp)=>{
    res.json({success:true, result:resp})
  },
  (err)=>{
    res.status(500).json({success:false, error:err})
  }
  )
}

const kigraTaxes = (data, success = (f) => f, error = (f) => f) => {
  const {
    query_type = null,
    id = null,
    title = null,
    tax_parent_code = null,
    parent_code=null,
    description=null,
    tax_code = null,
    tax_fee = null,
    sector = null,
  } = data;

  db.sequelize
    .query(
      `CALL kigra_taxes(:query_type, :id, :tax_code, :tax_parent_code, :title, :tax_fee, :sector)`,
      {
        replacements: {
          query_type,
          id,
          title:description?description:title,
          tax_parent_code:parent_code?parent_code:tax_parent_code,
          tax_code,
          tax_fee,
          sector,
        },
      }
    )
    .then((result) => {
      success(result);
    })
    .catch((err) => {
      error(err);
    });
};

module.exports.postKigrTaxes = (req, res) => {
  try {
    Promise.all(req.body.map((tax) => {
      return new Promise((resolve, reject) => {
        kigraTaxes(
          tax,
          (resp) => {
            resolve(resp);
          },
          (err) => {
            reject(err);
          }
        );
      });
    }))
      .then((results) => {
        res.json({ success: true, results });
      })
      .catch((err) => {
        res.status(500).json({ success: false, error: err });
      });
  } catch (e) {
    console.log('Error occurred', e);
    res.status(500).json({ success: false, error: e });
  }
};

module.exports.getKigrTaxes = (req, res)=>{
  kigraTaxes(req.query, (resp)=>{
    res.json({success:true, result:resp})
  },
  (err)=>{
    res.status(500).json({success:false, error:err})
  }
  )
}


module.exports.getLGARevenues = (req, res)=>{
  db.sequelize.query("SELECT * FROM `lga_revenues` WHERE tax_fee !=''; ")
  .then(resp=>{
    res.json({success:true, result:resp[0]})
  })
  .catch(error=>{
    console.log(error);
    res.status(500).json({success:false, error:'Unable to fetch lga revenues'}) 
  })
}

module.exports.getLGAs = (req, res)=>{
  db.sequelize.query("SELECT * FROM `lgas` WHERE state LIKE 'Kano%' ")
  .then(resp=>{
    res.json({success:true, result:resp[0]})
  })
  .catch(error=>{
    res.status(500).json({success:false, error:'Unable to fetch Lga list'}) 
  })
}

