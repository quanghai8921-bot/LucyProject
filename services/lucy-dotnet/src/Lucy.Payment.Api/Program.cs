using Lucy.Payment.Api.Data;
using Lucy.Payment.Api.Services;
using Lucy.Shared.Dtos;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddSingleton<PaymentDbContext>();
builder.Services.AddScoped<WalletService>();
builder.Services.AddScoped<TopUpService>();
builder.Services.AddScoped<DonationService>();
builder.Services.AddScoped<GiftService>();
builder.Services.AddScoped<WithdrawService>();
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
    Name = "Lucy.Payment.Api",
    Owner = "Linh",
    Status = "Healthy"
})))
    .WithName("GetPaymentHealth");
app.MapControllers();

app.Run();
