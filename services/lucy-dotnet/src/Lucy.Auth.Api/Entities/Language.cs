namespace Lucy.Auth.Api.Entities;

public sealed class Language
{
    public string LanguageId { get; set; } = default!;
    public required string LanguageName { get; set; }

    public ICollection<MentorApplication> MentorApplications { get; set; } = [];
}
