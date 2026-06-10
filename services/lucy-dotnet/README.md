# Lucy .NET Services

Workspace for Lucy .NET services.

## Structure

- `Lucy.DotNet.sln` - solution for all .NET services.
- `src/Lucy.Auth.Api` - authentication and account API. Owner: Bao.
- `src/Lucy.AuthPayment.Api` - wallet/payment API. Owner: Linh.
- `src/Lucy.Shared` - shared code used by .NET services.

## Commands

```powershell
dotnet restore .\Lucy.DotNet.sln
dotnet build .\Lucy.DotNet.sln
dotnet run --project .\src\Lucy.Auth.Api\Lucy.Auth.Api.csproj
dotnet run --project .\src\Lucy.AuthPayment.Api\Lucy.AuthPayment.Api.csproj
```
