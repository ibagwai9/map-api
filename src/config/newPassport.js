const ExtractJwt = require("passport-jwt").ExtractJwt;
const JwtStrategy = require("passport-jwt").Strategy;
const models = require("../models");

const Users = models.User;

const opts = {};
opts.jwtFromRequest = ExtractJwt.fromAuthHeaderAsBearerToken();
opts.secretOrKey = process.env.JWT_SECRET_KEY;
// opts.issuer = 'accounts.examplesoft.com';
// opts.audience = 'yoursite.net';

module.exports = (passport) => {
  passport.use(
    new JwtStrategy(opts, (jwt_payload, done) => {
      models.sequelize
        .query(`SELECT * from  sign_up WHERE id = :id`, {
          replacements: {
            id: jwt_payload.id,
          },
        })
        .then((user) => {
          if (user[0].length) {
            return done(null, user);
          }
          return done(null, false);
        })
        .catch((err) => console.log(err));
      // Users.findAll({ where: { id: jwt_payload.id } })
      //   .then(user => {
      //     if (user.length) {
      //       return done(null, user);
      //     }
      //     return done(null, false);
      //   })
      //   .catch(err => console.log(err));
    })
  );
};

// import { Strategy as JwtStrategy, ExtractJwt } from 'passport-jwt'
// import models from '../models'

// const Users = models.User;

// const opts = {};
// opts.jwtFromRequest = ExtractJwt.fromAuthHeaderAsBearerToken();
// opts.secretOrKey = 'secret';
// // opts.issuer = 'accounts.examplesoft.com';
// // opts.audience = 'yoursite.net';

// // create jwt strategy
// module.exports = passport => {
//   passport.use(
//     new JwtStrategy(opts, (jwt_payload, done) => {
//       Users.findAll({ where: { id: jwt_payload.id } })
//         .then(user => {
//           if (user.length) {
//             return done(null, user);
//           }
//           return done(null, false);
//         })
//         .catch(err => console.log(err));
//     })
//   );
// };
