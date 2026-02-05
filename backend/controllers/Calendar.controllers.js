const httpstatus = require("http-status");
const ApiError = require("../utils/ApiError");
const catchAsync = require("../utils/catchAsync");
const calendarService = require("../services/calendar.service");

const createEvent = catchAsync(async (req, res) => {
  const event = await calendarService.createEvent(req.body);
  res.status(201).send(event);
});

const getEvent = catchAsync(async (req, res) => {
  const event = await calendarService.getEventById(req.params.eventId);
  if (!event) {
    throw new ApiError(httpstatus.NOT_FOUND, "Event not found!");
  }
  res.send(event);
});

const getEvents = catchAsync(async (req, res) => {
  const { userId, startDate, endDate } = req.query;
  if (!userId) {
    throw new ApiError(
      httpstatus.BAD_REQUEST,
      "userId query parameter is required"
    );
  }
  const events = await calendarService.getEventsByUser(
    userId,
    startDate,
    endDate
  );
  res.send(events);
});

const updateEvent = catchAsync(async (req, res) => {
  const event = await calendarService.updateEventById(
    req.params.eventId,
    req.body
  );
  res.status(200).send(event);
});

const deleteEvent = catchAsync(async (req, res) => {
  await calendarService.deleteEventById(req.params.eventId);
  res.status(204).send();
});

module.exports = {
  createEvent,
  getEvent,
  getEvents,
  updateEvent,
  deleteEvent,
};
