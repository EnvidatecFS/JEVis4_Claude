package org.jevis.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.UUID;

@Service
public class FileUploadService {

    private static final Logger log = LoggerFactory.getLogger(FileUploadService.class);

    @Value("${jevis.upload.dir:./uploads}")
    private String uploadDir;

    public String store(MultipartFile file, String subDir) throws IOException {
        String originalName = file.getOriginalFilename() != null ? file.getOriginalFilename() : "file";
        String ext = "";
        int dotIdx = originalName.lastIndexOf('.');
        if (dotIdx >= 0) ext = originalName.substring(dotIdx);

        String uniqueName = UUID.randomUUID().toString() + ext;
        Path targetDir = Paths.get(uploadDir, subDir);
        Files.createDirectories(targetDir);
        Path target = targetDir.resolve(uniqueName);
        file.transferTo(target);

        log.info("Stored upload: {}", target);
        return subDir + "/" + uniqueName;
    }
}
