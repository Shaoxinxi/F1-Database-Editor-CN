@echo off
chcp 65001 >nul
echo.
echo ========================================
echo   一键诊断工具
echo ========================================
echo.

echo 正在诊断项目环境...
echo.

echo [1] 当前目录:
cd
echo.

echo [2] 检查Node.js:
where node
node -v
echo.

echo [3] 检查npm:
where npm
npm -v
echo.

echo [4] 检查项目文件:
if exist "package.json" (
    echo [OK] package.json 存在
) else (
    echo [错误] 找不到 package.json！
)

if exist "src" (
    echo [OK] src 目录存在
) else (
    echo [错误] 找不到 src 目录！
)

if exist "webpack.config.js" (
    echo [OK] webpack.config.js 存在
) else (
    echo [警告] 找不到 webpack.config.js
)
echo.

echo [5] package.json中的build脚本:
findstr "build" package.json
echo.

echo [6] 检查node_modules:
if exist "node_modules" (
    echo [OK] node_modules 存在
) else (
    echo [提示] node_modules 不存在，需要安装
)
echo.

echo ========================================
echo 诊断完成
echo ========================================
echo.
echo 如果看到[错误]，请检查是否在正确的项目目录
echo.
pause
