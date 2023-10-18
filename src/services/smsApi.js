const request = require("request");

const smsAPIKey = process.env.smsAPIKey;

const smsAPIurl = process.env.smsAPIurl;

exports.send = (phone, message, callback = (f) => f, err = (f) => f) => {
  var options = {
    method: "POST",
    url: `${smsAPIurl}/create?api_token=${smsAPIKey}&to=${phone}&from=KIRMAS&body=${message}&dnd=2`,
  };

  request(options, function (error, response) {
    if (error) err(error);
    callback(response.body);
  });
};

exports.SMSTemplate = (item) => {
  return `reset password otp is ${item} use it to reset password Support: 07036105884 , info@brainstorm.ng`;
};
