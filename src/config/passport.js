const { ExtractJwt } = require('passport-jwt')
const JwtStrategy =  require('passport-jwt').Strategy 
const models = require('../models')

const opts = {};
opts.jwtFromRequest = ExtractJwt.fromAuthHeaderAsBearerToken();
opts.secretOrKey = 'secret';

// create jwt strategy
module.exports = passport => {
  passport.use(
    new JwtStrategy(opts, (jwt_payload, done) => {
      models.sequelize.query(`SELECT * from  users WHERE id = "${jwt_payload.id}"`)
      .then((user) => {
        console.log(user[0]);
        if(user[0].length){
          return done(null, user[0]);
        }
        return done(null, false);
      }).catch(err => console.log(err));
    })
  );
};