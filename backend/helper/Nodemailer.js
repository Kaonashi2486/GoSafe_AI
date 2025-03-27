const nodemailer = require("nodemailer")
require("dotenv").config()
class Nodemailer{
    recieverEmail
    subject
    content

    constructor(recieverEmail,subject, content){
        this.recieverEmail = recieverEmail
        this.subject = subject
        this.content = content
    }

    sendMail(){

        const transporter = nodemailer.createTransport({
            service: 'Gmail',
            host: 'smtp.gmail.com',
            port: 465,
            secure: true,
            auth: {
                user: "udaan.initiativee@gmail.com",
                pass: "yknq irkx ouub wbhm",
            },
        });

        let details = {
            from:"udaan.initiativee@gmail.com",
            to: this.recieverEmail,
            subject: this.subject,
            html: this.content
        }

        transporter.sendMail(details, (error, info) => {
            if (error) {
              console.error("Error sending email: ", error);
            } else {
              console.log("Email sent: ", info.response);
            }
          }

        );}
}
module.exports = Nodemailer