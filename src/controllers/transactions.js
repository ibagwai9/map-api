const db = require('../models')

export const getInvoiceDetails = async (userId, refNo) => {
  try {
    const reqData = await db.sequelize.query(
      `SELECT a.user_id, a.reference_number, a.dr, a.description, b.name FROM tax_transactions a 
        JOIN users b on a.user_id=b.id 
        where 
        #a.user_id="${userId}" and 
        a.reference_number="${userId}" AND a.transaction_type='invoice'`,
    )
    return reqData[0]
  } catch (error) {
    return error
  }
}

const callHandleTaxTransaction = async (params) => {
  try {
    const results = await db.sequelize.query(
      `CALL HandleTaxTransaction(:query_type, :user_id, :agent_id,:org_code,
        :rev_code, :description, :nin_id, :org_name, :paid_by, :confirmed_by, 
        :payer_acct_no, :payer_bank_name, :cr, :dr, :transaction_date, 
        :transaction_type, :status, :reference_number)`,
      {
        replacements: { ...params },
      },
    )
    return results
  } catch (err) {
    console.error('Error executing stored procedure:', err)
    throw new Error('Error executing stored procedure')
  }
}

// This can serve create invoice or payment and nothing else
export const postTrx = async (req, res) => {
  const {
    user_id = null,
    agent_id = null,
    sector_id = 1,
    tax_list = [],
    transaction_date,
    reference_number,
    nin_id = '',
    org_name = '',
    paid_by = '',
    confirmed_by = '',
    payer_acct_no = '',
    payer_bank_name = '',
  } = req.body

  // Helper function to call the tax transaction asynchronously
  const callHandleTaxTransactionAsync = async (tax) => {
    const { description, amount, rev_code, org_code, transaction_type } = tax

    const params = {
      query_type: `insert_${transaction_type}`,
      user_id,
      agent_id,
      sector_id,
      description,
      cr: transaction_type === 'payment' ? amount : 0,
      dr: transaction_type === 'invoice' ? amount : 0,
      transaction_date,
      transaction_type,
      status: description === 'invoice' ? 'paid' : 'saved',
      reference_number,
      rev_code,
      org_code,
      nin_id,
      org_name,
      paid_by,
      confirmed_by,
      payer_acct_no,
      payer_bank_name,
    }

    try {
      const results = await callHandleTaxTransaction(params)
      return { success: true, data: results }
    } catch (error) {
      console.error('Error executing stored procedure:', error)
      return { success: false, message: 'Error executing stored procedure' }
    }
  }

  try {
    // Execute all tax transactions asynchronously using Promise.all
    const transactionResults = await Promise.all(
      tax_list.map(callHandleTaxTransactionAsync),
    )

    // Check if any transaction failed
    const hasFailedTransaction = transactionResults.some(
      (result) => !result.success,
    )

    if (hasFailedTransaction) {
      return res.status(500).json({
        success: false,
        message: 'Error executing some stored procedures',
      })
    }

    // Return the output parameters in the response
    return res.status(200).json({ success: true, data: transactionResults })
  } catch (err) {
    console.error('Error executing stored procedure:', err)
    return res
      .status(500)
      .json({ success: false, message: 'Error executing stored procedures' })
  }
}

// Update | Payment approval and others operations should use get
export const getTrx = async (req, res) => {
  const {
    user_id = null,
    agent_id = null,
    sector_id = 1,
    status = '',
    transaction_date = '',
    reference_number = '',
    nin_id = '',
    org_name = '',
    paid_by = '',
    confirmed_by = '',
    payer_acct_no = '',
    payer_bank_name = '',
    description = '',
    amount = '',
    rev_code = '',
    org_code = '',
    transaction_type = '',
    query_type = '',
  } = req.query

  const params = {
    user_id,
    agent_id,
    sector_id,
    description,
    cr: 0,
    dr: 0,
    transaction_date,
    transaction_type,
    status,
    reference_number,
    rev_code,
    org_code,
    nin_id,
    org_name,
    paid_by,
    confirmed_by,
    payer_acct_no,
    payer_bank_name,
    query_type,
  }

  try {
    const data = await callHandleTaxTransaction(params)
    res.json({ success: true, data })
  } catch (error) {
    console.error('Error executing stored procedure:', error)
    res
      .status(500)
      .json({ success: false, message: 'Error executing stored procedure' })
  }
}
