package com.asembria.insight.route;

import com.fasterxml.jackson.annotation.JsonProperty;

import javax.validation.constraints.NotBlank;

public class RouteRequest {
    @NotBlank
    private final String userId;
    @NotBlank
    private final String startStopId;
    @NotBlank
    private final String endStopId;
    @NotBlank
    private final String travelMode;
    @NotBlank
    private final String lineName;

    public RouteRequest(@JsonProperty("userId") String userId,
                        @JsonProperty("startStopId") String startStopId,
                        @JsonProperty("endStopId") String endStopId,
                        @JsonProperty("travelMode") String travelMode,
                        @JsonProperty("lineName") String lineName) {
        this.userId = userId;
        this.startStopId = startStopId;
        this.endStopId = endStopId;
        this.travelMode = travelMode;
        this.lineName = lineName;
    }

    public String getUserId() {
        return userId;
    }

    public String getStartStopId() {
        return startStopId;
    }

    public String getEndStopId() {
        return endStopId;
    }

    public String getTravelMode() {
        return travelMode;
    }

    public String getLineName() {
        return lineName;
    }

    @Override
    public String toString() {
        return "Route{" +
                ", userId='" + userId + '\'' +
                ", startStopId='" + startStopId + '\'' +
                ", endStopId='" + endStopId + '\'' +
                ", travelMode='" + travelMode + '\'' +
                ", lineName='" + lineName + '\'' +
                '}';
    }
}