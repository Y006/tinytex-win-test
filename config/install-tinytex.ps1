# 文件名: install-tinytex.ps1

Write-Host ">>> [1/3] 正在下载 TinyTeX 安装脚本..."
# 使用 curl.exe 下载官方批处理安装包
curl.exe -sL "https://yihui.org/tinytex/install-bin-windows.bat" -o install.bat

Write-Host ">>> [2/3] 执行安装..."
.\install.bat

# 定义安装路径
$tinyTexBin = "$env:APPDATA\TinyTeX\bin\windows"

# --- 关键步骤 ---
# 将路径写入 $env:GITHUB_PATH，这样该脚本执行完后，
# 下一个 Step (编译步骤) 依然能找到 xelatex 命令
Write-Host ">>> 配置环境变量: $tinyTexBin"
echo "$tinyTexBin" | Out-File -FilePath $env:GITHUB_PATH -Encoding utf8 -Append

# 临时将路径加入当前会话，以便立即安装宏包
$env:Path = "$tinyTexBin;$env:Path"

Write-Host ">>> [3/3] 安装依赖宏包 (中文支持 + 绘图)..."
# 自动安装 fandol (字体), ctex (中文), beamer (PPT), pgf (TikZ)
call tlmgr install ctex xecjk beamer pgf ms gbt7714 fandol

Write-Host ">>> TinyTeX 环境准备就绪！"