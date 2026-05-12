@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: ========================================
:: F1 Database Editor - 部署脚本
:: 作者: ModFans团队
:: 用途: 自动上传构建产物到服务器
:: ========================================

echo.
echo ========================================
echo   F1 Database Editor 部署脚本
echo   ModFans Team
echo ========================================
echo.

:: 配置区域（请根据实际情况修改）
set SERVER_IP=你的服务器IP
set SERVER_USER=root
set SERVER_PATH=/www/wwwroot/www.modfans.cc/f1-editor

:: 检查配置文件
if exist "deploy-config.txt" (
    echo [信息] 检测到配置文件，读取配置...
    for /f "tokens=1,2 delims==" %%a in (deploy-config.txt) do (
        if "%%a"=="SERVER_IP" set SERVER_IP=%%b
        if "%%a"=="SERVER_USER" set SERVER_USER=%%b
        if "%%a"=="SERVER_PATH" set SERVER_PATH=%%b
    )
    echo [成功] 配置加载完成
    echo.
) else (
    echo [提示] 未找到deploy-config.txt配置文件
    echo [提示] 将使用默认配置或手动输入
    echo.
)

:: 检查构建产物是否存在
set BUILD_DIR=
if exist "dist" (
    set BUILD_DIR=dist
) else if exist "build" (
    set BUILD_DIR=build
) else (
    echo [错误] 未找到构建产物目录！
    echo 请先运行 build.bat 进行构建
    echo.
    pause
    exit /b 1
)

echo [信息] 检测到构建产物目录: %BUILD_DIR%
echo.

:: 显示当前配置
echo ========================================
echo   部署配置
echo ========================================
echo   服务器IP: %SERVER_IP%
echo   用户名: %SERVER_USER%
echo   部署路径: %SERVER_PATH%
echo   本地目录: %BUILD_DIR%
echo ========================================
echo.

:: 询问是否继续
if "%SERVER_IP%"=="你的服务器IP" (
    echo [警告] 请先修改deploy-config.txt配置文件或手动输入服务器信息
    echo.
    choice /C YN /M "是否继续并手动输入服务器信息？"
    if errorlevel 2 exit /b 1
    
    echo.
    set /p SERVER_IP=请输入服务器IP: 
    set /p SERVER_USER=请输入用户名(默认root): 
    if "!SERVER_USER!"=="" set SERVER_USER=root
    set /p SERVER_PATH=请输入部署路径(默认/www/wwwroot/www.modfans.cc/f1-editor): 
    if "!SERVER_PATH!"=="" set SERVER_PATH=/www/wwwroot/www.modfans.cc/f1-editor
    echo.
) else (
    choice /C YN /M "是否确认部署？"
    if errorlevel 2 exit /b 1
    echo.
)

:: 检查SSH工具
echo [检查] 检查SSH工具...
where scp >nul 2>&1
if errorlevel 1 (
    echo [错误] 未找到scp命令！
    echo 请确保已安装OpenSSH客户端
    echo.
    echo Windows 10/11 安装方法:
    echo 设置 → 应用 → 可选功能 → 添加功能 → OpenSSH客户端
    echo.
    pause
    exit /b 1
)

echo [成功] SSH工具已就绪
echo.

:: 备份服务器文件
echo ========================================
echo   步骤 1/3: 备份服务器文件
echo ========================================
echo.
echo [执行] 正在备份服务器现有文件...
echo.

ssh %SERVER_USER%@%SERVER_IP% "if [ -d '%SERVER_PATH%' ]; then cp -r %SERVER_PATH% %SERVER_PATH%.backup.%date:~0,4%%date:~5,2%%date:~8,2%; echo 备份完成; else echo 无现有文件需要备份; fi"

if errorlevel 1 (
    echo [警告] 备份失败，但将继续部署...
    echo.
) else (
    echo [成功] 备份完成
    echo.
)

:: 上传文件
echo ========================================
echo   步骤 2/3: 上传文件到服务器
echo ========================================
echo.
echo [执行] 正在上传构建产物...
echo [提示] 这可能需要几分钟，请耐心等待...
echo.

:: 使用scp上传
scp -r %BUILD_DIR%\* %SERVER_USER%@%SERVER_IP%:%SERVER_PATH%/

if errorlevel 1 (
    echo.
    echo [错误] 文件上传失败！
    echo 请检查:
    echo 1. 服务器IP是否正确
    echo 2. SSH连接是否正常
    echo 3. 部署路径是否存在
    echo 4. 是否有写入权限
    echo.
    pause
    exit /b 1
)

echo.
echo [成功] 文件上传完成
echo.

:: 验证部署
echo ========================================
echo   步骤 3/3: 验证部署
echo ========================================
echo.
echo [执行] 正在验证服务器文件...
echo.

ssh %SERVER_USER%@%SERVER_IP% "echo 服务器文件统计:; ls -lh %SERVER_PATH% | head -20; echo.; echo 文件总数:; ls -lR %SERVER_PATH% | grep -c '^-' "

if errorlevel 1 (
    echo [警告] 验证失败，请手动检查服务器
    echo.
) else (
    echo.
    echo [成功] 部署验证完成
    echo.
)

:: 显示部署结果
echo ========================================
echo   部署完成！
echo ========================================
echo.
echo 部署信息:
echo   服务器: %SERVER_IP%
echo   路径: %SERVER_PATH%
echo   时间: %date% %time%
echo.
echo 访问地址:
echo   HTTP:  http://%SERVER_IP%/
echo   HTTPS: https://www.modfans.cc/f1-editor/
echo.
echo 建议操作:
echo 1. 在浏览器中访问上述地址测试
echo 2. 检查控制台是否有错误
echo 3. 测试存档编辑功能
echo 4. 如有问题，可从备份恢复: %SERVER_PATH%.backup.*
echo.

:: 保存配置到文件
choice /C YN /M "是否保存当前配置到deploy-config.txt？"
if errorlevel 1 (
    (
        echo SERVER_IP=%SERVER_IP%
        echo SERVER_USER=%SERVER_USER%
        echo SERVER_PATH=%SERVER_PATH%
    ) > deploy-config.txt
    echo [成功] 配置已保存到 deploy-config.txt
    echo.
)

:: 询问是否打开浏览器
choice /C YN /M "是否在浏览器中打开测试？"
if errorlevel 1 (
    start https://www.modfans.cc/f1-editor/
    echo [信息] 已打开浏览器
    echo.
)

echo ========================================
echo   感谢使用 ModFans 部署工具
echo ========================================
echo.
pause
