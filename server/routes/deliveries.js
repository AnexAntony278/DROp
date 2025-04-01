const express = require("express")
const mongoose = require("mongoose")
const routesRouter = express.Router()

const { DeliveryRoute } = require("../models/delivery_route.model")
const { Delivery } = require("../models/delivery.model")
const { User } = require("../models/user.model")

routesRouter.post("/", async (req, res) => {
    const {
        id, deliveries, startLocation, createdAt, agentId, distanceMatrix, status
    } = req.body;

    try {
        const agent = await User.findById(agentId);
        if (!agent) {
            return res.status(404).send("Agent not found");
        }

        const deliveryPromises = deliveries.map(async (delivery) => {
            const savedDelivery = await Delivery.findOneAndUpdate(
                { id: delivery.id },
                {
                    ownerName: delivery.ownerName,
                    phone: delivery.phone,
                    status: delivery.status,
                    note: delivery.note,
                    locationName: delivery.locationName,
                    productName: delivery.productName,
                    locationLatLng: delivery.locationLatLng,
                    deliveryAttempts: delivery.deliveryAttempts,
                    timeStamp: delivery.timeStamp
                },
                {
                    new: true,
                    upsert: true
                }
            );
            return savedDelivery;
        });
        const savedDeliveries = await Promise.all(deliveryPromises);

        const deliveryIds = savedDeliveries.map(delivery => new mongoose.Types.ObjectId(delivery._id));

        const a = await DeliveryRoute.findOneAndUpdate({ id }, {
            id, deliveries: deliveryIds, startLocation, createdAt,
            agentId, distanceMatrix, status
        }, {
            new: true, // Return the updated document
            upsert: true // If no document is found, create a new one
        });

        res.status(200).send();
    } catch (error) {
        res.status(500).send(error)
    }
})

module.exports = routesRouter;