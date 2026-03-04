package org.jevis.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.servers.Server;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.List;

@Configuration
public class OpenApiConfig {

    @Bean
    public OpenAPI jevisOpenAPI() {
        return new OpenAPI()
                .info(new Info()
                        .title("JEVis 4 API")
                        .description("REST API fuer die JEVis 4 Datenmanagement-Plattform. "
                                + "Bietet Zugriff auf Dashboard-Widgets, Ansichtenverwaltung, "
                                + "Monitoring-Daten und Sensorverwaltung.")
                        .version("1.0.0")
                        .contact(new Contact()
                                .name("JEVis Team")))
                .servers(List.of(
                        new Server().url("http://localhost:8080").description("Entwicklungsserver")));
    }
}
