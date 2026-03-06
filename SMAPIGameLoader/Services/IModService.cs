using System.Collections.Generic;
using System.Threading.Tasks;

namespace SMAPIGameLoader.Services
{
    /// <summary>
    /// Interface for mod management operations
    /// </summary>
    public interface IModService
    {
        /// <summary>
        /// Get list of installed mods
        /// </summary>
        Task<List<Dictionary<string, object>>> GetModListAsync();

        /// <summary>
        /// Install a mod from file path
        /// </summary>
        Task InstallModAsync(string filePath);

        /// <summary>
        /// Delete a mod by ID
        /// </summary>
        Task DeleteModAsync(string modId);

        /// <summary>
        /// Open mod folder in file manager
        /// </summary>
        Task OpenModFolderAsync();
    }
}
