package com.asembria.insight.utilities;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataAccessException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.PreparedStatementCreator;
import org.springframework.jdbc.core.ResultSetExtractor;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.support.KeyHolder;
import org.springframework.lang.Nullable;
import org.springframework.stereotype.Component;
import java.util.List;

@Component
public class JdbcTemplateHelper {
    private interface JdbcValidator<T> {
        T executeBlock();
    }

    private final JdbcTemplate jdbcTemplate;

    @Autowired
    public JdbcTemplateHelper(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public Integer update(PreparedStatementCreator preparedStatementCreator,
                          KeyHolder keyHolder) {
        JdbcValidator<Integer> block = () -> {
            return jdbcTemplate.update(preparedStatementCreator, keyHolder);
        };
        return validate(block);
    }

    public Integer update(String sql, @Nullable Object... args)  {
        JdbcValidator<Integer> block = () -> {
            return jdbcTemplate.update(sql, args);
        };
        return validate(block);
    }

    public <T> T queryForObject(String sql, RowMapper<T> rowMapper, @Nullable Object... args) {
        JdbcValidator<T> block = () -> {
            return jdbcTemplate.queryForObject(sql, rowMapper, args);
        };
        return validate(block);
    }

    public <T> List<T> query(String sql, RowMapper<T> rowMapper, @Nullable Object... args)  {
        JdbcValidator<List<T>> block = () -> {
            return jdbcTemplate.query(sql, rowMapper, args);
        };
        return validate(block);
    }

    public <T> T query(String sql, ResultSetExtractor<T> resultSetExtractor, @Nullable Object... args)  {
        JdbcValidator<T> block = () -> {
            return jdbcTemplate.query(sql, resultSetExtractor, args);
        };
        return validate(block);
    }

    public <T> T queryForObject(String sql, Class<T> requiredType, @Nullable Object... args)  {
        JdbcValidator<T> block = () -> {
            return jdbcTemplate.queryForObject(sql, requiredType, args);
        };
        return validate(block);
    }

    private <T> T validate(JdbcValidator<T> validator) {
        T result = null;
        try {
            result = validator.executeBlock();
        } catch (DataAccessException exception) {
            throw new ApiRequestException(exception.getMessage());
        } catch (Exception exception) {
            throw ApiRequestExceptionFactory.genericException;
        }
        return result;
    }
}

