package com.asembria.insight.utilities;

public class ApiRequestExceptionFactory {
    public static ApiRequestException failedUpdateException = new ApiRequestException("Failed update, something went wrong!");
    public static ApiRequestException failedDeleteException = new ApiRequestException("Failed deletion, something went wrong!");
    public static ApiRequestException failedCreationException = new ApiRequestException("Failed creation, something went wrong!");
    public static ApiRequestException missingIdException = new ApiRequestException("Missing required parameter id");
    public static ApiRequestException genericException = new ApiRequestException("Failure, something went wrong!");
}
