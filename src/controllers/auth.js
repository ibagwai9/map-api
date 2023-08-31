import db from "../models";
import bcrypt from "bcryptjs";
import jwt, { decode } from "jsonwebtoken";

exports.SignUp = (req, res) => {
  console.log(req.body);
  const {
    username = "",
    password = "",
    org_name = "",
    contact_name = "",
    email = "",
    org_email = "",
    role = "user",
    accessTo = "",
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
    lga = "",
    address = "",
    department = "",
  } = req.body;

  db.sequelize.query(`SELECT max(id) + 1 as id from users `).then((result) => {
    let maxId = result[0][0].id;
    //   console.log(maxId);
    db.sequelize
      .query(
        `SELECT * from users
     where email="${email}"`
      )
      .then((resp) => {
        console.log(resp[0]);
        if (resp[0].length) {
          console.log("user exist");
          return res
            .status(400)
            .json({ success: false, msg: "email already registered" });
        } else {
          bcrypt.genSalt(10, (err, salt) => {
            bcrypt.hash(password, salt, (err, hash) => {
              if (err) throw err;
              let newPass = hash;

              db.sequelize
                .query(
                  "CALL user_accounts(:query_type, NULL, :contact_name, :username, :email,:org_email, :password, :role, :bvn, :tin,:org_tin, :org_name, :rc, :account_type, :phone,:office_phone, :state, :lga, :address,:office_address, :accessTo)",
                  {
                    replacements: {
                      query_type: "insert",
                      org_name,
                      contact_name,
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
                      phone,
                      office_phone,
                      state,
                      lga,
                      address,
                      office_address,
                      accessTo,
                    },
                  }
                )
                .then(
                  (userResp) => {
                    db.sequelize
                      .query(`SELECT * from users where email="${email}"`)
                      .then((resultR) => {
                        //   res.json({
                        //   status: "success",
                        //   result : result[]
                        // });
                        let user = resultR[0][0];
                        console.log(user);

                        let payload = {
                          username: user.username,
                          email: user.email,
                        };
                        jwt.sign(
                          payload,
                          "secret",
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
                              taxID: user.taxID,
                            });
                          }
                        );
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
                        console.log(err);
                        res.status(500).json({ success: false, msg: err });
                      });
                  },
                  (_er) => console.log(_er)
                );
            });
          });
        }
      });
  });
};

exports.SignIn = (req, res) => {
  const { username, password, role } = req.body;

  //AND role = "${role}"

  db.sequelize
    .query(
      `SELECT * from 
		users WHERE username =  "${username}" OR email= "${username}" OR taxID = "${username}" `
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
              email: user.email,
            };

            jwt.sign(
              payload,
              "secret",
              {
                expiresIn: "1d",
              },
              (err, token) => {
                if (err) throw err;

                res.json({
                  success: true,
                  msg: "Successfully logged in",
                  token: "Bearer " + token,
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

exports.BudgetAppSignUp = (req, res) => {
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
    //   console.log(maxId);

    db.sequelize
      .query(
        `SELECT * from users
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
                        "secret",
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

exports.TreasuryAppSignUp = (req, res) => {
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
                          "secret",
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

exports.TreasuryAppSignIn = (req, res) => {
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
              "secret",
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

exports.verifyTokenTreasuryApp = (req, res) => {
  // const {verifyToken} = req.params
  const authToken = req.headers["authorization"];
  const token = authToken.split(" ")[1];
  console.log(authToken);

  jwt.verify(token, "secret", (err, decoded) => {
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

exports.verifyToken = (req, res) => {
  // const {verifyToken} = req.params
  const authToken = req.headers["authorization"];
  const token = authToken.split(" ")[1];
  console.log(authToken, "LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL");

  jwt.verify(token, "secret", (err, decoded) => {
    if (err) {
      return res.json({
        success: false,
        msg: "Failed to authenticate token",
        err,
      });
    }

    const { email } = decoded;

    console.log(decoded);

    db.sequelize
      .query(
        `SELECT *  from users 
      where email="${email}"`
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

exports.getUsers = (req, res) => {
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

export const searchUser = (req, res) => {
  const { query_type = "select-user", id = "" } = req.query;

  db.sequelize
    .query(
      "CALL user_accounts(:query_type, :id, :contact_name, :username, :email,:org_email, :password, :role, :bvn, :tin,:org_tin, :org_name, :rc, :account_type, :phone,:office_phone, :state, :lga, :address,:office_address, :accessTo)",
      {
        replacements: {
          query_type,
          id,
          org_name: "",
          contact_name: "",
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
