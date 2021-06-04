package com.asembria.insight.route;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import javax.validation.Valid;
import java.util.List;

@RestController
@RequestMapping("api/route")
public class RouteController {
    private final RouteService routeService;

    @Autowired
    public RouteController(RouteService routeService) {
        this.routeService = routeService;
    }

    @PostMapping
    public void createRoute(@RequestBody @Valid RouteRequest route){
        routeService.createRoute(route);
    }

    @DeleteMapping(path = "user/{id}")
    public void deleteRoute(@PathVariable("id") String id) {
        routeService.deleteRoute(id);
    }

    @PostMapping("stopInfo/{id}")
    public StopInfo getStopInfo(@PathVariable("id") String id, @RequestBody @Valid TransitDetails transitDetails) {
        return routeService.getStopInfo(id, transitDetails);
    }

    @GetMapping
    public String metadata() {
        return "insight route module";
    }
}
