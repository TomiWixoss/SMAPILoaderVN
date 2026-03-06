using System;
using System.IO;
using Xamarin.Android.AssemblyStore;

if (args.Length < 2)
{
    Console.WriteLine("Usage: ExtractTool <blob_file> <output_dir>");
    return;
}

string blobFile = args[0];
string outputDir = args[1];

if (!File.Exists(blobFile))
{
    Console.WriteLine($"Error: File not found: {blobFile}");
    return;
}

Directory.CreateDirectory(outputDir);

try
{
    var explorer = new AssemblyStoreExplorer(blobFile, keepStoreInMemory: true);
    Console.WriteLine($"Found {explorer.Assemblies.Count} assemblies");
    
    foreach (var assembly in explorer.Assemblies)
    {
        Console.WriteLine($"Extracting: {assembly.Name}");
        assembly.ExtractImage(outputDir);
    }
    
    Console.WriteLine($"✅ Extracted {explorer.Assemblies.Count} assemblies to: {outputDir}");
}
catch (Exception ex)
{
    Console.WriteLine($"❌ Error: {ex.Message}");
    Console.WriteLine(ex.StackTrace);
}
