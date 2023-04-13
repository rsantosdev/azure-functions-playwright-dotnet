using Microsoft.Extensions.Hosting;

//Microsoft.Playwright.Program.Main(new[] { "install" });

var host = new HostBuilder()
    .ConfigureFunctionsWorkerDefaults()
    .Build();

host.Run();
