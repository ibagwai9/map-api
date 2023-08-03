// controllers/transactionController.js
const axios = require('axios');
const crypto = require('crypto');

const merchantMacKey = "E187B1191265B18338B5DEBAF9F38FEC37B170FF582D4666DAB1F098304D5EE7F3BE15540461FE92F1D40332FDBBA34579034EE2AC78B1A1B8D9A321974025C4";

const getTransaction = async (req, res) => {
  const subpdtid = req.body.item_code //6204; // Your product ID
  const amount = req.body.amount;
  const txnref = req.body.txnref;

  const hashv = subpdtid + txnref + merchantMacKey;
  const thash = crypto.createHash('sha512').update(hashv).digest('hex');

  const params = {
    productid: subpdtid,
    transactionreference: txnref,
    amount: amount,
  };
  const ponmo = new URLSearchParams(params).toString();

  const url = `https://sandbox.interswitchng.com/webpay/api/v1/gettransaction.json?${ponmo}`;

  const headers = {
    "GET": "/HTTP/1.1",
    "Host": "sandbox.interswitchng.com",
    "User-Agent": "Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.9.0.1) Gecko/2008070208 Firefox/3.0.1",
    "Accept": "*/*",
    "Accept-Language": "en-us,en;q=0.5",
    "Keep-Alive": 300,
    "Connection": "keep-alive",
    "Hash": thash,
  };

  try {
    const response = await axios.get(url, { headers });
    res.json(response.data);
  } catch (error) {
    console.error('Error fetching transaction data:', error);
    res.status(500).json({ error: 'An error occurred while fetching transaction data' });
  }
};

module.exports = {
  getTransaction,
};