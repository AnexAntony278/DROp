const mongoose = require("mongoose");

const deliverySchema = new mongoose.Schema({
    id: {
        type: String,
        required: true,
        unique: true
    },
    ownerName: {
        type: String
    },
    phone: {
        type: String
    },
    status: {
        type: String,
        required: true,
        enum: ["IN_STOCK", "DELIVERED", "RETURNED"]
    },
    note: {
        type: String,
        required: true
    },
    locationName: {
        type: String,
        required: true
    },
    productName: {
        type: String,
        required: false
    },
    locationLatLng: {
        lat: { type: Number, required: true },
        lng: { type: Number, required: true }
    }
    ,
    deliveryAttempts: {
        type: Number,
        required: true
    },
    timeStamp: {
        type: Date,
        required: false
    }
}, {
    timestamps: true
});

const Delivery = mongoose.model('Delivery', deliverySchema);
module.exports = { Delivery };
