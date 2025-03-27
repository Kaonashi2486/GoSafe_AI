const express = require('express');
const router = express.Router();
const TryCatch = require('./helper/TryCatch');
const Messages = require('./constants/Message');

// imports here

const userController = require('./controllers/userController');


// Entity - Student --start
// Authentication - Student
router.post('/register-user', new TryCatch(userController.apiRegister).tryCatchGlobe());
router.post('/login-user', new TryCatch(userController.apiLogin).tryCatchGlobe());

// CRUD Operations - Student
router.post('/user/does-email-exists', new TryCatch(userController.doesEmailExist).tryCatchGlobe());
router.get('/user/get-by-id/:id', new TryCatch(userController.getById).tryCatchGlobe());
router.get('/user/get-by-email/:email', new TryCatch(userController.getByEmail).tryCatchGlobe());
router.get('/user/get-all', new TryCatch(userController.getAllStudents).tryCatchGlobe());
router.delete('/user/delete-by-id/:id', new TryCatch(userController.deleteById).tryCatchGlobe());
//other routes:


router.get("/health-check", (req,res)=>{
  res.json("Server Health: OK");
})

module.exports = router;
