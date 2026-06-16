using MailKit.Net.Smtp;
using MailKit.Security;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using MimeKit;
using MimeKit.Text;

namespace Lucy.Auth.Api.Services;

public interface IEmailService
{
    Task SendEmailAsync(string toEmail, string subject, string bodyHtml);
}

public class EmailService(IConfiguration config, ILogger<EmailService> logger) : IEmailService
{
    public async Task SendEmailAsync(string toEmail, string subject, string bodyHtml)
    {
        try
        {
            var host = config["SmtpSettings:Host"];
            var port = int.Parse(config["SmtpSettings:Port"] ?? "587");
            var enableSsl = bool.Parse(config["SmtpSettings:EnableSsl"] ?? "true");
            var userName = config["SmtpSettings:UserName"];
            var password = config["SmtpSettings:Password"];

            var email = new MimeMessage();
            email.From.Add(new MailboxAddress("Lucy Support", userName));
            email.To.Add(MailboxAddress.Parse(toEmail));
            email.Subject = subject;
            email.Body = new TextPart(TextFormat.Html) { Text = bodyHtml };

            using var smtp = new SmtpClient();
            
            var secureSocketOptions = enableSsl ? SecureSocketOptions.StartTls : SecureSocketOptions.Auto;
            await smtp.ConnectAsync(host, port, secureSocketOptions);
            await smtp.AuthenticateAsync(userName, password);
            await smtp.SendAsync(email);
            await smtp.DisconnectAsync(true);
            
            logger.LogInformation("Da gui email toi {ToEmail} voi tieu de '{Subject}'", toEmail, subject);
        }
        catch (Exception ex)
        {
            logger.LogError(ex, "Loi khi gui email toi {ToEmail}", toEmail);
            throw new InvalidOperationException("Khong the gui email. Vui long thu lai sau.");
        }
    }
}
