const Messages = require("../constants/Message");
const JsonResponse = require("../helper/JsonResponse");
const TryCatch = require("../helper/TryCatch");
const User = require("../models/User");

//LOGIN
exports.apiLogin = async function (req, res) {
  let user = new User(req.body);
  let result = await user.login();
  console.log(result);
  console.log(user.data);

  if (result) {
    let data = {
      ...user.data,
      role: "user",
    };

    new JsonResponse(req, res).jsonSuccess(data, "Login success");
  } else {
    res.locals.data = {
      isValid: false,
      loginFailed: true,
    };
    res.locals.message = new Messages().INVALID_CREDENTIALS;
    new JsonResponse(req, res).jsonError();
  }
};

//REGISTER
exports.apiRegister = async function (req, res) {
  let user = new User(req.body);
  console.log(req.body);

  let result = await user.register();
  if (result) {
    let data = {
      id: user.data._id,
      name: user.data.name,
      role: "user",
    };
    new JsonResponse(req, res).jsonSuccess(data, "Register success");
  } else {
    res.locals.data = {
      isVaild: false,
      authorizationFailed: true,
    };
    res.locals.message = regErrors;
    new JsonResponse(req, res).jsonError();
  }
};

//User Exists?

exports.getById = async function (req, res) {
  let user = new User();
  let userDoc = await user.getById(req.params.id);
  new JsonResponse(req, res).jsonSuccess(
    userDoc,
    new Messages().SUCCESSFULLY_RECEIVED
  );
};

exports.getByEmail = async function (req, res) {
  let user = new User();
  let userDoc = await user.findByEmail(req.params.email);
  console.log(userDoc);
  new JsonResponse(req, res).jsonSuccess(
    userDoc,
    new Messages().SUCCESSFULLY_RECEIVED
  );
};

exports.getAllUsers = async function (req, res) {
  let user = new User();
  let users = await user.getAllUsers();
  new JsonResponse(req, res).jsonSuccess(
    users,
    new Messages().SUCCESSFULLY_RECEIVED
  );
  return users;
};

exports.deleteById = async function (req, res) {
  let user = new User();
  await user.deleteById();
  new JsonResponse(req, res).jsonSuccess(
    true,
    new Messages().SUCCESSFULLY_DELETED
  );
};
