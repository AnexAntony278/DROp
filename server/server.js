const express = require('express');
var port = 3000;
const app = express();
app.use(express.json());

const connection = require('./db.connect.js')
const { User } = require('./models/user.model.js');

app.post('/signup', async (req, res) => {
    try {
        const { name, email, phone, password, role, managerId } = req.body;
        const newUser = await User.create({ name, email, phone, password, role, managerId });
        res.status(200).json({ "user_token": newUser._id, "message": "Login Success" });

    } catch (error) {
        res.status(500).send(error);
    }
});
``


app.listen(port, '0.0.0.0', () => {
    console.log(`\nDROP Server Running on port :${port}`)
});