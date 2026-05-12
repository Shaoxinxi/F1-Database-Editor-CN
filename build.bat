@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: 启用错误日志
echo. > build-error.log

:: ========================================
:: F1 Database Editor 中文汉化版 - 构建脚本
:: 作者: ModFans团队
:: 用途: 自动构建项目用于部署
:: ========================================

echo.
echo ========================================
echo   F1 Database Editor 构建脚本
echo   ModFans Team
echo ========================================
echo.

:: 检查Node.js是否安装
echo [检查] 正在检查Node.js环境...
where node >nul 2>&1
if errorlevel 1 (
    echo.
    echo [错误] 未检测到Node.js！
    echo.
    echo 请先安装Node.js:
    echo 1. 访问 https://nodejs.org/
    echo 2. 下载并安装LTS版本
    echo 3. 重新运行此脚本
    echo.
    echo 按任意键退出...
    pause >nul
    exit /b 1
)

:: 显示Node.js和npm版本
echo [信息] Node.js版本:
node -v
echo [信息] npm版本:
npm -v
echo.

:: 检查package.json是否存在
echo [检查] 正在检查项目文件...
if not exist "package.json" (
    echo [错误] 未找到package.json文件！
    echo 请确保在正确的项目目录中运行此脚本
    echo.
    pause
    exit /b 1
)

if not exist "src" (
    echo [错误] 未找到src目录！
    echo 项目文件不完整
    echo.
    pause
    exit /b 1
)

echo [成功] 项目文件检查通过
echo.

:: 检查node_modules是否存在
if not exist "node_modules" (
    echo [提示] 未检测到依赖包，准备安装...
    echo.
    goto install_deps
)

:: 检查是否需要重新安装依赖
echo [检查] 检查依赖包状态...
if exist "node_modules\.package-lock.json" (
    echo [信息] 依赖包已存在
    echo.
    choice /C YN /M "是否重新安装依赖？建议选N"
    if errorlevel 2 goto skip_install
    if errorlevel 1 goto install_deps
) else (
    goto install_deps
)

:skip_install
echo.
echo [跳过] 使用现有依赖包
goto build_project

:install_deps
echo.
echo ========================================
echo   步骤 1/3: 安装依赖包
echo ========================================
echo.
echo [执行] npm install...
echo.
call npm install

if errorlevel 1 (
    echo.
    echo [错误] 依赖包安装失败！
    echo 请检查网络连接或手动运行: npm install
    echo.
    pause
    exit /b 1
)

echo.
echo [成功] 依赖包安装完成
echo.

:build_project
echo ========================================
echo   步骤 2/3: 构建项目
echo ========================================
echo.

:: 检查是否有build脚本
findstr /C:"\"build\"" package.json >nul 2>&1
if errorlevel 1 (
    echo [错误] package.json中未找到build脚本！
    echo 请检查package.json配置
    echo.
    pause
    exit /b 1
)

echo [执行] npm run build...
echo.
call npm run build

if errorlevel 1 (
    echo.
    echo [错误] 项目构建失败！
    echo 请检查错误信息或手动运行: npm run build
    echo.
    pause
    exit /b 1
)

echo.
echo [成功] 项目构建完成
echo.

:: 检查构建产物
echo [检查] 检查构建产物...
set BUILD_DIR=
if exist "dist" (
    set BUILD_DIR=dist
) else if exist "build" (
    set BUILD_DIR=build
) else (
    echo [警告] 未找到常见的构建产物目录(dist或build)
    echo 请手动检查构建结果
    echo.
    pause
    exit /b 1
)

echo [成功] 构建产物目录: %BUILD_DIR%
echo.

:: 显示构建产物信息
echo ========================================
echo   步骤 3/3: 构建报告
echo ========================================
echo.

echo [信息] 构建产物统计:
echo   目录: %CD%\%BUILD_DIR%
echo.

:: 统计文件数量
set FILE_COUNT=0
for /r "%BUILD_DIR%" %%f in (*) do (
    set /a FILE_COUNT+=1
)
echo   文件总数: %FILE_COUNT%

:: 显示目录结构
echo.
echo [信息] 目录结构:
dir "%BUILD_DIR%" /b
echo.

:: 计算目录大小（近似）
echo [信息] 目录大小:
for /f "tokens=*" %%a in ('powershell -command "(Get-ChildItem '%BUILD_DIR%' -Recurse | Measure-Object -Property Length -Sum).Sum / 1MB"') do (
    echo   约: %%a MB
)

echo.
echo ========================================
echo   构建完成！
echo ========================================
echo.
echo 构建产物位置: %CD%\%BUILD_DIR%
echo.
echo 下一步操作:
echo 1. 将 %BUILD_DIR% 目录中的所有文件上传到服务器
echo 2. 服务器路径: /www/wwwroot/www.modfans.cc/f1-editor/
echo 3. 使用宝塔面板或FTP工具上传
echo.
echo 提示:
echo - 可以使用 deploy.bat 脚本自动部署
echo - 上传时请上传 %BUILD_DIR% 内的文件，不是整个目录
echo.

:: 询问是否打开构建产物目录
choice /C YN /M "是否打开构建产物目录？"
if errorlevel 2 goto end
if errorlevel 1 (
    explorer "%BUILD_DIR%"
    echo.
    echo [信息] 已打开构建产物目录
)

:end
echo.
echo ========================================
echo   感谢使用 ModFans 构建工具
echo ========================================
echo.
pause
