$port = 8080
$root = "C:\Users\MSI-\Desktop\Сеул 2026"
$encoding = [System.Text.Encoding]::UTF8

$mime = @{
    '.html' = 'text/html; charset=utf-8'
    '.htm'  = 'text/html; charset=utf-8'
    '.css'  = 'text/css'
    '.js'   = 'application/javascript'
    '.jpg'  = 'image/jpeg'
    '.jpeg' = 'image/jpeg'
    '.png'  = 'image/png'
    '.gif'  = 'image/gif'
    '.webp' = 'image/webp'
    '.ico'  = 'image/x-icon'
    '.svg'  = 'image/svg+xml'
    '.json' = 'application/json'
    '.mp4'  = 'video/mp4'
}

$tcp = New-Object System.Net.Sockets.TcpListener ([System.Net.IPAddress]::Loopback, $port)
$tcp.Start()
Write-Host "Server running at http://localhost:$port"

while ($true) {
    $client = $tcp.AcceptTcpClient()
    $stream = $client.GetStream()
    $reader = New-Object System.IO.StreamReader($stream)
    $request = $reader.ReadLine()
    
    if ($request -match 'GET\s+/(\S*?)(?:\s|$)') {
        $path = [System.Net.WebUtility]::UrlDecode($matches[1]) -replace '[?].*$', ''
        if ([string]::IsNullOrEmpty($path)) { $path = "index.html" }
        
        $fullPath = [System.IO.Path]::Combine($root, $path)
        
        if ([System.IO.File]::Exists($fullPath)) {
            $bytes = [System.IO.File]::ReadAllBytes($fullPath)
            $ext = [System.IO.Path]::GetExtension($fullPath).ToLower()
            $contentType = if ($mime.ContainsKey($ext)) { $mime[$ext] } else { 'application/octet-stream' }
            
            $header = "HTTP/1.1 200 OK`r`nContent-Type: $contentType`r`nContent-Length: $($bytes.Length)`r`nConnection: close`r`n`r`n"
            $headerBytes = $encoding.GetBytes($header)
            $stream.Write($headerBytes, 0, $headerBytes.Length)
            $stream.Write($bytes, 0, $bytes.Length)
        } else {
            $body = "<html><body><h1>404 Not Found</h1></body></html>"
            $bodyBytes = $encoding.GetBytes($body)
            $header = "HTTP/1.1 404 Not Found`r`nContent-Type: text/html; charset=utf-8`r`nContent-Length: $($bodyBytes.Length)`r`nConnection: close`r`n`r`n"
            $headerBytes = $encoding.GetBytes($header)
            $stream.Write($headerBytes, 0, $headerBytes.Length)
            $stream.Write($bodyBytes, 0, $bodyBytes.Length)
        }
    }
    
    $stream.Close()
    $client.Close()
}

$tcp.Stop()
