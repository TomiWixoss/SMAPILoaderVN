using Android.App;
using Android.OS;
using IO.Flutter.Embedding.Android;
using IO.Flutter.Plugin.Common;

namespace SMAPIGameLoader.Launcher
{
    [Activity(
        Label = "SMAPI Launcher",
        Theme = "@style/LaunchTheme",
        MainLauncher = true,
        ConfigurationChanges = Android.Content.PM.ConfigChanges.Orientation |
                              Android.Content.PM.ConfigChanges.KeyboardHidden |
                              Android.Content.PM.ConfigChanges.Keyboard |
                              Android.Content.PM.ConfigChanges.ScreenSize |
                              Android.Content.PM.ConfigChanges.Locale |
                              Android.Content.PM.ConfigChanges.LayoutDirection |
                              Android.Content.PM.ConfigChanges.FontScale |
                              Android.Content.PM.ConfigChanges.ScreenLayout |
                              Android.Content.PM.ConfigChanges.Density |
                              Android.Content.PM.ConfigChanges.UiMode
    )]
    public class LauncherActivity : FlutterActivity
    {
        private const string MethodChannelName = "abc.smapi.gameloadervn/bridge";
        private MethodChannelHandler? _methodChannelHandler;
        
        public static LauncherActivity? Instance { get; private set; }

        protected override void OnCreate(Bundle? savedInstanceState)
        {
            Instance = this;
            base.OnCreate(savedInstanceState);
            
            // Initialize Xamarin.Essentials
            Xamarin.Essentials.Platform.Init(this, savedInstanceState);
        }

        public override void ConfigureFlutterEngine(IO.Flutter.Embedding.Engine.FlutterEngine flutterEngine)
        {
            base.ConfigureFlutterEngine(flutterEngine);
            
            // Setup Method Channel
            var messenger = flutterEngine.DartExecutor.BinaryMessenger;
            var channel = new MethodChannel(messenger, MethodChannelName);
            
            _methodChannelHandler = new MethodChannelHandler(this);
            channel.SetMethodCallHandler(_methodChannelHandler);
        }

        public override void OnRequestPermissionsResult(int requestCode, string[] permissions, Android.Content.PM.Permission[] grantResults)
        {
            Xamarin.Essentials.Platform.OnRequestPermissionsResult(requestCode, permissions, grantResults);
            base.OnRequestPermissionsResult(requestCode, permissions, grantResults);
        }

        protected override void OnDestroy()
        {
            _methodChannelHandler?.Dispose();
            _methodChannelHandler = null;
            Instance = null;
            base.OnDestroy();
        }
    }
}
