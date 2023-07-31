import db from "../models";
import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import { number_generator } from "./payment_schedule";

exports.SignUp = (req, res) => {
  let form = req.body.form;
  console.log(req.body);
  const {
    username = null,
    password = null,
    fullname = null,
    email = null,
    role = "user",
    accessTo = null,
    bvn = null,
    company_name = null,
    rc = null,
    tin = null,
    account_type = null,
    phone = null,
    state = null,
    lga = null,
    address = null,
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
        console.log(resp[0]);
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
              number_generator(
                { query_type: "select", description: "taxID" },
                (code) => {
                  console.log(code[0]?.next_code, "TAXID>>>>>");
                  const taxID = code[0].next_code;
                  db.sequelize
                    .query(
                      "CALL user_accounts(:query_type, NULL, :fullname, :username, :email, :password, :role, :bvn, :tin, :company_name, :rc, :account_type, :phone, :state, :lga, :address, :accessTo,:taxID)",
                      {
                        replacements: {
                          query_type: "insert",
                          fullname,
                          username,
                          email,
                          password: newPass,
                          role,
                          bvn,
                          tin,
                          company_name,
                          rc,
                          account_type,
                          phone,
                          state,
                          lga,
                          address,
                          accessTo,
                          taxID,
                        },
                      }
                    )
                    .then((userResp) => {
                      db.sequelize
                        .query(
                          `SELECT * from users where username="${username}"`
                        )
                        .then((resultR) => {
                          //   res.json({
                          //   status: "success",
                          //   result : result[]
                          // });
                          let user = resultR[0];
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
                                taxID,
                              });
                              number_generator(
                                {
                                  query_type: "update",
                                  description: "taxID",
                                  code: taxID,
                                },
                                (r) => console.log(r),
                                (er) => console.log(er)
                              );
                            }
                          );
                        });
                    })
                    .catch((err) => {
                      console.log(err);
                      res.status(500).json({ status: "failed", err });
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

exports.verifyToken = (req, res) => {
  // const {verifyToken} = req.params
  const authToken = req.headers["authorization"];
  const token = authToken.split(" ")[1];
  console.log(authToken, 'LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL');

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
        `SELECT *  from users 
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

exports.getUsers = (req, res) => {
  const { role = "" } = req.query;
  db.sequelize
    .query(
      `SELECT * from users 
      where role="${role}"`
    )
    .then((result) => {
      res.json({ success: true, users: result[0] });
    })
    .catch((err) => {
      console.log(err);
      res.status(500).json({ status: "failed", err });
    });
};
