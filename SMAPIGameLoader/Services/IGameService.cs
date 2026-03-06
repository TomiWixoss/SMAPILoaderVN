using System.Threading.Tasks;

namespace SMAPIGameLoader.Services
{
    /// <summary>
    /// Interface for game-related operations
    /// </summary>
    public interface IGameService
    {
        /// <summary>
        /// Check if game is installed
        /// </summary>
        bool IsGameInstalled { get; }

        /// <summary>
        /// Get current game version
        /// </summary>
        string GetGameVersion();

        /// <summary>
        /// Launch the game with SMAPI
        /// </summary>
        Task LaunchGameAsync();
    }
}
