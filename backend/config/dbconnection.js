const mongoose = require("mongoose");
const express = require("express");

const connectDB = async () => {
  try {
    await mongoose.connect(
      "mongodb+srv://Mohammad2:Hamoshaa10@mymscluster.541wl.mongodb.net/ThrivewithMSdb?retryWrites=true&w=majority&appName=myMSCluster"
    );
  } catch (err) {
    console.error(err);
  }
};
module.exports = connectDB;
