//not required

const nodemailer = require("nodemailer");

const transporter = nodemailer.createTransport({
    service: "Gmail",
    host: "smtp.gmail.com",
    port: 465,
    secure: true,
    auth: {
      user: "udaan.initiativee@gmail.com",
      pass: "yknq irkx ouub wbhm",
    },
  });


  const mailOptions = {
    from: "udaan.initiativee@gmail.com",
    to: "sakshigolatkar2486@gmail.com",
    subject: "Hello from Nodemailer",
    text: "This is a test email sent using Nodemailer.",
  };

  transporter.sendMail(mailOptions, (error, info) => {
    if (error) {
      console.error("Error sending email: ", error);
    } else {
      console.log("Email sent: ", info.response);
    }
  });