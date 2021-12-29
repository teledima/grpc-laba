using System.Collections.Generic;
using System.Reflection;
using System.Text;
using Microsoft.Data.Sqlite;

namespace GrpcGreeterClient
{
    public class SourceGamesHelper
    {
        public string Filepath { get; private set; }
        public SourceGamesHelper(string filepath)
        {
            Filepath = filepath;
        }

        public List<SourceGames> GetRows()
        {
            var listResult = new List<SourceGames>();
            using var connection = new SqliteConnection(string.Format("Data Source = {0}", Filepath));
            connection.Open();
            var command = connection.CreateCommand();
            command.CommandText = "select games_name, achievements_name, downloadable_contents_name, categories_name from source_games";
            var reader = command.ExecuteReader();
            while (reader.Read())
            {
                listResult.Add(new SourceGames()
                {
                    GamesName = reader.IsDBNull(0)?null: reader.GetString(0),
                    AchievementsName = reader.IsDBNull(1) ? null : reader.GetString(1),
                    DownloadableContentsName = reader.IsDBNull(2) ? null : reader.GetString(2),
                    CategoriesName = reader.IsDBNull(3) ? null : reader.GetString(3)
                });
            }
            return listResult;
        }
    }


    public class SourceGames
    {
        public string GamesName { get; set; }

        public string CategoriesName { get; set; }

        public string DownloadableContentsName { get; set; }

        public string AchievementsName { get; set; }
    }
}
