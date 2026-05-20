$url = "http://localhost:8081/"
$root = "C:\Users\MSI-\Desktop\Сеул 2026"
$http = New-Object System.Net.HttpListener
$http.Prefixes.Add($url)
$http.Start()
$mime = @{".html" = "text/html; charset=utf-8"; ".css" = "text/css"; ".js" = "application/javascript"; ".png" = "image/png"; ".jpg" = "image/jpeg"; ".jpeg" = "image/jpeg"}
while ($http.IsListening) {
    $ctx = $http.GetContext()
    $path = $ctx.Request.Url.LocalPath.TrimStart("/")
    $fullPath = [System.IO.Path]::Combine($root, $path)
    if ([System.IO.File]::Exists($fullPath)) {
        $bytes = [System.IO.File]::ReadAllBytes($fullPath)
        $ext = [System.IO.Path]::GetExtension($fullPath).ToLower()
        if ($mime.ContainsKey($ext)) { $ctx.Response.ContentType = $mime[$ext] }
        $ctx.Response.OutputStream.Write($bytes, 0, $bytes.Length)
    } else {
        $idx = [System.IO.Path]::Combine($root, "index.html")
        $bytes = [System.IO.File]::ReadAllBytes($idx)
        $ctx.Response.ContentType = "text/html; charset=utf-8"
        $ctx.Response.OutputStream.Write($bytes, 0, $bytes.Length)
    }
    $ctx.Response.Close()
}
$http.Close()
