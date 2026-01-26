package org.jevis.controller;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.boot.web.servlet.error.ErrorController;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
public class CustomErrorController implements ErrorController {

    @RequestMapping("/error")
    public String handleError(HttpServletRequest request, Model model) {
        Object status = request.getAttribute(RequestDispatcher.ERROR_STATUS_CODE);
        Object exception = request.getAttribute(RequestDispatcher.ERROR_EXCEPTION);
        Object message = request.getAttribute(RequestDispatcher.ERROR_MESSAGE);
        String requestUri = (String) request.getAttribute(RequestDispatcher.ERROR_REQUEST_URI);

        Integer statusCode = status != null ? Integer.valueOf(status.toString()) : 500;

        model.addAttribute("statusCode", statusCode);
        model.addAttribute("errorMessage", message != null ? message.toString() : "Unknown error");
        model.addAttribute("requestUri", requestUri != null ? requestUri : "unknown");
        model.addAttribute("exception", exception != null ? exception.toString() : "No exception details");

        // Log error details
        System.err.println("=== ERROR PAGE ===");
        System.err.println("Status: " + statusCode);
        System.err.println("URI: " + requestUri);
        System.err.println("Message: " + message);
        System.err.println("Exception: " + exception);
        System.err.println("==================");

        return "pages/error";
    }
}
