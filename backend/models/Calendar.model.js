const mongoose = require("mongoose");

const calendarEventSchema = new mongoose.Schema(
  {
    userId: {
      type: String,
      required: true,
      trim: true,
    },
    title: {
      type: String,
      required: true,
      trim: true,
    },
    type: {
      type: String,
      required: true,
      enum: ["appointment", "medication", "test"],
    },
    description: {
      type: String,
      trim: true,
    },
    date: {
      type: Date,
      required: true,
    },
  },
  {
    timestamps: true, // This will add createdAt and updatedAt fields
  }
);

const CalendarEvents = mongoose.model("CalendarEvent", calendarEventSchema);

module.exports = CalendarEvents;
