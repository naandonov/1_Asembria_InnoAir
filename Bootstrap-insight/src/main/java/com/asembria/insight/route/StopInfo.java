package com.asembria.insight.route;

import com.fasterxml.jackson.annotation.JsonProperty;

public class StopInfo {
    private final Boolean passengersWillBoard;
    private final Boolean passengersWillDeboard;

    public Boolean getPassengersWillBoard() {
        return passengersWillBoard;
    }

    public Boolean getPassengersWillDeboard() {
        return passengersWillDeboard;
    }

    public StopInfo(@JsonProperty("passengersWillBoard") Boolean passengersWillBoard,
                    @JsonProperty("passengersWillDeboard") Boolean passengersWillDeboard) {
        this.passengersWillBoard = passengersWillBoard;
        this.passengersWillDeboard = passengersWillDeboard;
    }
}
