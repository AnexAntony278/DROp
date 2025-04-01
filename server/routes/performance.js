const express = require("express");
const performanceRouter = express.Router();
const { DeliveryRoute } = require('../models/delivery_route.model');

performanceRouter.get("/", async (req, res) => {

    try {

        const { agentId } = req.query;

        const now = new Date();
        const lastDay = new Date(now);
        lastDay.setDate(now.getDate() - 1);
        const lastWeek = new Date(now);
        lastWeek.setDate(now.getDate() - 7);
        const lastMonth = new Date(now);
        lastMonth.setMonth(now.getMonth() - 1);
        const lastYear = new Date(now);
        lastYear.setFullYear(now.getFullYear() - 1);

        const deliveryRoutes = await DeliveryRoute.find({ agentId }).populate('deliveries');
        let performaceStats = {
            deliveries: {
                lastDay: { delivered: 0, total: 0 },
                lastWeek: { delivered: 0, total: 0 },
                lastMonth: { delivered: 0, total: 0 },
                lastYear: { delivered: 0, total: 0 }
            },
            packages: {
                delievered: 0,
                total: 0
            }
        };

        deliveryRoutes.forEach(route => {
            const routeTime = new Date(route.createdAt);

            // Track total deliveryRoutes
            if (routeTime >= lastDay) performaceStats.deliveries.lastDay.total += 1;
            if (routeTime >= lastWeek) performaceStats.deliveries.lastWeek.total += 1;
            if (routeTime >= lastMonth) performaceStats.deliveries.lastMonth.total += 1;
            if (routeTime >= lastYear) performaceStats.deliveries.lastYear.total += 1;

            if (route.status === "COMPLETE") {
                //track complete deliveryRoutes
                if (routeTime >= lastDay) performaceStats.deliveries.lastDay.delivered += 1;
                if (routeTime >= lastWeek) performaceStats.deliveries.lastWeek.delivered += 1;
                if (routeTime >= lastMonth) performaceStats.deliveries.lastMonth.delivered += 1;
                if (routeTime >= lastYear) performaceStats.deliveries.lastYear.delivered += 1;
            }
            performaceStats.packages.total += route.deliveries.length;
            route.deliveries.forEach(delivery => {
                if (delivery.status == "DELIVERED") {
                    performaceStats.packages.delievered += 1;
                }
            });
        });
        res.status(200).json({ performaceStats });

    } catch (error) {
        res.status(500).send(error)
    }

});

module.exports = performanceRouter;
