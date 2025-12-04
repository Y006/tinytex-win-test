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
    # 使用 cmd /c 运行以捕获可能的崩溃
    cmd /c "tlmgr install $pkgString"

    # 2. 逐个验证 (安全性高，专门对付网络崩溃漏装)
    foreach ($pkg in $Packages) {
        # 检查包是否已在安装列表中
        $check = tlmgr info $pkg --only-installed
        
        if (-not $check) {
            Write-Host "⚠️ Warning: '$pkg' missing after batch install. Retrying..." -ForegroundColor Yellow
            
            # 单独重试安装 (网络波动的克星)
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
    Write-Host ">>> [Group: $GroupName] Verified." -ForegroundColor Cyan
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

# 更新 tlmgr 自身 (防止版本过旧)
cmd /c "tlmgr update --self"

# ==============================================================================
# 2. 定义宏包清单 (Groups Definition)
# ==============================================================================

$Group1 = @("latexmk", "tools", "oberdiek")

$Group2 = @("ctex", "xecjk", "fandol", "zhnumber", "gbt7714")

# Group 3: 字体与数学 (此处最易因网络超时而崩溃)
# scalefnt 必须在这里被严密监控
$Group3 = @(
    "tex-gyre", "newtx", "amscls", "amsmath", "amsfonts", "esint", "iftex",
    "mweights", "fontaxes", "scalefnt", "realscripts"
)

$Group4 = @(
    "appendix", "abstract", "hologo", "footmisc", "kvoptions", "etoolbox",
    "environ", "trimspaces", "xpatch", "xkeyval", "xstring"
)

$Group5 = @(
    "biblatex", "biber", "geometry", "graphics", "xcolor",
    "booktabs", "multirow", "makecell", "caption", "subcaption", "enumitem",
    "listings", "fancyvrb", "pgf", "siunitx", "cleveref", "microtype", "ms", "mwe",
    "ulem", "hyperref", "url"
)

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
# 4. 【关键修复】强制刷新 LaTeX 文件数据库
#    确保物理存在的文件的索引被 texhash 记录，否则编译器找不到
# ==============================================================================
Write-Host "`n>>> [System] Rebuilding Filename Database (mktexlsr)..."
cmd /c "mktexlsr"

Write-Host ">>> [System] Rebuilding Format Files (fmtutil)..."
cmd /c "fmtutil-sys --all"

# ==============================================================================
# 5. 最终自我诊断报告
# ==============================================================================
Write-Host "`n=========================================="
Write-Host "       FINAL SYSTEM DIAGNOSTICS           "
Write-Host "=========================================="

# 再次检查 scalefnt，确保它这次一定在
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