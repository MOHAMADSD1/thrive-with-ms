const nodemailer = require("nodemailer");
const config = require("../config/config");
const logger = require("../config/logger");

//console.log('SMTP config =>', config.email.smtp);

const transport = nodemailer.createTransport(config.email.smtp);
if (config.env !== "test") {
  transport
    .verify()
    .then(() => logger.info("Connected to email server"))
    .catch(() =>
      logger.warn(
        "Unable to connect to eemail server. Make sure you have configured the SMTP in .env"
      )
    );
}

const sendEmail = async (to, subject, text) => {
  const msg = { from: config.email.from, to, subject, text };
  await transport.sendMail(msg);
};

const sendResetPasswordEmail = async (to, token) => {
  const subject = "Reset password";
  // Reminder for me: DON'T FORGET TO replace this url with the link to the reset password page of my front-end app
  const resetPasswordUrl = `thrivewithms://reset-password?token=${token}`;
  const text = `Dear user,
    To reset your paswword, kindly click on this link : ${resetPasswordUrl}
    If you did not request any password resets, please ignore this email`;
  await sendEmail(to, subject, text);
};

const sendVereficationEmail = async (to, token) => {
  const subject = "Email Verification";
  const verificationEmailURl = `http://link-to-app/verify-email?token=${token}`;
  const text = `Dear user,
    To verify your email, kindly click on the link : ${verificationEmailURl}`;
  await sendEmail(to, subject, text);
};

module.exports = {
  transport,
  sendEmail,
  sendResetPasswordEmail,
  sendVereficationEmail,
};
