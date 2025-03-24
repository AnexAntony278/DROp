const mongoose = require('mongoose');
require('dotenv').config();
console.log(process.env.MONGO_SERVER_CONNECTION_STRING)
const connection = mongoose.connect(`${process.env.MONGO_SERVER_CONNECTION_STRING}`).then(() => {
    console.log('\nDatabase connection succesfull');
}).catch((a) => {
    console.log(`\nDatabase connection Error: ${a} `)
    return;
});

module.exports = connection;