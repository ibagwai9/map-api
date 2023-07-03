import db from "../models";
import bcrypt from 'bcryptjs'
import jwt from 'jsonwebtoken'

 exports.SignUp = (req, res) => {
    let form = req.body.form
    console.log(req.body)
    const {  username=null, password=null, fullname=null,email=null, role='user', accessTo=null, bvn=null,company_name=null,rc=null,tin=null,account_type=null,phone=null,state=null,lga=null,address=null} = req.body;

    db.sequelize
    .query(`SELECT  max(id) + 1 as id from sign_up `)
    .then((result) => {
    let maxId = result[0][0].id;
    //   console.log(maxId);
    db.sequelize.query(`SELECT * from users
     where username="${username}"`)
    .then(resp => {
      console.log(resp[0]);
      if(resp[0].length) {
        console.log('user exist')
        return res.status(400).json({ success: false, msg: 'username already registered' })
      } else {
        bcrypt.genSalt(10, (err, salt) => {
          bcrypt.hash(password, salt, (err, hash) => {
            if(err) throw err;
            let newPass = hash;

            db.sequelize.query('CALL user_coounts(:query_type, NULL, :firstname, :lastname, :username, :email, :password, :role, :bvn, :tin, :company_name, :rc, :account_type, :phone, :state, :lga, :address, :accessTo)', {
              replacements: {
                query_type: 'insert',
                firstname:fullname.split(' ')[0],
                lastname:fullname.split(' ')[1],
                username,
                email,
                password:newPass,
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
              },
            })
              .then((userResp) => {
                db.sequelize.query(`SELECT * from sign_up 
                  where username="${username}"`)
                .then(resultR => {
                //   res.json({
                //   status: "success",
                //   result : result[]
                // });
                let user = resultR[0];
            console.log(user)

            let payload = {
              username: user.username,
            }
            jwt.sign(payload, "secret", {
              expiresIn: "1d"
            }, 
            (err, token) => {
              if(err) throw err;
              
              res.json({
                success: true,
                msg: 'Successfully logged in',
                token,
                user
              })
            })
                })
                
              })
              .catch((err) => {
                console.log(err);
                res.status(500).json({ status: "failed", err });
              })
          })
        })
      }
    })

    })
  } 


 exports.SignIn = (req, res) => {
	const {
	username,
    password,
    role
} = req.body

//AND role = "${role}"

	db.sequelize.query(`SELECT * from 
		sign_up WHERE username =  "${username}" `)
		.then((result) => {
			if(!result[0].length){
				res.status(400).json({
          success : false,
					msg : "user does not exits",
					
				})
				console.log("user does not exits")
			}
      else{
      console.log(result[0][0].username)

      let originalPassword = result[0][0].password;

      bcrypt
        .compare(password, originalPassword)
        .then(isMatch => {
          if(isMatch) {
            console.log('matched!')
            let user = result[0][0];
            console.log(user)

            let payload = {
              username: user.username,
            }

            jwt.sign(payload, "secret", {
              expiresIn: "1d"
            }, 
            (err, token) => {
              if(err) throw err;
              
              res.json({
                success: true,
                msg: 'Successfully logged in',
                token,
                user
              })
            })
          } else {
            return res.status(400).json({ success: false, msg: 'Password not correct'})
          }
        })

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
		})
}
		


exports.verifyToken = (req, res) => {
  // const {verifyToken} = req.params
  const authToken = req.headers["authorization"];
  const token = authToken.split(" ")[1]
  console.log(authToken)

  jwt.verify(token, 'secret', (err, decoded) => {
    if(err) {
      return res.json({ success: false, msg: 'Failed to authenticate token', 
        err })
    }

    const { username } = decoded;

    db.sequelize.query(`SELECT *  from sign_up 
      where username="${username}"`)
    .then(result => {
      res.json({ success: true, user: result[0]})
    }).catch((err) => {
        console.log(err);
        res.status(500).json({ status: "failed", err });
      })    
    
  })
}

exports.getUsers = (req, res) => {
  const { role='' } = req.query
    db.sequelize.query(`SELECT * from sign_up 
      where role="${role}"`)
    .then(result => {
      res.json({ success: true, users: result[0]})
    }).catch((err) => {
        console.log(err);
        res.status(500).json({ status: "failed", err });
      })    
    

}
