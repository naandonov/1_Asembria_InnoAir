CREATE TABLE route
(
    id               INTEGER GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1) NOT NULL,
    user_id            VARCHAR2(100) NOT NULL,
    start_stop_id      VARCHAR2(100) NOT NULL,
    end_stop_id        VARCHAR2(100) NOT NULL,
    travel_type        VARCHAR2(100) NOT NULL,
    line_name          VARCHAR2(100) NOT NULL,
    PRIMARY KEY (id)
);