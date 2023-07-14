const db = require("../models")


export const PostBudget = (req, res) => {
    const { query_type = '' } = req.query;
    const arr = []
    req.body.forEach(item=>{
        const { id = 0,
        budget_year = '',
        admin_code = '',
        admin_description = '',
        economic_code = '',
        economic_description = '',
        program_code = '',
        program_description = '',
        function_code = '',
        function_description = '',
        fund_code = '',
        fund_description = '',
        geo_code = '',
        geo_description = '',
        budget_amount = '',
        actual_amount = '',
        budget_type = '',
        start_date = '',
        end_date = '',
        status = '',
        transaction_type = '' } = item;
        arr.push(db.sequelize.query(`CALL PerformBudgetOperation(:query_type,:id,:budget_year,:admin_code,:admin_description,:economic_code,:economic_description,:program_code,:program_description,:function_code,:function_description,:fund_code,:fund_description,:geo_code,:geo_description,:budget_amount,:actual_amount,:budget_type,:start_date,:end_date,:status,:transaction_type)`, {
            replacements: {
                query_type,
                id,
                budget_year,
                admin_code,
                admin_description,
                economic_code,
                economic_description,
                program_code,
                program_description,
                function_code,
                function_description,
                fund_code,
                fund_description,
                geo_code,
                geo_description,
                budget_amount,
                actual_amount,
                budget_type,
                start_date,
                end_date,
                status,
                transaction_type
            }
        }))
}
    
    )
  
    Promise.all(arr).then((results)=>{
        res.json({ results, success: true })
  
       })
      .catch(error => {
        res.status(500).json({ error });
        console.log(error)
      })
}