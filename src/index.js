const express = require("express");
const passport = require("passport");
const cors = require("cors");
const models = require("./models");
const multer = require("multer");
const passportConfig = require("./config/passport");
const helmet = require("helmet");

const path = require("path");
var upload = multer({ dest: "uploads/" });
var xmlparser = require("express-xml-bodyparser");

const app = express();
app.use(express.static(path.join(__dirname)));
app.use(xmlparser());
app.use(express.json({ limit: "50mb" }));

const cron = require("node-cron");

const swaggerUi = require("swagger-ui-express");
const swaggerDocument = require("./swagger-doc.json");

let port = process.env.PORT || 3589;
const { getTertiary } = require("./controllers/transactions");
const { institutions } = require("./config/institutions");
const { addHospitalData } = require("./controllers/transactions-hpt");
// make express look in the public directory for assets (css/js/img)
app.use(express.static(__dirname + "/public"));
app.use("/uploads", express.static(path.join(__dirname, "uploads")));
app.use("/uploads", express.static(path.join(__dirname, "src/uploads")));

app.use(express.static(__dirname + upload));

app.use(
  "/docs",
  swaggerUi.serve,
  swaggerUi.setup(swaggerDocument, { explorer: true })
);

app.use(cors());

// force: true will drop the table if it already exits
// models.sequelize.sync({ force: true }).then(() => {
models.sequelize.sync().then(() => {
  console.log("Drop and Resync with {force: true}");
});

// passport middleware
app.use(passport.initialize());
// app.use(passport.initialize());

// passport config
passportConfig(passport);
app.use(helmet());
// Use the Helmet middleware to set Content Security Policy
// app.use(
//   helmet.contentSecurityPolicy({
//     directives: {
//       defaultSrc: ["'self'"],
//       scriptSrc: ["'self'", "trusted-cdn.com"],
//     },
//   })
// );

// app.use(
//   helmet.hsts({
//     maxAge: 31536000, // 1 year in seconds
//     includeSubDomains: true,
//   })
// );
cron.schedule("0 2 * * *", () => {
  // cron.schedule("*/30 * * * * *", () => {
  institutions.forEach((inst) => {
    // console.log(inst);mnhy
    getTertiary(inst.code);
  });
});

// cron.schedule("* * * * *", () => {
// cron.schedule("40 18 * * *", () => {
//   console.log("Herrrrrr");
//   addHospitalData();
// });

app.use(helmet.xContentTypeOptions());

//default route
app.get("/", (req, res) => res.send("Hello my World, it gonna be good day!"));

require("./routes/transactions.js")(app);
require("./routes/user.js")(app);
require("./routes/pv_collection.js")(app);
require("./routes/payment_schedule.js")(app);
require("./routes/tsa.js")(app);
require("./routes/Transaction_history")(app);
require("./routes/auth.js")(app);
require("./routes/Sector")(app);
require("./routes/segment")(app);
require("./routes/interswitch.js")(app);
require("./routes/budget.js")(app);
require("./routes/reciept_logs.js")(app);

var server = app.listen(port, function () {
  var host = server.address().address;
  var port = server.address().port;
  console.log("App listening at http://%s:%s", host, port);
});
