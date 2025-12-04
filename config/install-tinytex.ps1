# 文件路径: config/install-tinytex.ps1

Write-Host ">>> [Step 1/8] Downloading TinyTeX installer script..."
curl.exe -sL "https://yihui.org/tinytex/install-bin-windows.bat" -o install.bat

Write-Host ">>> [Step 2/8] Executing installation..."
.\install.bat

$tinyTexBin = "$env:APPDATA\TinyTeX\bin\windows"

Write-Host ">>> [Step 3/8] Registering Environment Path: $tinyTexBin"
# 1. 写入 GitHub Actions 全局路径 (供后续 Step 使用)
echo "$tinyTexBin" | Out-File -FilePath $env:GITHUB_PATH -Encoding utf8 -Append
# 2. 写入当前会话路径 (供立即安装宏包使用)
$env:Path = "$tinyTexBin;$env:Path"

Write-Host ">>> [Step 4/8] Installing Packages - Group 1: Build Tools & Core"
# latexmk: 自动化编译神器
# tools: 包含 calc, indentfirst 等核心工具
tlmgr install latexmk tools

Write-Host ">>> [Step 5/8] Installing Packages - Group 2: Chinese Support"
# ctex, xecjk, fandol: 中文基础
# zhnumber: 中文数字
# gbt7714: 国标参考文献
tlmgr install ctex xecjk fandol zhnumber gbt7714

Write-Host ">>> [Step 6/8] Installing Packages - Group 3: Fonts & Math"
# tex-gyre: 基础英文字体
# newtx: 数学字体
# ams*: 数学公式支持
# esint: 积分符号
# iftex: 引擎检测
# mweights, fontaxes, scalefnt: newtx 的底层依赖 (修复 scalefnt not found)
tlmgr install tex-gyre newtx amscls amsmath amsfonts esint iftex mweights fontaxes scalefnt

Write-Host ">>> [Step 7/8] Installing Packages - Group 4: Template Logic"
# xstring, xpatch: 宏包补丁工具
# kvoptions, etoolbox: 模板逻辑
# appendix, abstract, hologo, footmisc: 常用模板组件
tlmgr install appendix abstract hologo footmisc kvoptions etoolbox environ trimspaces xpatch xkeyval xstring

Write-Host ">>> [Step 8/8] Installing Packages - Group 5: Formatting & Features"
# biblatex, biber: 参考文献
# geometry, graphics, xcolor: 版面与颜色
# booktabs, multirow, makecell: 表格
# caption, subcaption: 图片标题
# enumitem: 列表
# listings, fancyvrb: 代码
# pgf: 绘图
# siunitx: 单位
# cleveref: 引用
# microtype: 微调
# ms, mwe: 杂项与测试图
# ulem: 下划线支持 (elegantpaper 常用)
tlmgr install biblatex biber geometry graphics xcolor `
              booktabs multirow makecell caption subcaption enumitem `
              listings fancyvrb pgf siunitx cleveref microtype ms mwe ulem

Write-Host ">>> SUCCESS: Installation script finished successfully!"