import express from "express";
import passport from "passport";
import cors from "cors";
import models from "./models";
import multer from "multer";
import swaggerUi from "swagger-ui-express";
import swaggerDocument from "./swagger-doc.json";

const path = require("path");
var upload = multer({ dest: "uploads/" });

const app = express();
app.use(express.static(path.join(__dirname)));

app.use(express.json({ limit: "50mb" }));

let port = process.env.PORT || 3589;

// make express look in the public directory for assets (css/js/img)
app.use(express.static(__dirname + "/public"));
app.use("/uploads", express.static(path.join(__dirname, "uploads")));

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

// passport config
require("./config/passport")(passport);

//default route
app.get("/", (req, res) => res.send("Hello my World, it gonna be good day"));

require("./routes/transactions.js")(app);
require("./routes/user.js")(app);
require("./routes/pv_collection.js")(app);
require("./routes/payment_schedule.js")(app);
require("./routes/tsa.js")(app);
require("./routes/Transaction_history")(app);
require("./routes/auth.js")(app);
require("./routes/Sector")(app);
require("./routes/interswitch.js")(app);
require("./routes/budget.js")(app);
// require("./routes/organization")(app);
// require("./routes/segment")(app);
// require("./routes/budget")(app);
//create a server
var server = app.listen(port, function () {
  var host = server.address().address;
  var port = server.address().port;

  console.log("App listening at http://%s:%s", host, port);
});
