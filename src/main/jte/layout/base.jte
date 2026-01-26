@import gg.jte.Content

@param String title = "JEVis 4"
@param Content content

<!DOCTYPE html>
<html lang="de" data-theme="dark">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${title} - JEVis 4</title>

    <!-- Favicon -->
    <link rel="icon" type="image/x-icon" href="/images/favicon.ico">
    <link rel="icon" type="image/png" sizes="32x32" href="/images/favicon-32x32.png">
    <link rel="icon" type="image/png" sizes="16x16" href="/images/favicon-16x16.png">
    <link rel="apple-touch-icon" sizes="180x180" href="/images/apple-touch-icon.png">

    <link rel="stylesheet" href="/css/theme.css">
    <script src="https://unpkg.com/htmx.org@1.9.10"></script>
</head>
<body>
    ${content}
</body>
</html>
