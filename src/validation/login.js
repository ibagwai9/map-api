import Validator from 'validator';
import isEmpty from './isEmpty';

function validateLoginForm(data) {
  let errors = {};

  data.email = !isEmpty(data.email) ? data.email : '';
  data.password = !isEmpty(data.password) ? data.password : '';

  if (!Validator.isEmail(data.email)&&!Validator.isLength(data.email,6,32)) {
    errors.email = data.email.split('@').length>1?'Invalid Email.':'Invalid user name'
  }

  if (Validator.isEmpty(data.email)) {
    errors.email = 'Email is required';
  }

  if (Validator.isEmpty(data.password)) {
    errors.password = 'Password is required';
  }

  return {
    errors,
    isValid: isEmpty(errors),
  };
};

export default validateLoginForm