const express = require('express');
var port = 3000;
const app = express();
app.use(express.json());
const connection =
    require('./db.connect.js')
const deliveryRouter = require("./routes/delivery.js")
const userRouter = require("./routes/user.js")

app.use("/deliveries", deliveryRouter);
app.use("/users", userRouter);

app.listen(port, '0.0.0.0', () => {
    console.log(`\nDROP Server Running on port :${port}`)
});