const { Strategy, ExtractJwt } =  require('passport-jwt');
const models =  require ('../models');


const Users = models.User;

const opts = {};
opts.jwtFromRequest = ExtractJwt.fromAuthHeaderAsBearerToken();
opts.secretOrKey = 'secret';
// opts.issuer = 'accounts.examplesoft.com';
// opts.audience = 'yoursite.net';

// create jwt strategy
module.exports = passport => {
  passport.use(
    new Strategy(opts, (jwt_payload, done) => {
      models.sequelize.query(`SELECT * from  users WHERE id = "${jwt_payload.id}"`)
      .then((user) => {
        console.log(user[0]);
        if(user[0].length){
          return done(null, user[0]);
        }
        return done(null, false);
      }).catch(err => console.log(err));
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
