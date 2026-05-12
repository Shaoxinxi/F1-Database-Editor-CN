@echo off
chcp 65001 >nul

echo.
echo ========================================
echo   构建调试工具
echo ========================================
echo.

echo [步骤 1/5] 检查Node.js...
echo.
where node
if errorlevel 1 (
    echo.
    echo [错误] 未找到Node.js！
    echo 请先安装Node.js: https://nodejs.org/
    echo.
    pause
    exit /b 1
)

echo.
echo Node.js版本:
node -v
echo.

echo [步骤 2/5] 检查npm...
echo.
where npm
if errorlevel 1 (
    echo.
    echo [错误] 未找到npm！
    echo.
    pause
    exit /b 1
)

echo.
echo npm版本:
npm -v
echo.

echo [步骤 3/5] 检查项目文件...
echo.
echo 当前目录: %CD%
echo.

echo 检查 package.json...
if exist "package.json" (
    echo [成功] package.json 存在
) else (
    echo [错误] 未找到package.json！
    echo.
    echo 当前目录下的文件:
    dir /b
    echo.
    pause
    exit /b 1
)

echo.
echo 检查 src 目录...
if exist "src" (
    echo [成功] src 目录存在
    echo src目录内容:
    dir src /b
) else (
    echo [错误] 未找到src目录！
    echo.
    echo 当前目录下的文件夹:
    dir /ad /b
    echo.
    pause
    exit /b 1
)

echo.
echo 检查 webpack.config.js...
if exist "webpack.config.js" (
    echo [成功] webpack.config.js 存在
) else (
    echo [警告] 未找到webpack.config.js
)

echo [成功] 项目文件完整
echo.

echo [步骤 4/5] 检查依赖包...
echo.
if not exist "node_modules" (
    echo [提示] 需要安装依赖包
    echo.
    echo 开始安装...
    echo.
    echo 执行: npm install
    echo.
    call npm install 2>>build-debug.log
    if errorlevel 1 (
        echo.
        echo [错误] 安装失败！
        echo 错误日志已保存到: build-debug.log
        echo.
        echo 最后10行错误:
        powershell -command "Get-Content build-debug.log -Tail 10"
        echo.
        pause
        exit /b 1
    )
    echo.
    echo [成功] 依赖安装完成
) else (
    echo [信息] 依赖包已存在
    echo node_modules 目录大小:
    powershell -command "$size = (Get-ChildItem node_modules -Recurse | Measure-Object -Property Length -Sum).Sum / 1MB; Write-Host ('{0:N2} MB' -f $size)"
)

echo.
echo [步骤 5/5] 开始构建...
echo.
echo 执行: npm run build
echo.

echo 构建开始时间: %date% %time% >> build-debug.log
echo. >> build-debug.log

call npm run build >> build-debug.log 2>&1

if errorlevel 1 (
    echo.
    echo [错误] 构建失败！
    echo.
    echo 完整日志已保存到: build-debug.log
    echo.
    echo ========================================
    echo 最后20行错误信息:
    echo ========================================
    powershell -command "Get-Content build-debug.log -Tail 20"
    echo.
    echo ========================================
    echo.
    echo 请查看上方的错误信息，或打开 build-debug.log 文件
    echo.
    pause
    exit /b 1
)

echo.
echo ========================================
echo   构建成功！
echo ========================================
echo.

if exist "dist" (
    echo 构建产物目录: dist
    dir dist /b
) else if exist "build" (
    echo 构建产物目录: build
    dir build /b
) else (
    echo [警告] 未找到构建产物
)

echo.
pause
