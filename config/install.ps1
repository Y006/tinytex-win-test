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
# --- 终极全家桶安装命令 ---
# 1. 基础编译工具: latexmk, tools (calc, indentfirst等)
# 2. 中文环境: ctex, xecjk, fandol (字体), zhnumber
# 3. 字体与数学: tex-gyre (修复字体报错), newtx (模板数学字体), amscls, amsmath
# 4. 模板核心依赖: appendix (修复本次报错), abstract, hologo, kvoptions, etoolbox
# 5. 常用功能: biblatex, biber, caption, enumitem, listings, fancyvrb, geometry, graphics, xcolor
tlmgr install latexmk tools `
              ctex xecjk fandol zhnumber `
              tex-gyre newtx amscls amsmath amsfonts `
              appendix abstract hologo kvoptions etoolbox `
              biblatex biber caption subcaption enumitem listings fancyvrb `
              geometry graphics xcolor booktabs multirow makecell `
              pgf ms gbt7714 siunitx cleveref microtype environ trimspaces `
              footmisc esint iftex mwe

Write-Host ">>> SUCCESS: Installation script finished."