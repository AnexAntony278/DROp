const expres = require("express");
const userRouter = expres.Router();

const { User } = require('../models/user.model.js');

userRouter.post("/signup", async (req, res) => {
    try {
        const { name, email, phone, password, role, managerId } = req.body;
        const newUser = await User.create({ name, email, phone, password, role, managerId });
        res.status(200).json({ "user_token": JSON.stringify(newUser), "message": "SignUp Success" });

    } catch (error) {
        res.status(500).send(error);
    }
});

userRouter.post("/login", async (req, res) => {
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

userRouter.get("/agents", async (req, res) => {
    try {
        const { managerId } = req.query;
        const agents = await User.find({ managerId: { $regex: new RegExp(`^${managerId}$`, "i") } })
            .select("-password")
            .lean()
            .exec();
        res.status(200).json({ "agents": agents });
    } catch (error) {

    }
})

userRouter.get("/managers", async (req, res) => {
    try {
        const { email } = req.query;
        if (!email) {
            return res.status(400).json({ error: "Search text is required" });
        }
        const managersPredictions = await User.find({
            $or: [{ email: email }, { name: email }],
            role: "MANAGER"
        });
        if (managersPredictions.length == 0) {
            res.status(404).send();
        } else {
            res.status(200).send();

        }
    } catch (error) {
        res.status(500).json({ error: "Internal Server Error" });
    }
});


module.exports = userRouter;