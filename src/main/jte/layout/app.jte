@import gg.jte.Content
@import org.springframework.security.web.csrf.CsrfToken

@param String title = "JEVis 4"
@param String username
@param String currentPage = ""
@param Content content
@param CsrfToken _csrf = null

<!DOCTYPE html>
<html lang="de">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${title} - JEVis 4</title>

    <!-- Favicon -->
    <link rel="icon" type="image/x-icon" href="/images/favicon.ico">
    <link rel="icon" type="image/png" sizes="32x32" href="/images/favicon-32x32.png">
    <link rel="icon" type="image/png" sizes="16x16" href="/images/favicon-16x16.png">
    <link rel="apple-touch-icon" sizes="180x180" href="/images/apple-touch-icon.png">

    <!-- CSRF Token for htmx -->
    @if(_csrf != null)
    <meta name="csrf-token" content="${_csrf.getToken()}">
    <meta name="csrf-header" content="${_csrf.getHeaderName()}">
    <meta name="csrf-param" content="${_csrf.getParameterName()}">
    @endif

    <link rel="stylesheet" href="/css/theme.css">
    <script src="https://unpkg.com/htmx.org@1.9.10"></script>
    <script>
        // Configure htmx to send CSRF token with all requests
        document.addEventListener('DOMContentLoaded', function() {
            var csrfToken = document.querySelector('meta[name="csrf-token"]');
            var csrfHeader = document.querySelector('meta[name="csrf-header"]');
            if (csrfToken && csrfHeader) {
                document.body.addEventListener('htmx:configRequest', function(event) {
                    event.detail.headers[csrfHeader.content] = csrfToken.content;
                });
            }
        });
    </script>
</head>
<body>
    <div class="app-layout">
        <!-- Sidebar Navigation -->
        @template.components.sidebar(currentPage = currentPage)

        <!-- Main Wrapper (Header + Content) -->
        <div class="main-wrapper" id="mainWrapper">
            <!-- Top Header -->
            @template.components.header(username = username, _csrf = _csrf)

            <!-- Main Content -->
            <main class="main-content">
                ${content}
            </main>
        </div>
    </div>

    <!-- Hidden Logout Form -->
    @if(_csrf != null)
        <form method="post" action="/logout" id="logoutForm" style="display: none;">
            <input type="hidden" name="${_csrf.getParameterName()}" value="${_csrf.getToken()}">
        </form>
    @else
        <!-- CSRF Token not available - fallback to GET logout -->
        <div id="logoutForm" data-no-csrf="true" style="display: none;"></div>
    @endif

    <script>
        // Theme Management - Load immediately to prevent flash
        (function() {
            const savedTheme = localStorage.getItem('selectedTheme') || 'light';
            document.documentElement.setAttribute('data-theme', savedTheme);
        })();

        // Sidebar Toggle Functionality
        function toggleSidebar() {
            const sidebar = document.getElementById('sidebar');
            const mainWrapper = document.getElementById('mainWrapper');
            sidebar.classList.toggle('collapsed');
            mainWrapper.classList.toggle('sidebar-collapsed');

            // Save state to localStorage
            const isCollapsed = sidebar.classList.contains('collapsed');
            localStorage.setItem('sidebarCollapsed', isCollapsed);
        }

        // Restore sidebar state on page load
        document.addEventListener('DOMContentLoaded', function() {
            const isCollapsed = localStorage.getItem('sidebarCollapsed') === 'true';
            if (isCollapsed) {
                document.getElementById('sidebar').classList.add('collapsed');
                document.getElementById('mainWrapper').classList.add('sidebar-collapsed');
            }
        });

        // Mobile sidebar toggle
        function toggleMobileSidebar() {
            const sidebar = document.getElementById('sidebar');
            sidebar.classList.toggle('open');
        }

        // User Menu Dropdown
        function toggleUserMenu() {
            const dropdown = document.getElementById('userDropdown');
            dropdown.classList.toggle('show');
        }

        // Close dropdown when clicking outside
        document.addEventListener('click', function(event) {
            const userMenu = document.querySelector('.user-menu-wrapper');
            const dropdown = document.getElementById('userDropdown');

            if (userMenu && !userMenu.contains(event.target)) {
                dropdown.classList.remove('show');
            }
        });

        // Logout function
        function performLogout() {
            const formElement = document.getElementById('logoutForm');

            // Check if CSRF token is available
            if (formElement.hasAttribute('data-no-csrf')) {
                console.error('CSRF token not available! Cannot logout securely.');
                alert('Fehler: CSRF Token nicht verfügbar. Bitte Seite neu laden und erneut versuchen.');
                return;
            }

            console.log('=== LOGOUT DEBUG ===');
            console.log('Form element:', formElement);
            console.log('Form action:', formElement.action);
            console.log('Form method:', formElement.method);

            // Find CSRF token input
            const csrfInputs = formElement.querySelectorAll('input[type="hidden"]');
            console.log('Hidden inputs found:', csrfInputs.length);

            csrfInputs.forEach(function(input, index) {
                var displayValue = input.value ? input.value.substring(0, 10) + '...' : '(empty)';
                console.log('Input ' + index + ': name="' + input.name + '", value="' + displayValue + '"');
            });

            // Submit the form
            formElement.submit();
        }
    </script>
</body>
</html>
