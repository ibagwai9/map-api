const { ExtractJwt } = require('passport-jwt')
const JwtStrategy =  require('passport-jwt').Strategy 
const models = require('../models');
const db = require('../models');

const opts = {};
opts.jwtFromRequest = ExtractJwt.fromAuthHeaderAsBearerToken();
opts.secretOrKey =  process.env.JWT_SECRET_KEY;

// create jwt strategy
module.exports = passport => {
  passport.use(
    new JwtStrategy(opts, (jwt_payload, done) => {
      // Check if the token has expired
      const currentTime = Math.floor(Date.now() / 1000); // Convert to seconds
      // if (jwt_payload.exp > currentTime) {
      //   return done(null, false, { message: 'Token has expired' });
      // }

      db.User.findAll({ where: { id: jwt_payload.id } })
        .then((user) => {
          if (user.length) {
            return done(null, user);
          }
          return done(null, false);
        })
        .catch((err) => console.log(err));
    })
  );
};