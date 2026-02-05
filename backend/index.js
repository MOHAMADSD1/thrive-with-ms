const mongoose = require("mongoose");
const app = require("./app");
const connectDB = require("./config/dbconnection");
//const User = require("./models/Users.model");
const port = 3000;
connectDB();

app.get("/", (req, res) => {
  res.send("Hello from the server!");
});

mongoose.connection.once("open", () => {
  console.log("Connected to mongoDB");
  app.listen(port, () => {
    console.log(`Server is listening on port http://localhost:${port}`);
  });
});
