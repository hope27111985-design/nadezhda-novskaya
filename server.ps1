$http = New-Object System.Net.HttpListener
$http.Prefixes.Add("http://localhost:8080/")
$http.Start()
Write-Host "Server running at http://localhost:8080"
Write-Host "Press Ctrl+C to stop"

$mime = @{
    '.html' = 'text/html; charset=utf-8'
    '.htm' = 'text/html; charset=utf-8'
    '.css' = 'text/css'
    '.js' = 'application/javascript'
    '.jpg' = 'image/jpeg'
    '.jpeg' = 'image/jpeg'
    '.png' = 'image/png'
    '.gif' = 'image/gif'
    '.webp' = 'image/webp'
    '.ico' = 'image/x-icon'
    '.svg' = 'image/svg+xml'
    '.json' = 'application/json'
    '.mp4' = 'video/mp4'
    '.mov' = 'video/quicktime'
}

$root = "C:\Users\MSI-\Desktop\Сеул 2026"

while ($http.IsListening) {
    $ctx = $http.GetContext()
    $req = $ctx.Request
    $res = $ctx.Response
    
    $path = $req.Url.LocalPath.TrimStart('/')
    $fullPath = [System.IO.Path]::Combine($root, $path)
    
    if ([System.IO.File]::Exists($fullPath)) {
        try {
            $content = [System.IO.File]::ReadAllBytes($fullPath)
            $ext = [System.IO.Path]::GetExtension($fullPath).ToLower()
            if ($mime.ContainsKey($ext)) {
                $res.ContentType = $mime[$ext]
            } else {
                $res.ContentType = 'application/octet-stream'
            }
            $res.OutputStream.Write($content, 0, $content.Length)
            Write-Host "200 $path"
        } catch {
            $res.StatusCode = 500
            $msg = [System.Text.Encoding]::UTF8.GetBytes("Internal Server Error")
            $res.OutputStream.Write($msg, 0, $msg.Length)
            Write-Host "500 $path - $_"
        }
    } elseif ([System.IO.Directory]::Exists($fullPath)) {
        $index = [System.IO.Path]::Combine($fullPath, "index.html")
        if ([System.IO.File]::Exists($index)) {
            $content = [System.IO.File]::ReadAllBytes($index)
            $res.ContentType = 'text/html; charset=utf-8'
            $res.OutputStream.Write($content, 0, $content.Length)
        } else {
            $html = "<html><body><h2>Directory: $path</h2><ul>"
            foreach ($f in [System.IO.Directory]::GetFiles($fullPath)) {
                $name = [System.IO.Path]::GetFileName($f)
                $html += "<li><a href='$path/$name'>$name</a></li>"
            }
            $html += "</ul></body></html>"
            $buf = [System.Text.Encoding]::UTF8.GetBytes($html)
            $res.ContentType = 'text/html; charset=utf-8'
            $res.OutputStream.Write($buf, 0, $buf.Length)
        }
    } else {
        $idx = [System.IO.Path]::Combine($root, "index.html")
        if ([System.IO.File]::Exists($idx)) {
            $content = [System.IO.File]::ReadAllBytes($idx)
            $res.ContentType = 'text/html; charset=utf-8'
            $res.OutputStream.Write($content, 0, $content.Length)
        } else {
            $res.StatusCode = 404
            $msg = [System.Text.Encoding]::UTF8.GetBytes("Not Found")
            $res.OutputStream.Write($msg, 0, $msg.Length)
        }
        Write-Host "200 index.html (fallback for $path)"
    }
    
    $res.Close()
}

$http.Close()
