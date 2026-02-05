const express = require("express");
const calendarController = require("../controllers/Calendar.controllers");
const router = express.Router();

router.use((req, res, next) => {
  console.log("Calendar Route Hit:", {
    method: req.method,
    path: req.path,
    body: req.body,
    headers: req.headers,
  });
  next();
});

router
  .route("/")
  .post(calendarController.createEvent)
  .get(calendarController.getEvents);

router
  .route("/:eventId")
  .get(calendarController.getEvent)
  .patch(calendarController.updateEvent)
  .delete(calendarController.deleteEvent);

module.exports = router;
