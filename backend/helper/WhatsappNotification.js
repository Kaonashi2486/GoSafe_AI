import axios from "axios"
require("dotenv").config()
class WhatsappNotification {
    numberToSend;
    msgBody

    constructor(numberToSend, msgBody) {
        this.numberToSend = numberToSend
        this.msgBody = msgBody
    }

    sendWhatsappNotification() {
        const url = process.env.WHATSAPP_URL;
        const accessToken = process.env.WHATSAPP_ACCESS_TOKEN; 

        const data = {
            messaging_product: 'whatsapp',
            to: this.numberToSend,
            type: 'text',
            text: {
                body: this.msgBody
            },
        };

        const headers = {
            Authorization: "Bearer " + accessToken,
            'Content-Type': 'application/json',
        };

        axios.post(url, data, { headers })
            .then(response => {
                return response.data;
            })
            .catch(error => {
                return error.response.data;
            });
    }
}
module.exports = WhatsappNotification