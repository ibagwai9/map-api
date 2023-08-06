const passport = require("passport");

var config = {};

const userRoles = config.userRoles = {
    guest: 1,       
    user: 2,        
    admin: 4,      
    superAdmin: 8   
}

config.accessLevels = {
    guest: userRoles.guest | userRoles.user | userRoles.admin | userRoles.superAdmin, 
    user: userRoles.user | userRoles.admin | userRoles.superAdmin,                    
    admin: userRoles.admin | userRoles.superAdmin,                                    
    superAdmin: userRoles.superAdmin,                                                 
}

config.requireAuth =  passport.authenticate('jwt', {
    session: false,
  });

  module.exports = config;