const dotenv = require("dotenv");
const path = require("path");
const joi = require("joi");

dotenv.config({ path: path.join(__dirname, "/../.env") });

const envVarsSchema = joi
  .object()
  .keys({
    NODE_ENV: joi
      .string()
      .valid("production", "development", "test")
      .required(),
    PORT: joi.number().default(3000),
    MONGODB_URL: joi.string().required().description("MONGO DB URL"),
    JWT_SECRET: joi.string().required().description("JWT secrect key"),
    JWT_ACCESS_EXPIRATION_MINUTES: joi
      .number()
      .default(30)
      .description("How many mins needed for access token to be expired"),
    JWT_REFRESH_EXPIRATION_DAYS: joi
      .number()
      .default(35)
      .description("How many days needed for refresh token to be expired"),
    JWT_RESET_PASSWORD_EXPIRATION_MINUTES: joi
      .number()
      .default(7)
      .description(
        "How many mins needed for reset password token to be expired"
      ),
    JWT_VERIFY_EMAIL_EXPIRATION_MINUTES: joi
      .number()
      .default(7)
      .description("How many mins needed for verfiy email token to be expired"),
    SMTP_HOST: joi.string().description("Server that will send the email"),
    SMTP_PORT: joi.number().description("Port to connect to the email server"),
    SMTP_USERNAME: joi.string().description("Username for email server"),
    SMTP_PASSWORD: joi.string().description("Password for email server"),
    EMAIL_FROM: joi
      .string()
      .description("The from field in the emails sent by the app"),
  })
  .unknown();

const { value: envVars, error } = envVarsSchema
  .prefs({ errors: { label: "key" } })
  .validate(process.env);
if (error) {
  throw new Error(`Congif validation error; ${error.message}`);
}

module.exports = {
  env: envVars.NODE_ENV,
  port: envVars.PORT,
  mongoose: {
    url: envVars.MONGODB_URL + (envVars.NODE_ENV === "test" ? "-test" : ""),
    options: {
      useCreateIndex: true,
      userNewUrlParser: true,
      useUndifiedTopology: true,
    },
  },
  jwt: {
    secret: envVars.JWT_SECRET,
    accessExpirationMinutes: envVars.JWT_ACCESS_EXPIRATION_MINUTES,
    refreshExpirationDays: envVars.JWT_REFRESH_EXPIRATION_DAYS,
    resetPasswordExpirationMinutes: envVars.RESET_PASSWORD_EXPIRATION_MINUTES,
    verifyEmailExpirationMinutes: envVars.JWT_VERIFY_EMAIL_EXPIRATION_MINUTES,
  },
  email: {
    smtp: {
      host: envVars.SMTP_HOST,
      port: envVars.SMTP_PORT,
      secure: false,
      auth: {
        user: envVars.SMTP_USERNAME,
        pass: envVars.SMTP_PASSWORD,
      },
      from: {
        from: envVars.EMAIL_FROM,
      },
    },
  },
};
