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




// exports.contractorDetails = (res, req) => {
// 	const {
// 		contractor_no,
// 		contractor_name = "",
// 		contractor_phone = "",
// 		contractor_address = "",
// 		contractor_email = "",
// 		contractor_tin_no = "",		
// 		query_type = ""
// 	} = req.body

	
// 		db.sequelize.query(
// 			`CALL contractor_details(
// :contractor_no, :contractor_name, :contractor_phone, :contractor_address, 
// :contractor_email, :contractor_tin_no, :query_type
// 			)`,
// 			{
// 				replacements : {
// 					contractor_no,
// 		contractor_name,
// 		contractor_phone,
// 		contractor_address,
// 		contractor_email,
// 		contractor_tin_no,		
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
		pv_code = "",
    date = "",
    project_type = "",
    payment_type = "",
    mda_name = "",
    amount = "",
    query_type = ""
	} = req.body.form;

	const computer_pv_no = ""
	 console.log(req.body)

fetchCode('select','pv_code', (results) => {
  if(results && results.length ) {
    let funding_code = results[0].batch_code


db.sequelize.query(`call pv_collection (
	:query_type,  
	:pv_code,
    :date,
    :project_type,
    :payment_type,
    :mda_name,
    :amount
	)`,
		{
replacements : {
	query_type,
	pv_code,
    date,
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
					funding_code
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

