const request = require('request');

const smsAPIKey = 'FgROMRDs93kpR7bZEryWis5sPBfd4imuBIP3fZ9xECMUrVsaKpcg8qKAPTVU'

const smsAPIurl = 'https://www.bulksmsnigeria.com/api/v1/sms';

exports.send = (phone, message, callback=f=>f, err=f=>f) => {

	var options = {
	  'method': 'POST',
	  'url': `${smsAPIurl}/create?api_token=${smsAPIKey}&to=${phone}&from=KIRMAS&body=${message}&dnd=2`,
	};

	request(options, function (error, response) {
	  if (error) err(error);
	  callback(response.body);
	});

}