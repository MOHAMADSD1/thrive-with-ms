const mongoose = require("mongoose");

const symptomSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "user",
    required: true,
  },

  category: {
    type: String,
    enum: ["Physical", "Emotional", "Mobility", "Unique"],
    required: true,
  },

  date: {
    type: Date,
    required: true,
    default: Date.now,
  },

  symptom: [
    {
      name: {
        type: String,
        required: true,
      },
      severity: {
        type: Number,
        min: 1,
        max: 10,
        required: true,
      },
      notes: {
        type: String,
        trim: true,
      },
    },
  ],
});

const Symptom = mongoose.model("Symptom", symptomSchema);

module.exports = Symptom;
