const mongoose = require("mongoose");
const User = require("./models/Users.model");

const updateToAdmin = async () => {
  try {
    // Connect to MongoDB
    await mongoose.connect(
      "mongodb+srv://Mohammad2:Hamoshaa10@mymscluster.541wl.mongodb.net/ThrivewithMSdb?retryWrites=true&w=majority&appName=myMSCluster"
    );
    console.log("Connected to MongoDB");

    // Find user by email
    const user = await User.findOne({ email: "hamodiss10@hotmail.com" });
    if (!user) {
      console.error("User not found!");
      process.exit(1);
    }

    // Update user role to admin
    user.role = "admin";
    await user.save();

    console.log("Successfully updated user role to admin");
    console.log("User details:", {
      email: user.email,
      role: user.role,
      firstname: user.firstname,
      lastname: user.lastname,
    });
  } catch (error) {
    console.error("Error:", error.message);
  } finally {
    await mongoose.disconnect();
    console.log("Disconnected from MongoDB");
  }
};

updateToAdmin();
