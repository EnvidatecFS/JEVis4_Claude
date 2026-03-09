package org.jevis.controller;

import org.jevis.model.MeterType;
import org.jevis.service.FileUploadService;
import org.jevis.service.MeterTypeService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

@Controller
@RequestMapping("/meter-types")
public class MeterTypeController {

    private static final Logger log = LoggerFactory.getLogger(MeterTypeController.class);

    private final MeterTypeService meterTypeService;
    private final FileUploadService fileUploadService;

    public MeterTypeController(MeterTypeService meterTypeService, FileUploadService fileUploadService) {
        this.meterTypeService = meterTypeService;
        this.fileUploadService = fileUploadService;
    }

    @GetMapping
    public String meterTypesPage(Authentication auth, Model model) {
        model.addAttribute("username", auth.getName());
        return "pages/meter-types";
    }

    @GetMapping("/table")
    public String meterTypesTable(Model model) {
        model.addAttribute("meterTypes", meterTypeService.getAllMeterTypes());
        return "pages/meter-types-table";
    }

    @GetMapping("/new")
    public String newMeterTypeForm(Model model) {
        model.addAttribute("meterType", new MeterType());
        model.addAttribute("isNew", true);
        return "pages/meter-type-form";
    }

    @PostMapping
    public String createMeterType(
            @ModelAttribute MeterType meterType,
            @RequestParam(required = false) MultipartFile datasheet,
            @RequestParam(required = false) MultipartFile meterTypeImage,
            Model model) {
        try {
            if (datasheet != null && !datasheet.isEmpty()) {
                meterType.setDatasheetPath(fileUploadService.store(datasheet, "meter-types/datasheets"));
            }
            if (meterTypeImage != null && !meterTypeImage.isEmpty()) {
                meterType.setImagePath(fileUploadService.store(meterTypeImage, "meter-types/images"));
            }
            MeterType saved = meterTypeService.createMeterType(meterType);
            model.addAttribute("meterType", saved);
            model.addAttribute("success", true);
            model.addAttribute("isNew", false);
        } catch (Exception e) {
            log.error("Error creating MeterType", e);
            model.addAttribute("meterType", meterType);
            model.addAttribute("error", e.getMessage());
            model.addAttribute("isNew", true);
        }
        return "pages/meter-type-form";
    }

    @GetMapping("/{id}/edit")
    public String editMeterTypeForm(@PathVariable Long id, Model model) {
        model.addAttribute("meterType", meterTypeService.getMeterTypeById(id));
        model.addAttribute("isNew", false);
        return "pages/meter-type-form";
    }

    @PutMapping("/{id}")
    public String updateMeterType(
            @PathVariable Long id,
            @ModelAttribute MeterType meterType,
            @RequestParam(required = false) MultipartFile datasheet,
            @RequestParam(required = false) MultipartFile meterTypeImage,
            Model model) {
        try {
            if (datasheet != null && !datasheet.isEmpty()) {
                meterType.setDatasheetPath(fileUploadService.store(datasheet, "meter-types/datasheets"));
            }
            if (meterTypeImage != null && !meterTypeImage.isEmpty()) {
                meterType.setImagePath(fileUploadService.store(meterTypeImage, "meter-types/images"));
            }
            MeterType updated = meterTypeService.updateMeterType(id, meterType);
            model.addAttribute("meterType", updated);
            model.addAttribute("success", true);
            model.addAttribute("isNew", false);
        } catch (Exception e) {
            log.error("Error updating MeterType {}", id, e);
            model.addAttribute("meterType", meterType);
            model.addAttribute("error", e.getMessage());
            model.addAttribute("isNew", false);
        }
        return "pages/meter-type-form";
    }

    @DeleteMapping("/{id}")
    @ResponseBody
    public String deleteMeterType(@PathVariable Long id) {
        try {
            meterTypeService.deleteMeterType(id);
            return "";
        } catch (Exception e) {
            return "<div class=\"alert alert-danger\">Fehler: " + e.getMessage() + "</div>";
        }
    }
}
