package example;

import java.time.Duration;
import java.util.Map;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.dao.DataAccessException;

@SpringBootApplication
@RestController
public class Application {
    private static final Logger LOG = LoggerFactory.getLogger(Application.class);
    private final JdbcTemplate jdbc;
    private final StringRedisTemplate redis;
    public Application(JdbcTemplate jdbc, StringRedisTemplate redis) {
        this.jdbc = jdbc;
        this.redis = redis;
    }
    public static void main(String[] args) { SpringApplication.run(Application.class, args); }
    @GetMapping("/api/hello")
    public Map<String, String> hello() {
        try {
            String cached = redis.opsForValue().get("demo:message");
            if (cached != null) return Map.of("source", "redis", "message", cached);
        } catch (DataAccessException e) { LOG.warn("Cache read unavailable; using database"); }
        String message = jdbc.queryForObject("SELECT message FROM demo_message WHERE id = 1", String.class);
        try { redis.opsForValue().set("demo:message", message, Duration.ofSeconds(60)); }
        catch (DataAccessException e) { LOG.warn("Cache write unavailable"); }
        return Map.of("source", "mariadb", "message", message);
    }
}
