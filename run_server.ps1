$url = 'http://localhost:8081/'
$root = 'C:\Users\MSI-\Desktop\Сеул 2026'
$http = New-Object System.Net.HttpListener
$http.Prefixes.Add($url)
$http.Start()
$done = $false
$mime = @{'.html'='text/html; charset=utf-8';'.css'='text/css';'.js'='application/javascript';'.png'='image/png';'.jpg'='image/jpeg';'.jpeg'='image/jpeg'}
while (-not $done) {
    $task = $http.GetContextAsync()
    $wait = $task.Wait(300000)
    if (-not $wait) { continue }
    $ctx = $task.Result
    $path = $ctx.Request.Url.LocalPath.TrimStart('/')
    $fullPath = [IO.Path]::Combine($root, $path)
    if (Test-Path -LiteralPath $fullPath -PathType Leaf) {
        $bytes = [IO.File]::ReadAllBytes($fullPath)
        $ext = [IO.Path]::GetExtension($fullPath).ToLower()
        if ($mime.ContainsKey($ext)) { $ctx.Response.ContentType = $mime[$ext] }
        $ctx.Response.OutputStream.Write($bytes, 0, $bytes.Length)
    } else {
        $idx = [IO.Path]::Combine($root, 'index.html')
        $bytes = [IO.File]::ReadAllBytes($idx)
        $ctx.Response.ContentType = 'text/html; charset=utf-8'
        $ctx.Response.OutputStream.Write($bytes, 0, $bytes.Length)
    }
    $ctx.Response.Close()
}
