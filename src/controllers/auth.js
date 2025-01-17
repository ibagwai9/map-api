const db = require("../models");
const { SequelizeDatabaseError } = require("sequelize");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const { send, SMSTemplate } = require("../services/smsApi");
const transport = require("../config/nodemailer");

module.exports.SignUp = (req, res) => {
  const {
    username = "",
    password = "",
    org_name = "",
    contact_name = "",
    email = "",
    org_email = "",
    role = "user",
    accessTo = "",
    sector = "",
    bvn = "",
    company_name = "",
    office_address = "",
    rc = "",
    tin = "",
    org_tin = "",
    account_type = "",
    phone = "",
    office_phone = "",
    state = "",
    ward = "",
    lga = "",
    address = "",
    department = "",
    mda_name = "",
    mda_code = "",
    rank = "",
    contact_phone = "",
    status = "active",
    query_type = "insert",
    taxID = null,
    user_id = null,
    limit = 50,
    offset = 0,
    name = "",
  } = req.body;
  console.log(req.body, "jjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjj");

  db.sequelize.query(`SELECT max(id) + 1 as id from users `).then((result) => {
    let maxId = result[0][0].id;
    //   console.log(maxId);
    db.sequelize
      .query(
        `SELECT * from users
     where phone=:contact_phone`,
        {
          replacements: {
            contact_phone,
          },
        }
      )
      .then((resp) => {
        console.log(resp[0]);
        if (resp[0].length && query_type !== "add-account") {
          console.log("user exist");
          return res
            .status(400)
            .json({ success: false, msg: "Phone Number already registered" });
        } else {
          bcrypt.genSalt(10, (err, salt) => {
            bcrypt.hash(password, salt, (err, hash) => {
              if (err) throw err;
              let newPass = hash;
              db.sequelize
                .query(
                  "CALL user_accounts(:query_type, :user_id, :contact_name, :username, :email,:org_email, :password, :role, :bvn, :tin,:org_tin, :org_name, :rc, :account_type, :phone,:office_phone, :state, :lga, :address,:office_address, :mda_name, :mda_code, :department, :accessTo,:rank, :status,:taxID,:sector,:ward,:limit,:offset);",
                  {
                    replacements: {
                      query_type,
                      user_id,
                      org_name,
                      sector,
                      contact_name: contact_name ? contact_name : name,
                      username,
                      email,
                      org_email,
                      password: newPass,
                      role,
                      bvn,
                      tin,
                      org_tin,
                      company_name,
                      rc,
                      account_type,
                      phone: contact_phone,
                      office_phone,
                      state,
                      lga,
                      address,
                      office_address,
                      accessTo,
                      mda_name,
                      mda_code,
                      department,
                      rank,
                      status,
                      taxID,
                      ward,
                      limit,
                      offset,
                      name,
                    },
                  }
                )
                .then(
                  (userResp) => {
                    if (query_type !== 'add-account') {
                      db.sequelize
                        .query(
                          `SELECT * from users where phone="${contact_phone}"`
                        )
                        .then((resultR) => {
                          //   res.json({
                          //   status: "success",
                          //   result : result[]
                          // });
                          let user = resultR[0][0];
                          console.log(user);

                          let payload = {
                            id: user.id,
                            username: user.username,
                            email: user.email,
                            taxID: user.taxID,
                          };
                          jwt.sign(
                            payload,
                            process.env.JWT_SECRET_KEY,
                            {
                              expiresIn: 84300,
                            },
                            (err, token) => {
                              if (err) throw err;

                              res.json({
                                success: true,
                                msg: "Successfully logged in",
                                token,
                                user,
                                taxID: user.taxID,
                              });
                            }
                          );
                          if (phone) {
                            send(
                              phone,
                              `Welcome to KIRMAS\nYour Tax ID is ${user.taxID}`,
                              (resp) => {
                                console.log("SMS sent");
                                console.log(resp);
                              },
                              (err) => {
                                console.log("SMS not sent");
                                console.log(err);
                              }
                            );
                          }
                          if (email) {
                            transport
                              .sendMail({
                                from: "KIRMAS",
                                to: email,
                                subject: "Welcome",
                                html: ` <center>
                            <img src='https://mdas.kigra.gov.ng/images/knlogo.png'
                            height='80px' width='80px' />
                          </center>
                  
                          <h3>Warm welcome,</h3>
                          <h4>Thank you for registering with KIRMAS</h4>
                  
                          <p>Your Tax ID is ${user.taxID}.</p>      
                          <p>Do let us know if you are experiencing any difficulty at any point. Thank you.</p>
                          <br />
                  
                          <p>Best regards.</p>
                          <p>KIRMAS Support</p>`,
                              })
                              .then((info) => {
                                console.log("Message sent: %s", info.messageId);
                              })
                              .catch((err) => console.log("Error", err));
                          }

                          // .then((resultR) => {
                          //   //   res.json({
                          //   //   status: "success",
                          //   //   result : result[]
                          //   // });
                          //   let user = resultR[0][0];
                          //   console.log(user);

                          //   let payload = {
                          //     email: user.email,
                          //   };
                          //   jwt.sign(
                          //     payload,
                          //     "secret",
                          //     {
                          //       expiresIn: "1d",
                          //     },
                          //     (err, token) => {
                          //       if (err) throw err;

                          //       res.json({
                          //         success: true,
                          //         msg: "Successfully logged in",
                          //         token:'Bearer ' + token,
                          //         user,
                          //         taxID:user.taxID,
                          //       });

                          //     }
                          //   );
                          // });
                        })
                        .catch((err) => {
                          console.error("Database error:", err);
                          res
                            .status(500)
                            .json({ success: false, msg: "Database error", err });
                        });
                    } else {
                      res.json({
                        success: true,
                        msg: "Successfully logged in",
                        taxID,
                      });
                    }
                  },
                  (_er) => {
                    console.log(_er);
                    res.status(500).json({ success: false, msg: _er });
                  }
                )
                .catch((error) => {
                  console.log({ error });
                  // Catch the exact error
                  if (
                    error instanceof SequelizeDatabaseError &&
                    error.parent.code === "ER_SIGNAL_EXCEPTION"
                  ) {
                    res
                      .status(500)
                      .json({ success: false, msg: error.parent.sqlMessage });
                  } else {
                    // Catch other errors
                    res
                      .status(500)
                      .json({ success: false, msg: error.message });
                  }
                });
            });
          });
        }
      });
  });
};

module.exports.SignIn = async (req, res) => {
  const { username, password } = req.body;
  try {
    const user = await db.User.findOne({
      where: username.length > 10 ? { phone: username } : { taxID: username },
    });
    let users = [user.dataValues]

    console.log({ users });
    // let users=[user.dataValues]
    if (!users.length) {
      return res.status(404).json({
        success: false,
        msg: "User does not exist",
      });
    } else {
      // Only one user found, proceed with authentication
      console.log({ users });
      const user = users[0];
      const isMatch = await bcrypt.compare(password, user.password);

      if (isMatch) {
        const payload = {
          id: user.id,
          taxID: user.taxID,
          username: user.username,
          email: user.email,
          phone: user.phone,
          tax_accounts: [],
        };

        jwt.sign(
          payload,
          process.env.JWT_SECRET_KEY,
          {
            expiresIn: 86400,
          },
          (err, token) => {
            if (err) {
              return res
                .status(500)
                .json({ success: false, msg: "Server error" });
            }
            res.json({
              success: true,
              msg: "Successfully logged in",
              token: "Bearer " + token,
              user: user,
              tax_accounts: [],
            });
          }
        );
      } else {
        return res.status(400).json({ success: false, msg: "Wrong Password" });
      }
    }
  } catch (error) {
    return res.status(500).json({ success: false, msg: "Server error" });
  }
};

// module.exports.SignIn = (req, res) => {
//   const { username, password, role } = req.body;

//   //AND role = "${role}"

//   // db.sequelize
//   //   .query(
//   //     `SELECT * from
// 	// 	users WHERE username =  "${username}" OR email= "${username}" OR taxID = "${username}" `
//   //   )

//     db.User.findOne({
//       where: {
//         [db.Sequelize.Op.or]: [
//           { username },
//           { email: username },
//           { taxID: username },
//         ],
//       },
//     })
//     .then((result) => {
//       if (!result[0].length) {
//         res.status(400).json({
//           success: false,
//           msg: "user does not exits",
//         });
//         console.log("user does not exits");
//       } else {
//         console.log(result[0][0].username);

//         let originalPassword = result[0][0].password;

//         bcrypt.compare(password, originalPassword).then((isMatch) => {
//           if (isMatch) {
//             console.log("matched!");
//             let user = result[0][0];
//             console.log(user);

//             let payload = {
//               username: user.username,
//               email: user.email,
//             };

//             jwt.sign(
//               payload,
//               process.env.JWT_SECRET_KEY,
//               {
//                 expiresIn: "1d",
//               },
//               (err, token) => {
//                 if (err) throw err;

//                 res.json({
//                   success: true,
//                   msg: "Successfully logged in",
//                   token: "Bearer " + token,
//                   user,
//                 });
//               }
//             );
//           } else {
//             return res
//               .status(400)
//               .json({ success: false, msg: "Password not correct" });
//           }
//         });

//         // else{
//         // 	res.json({
//         // 		response : "Welcome back",
//         // 		status : 200,
//         // 		username : username,
//         // 		result
//         // 	})
//         // 	console.log("success")
//         // }
//       }
//     });
// };

module.exports.BudgetAppSignUp = (req, res) => {
  let form = req.body.form;
  console.log(req.body);
  const {
    username,
    password,
    fullname,
    role,
    accessTo,

    email = null,
    bvn = null,
    company_name = null,
    rc = null,
    tin = null,
    account_type = null,
    phone = null,
    state = null,
    lga = null,
    address = null,
    department = null,
  } = req.body;

  db.sequelize.query(`SELECT  max(id) + 1 as id from users `).then((result) => {
    let maxId = result[0][0].id;

    db.sequelize
      .query(`SELECT * from users where username="${username}"`)
      .then((resp) => {
        if (resp[0].length) {
          console.log("user exist");
          return res
            .status(400)
            .json({ success: false, msg: "username already registered" });
        } else {
          bcrypt.genSalt(10, (err, salt) => {
            bcrypt.hash(password, salt, (err, hash) => {
              if (err) throw err;
              let newPass = hash;

              db.sequelize
                .query(
                  `INSERT INTO users (id, username, password,fullname, role, accessTo, department ) VALUES 
                    ("${maxId}", "${username}","${newPass}","${fullname}","${role}","${accessTo}", "${department}")`
                )
                .then((results) => {
                  db.sequelize
                    .query(
                      `SELECT * from users 
                where username="${username}"`
                    )
                    .then((result) => {
                      //   res.json({
                      //   status: "success",
                      //   result : result[]
                      // });
                      let user = result[0][0];
                      console.log(user);

                      let payload = {
                        username: user.username,
                      };
                      jwt.sign(
                        payload,
                        process.env.JWT_SECRET_KEY,
                        {
                          expiresIn: "1d",
                        },
                        (err, token) => {
                          if (err) throw err;
                          res.json({
                            success: true,
                            msg: "Successfully logged in",
                            token,
                            user,
                          });
                        }
                      );
                    });
                })
                .catch((err) => {
                  console.log(err);
                  res.status(500).json({ status: "failed", err });
                });
            });
          });
        }
      });
  });
};

module.exports.TreasuryAppSignUp = (req, res) => {
  let form = req.body.form;
  console.log(req.body);
  const { username, password, fullname, role, accessTo } = req.body;

  db.sequelize
    .query(`SELECT  max(id) + 1 as id from sign_up `)
    .then((result) => {
      let maxId = result[0][0].id;
      //   console.log(maxId);

      db.sequelize
        .query(
          `SELECT * from sign_up
   where username="${username}"`
        )
        .then((resp) => {
          if (resp[0].length) {
            console.log("user exist");
            return res
              .status(400)
              .json({ success: false, msg: "username already registered" });
          } else {
            bcrypt.genSalt(10, (err, salt) => {
              bcrypt.hash(password, salt, (err, hash) => {
                if (err) throw err;
                let newPass = hash;

                db.sequelize
                  .query(
                    `INSERT INTO sign_up (id, username, password,fullname, role, accessTo ) VALUES 
            ("${maxId}", "${username}","${newPass}","${fullname}","${role}","${accessTo}")`
                  )
                  .then((results) => {
                    db.sequelize
                      .query(
                        `SELECT * from sign_up 
                where username="${username}"`
                      )
                      .then((result) => {
                        //   res.json({
                        //   status: "success",
                        //   result : result[]
                        // });
                        let user = result[0][0];
                        console.log(user);

                        let payload = {
                          username: user.username,
                        };
                        jwt.sign(
                          payload,
                          process.env.JWT_SECRET_KEY,
                          {
                            expiresIn: "1d",
                          },
                          (err, token) => {
                            if (err) throw err;

                            res.json({
                              success: true,
                              msg: "Successfully logged in",
                              token,
                              user,
                            });
                          }
                        );
                      });
                  })
                  .catch((err) => {
                    console.log(err);
                    res.status(500).json({ status: "failed", err });
                  });
              });
            });
          }
        });
    });
};

module.exports.TreasuryAppSignIn = (req, res) => {
  const { username, password, role } = req.body;

  //AND role = "${role}"

  db.sequelize
    .query(
      `SELECT * from 
		sign_up WHERE username =  "${username}" `
    )
    .then((result) => {
      if (!result[0].length) {
        res.status(400).json({
          success: false,
          msg: "user does not exits",
        });
        console.log("user does not exits");
      } else {
        console.log(result[0][0].username);

        let originalPassword = result[0][0].password;

        bcrypt.compare(password, originalPassword).then((isMatch) => {
          if (isMatch) {
            console.log("matched!");
            let user = result[0][0];
            console.log(user);

            let payload = {
              username: user.username,
            };

            jwt.sign(
              payload,
              process.env.JWT_SECRET_KEY,
              {
                expiresIn: "1d",
              },
              (err, token) => {
                if (err) throw err;

                res.json({
                  success: true,
                  msg: "Successfully logged in",
                  token,
                  user,
                });
              }
            );
          } else {
            return res
              .status(400)
              .json({ success: false, msg: "Password not correct" });
          }
        });

        // else{
        // 	res.json({
        // 		response : "Welcome back",
        // 		status : 200,
        // 		username : username,
        // 		result
        // 	})
        // 	console.log("success")
        // }
      }
    });
};

module.exports.verifyTokenTreasuryApp = (req, res) => {
  // const {verifyToken} = req.params
  const authToken = req.headers["authorization"];

  if (!authToken || !authToken.startsWith("Bearer ")) {
    return res.status(401).json({
      success: false,
      msg: "Invalid or missing token",
    });
  }
  const token = authToken.split(" ")[1];

  jwt.verify(token, process.env.JWT_SECRET_KEY, (err, decoded) => {
    if (err) {
      return res.json({
        success: false,
        msg: "Failed to authenticate token",
        err,
      });
    }

    const { username } = decoded;

    db.sequelize
      .query(
        `SELECT *  from sign_up 
      where username="${username}"`
      )
      .then((result) => {
        res.json({ success: true, user: result[0] });
      })
      .catch((err) => {
        console.log(err);
        res.status(500).json({ status: "failed", err });
      });
  });
};

module.exports.verifyToken = async function (req, res) {
  const authToken = req.headers["authorization"];
  if (!authToken || !authToken.startsWith("Bearer ")) {
    return res.status(401).json({
      success: false,
      msg: "Invalid or missing token",
    });
  }

  const token = authToken.slice(7); // Remove "Bearer " from the token string

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET_KEY);
    const { phone, taxID } = decoded;

    const user = await db.User.findOne({
      where: {
        [db.Sequelize.Op.and]: [
          // { username },
          { phone: phone },
          { taxID: taxID },
          // { email: username },
        ],
      },
    });

    if (!user) {
      return res.status(404).json({
        success: false,
        msg: "User not found",
      });
    }

    const tax_accounts = await db.sequelize.query(
      `SELECT * FROM tax_payers WHERE taxID='${user.taxID}'`
    );

    res.json({
      success: true,
      user,
      tax_accounts: tax_accounts[0] ? tax_accounts[0] : [],
    });
  } catch (err) {
    console.error(err);
    return res.status(401).json({
      success: false,
      msg: "Failed to authenticate token",
    });
  }
};

// module.exports.verifyToken = (req, res) => {
//   // const {verifyToken} = req.params
//   const authToken = req.headers["authorization"];
//   const token = authToken.split(" ")[1];

//   jwt.verify(token, process.env.JWT_SECRET_KEY, (err, decoded) => {
//     if (err) {
//       return res.json({
//         success: false,
//         msg: "Failed to authenticate token",
//         err,
//       });
//     }

//     const { email } = decoded;

//     console.log(decoded);

//     db.sequelize
//       .query(
//         `SELECT *  from users
//       where email="${email}"`
//       )
//       .then((result) => {
//         res.json({ success: true, user: result[0] });
//       })
//       .catch((err) => {
//         console.log(err);
//         res.status(500).json({ status: "failed", err });
//       });
//   });
// };

module.exports.getUsers = (req, res) => {
  const { role = "" } = req.query;
  db.sequelize
    .query(
      `SELECT * from sign_up 
      # where role="${role}"`
    )
    .then((result) => {
      res.json({ success: true, users: result[0] });
    })
    .catch((err) => {
      console.log(err);
      res.status(500).json({ status: "failed", err });
    });
};

module.exports.forgotPassword = (req, res) => {
  const { phone = "" } = req.query;
  db.sequelize
    .query(`SELECT * from users where phone=:phone`, {
      replacements: {
        phone,
      },
    })
    .then((result) => {
      res.json({ success: true, results: result[0] });
    })
    .catch((err) => {
      console.log(err);
      res.status(500).json({ status: "failed", err });
    });
};

module.exports.forgotPassword = (req, res) => {
  const { phone } = req.query;

  db.User.findAll({
    where: {
      phone,
    },
  }).then((user) => {
    if (!user.length) {
      return res
        .status(404)
        .json({ success: false, message: "User not found!" });
    }
    const min = 100000; // Minimum value (inclusive)
    const max = 999999; // Maximum value (inclusive)
    const randomNumber = Math.floor(Math.random() * (max - min + 1)) + min;

    let cc = randomNumber.toString().padStart(6, "0");

    db.sequelize
      .query(`update users set code=${cc} where phone=:phone`, {
        replacements: {
          phone,
        },
      })
      .then((user) => {
        if (user) {
          send(phone, SMSTemplate(cc), () => {
            res.json({
              success: true,
              message: "otp was send successfully",
              results: { phone, code: cc },
            });
          }),
            () => {
              res.json({
                success: false,
                message: "otp was not send try again",
              });
            };
        }
      })
      .catch((err) => {
        console.log(err);
        console.log("err");
        res.status(500).json({ success: false, message: err });
      });
  });
};
module.exports.codeVerification = (req, res) => {
  const { phone, code } = req.query;
  db.sequelize
    .query(`select * from users where  code=:code and phone=:phone`, {
      replacements: {
        phone,
        code,
      },
    })
    .then((results) =>
      res.json({ results: results[0], success: true, message: "valid" })
    )
    .catch((err) => {
      res.status(500).json({ success: false, message: err });
    });
};

module.exports.searchUser = (req, res) => {
  const { query_type = "select-user", id = "" } = req.query;
  db.sequelize
    .query(
      "CALL user_accounts(:query_type, :user_id, :name, :username, :email,:org_email, :password, :role, :bvn, :tin,:org_tin, :org_name, :rc, :account_type, :phone,:office_phone, :state, :lga, :address,:office_address, :mda_name, :mda_code, :department, :accessTo,:rank, :status,:taxID,:sector,:ward,:limit,:offset);",
      {
        replacements: {
          query_type,
          sector: "",
          id,
          org_name: "",
          contact_name: "",
          name: "",
          username: "",
          email: "",
          org_email: "",
          password: "",
          role: "",
          bvn: "",
          tin: "",
          org_tin: "",
          company_name: "",
          rc: "",
          account_type: "",
          phone: "",
          office_phone: "",
          state: "",
          lga: "",
          address: "",
          office_address: "",
          accessTo: "",
          mda_name: "",
          mda_code: "",
          department: "",
          rank: "",
          status: "active",
          ward: "",
          limit: 50,
          offset: 0,
        },
      }
    )
    .then((resp) => {
      res.json({ success: true, data: resp });
    })
    .catch((error) => {
      console.error({ error });
      res.status(500).json({ error, msg: "Error occured" });
    });
};

module.exports.getAdmins = (req, res) => {
  const { query_type = "select-user", id = "", mda_code = null } = req.query;

  db.sequelize
    .query(
      `SELECT u.*, NULL AS password FROM users u WHERE u.role IN('admin', 'agent') ${mda_code ? `AND mda_code='${mda_code}'` : ""
      } ;`
    )
    .then((resp) => {
      res.json({ success: true, data: resp[0] });
    })
    .catch((error) => {
      console.error({ error });
      res.status(500).json({ error, msg: "Error occured" });
    });
};

module.exports.generateNewPassword = (req, res) => {
  const { phone = "", password = "", code = "" } = req.body;
  bcrypt.genSalt(10, (err, salt) => {
    bcrypt.hash(password, salt, (err, hash) => {
      if (err) throw err;
      let newPass = hash;
      console.log(newPass);
      db.sequelize
        .query(
          "update  users set password=:newPass where phone=:phone and code =:code ",
          {
            replacements: {
              newPass,
              phone,
              code,
            },
          }
        )
        .then((resp) => {
          res.json({ success: true, data: resp[0] });
        })
        .catch((error) => {
          console.error({ error });
          res.status(500).json({ success: false, error, msg: "Error occured" });
        });
    });
  });
};

module.exports.UpdateTaxPayer = (req, res) => {
  const {
    user_id = null,
    username = "",
    org_name = "",
    name = "",
    contact_name = "",
    email = "",
    org_email = "",
    role = "user",
    accessTo = "",
    bvn = "",
    office_address = "",
    rc = "",
    tin = "",
    org_tin = "",
    account_type = "",
    phone = "",
    office_phone = "",
    state = "",
    lga = "",
    password = "",
    address = "",
    query_type = "update-taxpayer",
    mda_name = "",
    mda_code = "",
    department = "",
    rank = "",
    status = "active",
    taxID = null,
    sector = "",
    ward = "",
    limit = 50,
    offset = 0,
    contact_phone,
    contact_email,
    contact_address,
  } = req.body;
  bcrypt.genSalt(10, (err, salt) => {
    bcrypt.hash(password, salt, (err, hash) => {
      if (err) throw err;
      let newPass = hash;
      db.sequelize
        .query(
          "CALL user_accounts(:query_type, :user_id, :contact_name, :username, :email,:org_email, :password, :role, :bvn, :tin,:org_tin, :org_name, :rc, :account_type, :phone,:office_phone, :state, :lga, :address,:office_address, :mda_name, :mda_code, :department, :accessTo,:rank, :status,:taxID,:sector,:ward,:limit,:offset);",
          {
            replacements: {
              user_id,
              query_type,
              sector,
              org_name,
              contact_name: contact_name ? contact_name : name,
              username,
              email: contact_email || email,
              org_email,
              password: password ? newPass : null,
              role,
              bvn,
              ward,
              tin,
              org_tin,
              org_name,
              rc,
              account_type,
              phone: contact_phone ? contact_phone : phone,
              office_phone,
              state,
              lga,
              address: contact_address ? contact_address : address,
              office_address,
              accessTo,
              mda_name,
              mda_code,
              department,
              rank,
              status,
              taxID,
              sector,
              limit,
              offset,
            },
          }
        )
        .then((resp) => res.json({ success: true, data: resp }))
        .catch((error) => {
          console.error({ error });
          res.status(500).json({ success: false, msg: "Error occured" });
        });
    });
  });
};

module.exports.getTaxPayer = (req, res) => {
  const { user_id } = req.query;

  // First, try to find the record in the tax_payers table
  db.sequelize
    .query(`SELECT * FROM tax_payers t WHERE t.taxID='${user_id}'`, {
      replacements: {
        user_id,
      },
    })
    .then((resp) => {
      const taxPayerData = resp[0][0];
      res.json({ success: true, data: taxPayerData });
    })

    .catch((error) => {
      console.error({ error });
      res.status(500).json({ error, msg: "Error occurred" });
    });
};

module.exports.getTaxPayers = (req, res) => {
  const { user_id } = req.query;
  // First, try to find the record in the tax_payers table
  db.sequelize
    .query(
      `SELECT * FROM tax_payers WHERE taxID LIKE '%${user_id}%' OR name LIKE '%${user_id}%' OR org_name LIKE '%${user_id}%' OR phone LIKE '%${user_id}%' LIMIT 50`,
      {
        replacements: {
          user_id,
        },
      }
    )
    .then((resp) => {
      const taxPayerData = resp[0];
      res.json({ success: true, data: taxPayerData ? taxPayerData : [] });
    })

    .catch((error) => {
      console.error({ error });
      res.status(500).json({ error, msg: "Error occurred" });
    });
};

module.exports.searchTaxPayerByAll = (req, res) => {
  const { user_id, type = "" } = req.query;
  // First, try to find the record in the tax_payers table
  db.sequelize
    .query(
      `SELECT * FROM tax_payers WHERE account_type=:type and (taxID LIKE '%${user_id}%' OR name LIKE '%${user_id}%' OR org_name LIKE '%${user_id}%' OR phone LIKE '%${user_id}%') LIMIT 50`,
      {
        replacements: {
          user_id,
          type
        },
      }
    )
    .then((resp) => {
      const taxPayerData = resp[0];
      res.json({ success: true, data: taxPayerData ? taxPayerData : [] });
    })

    .catch((error) => {
      console.error({ error });
      res.status(500).json({ error, msg: "Error occurred" });
    });
};

module.exports.getTaxPayerInfo = (req, res) => {
  const { user_id } = req.query;
  db.sequelize
    .query(`SELECT * FROM tax_payers t  WHERE t.taxID='${user_id}'`, {
      replacements: {
        user_id,
      },
    })
    .then((resp) => {
      console.log(resp[0]);
      const taxPayerData = resp[0][0];
      res.json({ success: true, data: taxPayerData });
    })
    .catch((error) => {
      console.error({ error });
      res.status(500).json({ error, msg: "Error occurred" });
    });
};


