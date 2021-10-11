import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import passport from 'passport';

import db from '../models';
const User = db.User;

// load input validation
import validateRegisterForm from '../validation/register';
import validateLoginForm from '../validation/login';
import isEmpty from '../validation/isEmpty';

// create user
const create = (req, res) => {
  console.log(req.body);
  const { errors, isValid } = validateRegisterForm(req.body);
  let { 
    firstname, 
    lastname, 
    username, 
    role,
    email, 
    password,
  } = req.body;

  if(!isValid) {
    return res.status(400).json(errors);
  }

  User.findAll({ where: { email } }).then(user => {
    if (user.length) {
      return res.status(400).json({ email: 'Email already exists!' });
    } else {
      let newUser = { 
        firstname, 
        lastname, 
        username, 
        role,
        email, 
        password, 
      };
      bcrypt.genSalt(10, (err, salt) => {
        bcrypt.hash(newUser.password, salt, (err, hash) => {
          if (err) throw err;
          newUser.password = hash;
          User.create(newUser)
            .then(user => {
              res.json({ user });
            })
            .catch(err => {
              res.status(500).json({ err });
            });
        });
      });
    }
  });
};

const verifyAuth = (req, res, next) => {
  const authToken = req.headers["authorization"];
  const token = authToken.split(" ")[1];
  jwt.verify(token, "secret", (error, decoded) => {
    if (error) {
      return res.json({
        success: false,msg: "Failed to authenticate token." + error});
    }
    const { id } = decoded;
    User.findOne({ where: { id } })
      .then((user) => {
        if(!isEmpty(user)){
          res.json({success: true, user });
          next();
        }
      })
      .catch((error) => {
        // res.status(500).json({ success: false, error });
        console.log({error});
      });
  });
};
const login = (req, res) => {
  const { errors, isValid } = validateLoginForm(req.body);

  // check validation
  if(!isValid) {
    return res.status(400).json(errors);
  }
  const { email, password } = req.body;
  User.findAll({ 
    where: { 
      email
    } 
  })
  .then(user => {

    //check for user
    if (!user.length) {
      errors.email = 'User not found!';
      return res.status(404).json(errors);
    }
     
    let originalPassword = user[0].dataValues.password

    //check for password
    bcrypt
      .compare(password, originalPassword)
      .then(isMatch => {
        if (isMatch) {
          // user matched
          console.log('matched!')
          const { id, username } = user[0].dataValues;
          const payload = { id, username }; //jwt payload
          // console.log(payload)

          jwt.sign(payload, 'secret', { 
            expiresIn: 3600 
          }, (err, token) => {
            res.json({
              success: true,
              token: 'Bearer ' + token,
              role: user[0].dataValues.role
            });
          });
        } else {
          errors.password = 'Password not correct';
          return res.status(400).json(errors);
        }
    }).catch(error => console.log({error}));
  }).catch(error => res.status(500).json({error}));
};

// fetch all users
const findAllUsers = (req, res) => {
  User.findAll()
    .then(user => {
      res.json({ user });
    })
    .catch(err => res.status(500).json({ err }));
};

// fetch user by userId
const findById = (req, res) => {
  const id = req.params.userId;
  
  User.findAll({ where: { id } })
    .then(user => {
      if(!user.length) {
        return res.json({ msg: 'user not found'})
      }
      res.json({ user })
    })
    .catch(err => res.status(500).json({ err }));
};

// update a user's info
const update = (req, res) => {
  let { firstname, lastname, HospitalId, role, image } = req.body;
  const id = req.params.userId;

  User.update(
    {
      firstname,
      lastname,
      role,
    },
    { where: { id } }
  )
    .then(user => res.status(200).json({ user }))
    .catch(err => res.status(500).json({ err }));
};

// delete a user
const deleteUser = (req, res) => {
  const id = req.params.userId;

  User.destroy({ where: { id } })
    .then(() => res.status.json({ msg: 'User has been deleted successfully!' }))
    .catch(err => res.status(500).json({ msg: 'Failed to delete!' }));
};

export { 
    create, 
    login, 
    findAllUsers, 
    findById, 
    update, 
    verifyAuth,
    deleteUser 
}