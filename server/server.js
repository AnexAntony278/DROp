const express = require('express');
var port = 3000;
const app = express();
app.use(express.json({ limit: '1mb' }));
const connection =
    require('./db.connect.js')
const userRouter = require("./routes/user.js");
const routesRouter = require('./routes/routes.js');

app.use("/deliveries", routesRouter);
app.use("/users", userRouter);

app.listen(port, '0.0.0.0', () => {
    console.log(`\nDROP Server Running on port :${port}`)
});