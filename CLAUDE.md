# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

JEVis 4 is a web-based data storage and management platform primarily designed for photovoltaic (PV) systems. The software provides data collection, storage, and visualization capabilities for solar energy installations.

JEVis4_Claude is a Maven-based Java project under the `org.jevis` package.

**Project Details:**
- Group ID: `org.jevis`
- Artifact ID: `JEVis4_Claude`
- Version: `1.0-SNAPSHOT`
- Packaging: JAR

## Technology Stack

- **Backend Framework:** Spring Framework
- **Database:** PostgreSQL
- **Frontend:** htmx (for dynamic HTML interactions)
- **Template Engine:** JTE (Java Template Engine)
- **JavaScript Visualization Library:** prefer Apache ECharts

## Build System

This project uses Apache Maven for build management and dependency resolution.

## Build and Test Commands
- Build and run tests: `mvn clean test`
- Quick compile check: `mvn compile`
- Run specific test: `mvn test -Dtest=ClassName`

## Development Guidelines
- **Verification**: Always run `mvn clean test` after making changes to ensure the build remains stable.
- **Error Handling**: If the build fails, analyze the Maven output, fix the compilation errors or failing tests, and re-run the build.
- **Code Style**: Maintain existing naming conventions and patterns found in the project.
- **SRF protection**: "I am using htmx in a project where CSRF protection is enabled, but htmx is not sending the token with its requests. Please configure htmx to automatically include the CSRF token in all AJAX headers.


### Common Maven Commands

**Run the Spring Boot application (development):**

## Project Structure

```
src/
├── main/
│   ├── java/
│   │   └── org/jevis/
│   │       ├── App.java                    # Spring Boot main application
│   │       ├── config/                     # Configuration classes
│   │       │   └── SecurityConfig.java     # Spring Security configuration
│   │       ├── controller/                 # Web Controllers
│   │       │   ├── LoginController.java    # Login page controller
│   │       │   └── DashboardController.java # Dashboard controller
│   │       ├── service/                    # Business logic services
│   │       ├── repository/                 # JPA repositories
│   │       └── model/                      # JPA entities
│   ├── resources/
│   │   ├── application.properties          # Spring Boot configuration
│   │   └── static/
│   │       └── css/
│   │           └── theme.css               # Central application theme
│   └── jte/                                # JTE templates
│       ├── layout/
│       │   └── base.jte                    # Base layout template
│       └── pages/
│           ├── login.jte                   # Login page
│           └── dashboard.jte               # Dashboard page
└── test/
    └── java/
        └── org/jevis/
            └── AppTest.java                # Spring Boot integration tests
```

### Key Directories:
- **config/** - Spring configuration classes (SecurityConfig)
- **controller/** - Spring MVC Controllers handling HTTP requests and htmx interactions
- **service/** - Business logic layer
- **repository/** - Spring Data JPA repositories for database access
- **model/** - JPA entities representing database tables
- **jte/** - Type-safe Java templates for rendering HTML
  - **layout/** - Reusable layout templates (base.jte for auth pages, app.jte for main app)
  - **components/** - Reusable UI components (sidebar, header)
  - **pages/** - Individual page templates
- **static/** - CSS, JavaScript, and image files
  - **css/theme.css** - Central theme with CSS variables and component styles

## Database Configuration

The application supports both PostgreSQL (production) and H2 (development).

**Development Mode (H2 In-Memory Database):**
- Default configuration in `application.properties`
- No external database required
- H2 Console available at `http://localhost:8080/h2-console`
  - JDBC URL: `jdbc:h2:mem:jevis4`
  - Username: `sa`
  - Password: (empty)

**Production Mode (PostgreSQL):**
Uncomment and configure in `application.properties`:
```properties
spring.datasource.url=jdbc:postgresql://localhost:5432/jevis4
spring.datasource.username=postgres
spring.datasource.password=your_password
spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.PostgreSQLDialect
```

And comment out the H2 configuration.

## Template Engine (JTE)

JTE templates should be placed in `src/main/jte/`. The template engine provides:
- Type-safe templates
- Hot reloading in development
- Compile-time checking

Templates are written in `.jte` files and can be rendered from Spring Controllers.

## Frontend (htmx)

htmx is used for dynamic HTML interactions without writing JavaScript. It is automatically included in the base layout template (`src/main/jte/layout/base.jte`).

## CSS Theme System

The application uses a **central theme system** located at `src/main/resources/static/css/theme.css`. All styling should use this theme to ensure consistency across the application.

**Key Theme Features:**
- CSS Variables for colors, spacing, typography, and borders
- Pre-built component styles (cards, forms, buttons, alerts)
- Utility classes for common layout patterns
- Responsive design helpers
- PV-specific color palette (blue for primary, green for energy/success, orange for solar/warnings)

**Using the Theme:**
- All JTE templates automatically include the theme via the base layout
- Use CSS variables (e.g., `var(--primary-color)`) for custom styling
- Leverage pre-built classes (e.g., `.btn-primary`, `.card`, `.form-group`)
- Add new styles to `theme.css` to maintain centralization

## Testing Framework

The project uses JUnit 5 (Jupiter) with Spring Boot Test support. Tests use `@SpringBootTest` annotation for integration tests and standard JUnit 5 annotations (`@Test`, etc.).

## Architecture Notes

As a platform for PV (photovoltaic) system data management, the application handles:
- **Data Collection**: Time-series data from solar installations
- **Storage**: PostgreSQL for structured data and time-series metrics
- **Visualization**: Web-based dashboards using htmx for dynamic updates
- **Analysis**: Energy production monitoring and reporting

The architecture follows standard Spring Boot layered design:
1. **Presentation Layer** (Controllers + JTE templates + htmx)
2. **Business Logic Layer** (Services)
3. **Data Access Layer** (Repositories + JPA Entities)
4. **Database Layer** (PostgreSQL)

## Development Environment

The project is configured for IntelliJ IDEA but can be developed in any Java IDE that supports Maven projects. Build artifacts are placed in the `target/` directory (gitignored).

**Development workflow:**
1. Start PostgreSQL database
2. Configure database credentials in `application.properties`
3. Run with `mvn spring-boot:run`
4. Access application at `http://localhost:8080`
5. JTE templates auto-reload in development mode

**Demo Login Credentials:**
- Admin: `admin` / `admin`
- Operator: `operator` / `operator`

## Authentication & Security

The application uses Spring Security for authentication and authorization.

**Security Configuration** (`SecurityConfig.java`):
- Form-based login at `/login`
- Session-based authentication
- Role-based access control (ADMIN, USER)
- Static resources (CSS, JS) are publicly accessible
- All other routes require authentication

**Current User Storage:**
- In-memory user details (for development)
- Replace with database-backed authentication for production

**Protected Routes:**
- `/` - Redirects to `/home`
- `/home` - Home page with overview and welcome message
- `/dashboard` - Dashboard with detailed analytics
- All other application routes require authentication

**Public Routes:**
- `/login` - Login page
- `/register`, `/forgot-password` - Authentication related pages (placeholders)
- `/css/**`, `/js/**`, `/images/**` - Static assets

## Application Layout

The application uses a three-area layout for authenticated pages:

1. **Left Sidebar** (260px, collapsible)
   - Branding/logo at top
   - Navigation menu organized by sections
   - Toggle button to collapse/expand
   - Sidebar state persists in localStorage

2. **Top Header** (64px height)
   - Left: Mobile menu toggle (hidden on desktop)
   - Right: Search, notifications, help, user profile, settings
   - Fixed positioning for always-visible access

3. **Main Content Area**
   - Flexible width, adjusts when sidebar collapses
   - Page header with title and description
   - Content cards and components

**Layout Templates:**
- `layout/base.jte` - Minimal layout for authentication pages (login, register)
- `layout/app.jte` - Three-area layout for main application pages
- `components/sidebar.jte` - Navigation sidebar component
- `components/header.jte` - Top header component

**Creating New Pages:**
```jte
@param String username

@template.layout.app(
    title = "Page Title",
    username = username,
    currentPage = "routeName",
    content = @`
        <!-- Your page content here -->
    `
)
```

**Navigation Menu Structure:**
- Hauptmenü: Übersicht (/home), Dashboard (/dashboard)
- PV Anlagen: Anlagen, Monitoring, Auswertungen
- Datenverwaltung: Messpunkte (/sensors), Datenbank, Berichte
- System: Benutzer, Einstellungen

## Important Development Procedures


