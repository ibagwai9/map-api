import { Strategy as JwtStrategy, ExtractJwt } from "passport-jwt";
import db from "../models";
const opts = {};
opts.jwtFromRequest = ExtractJwt.fromAuthHeaderAsBearerToken();
opts.secretOrKey = process.env.JWT_SECRET_KEY;
module.exports = (passport) => {
  passport.use(
    new JwtStrategy(opts, (jwt_payload, done) => {
      // Check if the token has expired
      const currentTime = Math.floor(Date.now() / 1000); // Convert to seconds
      if (jwt_payload.exp > currentTime) {
        return done(null, false, { message: 'Token has expired' });
      }

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
