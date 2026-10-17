$root = "C:\Users\mmwpl\OneDrive\Documentos\Projetos Roblox\Terror"
$l = New-Object System.Net.HttpListener
$l.Prefixes.Add("http://localhost:8765/")
$l.Start()
$deadline = (Get-Date).AddMinutes(4)
$n = 0
$log = @()
while ((Get-Date) -lt $deadline -and $n -lt 12) {
  $task = $l.GetContextAsync()
  while (-not $task.IsCompleted -and (Get-Date) -lt $deadline) { Start-Sleep -Milliseconds 100 }
  if (-not $task.IsCompleted) { break }
  $ctx = $task.Result
  $reader = New-Object System.IO.StreamReader($ctx.Request.InputStream, [Text.Encoding]::UTF8)
  $obj = $reader.ReadToEnd() | ConvertFrom-Json
  if ($obj.path -match '\.\.' -or $obj.path -match '^[A-Za-z]:' -or $obj.path.StartsWith('\') -or $obj.path.StartsWith('/')) {
    $ctx.Response.StatusCode = 400; $ctx.Response.Close(); continue
  }
  $dest = Join-Path $root $obj.path
  New-Item -ItemType Directory -Force (Split-Path $dest) | Out-Null
  [IO.File]::WriteAllText($dest, $obj.content, (New-Object Text.UTF8Encoding($false)))
  $log += "$($obj.path) ($($obj.content.Length) chars)"
  $ctx.Response.StatusCode = 200; $ctx.Response.Close(); $n++
}
$l.Stop()
$log | Out-File (Join-Path $root "export.log.txt") -Encoding utf8

