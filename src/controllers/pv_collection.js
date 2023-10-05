const db = require("../models");

const UUIDV4 = require("uuid").v4;

const { fetchCode_batchIncrement } = require("./payment_schedule");

exports.updatePvCode = (req, res) => {
  const { description, query_type } = req.body;
  db.sequelize
    .query(
      `CALL pv_increment (
      :description,
      :query_type 
      )`,
      {
        replacements: {
          description,
          query_type,
        },
      }
    )
    .then((result) => {
      res.json({
        success: true,
        result,
      });

      console.log(result);
    })
    .catch((err) => {
      console.log(err);
      error(err);
    });
};

const fetchCode = (
  query_type = "select",
  description = "batch_code",
  callback = (f) => f,
  error = (f) => f
) => {
  db.sequelize
    .query(
      `CALL funding_increment (
      :description,
      :query_type 
      )`,
      {
        replacements: {
          description,
          query_type,
        },
      }
    )
    .then((result) => callback(result))
    .catch((err) => {
      console.log(err);
      error(err);
    });
};

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
  const {
    tsaBatch,
    batch_no = "",
    status = "",
    query_type = "",
    cheque_number = "",
    arabic_date = "",
  } = req.body;
  //  const { mda_name, mda_code, mda_economic_code, approved_by, approval } =
  //    JSON.parse(req.body.form);
  console.log(req.body);

  console.log("body", req.body);

  let count = 0;

  // reference_number: '',
  //     fund_date: '2022-01-10',
  //     mda_source_account: '',
  //     mda_account_no: '3230230231',
  //     mda_bank_name: '',
  //     mda_sort_code: '300',
  //     treasury_source_account: 'FCMB (2004262028)',
  //     treasury_account_name: 'FCMB',
  //     treasury_account_no: '2004262028',
  //     treasury_bank_name: 'FCMB',
  //     amount: '500',
  //     accType: 'Other Treasury Accounts',
  //     selectedAccountType: 'Statutory',
  //     fund_code: '123'

  fetchCode("select", "reference_number", (results) => {
    if (results && results.length) {
      let reference_number = results[0].batch_code;

      tsaBatch.forEach((item, idx) => {
        db.sequelize.query(
          `CALL tsa_funding (:fund_date,:mda_source_account,:mda_account_no,:mda_bank_name,:mda_sort_code,
      :treasury_account_name,:treasury_account_no,:treasury_bank_name,:amount,:reference_number,
      :fund_source,:fund_source_type,:fund_code,:types)`,
          {
            replacements: {
              fund_date: item.fund_date ? item.fund_date : "",
              mda_source_account: item.mda_source_account
                ? item.mda_source_account
                : "",
              mda_account_no: item.mda_account_no ? item.mda_account_no : "",
              mda_bank_name: item.mda_bank_name ? item.mda_bank_name : "",
              mda_sort_code: item.mda_sort_code ? item.mda_sort_code : "",
              treasury_account_name: item.treasury_account_name
                ? item.treasury_account_name
                : "",
              treasury_account_no: item.treasury_account_no
                ? item.treasury_account_no
                : "",
              treasury_bank_name: item.treasury_bank_name
                ? item.treasury_bank_name
                : "",
              amount: item.amount ? item.amount : item.amount,
              reference_number: item.reference_number
                ? item.reference_number
                : reference_number,
              fund_source: item.selectedAccountType
                ? item.selectedAccountType
                : "",
              fund_source_type: item.accType ? item.accType : "",
              fund_code: item.fund_code ? item.fund_code : "",
              types: item.types ? item.types : "",
            },
          }
        );
      });
      res.json({ success: true, reference_number });
    }
  });
};

function queryTsaAccount(
  { query_type = "", account = "", types = null },
  callback = (f) => f,
  error = (f) => f
) {
  db.sequelize
    .query("CALL get_tsa_account(:query_type, :account, :types)", {
      replacements: { query_type, account, types },
    })
    .then(callback)
    .catch(error);
}

exports.getTsaAccount = (req, res) => {
  queryTsaAccount(
    req.query,
    (results) => {
      res.json({ success: true, results });
    },
    (err) => {
      console.log(err);
      res.json({
        success: false,
        err,
      });
    }
  );
};

exports.fecthTsaFunding = (req, res) => {
  console.log("kello");
  console.log("body", req.body);
  const { query_type = "", account_number = "", account_type = "" } = req.body;

  db.sequelize
    .query(
      `CALL fetch_tsa_funding(:query_type,:account_number,:account_type)`,

      {
        replacements: {
          query_type,
          account_number,
          account_type,
        },
      }
    )
    .then((result) => {
      res.json({
        success: true,
        result,
      });

      // console.log("result1", result)
    })
    .catch((err) => {
      res.json({
        success: false,
        err,
      });
      console.log(err);
    });
};

exports.tsaFundingArray = (req, res) => {
  const {
    tsaBatch,
    batch_no = "",
    status = "",
    query_type = "",
    cheque_number = "",
    arabic_date = "",
  } = req.body;
  // const batch_no = uuid()

  console.log(req.body);

  console.log("body", req.body);

  let count = 0;

  fetchCode("select", "reference_number", (results) => {
    if (results && results.length) {
      let reference_number = results[0].batch_code;

      tsaBatch.forEach((item, idx) => {
        db.sequelize.query(
          `CALL tsa_funding (:fund_date,:mda_source_account,:mda_account_no,:mda_bank_name,:mda_sort_code,
      :treasury_account_name,:treasury_account_no,:treasury_bank_name,:amount,:reference_number,
      :fund_source,:fund_source_type,:fund_code,:types)`,
          {
            replacements: {
              fund_date: item.fund_date ? item.fund_date : "",
              date: item.date ? item.date : "",
              mda_source_account: item.mda_source_account
                ? item.mda_source_account
                : "",
              mda_account_no: item.mda_account_no ? item.mda_account_no : "",
              mda_bank_name: item.mda_bank_name ? item.mda_bank_name : "",
              mda_sort_code: item.mda_sort_code ? item.mda_sort_code : "",
              treasury_source_account: item.treasury_source_account
                ? item.treasury_source_account
                : "",
              treasury_account_name: item.treasury_account_name
                ? item.treasury_account_name
                : "",
              treasury_account_no: item.treasury_account_no
                ? item.treasury_account_no
                : "",
              treasury_bank_name: item.treasury_bank_name
                ? item.treasury_bank_name
                : "",
              amount: item.amount ? item.amount : item.amount,
              reference_number: item.reference_number
                ? item.reference_number
                : reference_number,
              fund_source: item.selectedAccountType
                ? item.selectedAccountType
                : "",
              fund_source_type: item.accType ? item.accType : "",
              fund_code: item.fund_code ? item.fund_code : "",
              types: item.types ? item.types : "",
            },
          }
        );
      });
      res.json({ success: true, reference_number });
    }
  });
};

exports.pvCollection = (req, res) => {
  const {
    pv_code = "",
    date = "",
    project_type = "",
    payment_type = "",
    mda_name = "",
    amount = "",
    query_type = "",
    description = "",
    contractor_name = "",
    contractor_phone = "",
    contractor_tin = "",
    contractor_email = "",
    contractor_address = "",
    account_name = "",
    account_number = "",
    bank_name = "",
    sort_code = "",
    project_classification = "",
    certificate_no = "",
  } = req.body.form;

  const { batch_code = "" } = req.body;

  const computer_pv_no = "";
  console.log(req.body);

  // fetchCode('select', 'pv_code', (results) => {
  //   if (results && results.length) {
  //     let pv_code = results[0].batch_code

  fetchCode("select", "contractor_code", (results) => {
    if (results && results.length) {
      let contractor_code = results[0].batch_code;
      db.sequelize
        .query(
          `call pv_collection (
            :query_type,
            :date, 
            :pv_code,
            :project_type,
            :payment_type,
            :mda_name,
            :amount,
            :description, :contractor_name,
            :contractor_phone, :contractor_tin, :contractor_email,
            :contractor_address, :account_name, 
            :account_number, :bank_name,:sort_code,:project_classification,:contractor_code,:certificate_no
          )`,
          {
            replacements: {
              query_type,
              date,
              pv_code,
              project_type,
              payment_type,
              mda_name,
              amount,
              description,
              contractor_name,
              contractor_phone,
              contractor_tin,
              contractor_email,
              contractor_address,
              account_name,
              account_number,
              bank_name,
              sort_code,
              project_classification,
              contractor_code,
              certificate_no,
            },
          }
        )
        .then((result) => {
          db.sequelize
            .query(
              `CALL contractor_details(
          :query_type,
          :contractor_name, :contractor_phone, :contractor_address, 
          :contractor_email, :contractor_tin, :contractor_code
    )`,
              {
                replacements: {
                  query_type,
                  contractor_name,
                  contractor_phone,
                  contractor_address,
                  contractor_email,
                  contractor_tin,
                  contractor_code,
                },
              }
            )
            .then((result) => {
              saveContractorBank({
                query_type: "INSERT",
                contractor_code,
                contractor_name,
                account_name,
                account_number,
                bank_name,
                sort_code,
              });

              // console.log(result)
            });

          res.json({
            success: true,
            pv_code,
            result,
          });
          // console.log(resul  t)
        })
        .catch((err) => {
          console.log(err);
          res.json({
            success: false,
            err,
          });
        });
    }
  });
  //   }
  // })
};

exports.contractorScheduleArray = (req, res) => {
  const {
    contractScheduleTable,
    // batch_no = '',
    status = "",
    query_type = "",
    cheque_number = "",
    arabic_date = "",
  } = req.body;
  // const batch_no = UUIDV4()
  console.log(req.body);
  fetchCode("select", "contractor_code", (results) => {
    if (results && results.length) {
      let batch_code = results[0].batch_code;

      console.log("body", req.body);
      // console.log(batch_code1)

      let count = 0;

      contractScheduleTable.forEach((item, idx) => {
        const contract_code = batch_code + "-" + idx + 1;
        console.log(contract_code);
        db.sequelize.query(
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
            :total_taxes, :contract_code, :contractor_tin, :mda_tin, :batch_no, :status,
            :cheque_number,
            :arabic_date,  :contractor_bank_name,
            :contractor_acc_name,
            :contractor_acc_no,
            :sort_code, :pv_code
          )`,
          {
            replacements: {
              query_type: item.query_type ? item.query_type : query_type,
              contractor_code: item.contractor_code ? item.contractor_code : "",
              date: item.date ? item.date : "",
              mda_name: item.mda_name ? item.mda_name : "",
              project_description: item.project_description
                ? item.project_description
                : "",
              contractor: item.contractor ? item.contractor : "",
              amount: item.amount ? item.amount : "",
              project_type: item.project_type ? item.project_type : "",
              payment_type: item.payment_type ? item.payment_type : "",
              project_classification: item.project_classification
                ? item.project_classification
                : "",
              VAT: item.VAT ? item.VAT : "",
              WHT: item.WHT ? item.WHT : "",
              SD: item.SD ? item.SD : "",
              EL: item.EL ? item.EL : "",
              tender: item.tender ? item.tender : "",
              WR: item.WR ? item.WR : "",
              others: item.others ? item.others : "",
              total_taxes: item.total_taxes ? item.total_taxes : "",
              contract_code,
              contractor_tin: item.contractor_tin ? item.contractor_tin : "",
              mda_tin: item.mda_tin ? item.mda_tin : "",
              batch_no: batch_code,
              status: item.status ? item.status : "",
              cheque_number: item.cheque_number ? item.cheque_number : "",
              arabic_date: item.arabic_date ? item.arabic_date : "",
              contractor_bank_name: item.contractor_bank_name
                ? item.contractor_bank_name
                : "",
              contractor_acc_name: item.contractor_acc_name
                ? item.contractor_acc_name
                : "",
              contractor_acc_no: item.contractor_acc_no
                ? item.contractor_acc_no
                : "",
              sort_code: item.sort_code ? item.sort_code : "",
              pv_code: item.pv_code ? item.pv_code : "",
            },
          }
        );

        if (item.taxesApplied && item.taxesApplied.length) {
          item.taxesApplied.map((tax) => {
            db.sequelize.query(
              "CALL tax_entry (:contractor_code, :description, :amount, :batch_no, :query_type, :batch_id)",
              {
                replacements: {
                  contractor_code: item.contractor_code,
                  description: tax.description,
                  amount: tax.amount,
                  batch_no: contract_code,
                  query_type: "new",
                  batch_id: batch_code,
                },
              }
            );
          });
        }
      });

      res.json({ success: true, contractor_code: batch_code });
    }
  });
};

function tsaBanks(
  { account = "", account_name = "", account_bank = "" },
  callback = (f) => f,
  error = (f) => f
) {
  db.sequelize
    .query("CALL tsa_banks(:acc, :acc_name, :acc_bank)", {
      replacements: {
        account,
        account_name,
        account_bank,
      },
    })
    .then(callback)
    .catch(error);
}

exports.getTsaAccount;

const taxApi = (
  {
    contractor_code = "",
    description = "",
    amount = "",
    contract_code = "",
    query_type = "",
    batch_id = "",
  },
  callback = (f) => f,
  error = (f) => f
) => {
  db.sequelize
    .query(
      "CALL tax_entry (:contractor_code, :description, :amount, :contract_code, :query_type, :batch_id)",
      {
        replacements: {
          contractor_code: contractor_code,
          description: description,
          amount: amount,
          contract_code,
          query_type: query_type,
          batch_id,
        },
      }
    )
    .then(callback)
    .catch(error);
};

exports.getTaxes = (req, res) => {
  // const {
  //   contractor_code = '',
  //   description = '',
  //   amount = '',
  //   contract_code = '',
  //   query_type = '',
  // } = req.query

  taxApi(
    req.query,
    (results) => {
      res.json({ success: false, results });
    },
    (err) => {
      res.status(500).json({ success: false, err });
    }
  );
};

exports.getTaxSchedule = (req, res) => {
  const { batch_id } = req.query;
  taxApi(
    {
      contractor_code: batch_id,
      query_type: "tax_schedule",
    },
    (taxList) => {
      // let schedule = {}
      // taxList.forEach(item => {
      //   taxApi({contractor_code: batch_id, description: item.description, query_type: 'schedule'},(results) => {
      //   // res.json({ success: false, results })
      //   schedule[item.description] = results
      // },(err) => {
      //   res.status(500).json({ success: false, err })
      // })
      // })

      // console.log(schedule)
      let schedule = {};
      // console.log(taxList, 'taxList')
      taxList.forEach((t) => {
        if (Object.keys(schedule).includes(t.description)) {
          schedule[t.description] = [...schedule[t.description], t];
        } else {
          schedule[t.description] = [t];
        }
      });

      // console.log(schedule)

      res.json({ success: true, schedule });
    }
  );
};

exports.contractorSchedule = (req, res) => {
  console.log("kello");
  console.log("body", req.body);
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
    total_taxes = "",
    batch_id = "",
    contractor_tin = "",
    mda_tin = "",
    batch_no = "",
    status = "",
    cheque_number = "",
    arabic_date = "",
    contractor_bank_name = "",
    contractor_acc_name = "",
    contractor_acc_no = "",
    sort_code = "",
    pv_code = "",
  } = req.body;

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
        :total_taxes,
        :batch_id, :contractor_tin, :mda_tin, :batch_no, :status,
        :cheque_number, :arabic_date, :contractor_bank_name,
        :contractor_acc_name,
        :contractor_acc_no,
        :sort_code,:pv_code
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
          total_taxes,
          batch_id,
          contractor_tin,
          mda_tin,
          batch_no,
          status,
          cheque_number,
          arabic_date,
          contractor_bank_name,
          contractor_acc_name,
          contractor_acc_no,
          sort_code,
          pv_code,
        },
      }
    )
    .then((result) => {
      res.json({
        success: true,
        result,
      });

      // console.log("result1", result)
    })
    .catch((err) => {
      res.json({
        success: false,
        err,
      });
      console.log(err);
    });
};

exports.contractorPaymentScheduleArray = (req, res) => {
  const {
    paymentScheduleTable,
    batch_no = "",
    status = "",
    query_type = "",
    cheque_number = "",
    arabic_date = "",
  } = req.body;
  // const batch_no = uuid()
  console.log(req.body);

  fetchCode_batchIncrement("select", "batch_code", (results) => {
    if (results && results.length) {
      let batch_code1 = results[0].batch_code;

      // console.log('body1', req.body)
      // console.log(batch_code1)
      // console.log('result', results[0].batch_code)

      let count = 0;

      paymentScheduleTable.forEach((item, idx) => {
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
            :total_taxes, :contract_code, 
            :contractor_tin, :mda_tin, :batch_no, :status,
            :cheque_number,
            :arabic_date, :contractor_bank_name,
            :contractor_acc_name,
            :contractor_acc_no,
            :sort_code, :pv_code
                                    
          )`,
            {
              replacements: {
                query_type: item.query_type ? item.query_type : query_type,
                contractor_code: item.contractor_code
                  ? item.contractor_code
                  : "",
                date: item.date ? item.date : "",
                mda_name: item.mda_name ? item.mda_name : "",
                project_description: item.project_description
                  ? item.project_description
                  : "",
                contractor: item.contractor ? item.contractor : "",
                amount: item.amount ? item.amount : "",
                project_type: item.project_type ? item.project_type : "",
                payment_type: item.payment_type ? item.payment_type : "",
                project_classification: item.project_classification
                  ? item.project_classification
                  : "",
                VAT: item.VAT ? item.VAT : "",
                WHT: item.WHT ? item.WHT : "",
                SD: item.SD ? item.SD : "",
                EL: item.EL ? item.EL : "",
                tender: item.tender ? item.tender : "",
                WR: item.WR ? item.WR : "",
                others: item.others ? item.others : "",
                total_taxes: item.total_taxes ? item.total_taxes : "",
                contract_code: item.contract_code ? item.contract_code : "",
                contractor_tin: item.contractor_tin ? item.contractor_tin : "",
                mda_tin: item.mda_tin ? item.mda_tin : "",
                batch_no: item.batch_id ? item.batch_id : "",
                status,
                cheque_number,
                arabic_date,
                contractor_bank_name: item.contractor_bank_name
                  ? item.contractor_bank_name
                  : "",
                contractor_acc_name: item.contractor_acc_name
                  ? item.contractor_acc_name
                  : "",
                contractor_acc_no: item.contractor_acc_no
                  ? item.contractor_acc_no
                  : "",
                sort_code: item.sort_code ? item.sort_code : "",
                pv_code: item.pv_code ? item.pv_code : "",
              },
            }
          )
          .then(() => {
            // if (item.payment_type === 'full_payment' && item.approval_no) {
            // db.sequelize.query(
            //   `CALL approval_collection (
            //     :collection_date,
            //     :approval_date,
            //     :mda_name,
            //     :mda_description,
            //     :approved_amount,
            //     :approved_by,
            //     :query_type,
            //     :mda_economic_code,
            //     :mda_code, :approval_no, :filter
            //   )`,
            //   {
            //     replacements: {
            //       collection_date: '',
            //       approval_date: '',
            //       mda_name: '',
            //       mda_description: '',
            //       approved_amount: '',
            //       approved_by: '',
            //       query_type: 'update_approval',
            //       mda_economic_code: '',
            //       mda_code: '',
            //       approval_no: item.approval_no,
            //       filter: '',
            //     },
            //   },
            // )
            // }
          });
      });
      res.json({ success: true, batch_code1 });
    }
  });

  // .then((result) => {
  //      count += 1
  //      console.log({ success: true, result, count })
  //    })
  //    .catch((error) => {
  //      res.json({
  //        success: false,
  //        error,
  //      })
  //    })
};

exports.projectType = (req, res) => {
  // console.log("kello")
  console.log("body", req.body);
  const { query_type = "" } = req.body;

  db.sequelize
    .query(
      `CALL project_type (
    :query_type
      )`,

      {
        replacements: {
          query_type,
        },
      }
    )
    .then((result) => {
      res.json({
        success: true,
        result,
      });

      // console.log("result1", result)
    })
    .catch((err) => {
      res.json({
        success: false,
        err,
      });
      console.log(err);
    });
};

exports.taxes = (req, res) => {
  // console.log("kello")
  // console.log("body", req.body);
  const { query_type = "" } = req.body;

  db.sequelize
    .query(
      `CALL taxes(:query_type)`,
      {
        replacements: {
          query_type,
        },
      }
    )
    .then((result) => {
      res.json({
        success: true,
        result,
      });

      // console.log("result1", result)
    })
    .catch((err) => {
      res.json({
        success: false,
        err,
      });
      console.log(err);
    });
};

exports.contractorDetails = (req, res) => {
  const {
    contractor_name = "",
    contractor_phone = "",
    contractor_address = "",
    contractor_email = "",
    contractor_tin = "",
    contractor_code = "",
    query_type = "",
    bankList = [],
  } = req.body;

  console.log("bodd", req.body);

  fetchCode("select", "contractor_code", (results) => {
    if (results && results.length) {
      let contractor_code1 = results[0].batch_code;

      db.sequelize
        .query(
          `CALL contractor_details(
				    :query_type,
            :contractor_name, :contractor_phone, :contractor_address, 
            :contractor_email, :contractor_tin, :contractor_code
			)`,
          {
            replacements: {
              query_type,
              contractor_name,
              contractor_phone,
              contractor_address,
              contractor_email,
              contractor_tin,
              contractor_code,
            },
          }
        )
        .then((result) => {
          if (bankList && bankList.length) {
            bankList.forEach((item) => {
              saveContractorBank(Object.assign({}, item, { contractor_code }));
            });
          }

          res.json({
            success: true,
            result,
            contractor_code1,
          });

          // console.log(result)
        })
        .catch((err) => {
          res.json({
            success: false,
            err,
          });
        });
    }
  });
};

const saveContractorBank = (
  {
    query_type = "",
    account_name = "",
    bank_name = "",
    account_number = "",
    sort_code = "",
    contractor_name = "",
    contractor_code = "",
  },
  callback = (f) => f,
  error = (f) => f
) => {
  db.sequelize
    .query(
      `CALL contractor_bank_details(
        :query_type,
        :bank_name,
        :account_name, 
        :account_number,
        :sort_code,
        :contractor_name,     
        :contractor_code
      )`,
      {
        replacements: {
          query_type,
          bank_name,
          account_name,
          account_number,
          sort_code,
          contractor_name,
          contractor_code,
        },
      }
    )
    .then(callback)
    .catch(error);
};

exports.contractor_bank_details = (req, res) => {
  const {} = req.body;
  // const { id = '' } = req.params
  // console.log(id)

  saveContractorBank(
    Object.assign(req.body),
    (result) => {
      res.json({
        success: true,
        result,
      });
    },
    (err) => {
      console.log(err);
      res.json({ success: false, err });
    }
  );
};

exports.fetchNgfAccountChart = (req, res) => {
  const {
    query_type = "",
    parent_code = "",
    child_code = "",
    sector = "",
  } = req.body.form;

  db.sequelize
    .query(
      `CALL ngf_account_chart(
:query_type,
:parent_code,
:child_code,
:sector      
      )`,
      {
        replacements: {
          query_type,
          parent_code,
          child_code,
          sector,
        },
      }
    )
    .then((result) => {
      res.json({
        success: true,
        result,
      });

      console.log(result);
    })
    .catch((err) => {
      console.log(err);
      res.json({
        success: false,
        err,
      });
    });
};
