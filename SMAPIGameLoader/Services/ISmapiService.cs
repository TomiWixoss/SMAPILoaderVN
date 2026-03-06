using System.Threading.Tasks;

namespace SMAPIGameLoader.Services
{
    /// <summary>
    /// Interface for SMAPI-related operations
    /// </summary>
    public interface ISmapiService
    {
        /// <summary>
        /// Check if SMAPI is installed
        /// </summary>
        bool IsSmapiInstalled { get; }

        /// <summary>
        /// Get current SMAPI version
        /// </summary>
        string GetSmapiVersion();

        /// <summary>
        /// Install SMAPI from APK file
        /// </summary>
        Task InstallSmapiAsync(string filePath);

        /// <summary>
        /// Upload SMAPI log to smapi.io
        /// </summary>
        Task<string> UploadLogAsync();
    }
}
