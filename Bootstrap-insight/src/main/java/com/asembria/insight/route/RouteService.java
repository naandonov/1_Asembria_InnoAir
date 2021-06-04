package com.asembria.insight.route;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
@Service
public class RouteService {
    private final RouteDataAccessServiceProvider routeDataAccessServiceProvider;

    @Autowired
    public RouteService(RouteDataAccessServiceProvider routeDataAccessServiceProvider) {
        this.routeDataAccessServiceProvider = routeDataAccessServiceProvider;
    }

    public void createRoute(RouteRequest route) {
        routeDataAccessServiceProvider.createRoute(route);
    }

    public void deleteRoute(String id) {
        routeDataAccessServiceProvider.deleteRoute(id);
    }

    public StopInfo getStopInfo(String id, TransitDetails transitDetails) {
        return new StopInfo(routeDataAccessServiceProvider.hasBoardingPassengersForStop(id, transitDetails),
                routeDataAccessServiceProvider.hasDeboardingPassengersForStop(id, transitDetails));
    }
}
