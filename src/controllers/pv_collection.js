const db = require("../models")


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


exports.pvCollection = (req, res) => {

	  
	
	const {
		date,
		pv_no,
		pv_date,
		
		project_type,
		project_name,
		mda_name,
		contractor_no,
		query_type,
		bank,
        sort_code,
        amount,
        tin,
        account_no,      
        project_description,
        tax_details
	} = req.body.pvColl;

	const computer_pv_no = ""
	 console.log(req.body.pvColl)

db.sequelize.query(`call pv_collection (:query_type, :date, :pv_no, :pv_date, 
	:computer_pv_no, :project_type, :project_name, :mda_name, :contractor_no, 
	:bank,
        :sort_code,
        :amount,
        :tin,
        :account_no, 
        :project_description,
        :tax_details
	)`,
			{
		replacements : {
		query_type, 
		date ,
		pv_no ,
		pv_date ,
		computer_pv_no,
		project_type ,
		project_name ,
		mda_name ,
	  	contractor_no,
	  	bank,
        sort_code,
        amount,
        tin,
        account_no,
        project_description,
        tax_details
		
				},
			},
		)
.then((result) => {
				res.json({
					success : true,
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




