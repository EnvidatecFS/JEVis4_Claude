package gg.jte.generated.ondemand.layout;
import gg.jte.Content;
public final class JtebaseGenerated {
	public static final String JTE_NAME = "layout/base.jte";
	public static final int[] JTE_LINE_INFO = {0,0,2,2,2,10,10,10,10,12,22,22,22,25,25,25,2,3,3,3,3};
	public static void render(gg.jte.html.HtmlTemplateOutput jteOutput, gg.jte.html.HtmlInterceptor jteHtmlInterceptor, String title, Content content) {
		jteOutput.writeContent("\n<!DOCTYPE html>\n<html lang=\"de\" data-theme=\"dark\">\n<head>\n    <meta charset=\"UTF-8\">\n    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">\n    <title>");
		jteOutput.setContext("title", null);
		jteOutput.writeUserContent(title);
		jteOutput.writeContent(" - JEVis 4</title>\n\n    ");
		jteOutput.writeContent("\n    <link rel=\"icon\" type=\"image/x-icon\" href=\"/images/favicon.ico\">\n    <link rel=\"icon\" type=\"image/png\" sizes=\"32x32\" href=\"/images/favicon-32x32.png\">\n    <link rel=\"icon\" type=\"image/png\" sizes=\"16x16\" href=\"/images/favicon-16x16.png\">\n    <link rel=\"apple-touch-icon\" sizes=\"180x180\" href=\"/images/apple-touch-icon.png\">\n\n    <link rel=\"stylesheet\" href=\"/css/theme.css\">\n    <script src=\"https://unpkg.com/htmx.org@1.9.10\"></script>\n</head>\n<body>\n    ");
		jteOutput.setContext("body", null);
		jteOutput.writeUserContent(content);
		jteOutput.writeContent("\n</body>\n</html>\n");
	}
	public static void renderMap(gg.jte.html.HtmlTemplateOutput jteOutput, gg.jte.html.HtmlInterceptor jteHtmlInterceptor, java.util.Map<String, Object> params) {
		String title = (String)params.getOrDefault("title", "JEVis 4");
		Content content = (Content)params.get("content");
		render(jteOutput, jteHtmlInterceptor, title, content);
	}
}
