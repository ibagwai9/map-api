const moment = require("moment");
const { uuid } = require("uuidv4");
const db = require("../models");
const today = moment().format("YYYY-MM-DD");
exports.paymentSchedule = (req, res) => {
  // console.log('kello')
  // console.log('body', req.body)
  const {
    query_type = "",
    date = today,
    batch_no = "",
    treasury_account_name = "",
    treasury_account_no = "",
    treasury_bank_name = "",
    mda_account_name = "",
    mda_account_no = "",
    mda_bank_name = "",
    mda_acct_sort_code = "",
    mda_code = "",
    mda_name = "",
    mda_description = "",
    mda_budget_balance = "",
    mda_economic_code = "",
    amount = 0,
    description = "",
    attachment = "",
    budget = "",
    approval = "",
    treasury_source_account = "",
    id = "",
    status = "",
    cheque_number = "",
    narration = "",
    arabic_date = "",
    payment_type = "",
    budget_year = "",
    type = "",
    limit = 10,
    offset = 0,
    search = "",
  } = req.body;

  db.sequelize
    .query(
      `CALL payment_schedule (
    :query_type, 
    :date,
    :batch_no,  
    :treasury_account_name,
    :treasury_account_no,
    :treasury_bank_name,
    :mda_account_name,
    :mda_account_no,
    :mda_bank_name,
    :mda_acct_sort_code ,
    :mda_code,
    :mda_name,
    :mda_description ,
    :mda_budget_balance,
    :mda_economic_code,
    :amount,
    :description ,
    :attachment,
    :treasury_source_account,
    :id,
    :budget,
    :approval,
    :status,
    :cheque_number,
    :narration,
    :arabic_date,
    :payment_type, 
    :budget_year,
    :type,:limit,:offset,:search,'',''
      )`,

      {
        replacements: {
          query_type,
          date,
          batch_no,
          treasury_account_name,
          treasury_account_no,
          treasury_bank_name,
          mda_account_name,
          mda_account_no,
          mda_bank_name,
          mda_acct_sort_code,
          mda_code,
          mda_name,
          mda_description,
          mda_budget_balance,
          mda_economic_code,
          amount,
          description,
          attachment,
          treasury_source_account,
          id,
          budget,
          approval,
          status,
          cheque_number,
          narration,
          arabic_date,
          payment_type,
          budget_year,
          type,
          limit,
          offset,
          search,
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

const fetchCode = (
  query_type = "select",
  description = "batch_code",
  callback = (f) => f,
  error = (f) => f
) => {
  db.sequelize
    .query(
      `CALL batch_increment (
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

exports.fetchCode_batchIncrement = fetchCode;

exports.updateBudgetCode = (req, res) => {
  const { description, query_type } = req.body;
  db.sequelize
    .query(
      `CALL batch_increment (
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
      // error(err)
    });
};

exports.paymentScheduleArray = (req, res) => {
  const {
    paymentScheduleTable,
    batch_no = "",
    status = "",
    query_type = "",
    cheque_number = "",
    id='',
    arabic_date = "",
  } = req.body;
  // const batch_no = uuid()
  console.log(req.body);

  fetchCode("select", "batch_code", (results) => {
    if (results && results.length) {
      let batch_code1 = results[0].batch_code;

      console.log("body1", req.body);
      console.log(batch_code1);
      console.log("result", results[0].batch_code);

      let count = 0;

      paymentScheduleTable.forEach((item, idx) => {
        db.sequelize
          .query(
            `CALL payment_schedule (
            :query_type, 
            :date,
            :batch_no,  
            :treasury_account_name,
            :treasury_account_no,
            :treasury_bank_name,
            :mda_account_name,
            :mda_account_no,
            :mda_bank_name,
            :mda_acct_sort_code ,
            :mda_code,
            :mda_name,
            :mda_description ,
            :mda_budget_balance,
            :mda_economic_code,
            :amount,
            :description ,
            :attachment,
            :treasury_source_account,
            :id,
            :budget,
            :approval,
            :status,
            :cheque_number,
            :narration,
            :arabic_date,
            :payment_type, :budget_year, :type,:limit,:offset,:search,:approval_no,:imageId
          )`,
            {
              replacements: {
                approval_no: item.approval_no ,
                imageId:item.imageId?item.imageId:'',
                query_type: item.query_type ? item.query_type : query_type,
                date: item.date ? item.date : today,
                batch_no: item.batch_no ? item.batch_no : batch_code1,
                treasury_account_name: item.treasury_account_name
                  ? item.treasury_account_name
                  : "",
                treasury_account_no: item.treasury_account_no
                  ? item.treasury_account_no
                  : "",
                treasury_bank_name: item.treasury_bank_name
                  ? item.treasury_bank_name
                  : "",
                mda_account_name: item.mda_account_name
                  ? item.mda_account_name
                  : "",
                mda_account_no: item.mda_account_no ? item.mda_account_no : "",
                mda_bank_name: item.mda_bank_name ? item.mda_bank_name : "",
                mda_acct_sort_code: item.mda_acct_sort_code
                  ? item.mda_acct_sort_code
                  : "",
                mda_code: item.mda_code ? item.mda_code : "",
                mda_name: item.mda_name ? item.mda_name : "",
                mda_description: item.mda_description
                  ? item.mda_description
                  : "",
                mda_budget_balance: item.mda_budget_balance
                  ? item.mda_budget_balance
                  : "",
                mda_economic_code: item.mda_economic_code
                  ? item.mda_economic_code
                  : "",
                amount: item.amount ? item.amount : "",
                description: item.description ? item.description : "",
                attachment: item.attachment ? item.attachment : "",
                treasury_source_account: item.treasury_source_account
                  ? item.treasury_source_account
                  : "",
                id: item.id ? item.id : "",
                budget: item.budget ? item.budget : "",
                approval: item.approval ? item.approval : "",
                status: status,
                cheque_number,
                narration: item.narration ? item.narration : "",
                arabic_date,
                payment_type: item.payment_type ? item.payment_type : "",
                budget_year: item.budget_year ? item.budget_year : "",
                type: item.type ? item.type : "",
                limit: item.limit ? item.limit : 1,
                offset: item.offset ? item.offset : 1,
                search: item.search ? item.search : "",
              },
            }
          )
          .then(() => {
            if (item.payment_type === "full_payment" && item.approval_no) {
              db.sequelize.query(
                `CALL approval_collection (
                  :collection_date,
                  :approval_date,
                  :mda_name,
                  :mda_description,
                  :approved_amount,
                  :approved_by,
                  :query_type,
                  :mda_economic_code,
                  :mda_code, 
                  :approval_no, 
                  :filter,
                  :id,''
                )`,
                {
                  replacements: {
                    collection_date: "",
                    approval_date: "",
                    mda_name: "",
                    mda_description: "",
                    approved_amount: "",
                    approved_by: "",
                    query_type: "update_approval",
                    mda_economic_code: "",
                    mda_code: "",
                    approval_no: item.approval_no,
                    filter: "",
                    id:''
                  },
                }
              );
            }
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

exports.numberGenerator = (res, req) => {
  const { description = "", code = "", query_type = "" } = req.body;

  db.sequelize
    .query(
      `CALL check_details(
:description, :code, :query_type
      )`,
      {
        replacements: {
          description,
          code,
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
      res.json({
        success: false,
        err,
      });
    });
};

exports.bankDetails = (res, req) => {
  const {
    account_name = "",
    account_description = "",
    account_number = "",
    bank_name = "",
    query_type = "",
  } = req.body;

  db.sequelize
    .query(
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
          query_type,
        },
      }
    )
    .then((result) => {
      res.json({
        success: true,
        result,
      });

      // console.log(result)
    })
    .catch((err) => {
      res.json({
        success: false,
        err,
      });
    });
};

function saveBudget(
  {
    mda_name,
    parent_code,
    child_code,
    description,
    amount = 0.1,
    remarks,
    query_type,
    id,
    post_budget_amount,
    Proposed_budget,
    Approved_budget,
    revised_budget,
    buget_code,
    buget_year,
    segment_code,
    admin_code,
    functional_code,
    fund_code,
    geo_code,
  },
  callback = (f) => f,
  error = (f) => f
) {
  db.sequelize
    .query(
      `CALL update_budget(:mda_name, :parent_code, :child_code, :description, :amount, :remarks, :query_type, :id, 
        :post_budget_amount,:Proposed_budget, :Approved_budget,:revised_budget, :buget_code, :buget_year,
        :segment_code,:admin_code,:functional_code,:fund_code,:geo_code)`,
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
          post_budget_amount,
          Proposed_budget,
          Approved_budget,
          revised_budget,
          buget_code,
          buget_year,
          segment_code,
          admin_code,
          functional_code,
          fund_code,
          geo_code,
        },
      }
    )
    .then(callback)
    .catch(error);
}

exports.batchUpload = (req, res) => {
  const { data = [] } = req.body;

  // budget_amount: 500000
  // budget_description: "MEDICAL EXPENSES-LOCAL"
  // economic_code: 22021004
  // mda_code: 11100800100
  // mda_name: " Kano State Emergency Relief & Rehablitation Board"

  for (let d = 0; d < data.length; d++) {
    let item = data[d];
    saveBudget(
      {
        mda_name: item.mda_name,
        parent_code: item.economic_code,
        child_code: item.mda_code,
        description: item.budget_description,
        amount: item.budget_amount,
        remarks: "",
        query_type: "INSERT",
        id: item.id,
        post_budget_amount: 0,
        Proposed_budget: 0,
        Approved_budget: item.budget_amount ? item.budget_amount : "",
        revised_budget: 0,
        buget_code: 0,
        buget_year: item.year ? item.year : "",
        segment_code: item.segment_code ? item.segment_code : "",
        admin_code: item.admin_code ? item.admin_code : "",
        functional_code: item.functional_code ? item.functional_code : "",
        fund_code: item.fund_code ? item.fund_code : "",
        geo_code: item.geo_code ? item.geo_code : "",
      },
      () => {
        console.log("Done");
      },
      (err) => {
        console.log(err);
        res.status(500).json({ success: true, err });
      }
    );
  }

  res.json({ success: true });
};

exports.updateBudget = (req, res) => {
  const {
    child_code = "",
    parent_code = "",
    // mda_parent_code,
    // mda_child_code,
    description = "",
    amount = 0.1,
    id = "",
    post_budget_amount = "",
    remarks = "",
    Proposed_budget = "",
    Approved_budget = "",
    revised_budget = "",
    buget_code = "",
    buget_year = "",
    segment_code = "",
    admin_code = "",
    functional_code = "",
    fund_code = "",
    geo_code = "",
  } = req.body.form;

  const query_type = req.body.query_type;

  const mda_name = "";
  const remarks1 = "";

  db.sequelize
    .query(
      `CALL update_budget(:mda_name, :parent_code, :child_code, :description, :amount, :remarks, :query_type, :id, 
        :post_budget_amount,:Proposed_budget, :Approved_budget,:revised_budget, :buget_code, :buget_year,
        :segment_code,:admin_code,:functional_code,:fund_code,:geo_code)`,
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
          post_budget_amount,
          Proposed_budget,
          Approved_budget,
          revised_budget,
          buget_code,
          buget_year,
          segment_code,
          admin_code,
          functional_code,
          fund_code,
          geo_code,
        },
      }
    )
    .then((result) => {
      res.json({
        success: true,
        result,
      });

      // console.log(result)
    })
    .catch((err) => {
      console.log(err);
      res.json({
        success: false,
        err,
      });
    });
};

exports.postBudget = (req, res) => {
  const { date, budget_code, remarks, budget_amount, query_type } =
    req.body.form;

  db.sequelize
    .query(
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
          budget_amount,
        },
      }
    )
    .then((result) => {
      res.json({
        success: true,
        result,
      });

      // console.log(result)
    })
    .catch((err) => {
      console.log(err);
      res.json({
        success: false,
        err,
      });
    });
};

exports.budget_summary = (req, res) => {
  const { excelData } = req.body;
  // console.log(req.body)

  db.sequelize
    .query(
      `insert into budget_summary (mda_code, mda_name, economic_code, 
    budget_description,
    budget_amount) values ${excelData.map((item) => "(?)").join(",")};`,
      {
        replacements: excelData,
        type: db.sequelize.QueryTypes.insert,
      }
    )
    .then((result) => {
      res.json({ result });
    })
    .catch((err) => console.log(err));

  // const {paymentScheduleTable} = req.body

  //  paymentScheduleTable.forEach((item, idx) => {
  //    db.sequelize.query(
  //      `CALL budget_summary (:query_type,
  // :mda_code, :mda_name, :economic_code, :budget_description, :budget_amount
  // )`,
  //      {
  //    replacements : {
  //    query_type : item.query_type ? item.query_type : "insert",
  //    mda_code : item.mda_name ? item.mda_name : "",
  //    economic_code : item.economic_code ? item.economic_code : "",
  //    budget_description : item.budget_description ? item.budget_description : "",
  //    budget_amount : item.budget_amount  ? item.budget_amount : "",
  //        }
  //      }
  //      )
  //  })

  //        .catch((err) => {
  //          res.json({
  //            success : false,
  //            err

  //          })
  //        })

  // console.log(req.body)
};

exports.mda_bank_details = (req, res) => {
  const { excelData, query_type } = req.body;
  // console.log(req.body

  db.sequelize
    .query(
      `insert into mda_bank_details (account_name, bank_name, 
    account_number, 
    sort_code, id
    ) values ${excelData.map((item) => "(?)").join(",")};`,
      {
        replacements: excelData,
        type: db.sequelize.QueryTypes.insert,
      }
    )
    .then((result) => {
      res.json({ result });
    })
    .catch((err) => console.log(err));
};

exports.deleteApproveCol = (req, res) => {
  const { id } = req.body;
  console.log(req.body);
  db.sequelize
    .query(`call delete_approval_collection(:id)`, {
      replacements: {
        id,
      },
    })
    .then((result) => {
      res.json({ result, success: true });
    })
    .catch((err) => console.log(err));
};

exports.getApproveCol = (req, res) => {
  const { id } = req.query;
  console.log(req.query);
  db.sequelize
    .query(`call get_approval_col(:id)`, {
      replacements: {
        id,
      },
    })
    .then((result) => {
      res.json({ result, success: true });
    })
    .catch((err) => console.log(err));
};

exports.select_mda_bank_details = (req, res) => {
  const {
    query_type = "",
    account_name = "",
    bank_name = "",
    account_number = "",
    sort_code = "",
    account_type = "",
  } = req.body;
  const { id = "" } = req.params;
  console.log(id);

  db.sequelize
    .query(
      `CALL mda_bank_details(
        :account_name,
        :account_number, 
        :sort_code,      
        :bank_name,    
        :query_type,
        :id
      )`,
      {
        replacements: {
          account_name,
          bank_name,
          account_number,
          sort_code,
          query_type,
          id,
        },
      }
    )
    .then((result) => {
      res.json({
        success: true,
        result,
      });

      // console.log(result)
    })
    .catch((err) => {
      console.log(err);
      res.json({ success: false, err });
    });
};

exports.get_budget_summary = (req, res) => {
  const { query_type = "", mda_code = "", economic_code = "" } = req.query;
  // console.log(req.body)
  console.log(req.query);
  db.sequelize
    .query(
      `CALL budget_summary(:query_type,:mda_code,:b,:economic_code,:d,:e)`,
      {
        replacements: {
          query_type,
          mda_code,
          b: "",
          economic_code,
          d: "",
          e: "",
        },
      }
    )
    .then((result) => {
      res.json({ success: "true", result });
    })
    .catch((err) => {
      console.log(err);
      res.status(500).json({ err });
    });
};

exports.get_batch_list = (req, res) => {
  const {
    query_type = "",
    batch_no = "",
    status = "",
    type = "main_treasury",
  } = req.body;
  // console.log(req.body)
  db.sequelize
    .query(`CALL batch_list(:query_type, :batch_no, :status,:type)`, {
      replacements: { query_type, batch_no, status, type },
    })
    .then((result) => {
      res.json({
        success: true,
        result,
      });
    })
    .catch((err) => {
      console.log(err);
      res.status(500).json({ err });
    });
};

exports.postChequeDetails = (req, res) => {
  console.log(req.body);
  const {
    date = today,
    batch_number = "",
    cheque_number = "",
    total_amount = "",
    query_type = "",
    status = "",
  } = req.body.form;
  const { type = "" } = req.body;

  db.sequelize
    .query(
      `CALL cheque_details(
      :date,
      :batch_number,
      :cheque_number,
      :total_amount,
      :status,
      :query_type
      :type
      )`,
      {
        replacements: {
          date,
          batch_number,
          cheque_number,
          total_amount,
          status,
          query_type,
          type,
        },
      }
    )
    .then((result) => {
      res.json({ result });
    })
    .catch((err) => {
      console.log(err);
      res.status(500).json({ err });
    });
};

exports.getApprovalAttachment = (req, res) => {
  const { approval_no } = req.query;

  db.sequelize
    .query(
      `SELECT * FROM approval_collection_images WHERE imageId="${approval_no}"`
    )
    .then((results) => {
      res.json({ success: "true", results: results[0] });
    })
    .catch((err) => {
      console.log(err);
      res.status(500).json({ err });
    });
};

exports.approvalCollection = (req, res) => {
  console.log("kello");
  console.log("body", req.body);
  const {
    query_type = "",
    collection_date = today,
    approval_date = today,
    mda_name = "",
    description = "",
    approved_amount = "",
    mda_economic_code = "",
    approved_by = "",
    mda_code = "",
    filter = "",
    id='',
    imageId =''
  } = req.body.form;

  number_generator(
    { query_type: "select", prefix: "app", description: "approval" },
    (resp) => {
      let nextcode = resp && resp.length ? resp[0].next_code : Date.now();
      let yearcode = moment().format("YY");
      let monthcode = moment().format("MM");
      let approval_no = `${yearcode}${monthcode}${nextcode}`;
      console.log("success", approval_no);

      db.sequelize
        .query(
          `CALL approval_collection (
        :collection_date,
        :approval_date,
        :mda_name,
        :mda_description,
        :approved_amount,
        :approved_by,
        :query_type,
        :mda_economic_code,
        :mda_code, :approval_no, :filter,:id,:imageId
      )`,
          {
            replacements: {
              collection_date,
              approval_date,
              mda_name,
              mda_description: description,
              approved_amount,
              approved_by,
              query_type,
              mda_economic_code,
              mda_code,
              approval_no,
              filter,
              id,
              imageId
            },
          }
        )
        .then((result) => {
          if (query_type === "insert") {
            number_generator({
              query_type: "update",
              prefix: "app",
              description: "approval",
              code: nextcode,
            });
          }

          res.json({
            success: true,
            result,
          });

          // console.log("result1", result)
        })
        .catch((err) => {
          console.log(err);
          res.json({
            success: false,
            err,
          });
        });
    },
    (err) => {
      console.log(err);
    }
  );
};

exports.getMdaBankDetails = (req, res) => {
  const {
    account_name = "",
    account_number = "",
    sort_code = "",
    bank_name = "",
    query_type = "",
    id = "",
  } = req.query;
  // console.log(req.body)
  console.log(req.query);
  db.sequelize
    .query(
      `CALL mda_bank_details(
      :account_name,
      :account_number,
      :sort_code,
      :bank_name,
      :query_type,
      :id
      )`,
      {
        replacements: {
          account_name,
          account_number,
          sort_code,
          bank_name,
          query_type,
          id,
        },
      }
    )
    .then((result) => {
      res.json({ success: "true", result });
    })
    .catch((err) => {
      console.log(err);
      res.status(500).json({ err });
    });
};

exports.fileUploader = (req, res) => {
  console.log("ii", JSON.stringify(req.body.form));
  console.log(req.files);
  const files = req.files;
  // const {user, event_name} = req.body
  console.log("jk", JSON.parse(req.body.form));
  const { mda_name, mda_code, mda_economic_code, approved_by, approval,imageId='' } =
    JSON.parse(req.body.form);

  files.forEach((item) => {
    console.log(`${__dirname}/${item.name}`);
    db.sequelize
      .query(
        `INSERT INTO approval_collection_images ( image_url, mda_name, economic_code,
    approved_by, approval, mda_code ,imageId   
 ) VALUES 
      ( "${item.filename}", "${mda_name}", "${mda_economic_code}", "${approved_by}", "${approval}",  "${mda_code}","${imageId}")`
      )
      .catch((err) => {
        console.log(err);
        // res.status(500).json({ status: "failed", err });
      });
  });
  res.json({
    status: "success",
    msg: "Event Pictures Posted successfully",
  });
};

exports.fetchApprovalImages = (req, res) => {
  const { query_type = "", economic_code = "", mda_code = "" } = req.body;
  console.log("pp", req.body);
  // console.log(req.query)
  db.sequelize
    .query(
      `CALL approval_collection_images(
      :query_type,
  :economic_code,
  :mda_code 
  
      )`,
      {
        replacements: {
          query_type,
          economic_code,
          mda_code,
        },
      }
    )
    .then((result) => {
      console.log("result", result);
      res.json({
        success: "true",
        result,
      });
    })
    .catch((err) => {
      console.log(err);
      res.status(500).json({ err });
    });
};

exports.getReports = (req, res) => {
  const {
    query_type = "",
    economic_code = "",
    admin_code = "",
    segment_code = "",
    functional_code = "",
    fund_code = "",
    geo_code = "",
    operation = "",
    revenue_head = "",
  } = req.query;

  db.sequelize
    .query(
      `CALL get_reports(:query_type, :economic_code, :admin_code, :segment_code, :functional_code, 
      :fund_code, :geo_code, :operation, :revenue_head)`,
      {
        replacements: {
          query_type,
          economic_code,
          admin_code,
          segment_code,
          functional_code,
          fund_code,
          geo_code,
          operation,
          revenue_head,
        },
      }
    )
    .then((results) => {
      res.json({
        success: "true",
        results,
      });
    })
    .catch((err) => {
      console.log(err);
      res.status(500).json({ err });
    });
};

function number_generator(
  { query_type = "", prefix = "", description = "", code = "" },
  callback = (f) => f,
  error = (f) => f
) {
  db.sequelize
    .query("CALL number_generator(:query_type, :prefix, :description, :code)", {
      replacements: {
        query_type,
        prefix,
        description,
        code,
      },
    })
    .then(callback)
    .catch(error);
}

exports.postNextCode = (req, res) => {
  number_generator(req.body, (results) => {
    res.json({ success: true, results });
  }).catch((err) => {
    res.status(500).json({ success: false, err });
  });
};

exports.getNextCode = (req, res) => {
  number_generator(req.query, (results) => {
    res.json({ success: true, results });
  }).catch((err) => {
    res.status(500).json({ success: false, err });
  });
};


exports.reportDashboard = (req,res) => {
  const  { query_type, fromDate, toDate } = req.query;

  db.sequelize.query('CALL ag_dashboard(:query_type, :fromDate, :toDate)', {
    replacements: { query_type, fromDate, toDate }
  }).then(results => {
    res.json({ success: true, results })
  })
    .catch(error => {
      console.log(error)
      res.status(500).json({ success:false, error })
    });
}