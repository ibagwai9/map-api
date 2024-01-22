const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const db = require("../models");
const User = db.User;

// load input validation
const validateRegisterForm = require("../validation/register");
const validateLoginForm = require("../validation/login");
const isEmpty = require("../validation/isEmpty");

// create user
const create = (req, res) => {
  console.log(req.body);
  const { errors, isValid } = validateRegisterForm(req.body);
  let { name, username, role, email, password } = req.body;

  if (!isValid) {
    return res.status(400).json(errors);
  }

  User.findAll({ where: { email } }).then((user) => {
    if (user.length) {
      return res.status(400).json({ email: "Email already exists!" });
    } else {
      let newUser = {
        name,
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
            .then((user) => {
              res.json({ user });
            })
            .catch((err) => {
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
  jwt.verify(token, process.env.JWT_SECRET_KEY, (error, decoded) => {
    if (error) {
      return res.json({
        success: false,
        msg: "Failed to authenticate token." + error,
      });
    }
    const { id } = decoded;
    User.findOne({ where: { id } })
      .then((user) => {
        if (!isEmpty(user)) {
          res.json({ success: true, user });
          next();
        }
      })
      .catch((error) => {
        // res.status(500).json({ success: false, error });
        console.log({ error });
      });
  });
};

const login = (req, res) => {
  const { errors, isValid } = validateLoginForm(req.body);
  // check validation
  if (!isValid) {
    return res.status(400).json(errors);
  }
  const { email, password } = req.body;
  db.sequelize
    .query(`select * from users where email=:email or username=:email`, {
      replacements: { email },
    })
    .then((users) => {
      // console.log({users:users[0][0].email})
      //check for user
      if (!users.length) {
        errors.email = "User not found!";
        return res.status(404).json(errors);
      }
      const user = users[0][0];

      let originalPassword = user.password;

      //check for password
      bcrypt
        .compare(password, originalPassword)
        .then((isMatch) => {
          if (isMatch) {
            // user matched
            console.log("matched!");
            const { id, username } = user;
            const payload = { id, username }; //jwt payload
            // console.log(payload)

            jwt.sign(
              payload,
              process.env.JWT_SECRET_KEY,
              {
                expiresIn: 3600,
              },
              (err, token) => {
                res.json({
                  success: true,
                  token: "Bearer " + token,
                  role: user.role,
                });
              }
            );
          } else {
            errors.password = "Password not correct";
            return res.status(400).json(errors);
          }
        })
        .catch((error) => console.log({ error }));
    })
    .catch((error) => res.status(500).json({ error }));
};

// fetch all users
const findAllUsers = (req, res) => {
  User.findAll()
    .then((user) => {
      res.json({ user });
    })
    .catch((err) => res.status(500).json({ err }));
};

// fetch user by userId
const findById = (req, res) => {
  const id = req.params.userId;

  User.findAll({ where: { id } })
    .then((user) => {
      if (!user.length) {
        return res.json({ msg: "user not found" });
      }
      res.json({ user });
    })
    .catch((err) => res.status(500).json({ err }));
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
    .then((user) => res.status(200).json({ user }))
    .catch((err) => res.status(500).json({ err }));
};

// delete a user
const deleteUser = (req, res) => {
  const id = req.params.userId;

  User.destroy({ where: { id } })
    .then(() => res.status.json({ msg: "User has been deleted successfully!" }))
    .catch((err) => res.status(500).json({ msg: "Failed to delete!" }));
};

const resetPassword = (req, res) => {
  const { id, password, newPassword } = req.body;

  User.findOne({ where: { id } })
    .then((user) => {
      if (!user) {
        return res.status(404).json({ msg: "User not found", success: false });
      }

      bcrypt.compare(password, user.password).then((isMatch) => {
        if (!isMatch) {
          return res
            .status(400)
            .json({ msg: "Incorrect password", success: false });
        }

        bcrypt.genSalt(10, (err, salt) => {
          bcrypt.hash(newPassword, salt, (err, hash) => {
            if (err) throw err;
            user.password = hash;
            user
              .save()
              .then(() =>
                res
                  .status(200)
                  .json({ msg: "Password reset successful", success: true })
              )
              .catch((err) => res.status(500).json({ err, success: false }));
          });
        });
      });
    })
    .catch((err) => res.status(500).json({ err }));
};

module.exports = {
  create,
  login,
  findAllUsers,
  findById,
  update,
  verifyAuth,
  deleteUser,
  resetPassword,
};
