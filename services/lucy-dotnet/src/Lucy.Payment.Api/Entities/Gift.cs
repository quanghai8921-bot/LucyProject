namespace Lucy.Payment.Api.Entities;

public sealed class Gift
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public required string Name { get; set; }
    public decimal Price { get; set; }
}
