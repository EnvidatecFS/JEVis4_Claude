package org.jevis.controller;

import jakarta.servlet.http.HttpServletRequest;
import org.springframework.security.web.csrf.CsrfToken;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Controller
public class LoginController {

    @GetMapping("/login")
    public String login(
            @RequestParam(value = "error", required = false) Boolean error,
            @RequestParam(value = "logout", required = false) Boolean logout,
            HttpServletRequest request,
            Model model) {

        // Get CSRF token
        CsrfToken csrfToken = (CsrfToken) request.getAttribute(CsrfToken.class.getName());

        model.addAttribute("model", new LoginViewModel(error, logout));
        model.addAttribute("csrf", csrfToken);
        return "pages/login";
    }

    /**
     * View Model for Login Page
     */
    public record LoginViewModel(Boolean error, Boolean logout) {
        public LoginViewModel() {
            this(null, null);
        }
    }
}
