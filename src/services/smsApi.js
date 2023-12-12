const request = require("request");

const smsAPIKey = process.env.smsAPIKey;

const smsAPIurl = process.env.smsAPIurl;

exports.send = (phone, message, callback = (f) => f, err = (f) => f) => {
  var options = {
    'method': 'POST',
    'url': `https://www.bulksmsnigeria.com/api/v1/sms/create?api_token=NU5Gk6cA03bDGokDQZWabCyftUQ3vq9C4yLNwwqU1NxuwL8iTVu9zJKIOwn5&to=${phone}&from=KIRMAS&body=${message}&dnd=2`,
  };

  request(options, function (error, response) {
    if (error) throw new Error(error);
    callback(response.body)
    console.log(response.body);
  });
};






exports.SMSTemplate = (item) => {
  return `Reset password otp is ${item} use it to reset your password Support: 07036105884 , info@brainstorm.ng`;
};
