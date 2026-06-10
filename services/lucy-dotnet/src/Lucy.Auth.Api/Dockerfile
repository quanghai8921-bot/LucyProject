FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

COPY Lucy.Auth.Api.csproj ./
RUN dotnet restore Lucy.Auth.Api.csproj

COPY . ./
RUN dotnet publish Lucy.Auth.Api.csproj -c Release -o /app/publish

FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS final
WORKDIR /app

COPY --from=build /app/publish ./

ENV ASPNETCORE_URLS=http://0.0.0.0:${PORT}
ENTRYPOINT ["dotnet", "Lucy.Auth.Api.dll"]