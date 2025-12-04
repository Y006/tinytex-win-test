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
# latexmk: 自动化编译神器，自动处理引用和多次编译
# tools: 包含 calc, indentfirst 等 LaTeX 核心工具箱
tlmgr install latexmk tools

Write-Host ">>> [Step 5/8] Installing Packages - Group 2: Chinese Support"
# ctex: 中文排版核心
# xecjk: XeLaTeX 下的中文字体支持
# fandol: 开源中文字体集 (解决服务器无中文字体问题)
# zhnumber: 中文数字转换 (如 "一、二、三")
# gbt7714: 符合中国国标的参考文献样式
tlmgr install ctex xecjk fandol zhnumber gbt7714

Write-Host ">>> [Step 6/8] Installing Packages - Group 3: Fonts & Math"
# tex-gyre: 修复 elegantpaper 缺少的英文字体 (Heros/Termes)
# newtx: 模板默认使用的数学字体
# ams*: 美国数学会数学公式三剑客 (amsmath, amsfonts, amscls)
# esint: 扩展积分符号
# iftex: 编译引擎检测工具
tlmgr install tex-gyre newtx amscls amsmath amsfonts esint iftex

Write-Host ">>> [Step 7/8] Installing Packages - Group 4: Template Logic"
# 这些通常是 .cls 文件底层的依赖
# appendix/abstract/hologo/footmisc: 修复之前报的 .sty not found 错误
# kvoptions/etoolbox: 处理模板参数和编程逻辑
# environ/trimspaces: 环境定义与空格处理
# xpatch: 给宏包打补丁的工具，newtx 强依赖它
# xkeyval: 处理键值对参数的基础包
tlmgr install appendix abstract hologo footmisc kvoptions etoolbox environ trimspaces xpatch xkeyval

Write-Host ">>> [Step 8/8] Installing Packages - Group 5: Formatting & Features"
# biblatex/biber: 现代参考文献管理
# geometry/graphics/xcolor: 页面尺寸、图片、颜色
# booktabs/multirow/makecell: 专业三线表与复杂表格
# caption/subcaption: 图表标题与子图
# enumitem: 列表样式定制
# listings/fancyvrb: 代码块高亮与显示
# pgf: TikZ 绘图底层
# siunitx: 物理单位格式化
# cleveref: 智能引用
# microtype: 英文排版微调 (字符间距优化)
# ms: 包含 everyshi 等杂项包
# mwe: 包含 example-image 占位图 (修复缺失图片报错)
tlmgr install biblatex biber geometry graphics xcolor `
              booktabs multirow makecell caption subcaption enumitem `
              listings fancyvrb pgf siunitx cleveref microtype ms mwe

Write-Host ">>> SUCCESS: Installation script finished successfully!"