# Xmlips - XML in PowerShell

PowerShell module for basic operations on XML

Xmlips is designed for Windows PowerShell 5.1 and PowerShell Core.

The module focuses on using XML files as data storages in simple and effective
ways in PowerShell. The main scenario is read, find, edit, and save if changed.
Another scenario is logging, i.e. append elements to files and read them later.

For the list of cmdlets and operations, see [about_Xmlips](https://github.com/nightroman/Xmlips/blob/main/Module/en-US/about_Xmlips.help.txt).

## Install

Install the PSGallery module [Xmlips](https://www.powershellgallery.com/packages/Xmlips):

```powershell
Install-Module Xmlips
```

## Examples

- [Add-ProjectReference.ps1](https://github.com/nightroman/Xmlips/blob/main/Examples/Add-ProjectReference.ps1)
adds a reference to a Visual Studio project.
- [Clear-Dgml.ps1](https://github.com/nightroman/Xmlips/blob/main/Examples/Clear-Dgml.ps1)
removes designer generated attributes from DGML.
- [Update-ILSpyList.ps1](https://github.com/nightroman/Xmlips/blob/main/Examples/Update-ILSpyList.ps1)
updates the specified ILSpy assembly list.
- [Update-WebXml.ps1](https://github.com/nightroman/Xmlips/blob/main/Examples/Update-WebXml.ps1)
gets and updates the specified data from web.

## See also

- [Xmlips Release Notes](https://github.com/nightroman/Xmlips/blob/main/Release-Notes.md)
