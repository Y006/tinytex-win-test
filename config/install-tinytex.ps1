# 文件路径: config/install-tinytex.ps1

Write-Host ">>> [Step 1/9] Downloading TinyTeX installer script..."
curl.exe -sL "https://yihui.org/tinytex/install-bin-windows.bat" -o install.bat

Write-Host ">>> [Step 2/9] Executing installation..."
.\install.bat

$tinyTexBin = "$env:APPDATA\TinyTeX\bin\windows"

Write-Host ">>> [Step 3/9] Registering Environment Path: $tinyTexBin"
echo "$tinyTexBin" | Out-File -FilePath $env:GITHUB_PATH -Encoding utf8 -Append
$env:Path = "$tinyTexBin;$env:Path"

Write-Host ">>> [Step 4/9] Group 1: Build Tools & Core"
# oberdiek: 底层工具合集，防报错神器
tlmgr install latexmk tools oberdiek

Write-Host ">>> [Step 5/9] Group 2: Chinese Support"
tlmgr install ctex xecjk fandol zhnumber gbt7714

Write-Host ">>> [Step 6/9] Group 3: Fonts & Math"
# realscripts: newtx 在 xelatex 下的隐形依赖
# mweights, fontaxes, scalefnt: newtx 字体权重调整依赖
tlmgr install tex-gyre newtx amscls amsmath amsfonts esint iftex `
              mweights fontaxes scalefnt realscripts

Write-Host ">>> [Step 7/9] Group 4: Template Logic"
# xstring, xpatch: 宏包补丁工具，极其重要
tlmgr install appendix abstract hologo footmisc kvoptions etoolbox `
              environ trimspaces xpatch xkeyval xstring

Write-Host ">>> [Step 8/9] Group 5: Formatting & Features"
# ulem: 下划线/删除线
# hyperref, url: 显式安装以防万一
tlmgr install biblatex biber geometry graphics xcolor `
              booktabs multirow makecell caption subcaption enumitem `
              listings fancyvrb pgf siunitx cleveref microtype ms mwe `
              ulem hyperref url

Write-Host ">>> [Step 9/9] Group 6: Academic & Thesis Extras (NEW!)"
# --- 新增内容 ---
# fancyhdr: 页眉页脚定制 (学位论文标配)
# setspace: 行距调整 (1.5倍行距等)
# titlesec/titletoc: 章节标题与目录定制
# pdfpages/pdflscape: 插入PDF页/横向页面
# algorithms...: 伪代码排版 (计算机/工程必备)
# threeparttable/longtable: 复杂/跨页表格
# mhchem: 化学公式
# overpic: 图片叠字
# natbib: 传统期刊引用支持
tlmgr install fancyhdr setspace titlesec titletoc `
              pdfpages pdflscape `
              algorithms algorithmicx algorithm2e `
              threeparttable longtable tabularx `
              mhchem overpic natbib

Write-Host ">>> SUCCESS: Installation script finished successfully!"