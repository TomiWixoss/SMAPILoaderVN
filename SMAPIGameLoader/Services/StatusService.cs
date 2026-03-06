using System.Collections.Generic;
using System.Threading.Tasks;
using Xamarin.Essentials;

namespace SMAPIGameLoader.Services
{
    /// <summary>
    /// Service for app status operations
    /// </summary>
    public class StatusService : IStatusService
    {
        private readonly IGameService _gameService;
        private readonly ISmapiService _smapiService;

        public StatusService(IGameService gameService, ISmapiService smapiService)
        {
            _gameService = gameService;
            _smapiService = smapiService;
        }

        public Task<Dictionary<string, object>> GetAppStatusAsync()
        {
            return Task.Run(() =>
            {
                var status = new Dictionary<string, object>
                {
                    ["launcherVersion"] = AppInfo.VersionString,
                    ["gameVersion"] = _gameService.GetGameVersion(),
                    ["smapiVersion"] = _smapiService.GetSmapiVersion(),
                    ["isReady"] = _gameService.IsGameInstalled && _smapiService.IsSmapiInstalled
                };

                return status;
            });
        }
    }
}
