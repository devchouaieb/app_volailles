const nodemailer = require('nodemailer');

const sendEmail = async (options) => {
  // Create transporter
  const transporter =  nodemailer.createTransport({
    service: "SendinBlue", // no need to set host or port etc.
    auth: {
      user: "dev.chouaieb@gmail.com",
      pass: "z7XwGQ6SVg0IyNYt",
    },
  });

  // Define email options
  const message = {
    from: "app_volailles@gmail.com",
    to: options.to,
    subject: options.subject,
    html: options.text
  };

  // Send email
  const info = await transporter.sendMail(message);

  console.log('Message sent: %s', info.messageId);
};

module.exports = sendEmail; 