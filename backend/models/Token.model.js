const mongoose = require("mongoose");
const { tokenTypes } = require("../config/tokens");

const tokensSchema = new mongoose.Schema(
  {
    token: {
      type: String,
      required: true,
      index: true,
    },
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "user",
      required: true,
    },
    type: {
      type: String,
      enum: [
        tokenTypes.REFRESH,
        tokenTypes.ACCESS,
        tokenTypes.RESET_PASSWORD,
        tokenTypes.VERIFY_EMAIL,
      ],
      required: true,
    },
    expires: {
      type: Date,
      required: true,
    },
    blackListed: {
      type: Boolean,
      default: false,
    },
  },
  {
    timestamps: true,
  }
);

const Token = mongoose.model("Token", tokensSchema);

module.exports = Token;
