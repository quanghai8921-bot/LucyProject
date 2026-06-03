using System.Text;
using Lucy.Auth.Api.Data;
using Lucy.Auth.Api.Entities;
using Lucy.Auth.Api.Services;
using Lucy.Shared.Constants;
using Lucy.Shared.Dtos;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.FileProviders;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi;

var builder = WebApplication.CreateBuilder(args);
builder.Logging.ClearProviders();
builder.Logging.AddConsole();

// ── Database: EF Core + Pomelo MySQL ────────────────────────────────────────
var connectionString = builder.Configuration.GetConnectionString("DefaultConnection")
    ?? throw new InvalidOperationException("Connection string 'DefaultConnection' is missing.");

builder.Services.AddDbContext<AuthDbContext>(options =>
    options.UseMySql(connectionString, new MySqlServerVersion(new Version(8, 0, 36)),
        mysql => mysql.EnableRetryOnFailure(3)));

// ── JWT Authentication ───────────────────────────────────────────────────────
var jwtSecret = builder.Configuration["JwtSettings:SecretKey"]
    ?? throw new InvalidOperationException("JwtSettings:SecretKey is missing.");
var jwtIssuer   = builder.Configuration["JwtSettings:Issuer"]   ?? "lucy-auth";
var jwtAudience = builder.Configuration["JwtSettings:Audience"] ?? "lucy-client";

builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer           = true,
            ValidIssuer              = jwtIssuer,
            ValidateAudience         = true,
            ValidAudience            = jwtAudience,
            ValidateIssuerSigningKey = true,
            IssuerSigningKey         = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtSecret)),
            ValidateLifetime         = true,
            ClockSkew                = TimeSpan.Zero
        };

        options.Events = new JwtBearerEvents
        {
            OnChallenge = context =>
            {
                context.HandleResponse();
                context.Response.StatusCode  = 401;
                context.Response.ContentType = "application/json";
                var result = System.Text.Json.JsonSerializer.Serialize(
                    ApiResponse<object>.Fail("Bạn chưa đăng nhập hoặc token không hợp lệ."));
                return context.Response.WriteAsync(result);
            },
            OnForbidden = context =>
            {
                context.Response.StatusCode  = 403;
                context.Response.ContentType = "application/json";
                var result = System.Text.Json.JsonSerializer.Serialize(
                    ApiResponse<object>.Fail("Bạn không có quyền thực hiện hành động này."));
                return context.Response.WriteAsync(result);
            }
        };
    });

builder.Services.AddAuthorization();

// ── Services ─────────────────────────────────────────────────────────────────
builder.Services.AddScoped<JwtService>();
builder.Services.AddScoped<AuthService>();
builder.Services.AddScoped<AdminService>();

// ── Controllers ──────────────────────────────────────────────────────────────
builder.Services.AddControllers();

// ── Swagger / OpenAPI ────────────────────────────────────────────────────────
builder.Services.AddOpenApi();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(options =>
{
    options.SwaggerDoc("v1", new()
    {
        Title       = "Lucy Auth API",
        Version     = "v1",
        Description = "Đăng ký, Đăng nhập, Phân quyền, Xét duyệt Role – Lucy Project"
    });

    // JWT Bearer — Swashbuckle 10.x dùng OpenApiSecurityScheme từ Microsoft.OpenApi 2.x
    options.AddSecurityDefinition("bearer", new OpenApiSecurityScheme
    {
        Type         = SecuritySchemeType.Http,
        Scheme       = "bearer",
        BearerFormat = "JWT",
        Description  = "Nhập JWT access token. Ví dụ: eyJhbGci..."
    });

    // Swashbuckle 10.x: AddSecurityRequirement với document parameter
    options.AddSecurityRequirement(document => new OpenApiSecurityRequirement
    {
        [new OpenApiSecuritySchemeReference("bearer", document)] = []
    });
});

// ── CORS ─────────────────────────────────────────────────────────────────────
builder.Services.AddCors(options =>
    options.AddDefaultPolicy(policy =>
        policy.AllowAnyOrigin().AllowAnyHeader().AllowAnyMethod()));

var app = builder.Build();

// ── Ensure database for local development ─────────────────────────────────────
using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<AuthDbContext>();
    try
    {
        await db.Database.EnsureCreatedAsync();

        // Seed default Admin if not exists
        if (!await db.Users.AnyAsync(u => u.Email == "admin@lucy.app"))
        {
            var adminUser = new User
            {
                UserId = "Uadmin",
                FullName = "System Admin",
                Email = "admin@lucy.app",
                PhoneNumber = "0999999999",
                Passwords = BCrypt.Net.BCrypt.HashPassword("admin123"),
                IsStatus = 1
            };
            db.Users.Add(adminUser);
            db.UserRoles.Add(new UserRole
            {
                UserId = adminUser.UserId,
                RoleId = RoleCodes.AdminId
            });
            await db.SaveChangesAsync();
        }
    }
    catch (Exception ex)
    {
        var logger = scope.ServiceProvider.GetRequiredService<ILogger<Program>>();
        logger.LogError(ex, "Loi khi tao/kiem tra database. Tiep tuc chay...");
    }
}

// ── Middleware pipeline ───────────────────────────────────────────────────────
if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();      // /openapi/v1.json
    app.UseSwagger();
    app.UseSwaggerUI(c =>
    {
        c.SwaggerEndpoint("/swagger/v1/swagger.json", "Lucy Auth API v1");
        c.RoutePrefix = "swagger";
    });
}

app.UseCors();
app.UseHttpsRedirection();

var uploadsPath = Path.Combine(app.Environment.ContentRootPath, "uploads");
Directory.CreateDirectory(uploadsPath);
app.UseStaticFiles(new StaticFileOptions
{
    FileProvider = new PhysicalFileProvider(uploadsPath),
    RequestPath = "/uploads"
});

app.UseAuthentication();
app.UseAuthorization();

// Health check
app.MapGet("/health", () => Results.Ok(ApiResponse<object>.Ok(new
{
    Name   = "Lucy.Auth.Api",
    Owner  = "Bao",
    Status = "Healthy",
    Time   = DateTimeOffset.UtcNow
}))).WithName("GetAuthHealth").AllowAnonymous();

app.MapControllers();
app.Run();
