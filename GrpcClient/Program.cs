#region snippet2
using System;
using System.Threading.Tasks;
using Grpc.Net.Client;
using Grpc.Core;

namespace GrpcClient
{
    class Program
    {
        #region snippet
        static async Task Main(string[] args)
        {
            AppContext.SetSwitch("System.Net.Http.SocketsHttpHandler.Http2UnencryptedSupport", true);
            // Get all rows
            var rows = new SourceGamesHelper("games.db").GetRows();

            // The port number(5001) must match the port of the gRPC server.
            using var channel = GrpcChannel.ForAddress(Settings.Default.grpc_server_addr);
            var client = new Exporter.ExporterClient(channel);

            Console.WriteLine("Start export");
            var callOptions = new CallOptions(deadline: DateTime.UtcNow.AddMinutes(2));
            try
            {
                foreach (SourceGames sourceGame in rows)
                {
                    Console.Write(string.Format("Export [{0, -20}][{1, -20}][{2, -15}][{3, -40}]; ", sourceGame.GamesName, sourceGame.AchievementsName, sourceGame.CategoriesName, sourceGame.DownloadableContentsName));
                    var reply = await client.ExportAsync(
                                      new Row
                                      {
                                          GameName = sourceGame.GamesName,
                                          AchievementName = sourceGame.AchievementsName,
                                          CategoryName = sourceGame.CategoriesName,
                                          DownloadableContentName = sourceGame.DownloadableContentsName
                                      }, callOptions);
                    Console.WriteLine(string.Format("status: {0, -2}", reply.Ok));
                }
            }
            catch (RpcException ex)
            {
                Console.WriteLine(string.Format("{0}, status code: {1}", ex.Status.Detail, ((uint)ex.StatusCode)));
            }
            finally
            {
                Console.WriteLine("Press any key to exit...");
                Console.ReadKey();
            }
        }
        #endregion
    }
}
#endregion