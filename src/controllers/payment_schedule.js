const { uuid } = require('uuidv4');
const db = require("../models")


exports.paymentSchedule = (req, res) => {
	const { paymentScheduleTable } = req.body
	console.log(req.body);
	const batch_no = uuid();
	let count = 0;
	paymentScheduleTable.forEach((item, idx) => {
		db.sequelize.query(`CALL payment_schedule (:query_type,
:date, :payment_type, :description, :economic_code, :amount, :batch_no,
:source_account, :mda_name, :compliance_status, :compliance_details, :budget_status,
:approval_status, :approved_by, :attachment_links
			)`,
			{
				replacements: {
					query_type: item.query_type ? item.query_type : "insert",
					date: item.date ? item.date : "",
					payment_type: item.payment_type ? item.payment_type : "",
					description: item.description ? item.description : "",
					economic_code: item.economic_code ? item.economic_code : "",
					amount: item.amount ? item.amount : "",
					batch_no,
					source_account: item.source_account ? item.source_account : "",
					mda_name: item.mda_name ? item.mda_name : "",
					compliance_status: item.compliance_status ? item.compliance_status : "",
					compliance_details: item.compliance_status ? item.compliance_status : "",
					budget_status: item.budget_status ? item.budget_status : "",
					approval_status: item.approval_status ? item.approval_status : "",
					approved_by: item.approved_by ? item.approved_by : "",
					attachment_links: item.attachment_links ? item.attachment_links : ""
				}
			})

			.then((result) => { count += 1; console.log({ success: true, result, count }) })
			.catch((error) => {
				res.json({
					success: false, error
				})
			})
	})
	res.json({ success: true, batch_no });
}

exports.numberGenerator = (res, req) => {
	const {
		description = "",
		code = "",
		query_type = ""
	} = req.body


	db.sequelize.query(
		`CALL check_details(
:description, :code, :query_type
			)`,
		{
			replacements: {
				description,
				code,
				query_type
			}
		}
	).then((result) => {
		res.json({
			success: true,
			result
		})

		console.log(result)
	})
		.catch((err) => {
			res.json({
				success: false,
				err

			})
		})
}


exports.bankDetails = (res, req) => {
	const {
		account_name = "",
		account_description = "",
		account_number = "",
		bank_name = "",
		query_type = ""
	} = req.body


	db.sequelize.query(
		`CALL payment_schedule(
:date, :payment_type, :description, :economic_code, :amount, :batch_no,
:source_account, :mda_name, :compliance_status, :compliance_details, :budget_status,
:approval_status, :approved_by, attachment_links
			)`,
		{
			replacements: {
				account_name,
				account_description,
				account_number,
				bank_name,
				query_type
			}
		}
	).then((result) => {
		res.json({
			success: true,
			result
		})

		console.log(result)
	})
		.catch((err) => {
			res.json({
				success: false,
				err

			})
		})
}

exports.updateBudget = (req, res) => {
	const {
		child_code = "",
		parent_code = "",
		// mda_parent_code,
		// mda_child_code,
		description = "",
		amount = "",
		id = "",
		post_budget_amount = "",
		remarks = ""
	} = req.body.form

	const query_type = req.body.query_type

	const mda_name = ""
	const remarks1 = ""


	db.sequelize.query(
		`CALL update_budget(
:mda_name, :parent_code, :child_code, 
:description, :amount, :remarks, :query_type, :id, :post_budget_amount
			)`,
		{
			replacements: {
				mda_name,
				parent_code,
				child_code,
				description,
				amount,
				remarks,
				query_type,
				id,
				post_budget_amount
			}
		}
	).then((result) => {
		res.json({
			success: true,
			result
		})

		console.log(result)
	})
		.catch((err) => {
			console.log(err)
			res.json({
				success: false,
				err

			})
		})
}

exports.postBudget = (req, res) => {
	const {
		date,
		budget_code,
		remarks,
		budget_amount,
		query_type
	} = req.body.form




	db.sequelize.query(
		`CALL post_budget(
			:query_type,
:date,
    :budget_code,
    :remarks,
    :budget_amount
     
			)`,
		{
			replacements: {
				query_type,
				date,
				budget_code,
				remarks,
				budget_amount

			}
		}
	).then((result) => {
		res.json({
			success: true,
			result
		})

		console.log(result)
	})
		.catch((err) => {
			console.log(err)
			res.json({
				success: false,
				err

			})
		})
}


exports.budget_summary = (req, res) => {
	const { excelData } = req.body
	// console.log(req.body)

	db.sequelize.query(
		`insert into budget_summary (mda_code, mda_name, economic_code, 
		budget_description,
		budget_amount) values ${excelData.map((item) => "(?)").join(",")};`,
		{
			replacements: excelData,
			type: db.sequelize.QueryTypes.insert
		}
	)
		.then((result) => {
			res.json({ result })
		})
		.catch((err) => console.log(err))

	// const {paymentScheduleTable} = req.body


	// 	paymentScheduleTable.forEach((item, idx) => {
	// 		db.sequelize.query(
	// 			`CALL budget_summary (:query_type,
	// :mda_code, :mda_name, :economic_code, :budget_description, :budget_amount
	// )`,
	// 			{
	// 		replacements : {
	// 		query_type : item.query_type ? item.query_type : "insert",
	// 		mda_code : item.mda_name ? item.mda_name : "",
	// 		economic_code : item.economic_code ? item.economic_code : "",
	// 		budget_description : item.budget_description ? item.budget_description : "",
	// 		budget_amount : item.budget_amount  ? item.budget_amount : "",		
	// 				}
	// 			}
	// 			)
	// 	})


	// 				.catch((err) => {
	// 					res.json({
	// 						success : false,
	// 						err

	// 					})
	// 				})

	// console.log(req.body)
}

exports.mda_bank_details = (req, res) => {
	const { excelData, query_type } = req.body
	// console.log(req.body
	db.sequelize.query(
		`insert into mda_bank_details (account_name, bank_name, 
		account_number, 
		sort_code
		) values ${excelData.map((item) => "(?)").join(",")};`,
		{
			replacements: excelData,
			type: db.sequelize.QueryTypes.insert
		}
	)
		.then((result) => {
			res.json({ result })
		})
		.catch((err) => console.log(err))
}

exports.select_mda_bank_details = (req, res) => {
	const {
		query_type = "",
		account_name = "",
		bank_name = "",
		account_number = "",
		sort_code = "",
		account_type="",
		id="",
	} = req.body


	db.sequelize.query(
		`CALL mda_bank_details(
			:account_name, :bank_name, 
		:account_number, 
		:sort_code, 
		:account_type,
		:id,
		:query_type
			)`,
		{
			replacements: {
				account_name, bank_name,
				account_number,
				sort_code,
				query_type,
				account_type,
				id,
			}
		}
	).then((result) => {
		res.json({
			success: true,
			result
		})

		console.log(result)
	})
		.catch((err) => {
			console.log(err)
			res.json({
				success: false,
				err

			})
		})
}
