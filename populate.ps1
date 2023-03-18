param(
	[string]$current_dir = ""
)

$ProgressPreference = "SilentlyContinue"

$download_files = Get-ChildItem -Recurse $current_dir | Where {! $_.PSIsContainer -and $_ -match "download_list.txt"} | Select Name, `
  @{ n = 'Folder'; e = { Convert-Path $_.PSParentPath } }, `
  FullName

function DownloadFile {
	param(
		[string]$Uri,
		[string]$OutFile
	)
	if ($PSVersionTable.PSVersion.Major -lt 7) {
		$client = New-Object System.Net.WebClient
		$client.DownloadFile($Uri, $OutFile)
	} else {
		Invoke-WebRequest -Uri $Uri -OutFile $OutFile 
	}
}

foreach ($file in $download_files) {

	Write-Output "`n--- [Current: $($file.Folder)] ---`n"
	$items = Get-Content $file.FullName

	foreach ($item in $items) {

		if (!($item -like '#*') -and !($item -like '\s*$?')) {

			$item = ($item -split '\s*=\s*')
			$file_path = $item[0]
			$URI = $item[1]

			if ($file_path -match '\\\w+\.\w+\\?$') {	
				$dirs = $file_path -Replace '\\\w+\.\w+\\?$' -Replace ""
				New-Item -Path "$($file.Folder)\$($dirs)" -Type "directory" -Force | Out-Null
			}

			if ($item) {

				Write-Output "File: $($file_path)"
				DownloadFile $($URI) "$($file.Folder)\$($file_path)"

			}

		}

	}

}

Write-Output ''
