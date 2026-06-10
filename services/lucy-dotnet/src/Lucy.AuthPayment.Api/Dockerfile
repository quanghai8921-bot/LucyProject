FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

COPY Lucy.AuthPayment.Api.csproj ./
RUN dotnet restore Lucy.AuthPayment.Api.csproj

COPY . ./
RUN dotnet publish Lucy.AuthPayment.Api.csproj -c Release -o /app/publish

FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS final
WORKDIR /app

COPY --from=build /app/publish ./

ENV ASPNETCORE_URLS=http://0.0.0.0:${PORT}
ENTRYPOINT ["dotnet", "Lucy.AuthPayment.Api.dll"]
