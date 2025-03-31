const mongoose = require("mongoose");

const deliveryRouteSchema = new mongoose.Schema({
    id: {
        type: String,
        required: true,
        unique: true
    },
    deliveries: [{
        type: mongoose.Schema.Types.ObjectId,
        ref: "Delivery",
        required: true
    }],
    startLocation: {
        lat: { type: Number, required: true },
        lng: { type: Number, required: true }
    },
    createdAt: {
        type: Date,
    },
    agentId: {
        type: String
    },
    distanceMatrix: {
        type: [[Number]],
        required: true
    },
    status: {
        type: String,
        enum: ["INCOMPLETE", "COMPLETED"],
        default: "INCOMPLETE"
    }
}, { _id: false });

const DeliveryRoute = mongoose.model("DeliveryRoute", deliveryRouteSchema);
module.exports = { DeliveryRoute };