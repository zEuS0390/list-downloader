$ProgressPreference = "SilentlyContinue"

$base_uri = "https://drive.google.com/uc?export=download&id="
$base_uri_doc = "https://docs.google.com/presentation/d"

$doc_ext_names = @("docx", "pptx")
$video_ext_names = @("mp4", "avi", "3gp")

$download_files = Get-ChildItem -Recurse | Where {! $_.PSIsContainer -and $_ -match "download_list.txt"} | Select Name, `
  @{ n = 'Folder'; e = { Convert-Path $_.PSParentPath } }, `
  FullName

foreach ($file in $download_files) {

	Write-Output "`n--- [Current: $($file.Folder)] ---`n"
	$items = Get-Content $file.FullName

	foreach ($item in $items) {

		if (!($item -like '#*')) {

			$item = ($item -split ':\s*')
			$file_path = $item[0]
			$file_id = $item[1]
			$file_ext_name = ($file_path -Split "\.")[1]

			if ($file_path -match '\\\w+\.\w+\\?$') {	
				$dirs = $file_path -Replace '\\\w+\.\w+\\?$' -Replace ""
				New-Item -Path $dirs -Type "directory" -Force | Out-Null
			}


			if ($doc_ext_names -Contains $file_ext_name) {

				Write-Output "Document: $($file_path)"
				Invoke-WebRequest -Uri "$($base_uri_doc)/$($file_id)/export/$($file_ext_name)" -OutFile "$($file.Folder)\$($file_path)"

			} elseif ($video_ext_names -Contains $file_ext_name) {

				Write-Output "Video: $($file_path)"
				Invoke-WebRequest -Uri "$($base_uri)$($file_id)" -OutFile "$($file.Folder)\$($file_path)"

			}

		}

	}

}
