package com.example.config;

import org.springframework.boot.ssl.SslBundles;
import org.springframework.boot.test.context.TestConfiguration;
import org.springframework.boot.web.client.RestTemplateBuilder;
import org.springframework.context.annotation.Bean;

/**
 * SSL Configuration for {@link org.springframework.boot.test.web.client.TestRestTemplate}
 */
@TestConfiguration
public class TestRestTemplateConfig {

    @Bean
    public RestTemplateBuilder restTemplateBuilder(SslBundles sslBundles) {
        return new RestTemplateBuilder().sslBundle(sslBundles.getBundle("server"));
    }
}
