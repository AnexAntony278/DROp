const express = require('express');
var port = 3000;
const app = express();
app.use(express.json());

const connection = require('./db.connect.js')
const { User } = require('./models/user.model.js');

app.post("/signup", async (req, res) => {
    try {
        const { name, email, phone, password, role, managerId } = req.body;
        const newUser = await User.create({ name, email, phone, password, role, managerId });
        res.status(200).json({ "user_token": JSON.stringify(newUser), "message": "SignUp Success" });

    } catch (error) {
        res.status(500).send(error);
    }
});

app.post("/login", async (req, res) => {
    try {
        const { name_or_email, password } = req.body;

        const user = await User.findOne({
            password: password,
            $or: [{ name: name_or_email }, { email: name_or_email }]
        })
        if (user) {
            res.status(200).json({ "user_token": JSON.stringify(user), "message": "Login success" });
            return;
        } else {
            res.status(500).send("Invalid Credinentials");
            return;
        }
    } catch (error) {
        res.status(500).send("Internal Error");
    }
})


app.listen(port, '0.0.0.0', () => {
    console.log(`\nDROP Server Running on port :${port}`)
});