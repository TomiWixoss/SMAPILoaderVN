using System.Collections.Generic;
using System.Threading.Tasks;

namespace SMAPIGameLoader.Services
{
    /// <summary>
    /// Interface for app status operations
    /// </summary>
    public interface IStatusService
    {
        /// <summary>
        /// Get current app status
        /// </summary>
        Task<Dictionary<string, object>> GetAppStatusAsync();
    }
}
