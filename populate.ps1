param(
	[string]$current_dir = ".",
	[string]$base_uri = "https://drive.google.com/uc?export=download&id="
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

		if (!($item -like '#*')) {

			$item = ($item -split ':\s*')
			$file_path = $item[0]
			$file_id = $item[1]

			if ($file_path -match '\\\w+\.\w+\\?$') {	
				$dirs = $file_path -Replace '\\\w+\.\w+\\?$' -Replace ""
				New-Item -Path $dirs -Type "directory" -Force | Out-Null
			}
			
			Write-Output "File: $($file_path)"
			DownloadFile "$($base_uri)$($file_id)" "$($file.Folder)\$($file_path)"
		}

	}

}
