const mongoose = require("mongoose");

const treatmentSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },
    name: {
      type: String,
      required: true,
      trim: true,
    },

    startDate: {
      type: Date,
      required: true,
    },

    isStopped: {
      type: Boolean,
      default: false,
    },
  },
  {
    timestamps: true,
  }
);

const Treatment = mongoose.model("Treatment", treatmentSchema);

module.exports = Treatment;
