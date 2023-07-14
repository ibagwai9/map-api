const { postSegment } = require("../controllers/segment")

module.exports = (app) => {
    app.post("/segment", postSegment)
  }