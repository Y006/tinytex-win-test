# 文件路径: config/install-tinytex.ps1

Write-Host ">>> [Step 1/4] Downloading TinyTeX installer script..."
curl.exe -sL "https://yihui.org/tinytex/install-bin-windows.bat" -o install.bat

Write-Host ">>> [Step 2/4] Executing installation..."
.\install.bat

$tinyTexBin = "$env:APPDATA\TinyTeX\bin\windows"

Write-Host ">>> [Step 3/4] Registering Environment Path: $tinyTexBin"
# 1. 写入 GitHub Actions 全局路径 (供后续 Step 使用)
echo "$tinyTexBin" | Out-File -FilePath $env:GITHUB_PATH -Encoding utf8 -Append
# 2. 写入当前会话路径 (供立即安装宏包使用)
$env:Path = "$tinyTexBin;$env:Path"

Write-Host ">>> [Step 4/4] Installing dependencies (Chinese font + TikZ)..."

# --- 修正点：去掉了 'call' ---
# 自动安装 Fandol (字体), ctex (中文), beamer (PPT), pgf (TikZ)
tlmgr install ctex xecjk beamer pgf ms gbt7714 fandol

Write-Host ">>> SUCCESS: Installation script finished."