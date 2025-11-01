package com.example;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.web.servlet.MockMvc;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * @author Rob Winch
 */
@SpringBootTest
@AutoConfigureMockMvc
class MfaApplicationTests {

    @Autowired
    private MockMvc mvc;

    @Test
    void indexWhenAuthenticatedWithPasswordThenForbidden() throws Exception {
        this.mvc.perform(get("/")).andExpect(status().isForbidden());
    }

    @Test
    @WithMockUser
    void indexWhenAuthenticatedWithPasswordThenSuccess() throws Exception {
        this.mvc.perform(get("/")).andExpect(status().isOk());
    }

}
