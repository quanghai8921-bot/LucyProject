namespace Lucy.Shared.Helpers;

public static class IdGenerator
{
    public static Guid NewId()
    {
        return Guid.NewGuid();
    }
}
