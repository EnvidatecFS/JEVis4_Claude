package org.jevis.controller;

import jakarta.servlet.http.HttpServletRequest;
import org.jevis.model.CsrAction;
import org.jevis.model.CsrCategory;
import org.jevis.model.CsrStatus;
import org.jevis.service.CsrActionService;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.web.csrf.CsrfToken;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

@Controller
@RequestMapping("/csr")
public class CsrController {

    private final CsrActionService csrActionService;

    public CsrController(CsrActionService csrActionService) {
        this.csrActionService = csrActionService;
    }

    @GetMapping
    public String csrPage(@AuthenticationPrincipal UserDetails userDetails, HttpServletRequest request, Model model) {
        model.addAttribute("username", userDetails.getUsername());
        CsrfToken csrfToken = (CsrfToken) request.getAttribute(CsrfToken.class.getName());
        model.addAttribute("_csrf", csrfToken);
        model.addAttribute("categories", CsrCategory.values());
        model.addAttribute("statuses", CsrStatus.values());
        return "pages/csr";
    }

    @GetMapping("/table")
    public String csrTable(
            @RequestParam(defaultValue = "") String search,
            @RequestParam(defaultValue = "") String category,
            @RequestParam(defaultValue = "") String status,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(defaultValue = "createdAt") String sortBy,
            @RequestParam(defaultValue = "desc") String sortDir,
            Model model
    ) {
        Sort sort = sortDir.equalsIgnoreCase("asc")
            ? Sort.by(sortBy).ascending()
            : Sort.by(sortBy).descending();
        Pageable pageable = PageRequest.of(page, size, sort);

        Page<CsrAction> actionsPage;

        if (!search.isEmpty() || !category.isEmpty() || !status.isEmpty()) {
            actionsPage = csrActionService.searchActions(search, category, status, pageable);
        } else {
            actionsPage = csrActionService.getAllActions(pageable);
        }

        model.addAttribute("actions", actionsPage.getContent());
        model.addAttribute("currentPage", page);
        model.addAttribute("totalPages", actionsPage.getTotalPages());
        model.addAttribute("totalElements", actionsPage.getTotalElements());
        model.addAttribute("search", search);
        model.addAttribute("category", category);
        model.addAttribute("status", status);
        model.addAttribute("sortBy", sortBy);
        model.addAttribute("sortDir", sortDir);
        model.addAttribute("categories", CsrCategory.values());
        model.addAttribute("statuses", CsrStatus.values());

        return "pages/csr-table";
    }

    @GetMapping("/{id}/edit")
    public String editActionForm(@PathVariable Long id, Model model) {
        CsrAction action = csrActionService.getActionById(id);
        model.addAttribute("action", action);
        model.addAttribute("categories", CsrCategory.values());
        model.addAttribute("statuses", CsrStatus.values());
        return "pages/csr-edit-form";
    }

    @PutMapping("/{id}")
    public String updateAction(
            @PathVariable Long id,
            @ModelAttribute CsrAction actionData,
            Model model
    ) {
        try {
            CsrAction updated = csrActionService.updateAction(id, actionData);
            model.addAttribute("action", updated);
            model.addAttribute("success", true);
            model.addAttribute("message", "Maßnahme erfolgreich aktualisiert");
        } catch (Exception e) {
            CsrAction action = csrActionService.getActionById(id);
            model.addAttribute("action", action);
            model.addAttribute("success", false);
            model.addAttribute("message", "Fehler: " + e.getMessage());
        }
        model.addAttribute("categories", CsrCategory.values());
        model.addAttribute("statuses", CsrStatus.values());
        return "pages/csr-edit-form";
    }

    @PostMapping
    public String createAction(
            @ModelAttribute CsrAction actionData,
            @AuthenticationPrincipal UserDetails userDetails,
            Model model
    ) {
        try {
            actionData.setCreatedBy(userDetails.getUsername());
            CsrAction created = csrActionService.createAction(actionData);
            model.addAttribute("action", created);
            model.addAttribute("success", true);
            model.addAttribute("message", "Maßnahme erfolgreich erstellt");
        } catch (Exception e) {
            model.addAttribute("action", actionData);
            model.addAttribute("success", false);
            model.addAttribute("message", "Fehler: " + e.getMessage());
        }
        model.addAttribute("categories", CsrCategory.values());
        model.addAttribute("statuses", CsrStatus.values());
        return "pages/csr-create-form";
    }

    @GetMapping("/new")
    public String newActionForm(Model model) {
        model.addAttribute("action", new CsrAction());
        model.addAttribute("categories", CsrCategory.values());
        model.addAttribute("statuses", CsrStatus.values());
        return "pages/csr-create-form";
    }

    @DeleteMapping("/{id}")
    @ResponseBody
    public String deleteAction(@PathVariable Long id) {
        try {
            csrActionService.deleteAction(id);
            return "";
        } catch (Exception e) {
            return "<div class=\"alert alert-danger\">" + e.getMessage() + "</div>";
        }
    }
}
