function Invoke-Confetti {
[CmdletBinding()]
param (
    [Parameter()]
    [string]
    $LabelText = "Congratulations! We did it!"
)

#WPF Library for Playing Movie and some components
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.ComponentModel

$syncHash = [hashtable]::Synchronized(@{})
$newRunspace =[runspacefactory]::CreateRunspace()
$newRunspace.ApartmentState = "STA"
$newRunspace.ThreadOptions = "ReuseThread"         
$newRunspace.Open()
$newRunspace.SessionStateProxy.SetVariable("syncHash",$syncHash)
$newRunspace.SessionStateProxy.SetVariable("rootdir",$PSScriptRoot)
$newRunspace.SessionStateProxy.SetVariable("labelText",$LabelText)
$psCmd = [PowerShell]::Create().AddScript({   
    [xml]$XAML = @"
 
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="PowerShell Video Player" ResizeMode="NoResize" WindowState="Maximized" WindowStyle="None" Background="Black">
    <Grid Margin="0,0,0,0">
        <MediaElement HorizontalAlignment="Stretch" Name="VideoPlayer" LoadedBehavior="Manual" UnloadedBehavior="Stop" />
            <Label Name="Label1" Content="$labelText" Grid.Row="0" Grid.ColumnSpan="2"
            FontSize="44" FontFamily="Georgia" FontWeight="Bold" Background="Transparent" Foreground="Orange"
            VerticalAlignment="Center" HorizontalAlignment="Center" />
    </Grid>
</Window>
"@
 
#Movie Path
[uri]$syncHash.VideoSource = "$rootdir\confetti.mp4"
#Devide All Objects on XAML
$XAMLReader=(New-Object System.Xml.XmlNodeReader $XAML)
$syncHash.Window=[Windows.Markup.XamlReader]::Load( $XAMLReader )
$syncHash.Window.Topmost = $true
$syncHash.VideoPlayer = $syncHash.Window.FindName("VideoPlayer")

#Video Default Setting
$syncHash.VideoPlayer.Volume = 100;
$syncHash.VideoPlayer.Source = $syncHash.VideoSource;
$syncHash.VideoPlayer.Play()

$syncHash.playing = $true



#Show Up the Window 
$syncHash.Window.ShowDialog() | out-null
})
$psCmd.Runspace = $newRunspace
$data = $psCmd.BeginInvoke()


Function Close-WPFWindow {
    $syncHash.Window.Dispatcher.invoke([action]{
        $syncHash.Window.Close()
    },
    "Normal")
}
while(!($syncHash.VideoPlayer)){
    Start-Sleep -Milliseconds 250
}
$eventSubscription = Register-ObjectEvent -InputObject ($syncHash.VideoPlayer) -EventName "MediaEnded" -Action {
    $Event.MessageData.playing = $false
} -MessageData $syncHash

while($syncHash.playing){
Start-Sleep -Milliseconds 250
}
Close-WPFWindow

Unregister-Event ($eventSubscription.Name) # Clean-up
}