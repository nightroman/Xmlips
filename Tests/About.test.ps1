
#requires -Modules Xmlips

task help {
	. Helps.ps1
	Test-Helps ..\Module\en-US\Xmlips.dll-Help.ps1
}
