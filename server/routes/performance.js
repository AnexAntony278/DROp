const express = require("express");
const performanceRouter = express.Router();
const { DeliveryRoute } = require('../models/delivery_route.model');

performanceRouter.get("/", async (req, res) => {
    try {
        const { agentId } = req.query;
        const deliveryRoutes = await DeliveryRoute.find({ "agentId": agentId }).populate('deliveries');
        const now = new Date();
        const lastDay = new Date(); lastDay.setDate(now.getDate() - 1);
        const lastWeek = new Date(); lastWeek.setDate(now.getDate() - 7);
        const lastMonth = new Date(); lastMonth.setMonth(now.getMonth() - 1);
        const lastYear = new Date(); lastYear.setYear(now.getYear() - 1);

        let performanceStats = {
            deliveries: {
                lastDay: { delivered: 0, total: 0 },
                lastWeek: { delivered: 0, total: 0 },
                lastMonth: { delivered: 0, total: 0 },
                lastYear: { delivered: 0, total: 0 },
                allTime: { delivered: 0, total: 0 }
            },
            packages: {
                delivered: 0,
                total: 0
            }
        };

        deliveryRoutes.forEach((route) => {
            const routeCreatedTime = route.createdAt;

            if (routeCreatedTime > lastDay) {
                performanceStats["deliveries"]["lastDay"]["total"] += 1;
            }
            if (routeCreatedTime > lastWeek) {
                performanceStats["deliveries"]["lastWeek"]["total"] += 1;
            }
            if (routeCreatedTime > lastMonth) {
                performanceStats["deliveries"]["lastMonth"]["total"] += 1;
            }
            if (routeCreatedTime > lastYear) {
                performanceStats["deliveries"]["lastYear"]["total"] += 1;
            }
            performanceStats["deliveries"]["allTime"]["total"] += 1;
            if (route.status == "COMPLETE") {
                if (routeCreatedTime > lastDay) {
                    performanceStats["deliveries"]["lastDay"]["delivered"] += 1;
                }
                if (routeCreatedTime > lastWeek) {
                    performanceStats["deliveries"]["lastWeek"]["delivered"] += 1;
                }
                if (routeCreatedTime > lastMonth) {
                    performanceStats["deliveries"]["lastMonth"]["delivered"] += 1;
                }
                if (routeCreatedTime > lastYear) {
                    performanceStats["deliveries"]["lastYear"]["delivered"] += 1;
                }
                performanceStats["deliveries"]["allTime"]["delivered"] += 1;
            }

            route.deliveries.forEach((delivery) => {
                if (delivery.status == "DELIVERED") {
                    performanceStats["packages"]["delivered"] += 1;
                }
                performanceStats["packages"]["total"] += 1;
            });
        });
        res.status(200).json({ performanceStats });

    } catch (error) {
        res.status(500).send(error)
    }

});

module.exports = performanceRouter;
