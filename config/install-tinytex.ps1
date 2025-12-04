# 文件路径: config/install-tinytex.ps1

# ==============================================================================
# 0. 定义核心函数：安装并验证 (Install-And-Verify)
#    功能：批量安装 -> 逐个检查 -> 失败自动重试 -> 致命错误中断
# ==============================================================================
function Install-And-Verify {
    param (
        [string]$GroupName,
        [string[]]$Packages
    )
    Write-Host "`n>>> [Group: $GroupName] Starting installation..."
    
    # 1. 尝试批量安装 (速度快)
    # 使用 join 将数组合并为字符串，彻底避免换行符引发的语法错误
    $pkgString = $Packages -join " "
    cmd /c "tlmgr install $pkgString"

    # 2. 逐个验证 (安全性高)
    foreach ($pkg in $Packages) {
        # 检查包是否已在安装列表中
        $check = tlmgr info $pkg --only-installed
        
        if (-not $check) {
            Write-Host "⚠️ Warning: '$pkg' was NOT found after batch install. Retrying individually..." -ForegroundColor Yellow
            
            # 单独重试安装
            cmd /c "tlmgr install $pkg"
            
            # 二次验证
            $retryCheck = tlmgr info $pkg --only-installed
            if (-not $retryCheck) {
                Write-Host "❌ FATAL ERROR: Failed to install '$pkg'. Stopping script." -ForegroundColor Red
                exit 1
            } else {
                Write-Host "✅ Fixed: '$pkg' is now installed." -ForegroundColor Green
            }
        }
    }
    Write-Host ">>> [Group: $GroupName] All Verified." -ForegroundColor Cyan
}

# ==============================================================================
# 1. 初始化：下载并安装 TinyTeX 基础环境
# ==============================================================================
Write-Host ">>> [Init] Downloading TinyTeX..."
curl.exe -sL "https://yihui.org/tinytex/install-bin-windows.bat" -o install.bat

Write-Host ">>> [Init] Executing Installer..."
.\install.bat

$tinyTexBin = "$env:APPDATA\TinyTeX\bin\windows"

Write-Host ">>> [Init] Registering Path: $tinyTexBin"
echo "$tinyTexBin" | Out-File -FilePath $env:GITHUB_PATH -Encoding utf8 -Append
$env:Path = "$tinyTexBin;$env:Path"

# ==============================================================================
# 2. 定义宏包清单 (Groups Definition)
# ==============================================================================

# --- Group 1: 构建工具与核心组件 ---
# latexmk: 自动化编译神器，自动处理引用和多次编译
# tools: 包含 calc, indentfirst 等 LaTeX 核心工具箱
# oberdiek: 底层工具合集 (infwarerr, kvoptions等)，大量宏包的隐形依赖
$Group1 = @("latexmk", "tools", "oberdiek")

# --- Group 2: 中文支持 ---
# ctex: 中文排版核心框架
# xecjk: XeLaTeX 引擎下的中文字体支持
# fandol: 开源中文字体集 (解决服务器无 Windows 字体的问题)
# zhnumber: 中文数字转换 (如 "一、二、三")
# gbt7714: 符合中国国家标准 (GB/T 7714) 的参考文献样式
$Group2 = @("ctex", "xecjk", "fandol", "zhnumber", "gbt7714")

# --- Group 3: 字体与数学 (此处最易报错) ---
# tex-gyre: 基础英文字体 (修复 elegantpaper 缺少的 Heros/Termes)
# newtx: 模板默认使用的 Times 风格数学字体
# ams*: 美国数学会数学公式三剑客 (amsmath, amsfonts, amscls)
# esint: 扩展积分符号 (如闭合积分)
# iftex: 编译引擎检测工具
# mweights, fontaxes: 字体辅助工具 (newtx 依赖)
# scalefnt: 字体缩放工具 (newtx 核心依赖，此前报错源头)
# realscripts: 角标优化工具 (newtx 在 xelatex 下的隐形依赖)
$Group3 = @(
    "tex-gyre", "newtx", "amscls", "amsmath", "amsfonts", "esint", "iftex",
    "mweights", "fontaxes", "scalefnt", "realscripts"
)

# --- Group 4: 模板底层逻辑 ---
# appendix: 附录支持 (修复 File appendix.sty not found)
# abstract: 摘要定制
# hologo: TeX Logo 显示 (如 XeTeX, BibTeX 图标)
# footmisc: 脚注增强 (修复 elegantpaper 报错)
# kvoptions, etoolbox: 处理模板键值对参数和编程逻辑
# environ, trimspaces: 环境定义与空格处理
# xpatch, xkeyval, xstring: 宏包补丁与字符串处理 (newtx 强依赖)
$Group4 = @(
    "appendix", "abstract", "hologo", "footmisc", "kvoptions", "etoolbox",
    "environ", "trimspaces", "xpatch", "xkeyval", "xstring"
)

# --- Group 5: 格式与功能 ---
# biblatex, biber: 下一代参考文献管理系统
# geometry: 页面尺寸与边距设置
# graphics: 图片加载支持
# xcolor: 颜色支持
# booktabs, multirow, makecell: 专业三线表、合并行、单元格换行
# caption, subcaption: 图表标题定制与子图支持
# enumitem: 列表样式定制 (如调整列表间距)
# listings, fancyvrb: 代码块高亮与增强显示
# pgf: TikZ 绘图底层库
# siunitx: 物理单位格式化 (科研论文必备)
# cleveref: 智能交叉引用 (自动加 "图", "公式" 前缀)
# microtype: 英文排版微调 (字符间距优化)
# ms, mwe: 杂项包与测试图片资源 (修复 example-image 缺失)
# ulem: 下划线与删除线
# hyperref, url: 超链接与 URL 处理
$Group5 = @(
    "biblatex", "biber", "geometry", "graphics", "xcolor",
    "booktabs", "multirow", "makecell", "caption", "subcaption", "enumitem",
    "listings", "fancyvrb", "pgf", "siunitx", "cleveref", "microtype", "ms", "mwe",
    "ulem", "hyperref", "url"
)

# --- Group 6: 学术与论文增强 (中国高校 & 期刊必备) ---
# fancyhdr: 页眉页脚定制 (学位论文标配)
# setspace: 行距调整 (如 1.5 倍行距)
# titlesec, titletoc: 章节标题与目录样式定制
# pdfpages, pdflscape: 插入 PDF 页面 / 页面横向旋转
# algorithms...: 伪代码排版 (计算机/工程类论文必备)
# threeparttable: 带注脚的表格 (Table Notes)
# longtable, tabularx: 跨页长表格 / 自动列宽表格
# mhchem: 化学公式排版
# overpic: 图片叠字 (在图片上打标签)
# natbib: 传统期刊引用支持 (兼容旧模板)
$Group6 = @(
    "fancyhdr", "setspace", "titlesec", "titletoc",
    "pdfpages", "pdflscape",
    "algorithms", "algorithmicx", "algorithm2e",
    "threeparttable", "longtable", "tabularx",
    "mhchem", "overpic", "natbib"
)

# ==============================================================================
# 3. 执行安装流程 (依次调用函数)
# ==============================================================================
Install-And-Verify -GroupName "Build Tools"     -Packages $Group1
Install-And-Verify -GroupName "Chinese Support" -Packages $Group2
Install-And-Verify -GroupName "Fonts & Math"    -Packages $Group3
Install-And-Verify -GroupName "Template Logic"  -Packages $Group4
Install-And-Verify -GroupName "Features"        -Packages $Group5
Install-And-Verify -GroupName "Academic Extras" -Packages $Group6

# ==============================================================================
# 4. 【关键修复】强制刷新 LaTeX 数据库 (Fix File Not Found)
# ==============================================================================
Write-Host "`n>>> [System] Rebuilding Filename Database (mktexlsr)..."
# 强制让 LaTeX 重新扫描硬盘上的所有文件
cmd /c "mktexlsr"

Write-Host ">>> [System] Rebuilding Format Files (fmtutil)..."
# 重新生成格式文件，确保新字体配置生效
cmd /c "fmtutil-sys --all"

# ==============================================================================
# 5. 最终诊断
# ==============================================================================
Write-Host "`n=========================================="
Write-Host "       FINAL SYSTEM DIAGNOSTICS           "
Write-Host "=========================================="
$CriticalChecks = @("scalefnt", "newtx", "ctex", "biblatex", "latexmk")
foreach ($pkg in $CriticalChecks) {
    if (tlmgr info $pkg --only-installed) {
        Write-Host "OK: $pkg" -ForegroundColor Green
    } else {
        Write-Host "FAIL: $pkg is MISSING!" -ForegroundColor Red
        exit 1
    }
}

Write-Host "`n>>> SUCCESS: TinyTeX Environment Ready!" -ForegroundColor Green