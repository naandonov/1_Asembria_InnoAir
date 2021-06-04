package com.asembria.insight.route;

import com.fasterxml.jackson.annotation.JsonProperty;

import javax.validation.constraints.NotBlank;

public class TransitDetails {

    @NotBlank
    private final String travelMode;
    @NotBlank
    private final String lineName;

    public String getTravelMode() {
        return travelMode;
    }

    public String getLineName() {
        return lineName;
    }

    public TransitDetails(@JsonProperty("travelMode") String travelMode,
                          @JsonProperty("lineName") String lineName) {
        this.travelMode = travelMode;
        this.lineName = lineName;
    }

    @Override
    public String toString() {
        return "TransitDetails{" +
                "travelMode='" + travelMode + '\'' +
                ", lineName='" + lineName + '\'' +
                '}';
    }
}
