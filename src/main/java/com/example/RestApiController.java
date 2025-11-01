package com.example;

import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class RestApiController {

    @GetMapping
    public Object user(Authentication authentication) {
        return authentication.getPrincipal();
    }
}
