const httpstatus = require("http-status");
const ApiError = require("../utils/ApiError");
const Calendar = require("../models/Calendar.model");

const createEvent = async (eventBody) => {
  return Calendar.create(eventBody);
};

const getEventById = async (eventId) => {
  return Calendar.findById(eventId);
};

const getEventsByUser = async (userId, startDate, endDate) => {
  const query = { userId };

  // If date range is provided, filter events within that range
  if (startDate && endDate) {
    query.date = {
      $gte: new Date(startDate),
      $lte: new Date(endDate),
    };
  }

  return Calendar.find(query).sort({ date: 1 });
};

const updateEventById = async (eventId, updateBody) => {
  const event = await getEventById(eventId);
  if (!event) {
    throw new ApiError(httpstatus.NOT_FOUND, "Event not found!");
  }
  Object.assign(event, updateBody);
  await event.save();
  return event;
};

const deleteEventById = async (eventId) => {
  const event = await getEventById(eventId);
  if (!event) {
    throw new ApiError(httpstatus.NOT_FOUND, "Event not found!");
  }
  await event.deleteOne();
  return event;
};

module.exports = {
  createEvent,
  getEventById,
  getEventsByUser,
  updateEventById,
  deleteEventById,
}; 