package com.example;

import com.example.config.TestRestTemplateConfig;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.boot.web.server.AbstractConfigurableWebServerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT, classes = TestRestTemplateConfig.class)
class SpringBootSslServerApplicationTests {

    @Autowired
    private TestRestTemplate restTemplate;

    @Autowired
    private AbstractConfigurableWebServerFactory webServerFactory;

    @BeforeAll
    static void beforeAll() {
        // require for disabling localhost dns validation
        //System.setProperty("jdk.internal.httpclient.disableHostnameVerification", "true");
    }

    @Test
    void test_ssl() {
        assertThat(this.webServerFactory.getSsl().isEnabled()).isTrue();
    }

    @Test
    void success_login_request() {
        ResponseEntity<Object> entity = this.restTemplate.getForEntity("/", Object.class);
        assertThat(entity.getStatusCode()).isEqualTo(HttpStatus.OK);
    }

}
