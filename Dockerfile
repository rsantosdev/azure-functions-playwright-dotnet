
FROM mcr.microsoft.com/azure-functions/dotnet-isolated:4-dotnet-isolated7.0 AS base
WORKDIR /home/site/wwwroot
EXPOSE 80
RUN apt update && apt install -y curl gnupg apt-transport-https
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
RUN sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-debian-bullseye-prod bullseye main" > /etc/apt/sources.list.d/microsoft.list'
RUN apt update && apt install -y powershell

FROM mcr.microsoft.com/dotnet/sdk:7.0 AS build
WORKDIR /src
COPY ["PlaywrightOnAzureFunctionsDemo.csproj", "."]
RUN dotnet restore "./PlaywrightOnAzureFunctionsDemo.csproj"
COPY . .
WORKDIR "/src/."
RUN dotnet build "PlaywrightOnAzureFunctionsDemo.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "PlaywrightOnAzureFunctionsDemo.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /home/site/wwwroot
COPY --from=publish /app/publish .
RUN pwsh ./playwright.ps1 install --with-deps
ENV AzureWebJobsScriptRoot=/home/site/wwwroot \
    AzureFunctionsJobHost__Logging__Console__IsEnabled=true