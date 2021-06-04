package com.asembria.insight.route;

public interface RouteDataAccessServiceProvider {
    Integer createRoute(RouteRequest route);
    Integer deleteRoute(String id);
    Boolean hasBoardingPassengersForStop(String id, TransitDetails transitDetails);
    Boolean hasDeboardingPassengersForStop(String id, TransitDetails transitDetails);
}
