const express = require("express");
const passport = require("passport");
const cors = require("cors");
const { jwtStrategy } = require("./config/passport");
const ApiError = require("./utils/ApiError");
const userRouter = require("./routes/user.route");
const symptomRouter = require("./routes/symptom.route");
const exerciseRouter = require("./routes/exercise.route");
const authRouter = require("./routes/auth.route");
const mealsRouter = require("./routes/meals.routes");
const supplementRouter = require("./routes/supplements.route");
const treatmentRoute = require("./routes/treatment.route");
const calendarRouter = require("./routes/calendar.route");
const app = express();

app.use(
  cors({
    origin: "http://localhost:3001", // Your admin panel frontend URL
    credentials: true, // Allow credentials (cookies, authorization headers, etc.)
  })
);

app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(passport.initialize());

passport.use("jwt", jwtStrategy);

app.use("/api/auth", authRouter);
app.use("/api/users", userRouter);
app.use("/api/symptoms", symptomRouter);
app.use("/api/exercise", exerciseRouter);
app.use("/api/meals", mealsRouter);
app.use("/api/supplements", supplementRouter);
app.use("/api/treatments", treatmentRoute);
app.use("/api/calendar", calendarRouter);

app.use((err, req, res, next) => {
  console.error("Error:", err); // Log the full error for debugging

  // Handle ApiError instances
  if (err instanceof ApiError) {
    return res.status(err.statusCode || 500).json({
      status: "error",
      message: err.message,
      statusCode: err.statusCode,
    });
  }

  // Handle mongoose duplicate key error
  if (err.code === 11000) {
    return res.status(400).json({
      status: "error",
      message: "Email is already taken",
      statusCode: 400,
    });
  }

  // Fallback for unexpected errors
  res.status(500).json({
    status: "error",
    message: "Internal server error",
    statusCode: 500,
  });
});

module.exports = app;
