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

## Build System

This project uses Apache Maven for build management and dependency resolution.

### Common Maven Commands

**Run the Spring Boot application (development):**

**IMPORTANT:** Before starting a new Spring Boot instance, always stop any running instance first to avoid port conflicts (Port 8080).

```bash
# Step 1: Find and kill existing process on port 8080
netstat -ano | findstr ":8080"
# Note the PID (last column), then:
taskkill //F //PID <PID>

# Step 2: Start the application
mvn spring-boot:run
```

**Build the project:**
```bash
mvn clean package
```

**Run the application from JAR:**
```bash
java -jar target/JEVis4_Claude-1.0-SNAPSHOT.jar
```

**Run tests:**
```bash
mvn test
```

**Run a single test class:**
```bash
mvn test -Dtest=AppTest
```

**Run a specific test method:**
```bash
mvn test -Dtest=AppTest#contextLoads
```

**Clean build artifacts:**
```bash
mvn clean
```

**Compile only:**
```bash
mvn compile
```

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

### Restarting the Application

Before running `mvn spring-boot:run`, always ensure no previous instance is running:

1. **Check for running instance:**
   ```bash
   netstat -ano | findstr ":8080"
   ```

2. **Kill the process if found:**
   ```bash
   taskkill //F //PID <PID>
   ```
   (Replace `<PID>` with the process ID from step 1)

3. **Then start the application:**
   ```bash
   mvn spring-boot:run
   ```

**Why this matters:** Spring Boot binds to port 8080. If a previous instance is still running, the new instance will fail with "Port 8080 was already in use".
