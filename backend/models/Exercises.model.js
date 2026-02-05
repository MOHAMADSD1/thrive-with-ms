const { required } = require("joi");
const mongoose = require("mongoose");

const exerciseSchema = new mongoose.Schema(
  {
    title: {
      type: String,
      required: true,
      trim: true,
    },
    description: {
      type: String,
      required: true,
      trim: true,
    },
    videoId: {
      type: String,
      required: true,
      trim: true,
      match: [
        /^[a-zA-Z0-9_-]{11}$/,
        "The video ID must be an 11 character EX of :YouTube video ID (dQw4w9WgXcQ)",
      ],
    },
    category: {
      type: String,
      enum: [
        "strength",
        "stretch",
        "relaxation",
        "balance",
        "mobility",
        "other",
      ],
    },
    duration: {
      type: String,
      required: true,
    },
    thumbnailUrl: {
      type: String,
      required: true,
      trim: true,
    },
  },
  {
    timestamps: true,
  }
);

const Exercise = mongoose.model("Exercise", exerciseSchema);

module.exports = Exercise;
