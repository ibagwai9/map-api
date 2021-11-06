const db = require("../models")

exports.updatePvCode = (req, res) => {
const { description,query_type} = req.body
  db.sequelize
      .query(
    `CALL pv_increment (
      :description,
      :query_type 
      )`,
        {
          replacements: {
            description,
            query_type
          },
        },) 
      .then((result) => {
      res.json({
        success: true,
        result,
      })

      console.log(result)
    }).catch(err => {
          console.log(err) 
          error(err)
        })
}

const fetchCode = (query_type ="select", description = "batch_code", callback=f=>f, error=f=>f) => {
  db.sequelize
      .query(
    `CALL funding_increment (
      :description,
      :query_type 
      )`,
        {
          replacements: {
            description,
            query_type
          }
        }).then(result => 
          callback(result)
        ).catch(err => {
          console.log(err) 
          error(err)
        })
}



// exports.checkDetails = (res, req) => {
// 	const {
// 		date = "",
// 		batch_no = "",
// 		check_no = "",
// 		query_type = ""
// 	} = req.body

	
// 		db.Sequelize.query(
// 			`CALL check_details(
// :date, :batch_no, :check_no, :query_type
// 			)`,
// 			{
// 				replacements : {
// 					date,
// 		batch_no,
// 		check_no,
// 		query_type
// 				}
// 			}
// 			).then((result) => {
// 				res.json({
// 					success : true,
// 					result
// 				})

// 				console.log(result)
// 			})
// 				.catch((err) => {
// 					res.json({
// 						success : false,
// 						err

// 					})
// 		})
// }





// exports.tatchDetails = (res, req) => {
// 	const {
// 		tatch_description = "",
// 		project_code = "",
// 		contractor_tin_no = "",
// 		mda_tin_no = "",
// 		amount = "",
// 		project_details = "",
// 		query_type = ""
// 	} = req.body

	
// 		db.sequelize.query(
// 			`CALL tatch_details(
// :tatch_description, :project_code, :contractor_tin_no, :mda_tin_no,
//  :amount, :project_details,
// :query_type
// 			)`,
// 			{
// 				replacements : {
// 					tatch_description,
// 		project_code,
// 		contractor_tin_no,
// 		mda_tin_no,
// 		amount,
// 		project_details,
// 		query_type
// 				}
// 			}
// 			).then((result) => {
// 				res.json({
// 					success : true,
// 					result
// 				})

// 				console.log(result)
// 			})
// 				.catch((err) => {
// 					res.json({
// 						success : false,
// 						err

// 					})
// 				})
// }






exports.tsaFundingArray = (req, res) => {
  const { tsaBatch, batch_no = "", status = "",
   query_type = "", cheque_number = "", arabic_date = "" } = req.body
  // const batch_no = uuid()

   console.log(req.body)

    console.log("body",req.body)
    

  let count = 0

fetchCode('select','funding_code', (results) => {
  if(results && results.length ) {
    let funding_code = results[0].batch_code

  tsaBatch.forEach((item, idx) => {
    db.sequelize
    .query(
    `CALL tsa_funding (
    :query_type,
    :funding_code,
    :date,
    :mda_source_account,
    :mda_account_no,
    :mda_bank_name,
    :mda_sort_code,
    :treasury_source_account,
    :treasury_account_name,
    :treasury_account_no,
    :treasury_bank_name,
    :amount       
      )`,
        {
          replacements: {
            query_type: item.query_type ? item.query_type : query_type,
            funding_code : item.funding_code ? item.funding_code : funding_code,
            date : item.date ? item.date : "",
            mda_source_account : item.mda_source_account ? item.mda_source_account : "",
            mda_account_no : item.mda_account_no ? item.mda_account_no : "",
            mda_bank_name : item.mda_bank_name ? item.mda_bank_name : "",
            mda_sort_code : item.mda_sort_code ? item.mda_sort_code : "",
            treasury_source_account : item.treasury_source_account ? item.treasury_source_account : "",
            treasury_account_name : item.treasury_account_name ? item.treasury_account_name : "",
            treasury_account_no : item.treasury_account_no ? item.treasury_account_no : "",
            treasury_bank_name : item.treasury_bank_name ? item.treasury_bank_name : "",
            amount : item.amount ? item.amount : item.amount
          }, 
        },
      )
     
  })
  res.json({ success: true, funding_code })
   }
})
 
}


exports.tsaFunding = (req, res) => {
   console.log("kello")
   console.log("body", req.body)
 const {
    query_type = "",
    funding_code = "",
    date = "",
    mda_source_account = "",
    mda_account_no = "",
    mda_bank_name = "",
    mda_sort_code = "",
    treasury_source_account = "",
    treasury_account_name = "",
    treasury_account_no = "",
    treasury_bank_name = "",
    amount = ""       
    
  } = req.body

  db.sequelize
      .query(
    `CALL tsa_funding (
    :query_type,
    :funding_code,
    :date,
    :mda_source_account,
    :mda_account_no,
    :mda_bank_name,
    :mda_sort_code,
    :treasury_source_account,
    :treasury_account_name,
    :treasury_account_no,
    :treasury_bank_name,
    :amount       
    
      )`,

    {
        replacements: {
    query_type,
    funding_code,
    date,
    mda_source_account,
    mda_account_no,
    mda_bank_name,
    mda_sort_code,
    treasury_source_account,
    treasury_account_name,
    treasury_account_no,
    treasury_bank_name,
    amount       
        },
      }
    ).then((result) => {
      res.json({
        success: true,
        result,
      })

      // console.log("result1", result)
    })
    .catch((err) => {
      res.json({
        success: false,
        err,
      })
      console.log(err)
    })

  }



  exports.tsaFundingArray = (req, res) => {
  const { tsaBatch, batch_no = "", status = "",
   query_type = "", cheque_number = "", arabic_date = "" } = req.body
  // const batch_no = uuid()

   console.log(req.body)

    console.log("body",req.body)
    

  let count = 0

fetchCode('select','funding_code', (results) => {
  if(results && results.length ) {
    let funding_code = results[0].batch_code

  tsaBatch.forEach((item, idx) => {
    db.sequelize
    .query(
    `CALL tsa_funding (
    :query_type,
    :funding_code,
    :date,
    :mda_source_account,
    :mda_account_no,
    :mda_bank_name,
    :mda_sort_code,
    :treasury_source_account,
    :treasury_account_name,
    :treasury_account_no,
    :treasury_bank_name,
    :amount       
      )`,
        {
          replacements: {
            query_type: item.query_type ? item.query_type : query_type,
            funding_code : item.funding_code ? item.funding_code : funding_code,
            date : item.date ? item.date : "",
            mda_source_account : item.mda_source_account ? item.mda_source_account : "",
            mda_account_no : item.mda_account_no ? item.mda_account_no : "",
            mda_bank_name : item.mda_bank_name ? item.mda_bank_name : "",
            mda_sort_code : item.mda_sort_code ? item.mda_sort_code : "",
            treasury_source_account : item.treasury_source_account ? item.treasury_source_account : "",
            treasury_account_name : item.treasury_account_name ? item.treasury_account_name : "",
            treasury_account_no : item.treasury_account_no ? item.treasury_account_no : "",
            treasury_bank_name : item.treasury_bank_name ? item.treasury_bank_name : "",
            amount : item.amount ? item.amount : item.amount
          }, 
        },
      )
     
  })
  res.json({ success: true, funding_code })
   }
})
 
}


exports.pvCollection = (req, res) => {

	  
	
	const {
		// pv_code = "",
    date = "",
    project_type = "",
    payment_type = "",
    mda_name = "",
    amount = "",
    query_type = ""
	} = req.body.form;

	const {batch_code = ""} = req.body

	const computer_pv_no = ""
	 console.log(req.body)

fetchCode('select','pv_code', (results) => {
  if(results && results.length ) {
    let pv_code = results[0].batch_code


db.sequelize.query(`call pv_collection (
	:query_type,
	:date, 
	:pv_code,
    :project_type,
    :payment_type,
    :mda_name,
    :amount
	)`,
		{
replacements : {
	query_type,
	date,
	pv_code,
    project_type,
    payment_type,
    mda_name,
    amount 
				},
			},
		)
.then((result) => {
				res.json({
					success : true,
					pv_code,
					result
				})
				console.log(result)

			})
				.catch((err) => {
					console.log(err)
					res.json({
						success : false,
						err

					})
				})
			}
		})
			
}



exports.contractorScheduleArray = (req, res) => {
  const { contractScheduleTable, batch_no = "", status = "",
   query_type = "", cheque_number = "", arabic_date = "" } = req.body
  // const batch_no = uuid()
   console.log(req.body)
fetchCode('select','contractor_code', (results) => {
  if(results && results.length ) {
    let contractor_code = results[0].batch_code

    console.log("body",req.body)
    // console.log(batch_code1)

  let count = 0

  contractScheduleTable.forEach((item, idx) => {
    db.sequelize
    .query(
    `CALL contractor_schedule (
    :query_type,
    :contractor_code, 
    :date,
    :mda_name,
    :project_description,
    :contractor,
    :amount,
    :project_type,
    :payment_type,
    :project_classification,
    :VAT,
    :WHT,
    :SD,
    :EL,
    :tender,
    :WR,
    :others,
    :total_taxes  
      )`,
        {
          replacements: {
            query_type: item.query_type ? item.query_type : query_type,
            contractor_code : contractor_code,
            date: item.date ? item.date : '',
    		mda_name : item.mda_name ? item.mda_name : "",
    		project_description : item.project_description ? item.project_description : "",
    		contractor : item.contractor ? item.contractor : "",
    		amount : item.amount ? item.amount : "",
    		project_type : item.project_type ? item.project_type : "",
    		payment_type : item.payment_type ? item.payment_type : "",
    		project_classification : item.project_classification  ? item.project_classification : "",
    		VAT : item.VAT ? item.VAT : "",
    		WHT : item.WHT ? item.WHT : "",
    		SD : item.SD ? item.SD : "",
    		EL : item.EL ? item.EL : "",
    		tender : item.tender ? item.tender : "",
    		WR : item.WR ? item.WR : "",
            others : item.others ? item.others : "",
            total_taxes : item.total_taxes ? item.total_taxes : ""
          },
        },
      )

     
  })
  res.json({ success: true, contractor_code })
  }
})
 }


 exports.contractorSchedule = (req, res) => {
   console.log("kello")
   console.log("body", req.body)
 const {
    query_type = "",
    contractor_code = "", 
    date = "",
    mda_name = "",
    project_description = "",
    contractor = "",
    amount = "",
    project_type = "",
    payment_type = "",
    project_classification = "",
    VAT = "",
    WHT = "",
    SD = "",
    EL = "",
    tender = "",
    WR = "",
    others = "",
    total_taxes = ""
  } = req.body

  db.sequelize
      .query(
    `CALL contractor_schedule (
    :query_type,
    :contractor_code, 
    :date,
    :mda_name,
    :project_description,
    :contractor,
    :amount,
    :project_type,
    :payment_type,
    :project_classification,
    :VAT,
    :WHT,
    :SD,
    :EL,
    :tender,
    :WR,
    :others,
    :total_taxes
    
      )`,

    {
        replacements: {
    query_type,
    contractor_code, 
    date,
    mda_name,
    project_description,
    contractor,
    amount,
    project_type,
    payment_type,
    project_classification,
    VAT,
    WHT,
    SD,
    EL,
    tender,
    WR,
    others,
    total_taxes
        },
      }
    ).then((result) => {
      res.json({
        success: true,
        result,
      })

      // console.log("result1", result)
    })
    .catch((err) => {
      res.json({
        success: false,
        err,
      })
      console.log(err)
    })

  }

  exports.projectType = (req, res) => {
   // console.log("kello")
   console.log("body", req.body)
 const {
    query_type = "",
  } = req.body

  db.sequelize
      .query(
    `CALL project_type (
    :query_type
      )`,

    {
        replacements: {
    query_type
        },
      }
    ).then((result) => {
      res.json({
        success: true,
        result,
      })

      // console.log("result1", result)
    })
    .catch((err) => {
      res.json({
        success: false,
        err,
      })
      console.log(err)
    })

  }


exports.taxes = (req, res) => {
   // console.log("kello")
   console.log("body", req.body)
 const {
    query_type = "",
  } = req.body

  db.sequelize
      .query(
    `CALL taxes (
    :query_type
      )`,

    {
        replacements: {
    query_type
        },
      }
    ).then((result) => {
      res.json({
        success: true,
        result,
      })

      // console.log("result1", result)
    })
    .catch((err) => {
      res.json({
        success: false,
        err,
      })
      console.log(err)
    })

  }




exports.contractorDetails = (req, res) => {
	const {
		contractor_name = "",
		contractor_phone = "",
		contractor_address = "",
		contractor_email = "",
		contractor_tin_no = "",		
		query_type = ""
	} = req.body

	console.log("bodd", req.body)

	fetchCode('select','contractor_code', (results) => {
  if(results && results.length ) {
    let contractor_code = results[0].batch_code


	
		db.sequelize.query(
			`CALL contractor_details(
				:query_type,
 :contractor_name, :contractor_phone, :contractor_address, 
:contractor_email, :contractor_tin_no, :contractor_code 
			)`,
			{
				replacements : {
						query_type,
					
		contractor_name,
		contractor_phone,
		contractor_address,
		contractor_email,
		contractor_tin_no,
		contractor_code		
	
		
				}
			}
			).then((result) => {
				res.json({
					success : true,
					result,
					contractor_code
				})

				console.log(result)
			})
				.catch((err) => {
					res.json({
						success : false,
						err

					})
		})
			}
		})
}

