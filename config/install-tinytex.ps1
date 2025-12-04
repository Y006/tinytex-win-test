# 文件名: install.ps1

Write-Host ">>> [1/4] Downloading TinyTeX installer..."
curl.exe -sL "https://yihui.org/tinytex/install-bin-windows.bat" -o install.bat

Write-Host ">>> [2/4] Executing installation..."
.\install.bat

$tinyTexBin = "$env:APPDATA\TinyTeX\bin\windows"

Write-Host ">>> [3/4] Registering Environment Path: $tinyTexBin"
# 写入 GitHub Actions 全局路径
echo "$tinyTexBin" | Out-File -FilePath $env:GITHUB_PATH -Encoding utf8 -Append
# 更新当前会话路径
$env:Path = "$tinyTexBin;$env:Path"

Write-Host ">>> [4/4] Installing dependencies (Chinese font + TikZ)..."
call tlmgr install ctex xecjk beamer pgf ms gbt7714 fandol

Write-Host ">>> SUCCESS: Installation script finished."