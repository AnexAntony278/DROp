
const mongoose = require('mongoose');
const connection = mongoose.connect('mongodb://localhost:27017/').then(() => {
    console.log('\nDatabase conection suucesfull');
}).catch((a) => {
    console.log(`\nDatabase conection Error:${a} `)
    return;
});


module.exports = connection;