package com.example;

import org.springframework.boot.actuate.autoconfigure.security.servlet.EndpointRequest;
import org.springframework.boot.autoconfigure.security.servlet.PathRequest;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.provisioning.InMemoryUserDetailsManager;
import org.springframework.security.web.SecurityFilterChain;


@Configuration(proxyBeanMethods = false)
@EnableWebSecurity(/*debug = true*/)
public class SecurityConfig {

    @Bean
    SecurityFilterChain web(HttpSecurity http) throws Exception {
        // @formatter:off
		http
            .authorizeHttpRequests((authorizeHttpRequests) -> authorizeHttpRequests
                    // allow all actuator endpoints and all static content
                    .requestMatchers(PathRequest.toStaticResources().atCommonLocations(), EndpointRequest.toAnyEndpoint())
                    .permitAll()
                    .requestMatchers("/error")
                    .permitAll()
                    .anyRequest()
                    .authenticated())
			.x509(Customizer.withDefaults())
            .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.NEVER));
		// @formatter:on
        return http.build();
    }

    @Bean
    public UserDetailsService users() {
        return new InMemoryUserDetailsManager(
                User.withDefaultPasswordEncoder()
                        .username("api")
                        .password("password")
                        .roles("USER", "ADMIN")
                        .build(),
                User.withDefaultPasswordEncoder()
                        .username("localhost")
                        .password("password")
                        .roles("USER", "ADMIN")
                        .build(),
                User.withDefaultPasswordEncoder()
                        .username("browser")
                        .password("password")
                        .roles("USER", "ADMIN")
                        .build()
        );
    }

}
