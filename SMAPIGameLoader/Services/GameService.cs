using Android.Content;
using SMAPIGameLoader.Game;
using SMAPIGameLoader.Launcher;
using SMAPIGameLoader.Tool;
using System;
using System.Threading.Tasks;

namespace SMAPIGameLoader.Services
{
    /// <summary>
    /// Service for game-related operations
    /// </summary>
    public class GameService : IGameService
    {
        private readonly Context _context;

        public GameService(Context context)
        {
            _context = context ?? throw new ArgumentNullException(nameof(context));
        }

        public bool IsGameInstalled => StardewApkTool.IsInstalled;

        public string GetGameVersion()
        {
            return StardewApkTool.CurrentGameVersion?.ToString() ?? "Not installed";
        }

        public Task LaunchGameAsync()
        {
            return Task.Run(() =>
            {
                if (!IsGameInstalled)
                {
                    throw new InvalidOperationException("Stardew Valley is not installed");
                }

                if (!SMAPIInstaller.IsInstalled)
                {
                    throw new InvalidOperationException("SMAPI is not installed");
                }

                if (_context is Android.App.Activity activity)
                {
                    // Use existing EntryGame logic
                    EntryGame.LaunchGameActivity(activity);
                }
                else
                {
                    throw new InvalidOperationException("Context is not an Activity");
                }
            });
        }
    }
}
