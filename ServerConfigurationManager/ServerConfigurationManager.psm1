foreach ($file in Get-ChildItem -Path "$PSScriptRoot\private" -Recurse -Filter *.ps1) {
	. $file.FullName
}
foreach ($file in Get-ChildItem -Path "$PSScriptRoot\public" -Recurse -Filter *.ps1) {
	. $file.FullName
}
foreach ($file in Get-ChildItem -Path "$PSScriptRoot\scripts" -Recurse -Filter *.ps1) {
	. $file.FullName
}