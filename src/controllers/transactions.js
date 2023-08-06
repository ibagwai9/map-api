const db = require('../models');

const callHandleTaxTransaction = async (params) => {
  try {
    const results = await db.sequelize.query('CALL HandleTaxTransaction(:query_type, :user_id, :agent_id,:org_code,:rev_code, :description, :cr, :dr, :transaction_date, :transaction_type, :status, :reference_number)', {
      replacements: { ...params },
    });
    return results;
  } catch (err) {
    console.error('Error executing stored procedure:', err);
    throw new Error('Error executing stored procedure');
  }
};

// This can only serve create invoice or payment and nothing else
export const postTrx = async (req, res) => {
  try {
    const {
      user_id = null,
      agent_id = null,
      sector_id = 1,
      tax_list = [],
      transaction_date,
      reference_number,
    } = req.body;

    // Helper function to call the tax transaction asynchronously
    const callHandleTaxTransactionAsync = async (tax) => {
      const {
        description,
        amount,
        rev_code,
        org_code,        
        transaction_type,
      } = tax;

      const params = {
        query_type:`insert_${transaction_type}`,
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
        status: 'success',
      };

      return await callHandleTaxTransaction(params);
    };

    // Execute all tax transactions asynchronously using Promise.all
    const results = await Promise.all(tax_list.map(callHandleTaxTransactionAsync));

    // Return the output parameters in the response
    return res.status(200).json({ success: true, data: results });
  } catch (err) {
    console.error('Error executing stored procedure:', err);
    return res.status(500).json({ success: false, message: 'Error executing stored procedure' });
  }
};



export const getTrx = async (req, res) => {
    const {
      query_type,
      user_id,
      agent_id,
      sector_id,
      description,
      transaction_date,
      transaction_type,
      status,
      reference_number,
    } = req.query;
  
    // Define the input parameters for the stored procedure
    const params = {
      query_type,
      user_id,
      agent_id,
      sector_id,
      description,
      cr:0,
      dr:0,
      transaction_date,
      transaction_type,
      status,
      reference_number,
    };
  
    try {
      const results = await callHandleTaxTransaction(params);
      // Return the output parameters in the response
      return res.status(200).json({ success: true, data: results[0] });
    } catch (err) {
      console.error('Error executing stored procedure:', err);
      return res.status(500).json({ success: false, message: 'Error executing stored procedure' });
    }
  };
  