var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();

app.MapGet("/", () => Results.Content("""
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="utf-8">
        <title>Rapid Platform - PaaS</title>
    </head>
    <body>
        <h1>Azure Rapid Platform</h1>
        <p>Application: ASP.NET Core on Windows App Service</p>
        <p>Version: 1.0</p>
        <ul>
            <li><a href="/health">Application health</a></li>
            <li><a href="/info">Application information</a></li>
        </ul>
    </body>
    </html>
    """, "text/html"));

app.MapGet("/health", () => Results.Ok(new
{
    status = "Healthy",
    application = "Rapid.Web"
}));

app.MapGet("/info", () => Results.Ok(new
{
    application = "Rapid.Web",
    version = "1.0",
    instance = Environment.GetEnvironmentVariable("WEBSITE_INSTANCE_ID")
        ?? Environment.MachineName
}));

app.Run();