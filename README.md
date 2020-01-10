# Xmlips - XML in PowerShell

Cmdlets for basic operations on XML in PowerShell v2.0 or newer.

The module focuses on using XML files as data storages in simple and effective
ways in PowerShell. The main scenario is read, find, edit, and save if changed.
Another scenario is logging, i.e. append elements to files and read them later.

For the list of cmdlets and operations, see [about_Xmlips](https://github.com/nightroman/Xmlips/blob/master/Module/en-US/about_Xmlips.help.txt).

***
## Get and install

**Package from PSGallery**

Install the PSGallery module [Xmlips](https://www.powershellgallery.com/packages/Xmlips):

```powershell
Install-Module Xmlips
```

**Package from NuGet (legacy)**

Manually install the NuGet package [Xmlips](https://www.nuget.org/packages/Xmlips).
Download and unpack it to the current location by this PowerShell command:

```powershell
Invoke-Expression "& {$((New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/nightroman/PowerShelf/master/Save-NuGetTool.ps1'))} Xmlips"
```

Then copy the directory *Xmlips* to a PowerShell module directory, see `$env:PSModulePath`.

***
## Examples

- [Add-ProjectReference.ps1](https://github.com/nightroman/Xmlips/blob/master/Examples/Add-ProjectReference.ps1)
adds a reference to a Visual Studio project.
- [Clear-Dgml.ps1](https://github.com/nightroman/Xmlips/blob/master/Examples/Clear-Dgml.ps1)
removes designer generated attributes from DGML.
- [Update-ILSpyList.ps1](https://github.com/nightroman/Xmlips/blob/master/Examples/Update-ILSpyList.ps1)
updates the specified ILSpy assembly list.
- [Update-WebXml.ps1](https://github.com/nightroman/Xmlips/blob/master/Examples/Update-WebXml.ps1)
gets and updates the specified data from web.

***
## See also

- [Xmlips Release Notes](https://github.com/nightroman/Xmlips/blob/master/Release-Notes.md)
