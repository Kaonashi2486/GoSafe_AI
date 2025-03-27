//use nodemailer here
//not required

const Nodemailer = require('./Nodemailer');

// Create an instance of the Nodemailer class
const email = new Nodemailer(
    'sakshigolatkar2486@gmail.com', 
    'Hello!', 
    '<p>This is a test email.</p>',
    
);
console.log(email);
// Send the emails
email.sendMail();
