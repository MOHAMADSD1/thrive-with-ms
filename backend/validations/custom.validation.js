const objectId = (value, helpers) => {
  if (!value.match(/^[0-9a-fA-F]{24}$/)) {
    return helpers.message('"{{#label}}" must be valid mongo id');
  }
  return value;
};

const password = (value, helpers) => {
  if (value.length < 8) {
    return helpers.message("Password must be at least 8 charachters");
  }
  if (!value.match(/\d/) || !value.match(/[a-zA-Z]/)) {
    return helpers.message(
      "Password must contatin at lease one letter and one number"
    );
  }
  return value;
};

module.exports = {
  objectId,
  password,
};
