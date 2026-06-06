namespace lucy_auth_payment.Common;

public class BaseResponse<T>
{
    public bool Success { get; set; } = true;

    public string Message { get; set; } = string.Empty;

    public T? Data { get; set; }
}
