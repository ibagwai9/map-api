import {
  SignIn,
  SignUp,
  verifyToken,
  getUsers,
  TreasuryAppSignIn,
  TreasuryAppSignUp,
  verifyTokenTreasuryApp,
} from '../controllers/auth'

module.exports = (app) => {
  app.post('/sign_in', SignIn)
  app.post('/sign_up', SignUp)

  app.post('/treasury-app/sign_in', TreasuryAppSignIn)
  app.post('/treasury-app/sign_up', TreasuryAppSignUp)
  app.get('/treasury-app/verify-token', verifyTokenTreasuryApp)

  app.post('/register-kigra')
  app.get('/users', getUsers)
  app.get('/verify-token', verifyToken)
}
