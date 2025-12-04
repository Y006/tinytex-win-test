# 文件路径: config/install-tinytex.ps1

Write-Host ">>> [Step 1/4] Downloading TinyTeX installer script..."
curl.exe -sL "https://yihui.org/tinytex/install-bin-windows.bat" -o install.bat

Write-Host ">>> [Step 2/4] Executing installation..."
.\install.bat

$tinyTexBin = "$env:APPDATA\TinyTeX\bin\windows"

Write-Host ">>> [Step 3/4] Registering Environment Path: $tinyTexBin"
echo "$tinyTexBin" | Out-File -FilePath $env:GITHUB_PATH -Encoding utf8 -Append
$env:Path = "$tinyTexBin;$env:Path"

Write-Host ">>> [Step 4/4] Installing dependencies..."
# 核心修改：加入了 latexmk
# 同时保留了之前分析出的所有论文写作必备包
# --- 核心修改：追加了 abstract, hologo, fancyvrb 等模板常用包 ---
tlmgr install latexmk ctex xecjk beamer pgf ms gbt7714 fandol tools `
              biblatex biber siunitx caption subcaption cleveref `
              enumitem multirow makecell listings mathtools microtype `
              abstract hologo fancyvrb environ trimspaces

Write-Host ">>> SUCCESS: Installation script finished."