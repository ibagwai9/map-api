import { SignIn, SignUp, verifyToken, getUsers } from '../controllers/auth'

module.exports = (app) => {
  app.post('/sign_in', SignIn)
  app.post('/sign_up', SignUp)
  app.get('/users', getUsers)
  app.get('/verify-token', verifyToken)
}
