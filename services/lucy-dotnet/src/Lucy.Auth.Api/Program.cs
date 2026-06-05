using Lucy.Auth.Api.Data;
using Lucy.Auth.Api.Services;
using Lucy.Shared.Dtos;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddSingleton<AuthDbContext>();
builder.Services.AddScoped<AuthService>();
builder.Services.AddScoped<JwtService>();
builder.Services.AddControllers();
builder.Services.AddOpenApi();

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
}

app.UseHttpsRedirection();

app.MapGet("/health", () => Results.Ok(ApiResponse<object>.Ok(new
{
    Name = "Lucy.Auth.Api",
    Owner = "Bao",
    Status = "Healthy"
})))
    .WithName("GetAuthHealth");
app.MapControllers();

app.Run();
