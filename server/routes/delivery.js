const express = require("express")
const deliveryRoute = express.Router()

deliveryRoute.post("/", (req, res) => {
    res.status(200).send("OKKKKKKKKKKKK")

})
deliveryRoute.post("/all", (req, res) => {
    res.status(200).send("ALLLL")

})

module.exports = deliveryRoute;