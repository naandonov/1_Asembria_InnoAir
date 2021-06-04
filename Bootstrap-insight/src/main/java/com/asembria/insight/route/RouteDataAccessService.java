package com.asembria.insight.route;

import com.asembria.insight.utilities.JdbcTemplateHelper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import javax.validation.Valid;
import java.util.List;

@Repository
public class RouteDataAccessService implements RouteDataAccessServiceProvider {
    private final JdbcTemplateHelper jdbcTemplateHelper;

    @Autowired
    public RouteDataAccessService(JdbcTemplateHelper jdbcTemplateHelper) {
        this.jdbcTemplateHelper = jdbcTemplateHelper;
    }

    @Override
    public Integer createRoute(RouteRequest route) {
        String query = "" +
                "INSERT INTO route ( " +
                "user_id, " +
                "start_stop_id, " +
                "end_stop_id, " +
                "travel_type, " +
                "line_name) " +
                "VALUES(?, ?, ?, ?, ?)";

        return jdbcTemplateHelper.update(query,
                route.getUserId(),
                route.getStartStopId(),
                route.getEndStopId(),
                route.getTravelMode(),
                route.getLineName());
    }

    public Integer deleteRoute(String id) {
        String query = "" +
                "DELETE FROM route " +
                "WHERE route.user_id = ?";
        return jdbcTemplateHelper.update(query, id);
    }

    public Boolean hasBoardingPassengersForStop(String id, TransitDetails transitDetails) {
        String query = "SELECT COUNT(*) from route WHERE start_stop_id = ? AND travel_type = ? AND line_name = ?";
        int count = jdbcTemplateHelper.queryForObject(query, Integer.class, id, transitDetails.getTravelMode(), transitDetails.getLineName());
        return count != 0;
    }

    public Boolean hasDeboardingPassengersForStop(String id, TransitDetails transitDetails) {
        String query = "SELECT COUNT(*) from route WHERE end_stop_id = ? AND travel_type = ? AND line_name = ?";
        int count = jdbcTemplateHelper.queryForObject(query, Integer.class, id, transitDetails.getTravelMode(), transitDetails.getLineName());
        return count != 0;
    }
}
