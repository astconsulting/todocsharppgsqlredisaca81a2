using Microsoft.EntityFrameworkCore;
using SimpleTodo.Api;

var builder = WebApplication.CreateBuilder(args);
builder.Services.AddScoped<ListsRepository>();
builder.Configuration.AddEnvironmentVariables();
builder.Services.AddDbContext<TodoDb>(options =>
{
    var pgHost = builder.Configuration["POSTGRES_HOST"];
    var pgPassword = builder.Configuration["POSTGRES_PASSWORD"];
    var pgUser = builder.Configuration["POSTGRES_USERNAME"];
    var pgDatabase = builder.Configuration["POSTGRES_DATABASE"];
    var pgConnection = $"Host={pgHost};Database={pgDatabase};Username={pgUser};Password={pgPassword};Timeout=300";
    options.UseNpgsql(pgConnection, sqlOptions => sqlOptions.EnableRetryOnFailure());
});

builder.Services.AddControllers();
builder.Services.AddApplicationInsightsTelemetry(builder.Configuration);

var app = builder.Build();

await using (var scope = app.Services.CreateAsyncScope())
{
    var db = scope.ServiceProvider.GetRequiredService<TodoDb>();
    await db.Database.EnsureCreatedAsync();
}

app.UseCors(policy =>
{
    policy.AllowAnyOrigin();
    policy.AllowAnyHeader();
    policy.AllowAnyMethod();
});
    
// Swagger UI
app.UseSwaggerUI(options => {
    options.SwaggerEndpoint("./openapi.yaml", "v1");
    options.RoutePrefix = "";
});

app.UseStaticFiles(new StaticFileOptions{
    // Serve openapi.yaml file
    ServeUnknownFileTypes = true,
});

app.MapControllers();
app.Run();