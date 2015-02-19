::
:: profile.bat
:: Restore and backup Firefox OS profile.
:: Usage: profile.bat <backup|restore> [backup_name]
::
:: https://github.com/kosmodrey/firefoxos-profile-bat
::

@echo off

cls

setlocal EnableExtensions

set BackupTime=%time%
set BackupDate=%date%
set BackupRoot=%~dp0
set BackupPath=%BackupRoot%backup
for /F "tokens=1-4 delims=./ " %%A in ('date/t') do (
  set DateDay=%%A
  set DateMonth=%%B
  set DateYear=%%C
)
for /F "tokens=1-4 delims=/ " %%D in ('time/t') do set DateTime=%%D
set BackupDate=%DateDay%-%DateMonth%-%DateYear%_%time:~0,2%-%time:~3,2%-%time:~6,2%
set BackupProfileFolder=%BackupDate%
set BackupLog=backup-log.txt
set BackupRestoreLog=restore-log.txt

set arg_do=%1
set arg_backup=%2

set run_adb=adb

if "%arg_do%"=="backup" goto DO_BACKUP
if "%arg_do%"=="restore" goto DO_RESTORE
echo Invalid arguments. & goto DO_INFO
goto:eof

:DO_INFO

	echo.Usage: profile.bat ^<backup^|restore^> [backup_name]
	exit /b

:goto:eof

:DO_BACKUP

	echo Backup profile...

	if not exist "%BackupPath%" mkdir %BackupPath%
	cd %BackupPath%

	if not "%arg_backup%"=="" set BackupProfileFolder=%arg_backup%

	echo Creating "%BackupProfileFolder%" backup...
	mkdir %BackupProfileFolder%
	cd %BackupProfileFolder%

	echo.
	call %run_adb% devices

	echo + Stop b2g...
	call %run_adb% shell stop b2g >> %BackupLog% 2>&1

	echo + Backup Wi-Fi config...
	call %run_adb% pull /data/misc/wifi/wpa_supplicant.conf ./wifi/wpa_supplicant.conf >> %BackupLog% 2>&1

	echo + Backup user profile folder...
	mkdir profile
	call %run_adb% pull /data/b2g/mozilla ./profile >> %BackupLog% 2>&1

	echo + Backup user local data...
	mkdir local
	call %run_adb% pull /data/local ./local >> %BackupLog% 2>&1

	echo + Start b2g...
	call %run_adb% shell start b2g >> %BackupLog% 2>&1

	echo + Backup done!
	echo.
	echo Check %BackupPath%\%BackupProfileFolder%\%BackupLog% for details.

goto:eof

:DO_RESTORE

	echo Restore profile...

	if "%arg_backup%"=="" echo ! Missing backup name argument. & goto DO_INFO
	if not exist "%BackupPath%\%arg_backup%" echo ! Backup folder "%BackupPath%\%arg_backup%" does't exist. & echo.Abort. & exit /b
	if not exist "%BackupPath%\%arg_backup%\wifi" echo ! Missing "%BackupPath%\%arg_backup%\wifi" folder. & echo.Abort. & exit /b
	if not exist "%BackupPath%\%arg_backup%\local" echo ! Missing "%BackupPath%\%arg_backup%\local" folder. & echo.Abort. & exit /b
	if not exist "%BackupPath%\%arg_backup%\profile" echo ! Missing "%BackupPath%\%arg_backup%\profile" folder. & echo.Abort. & exit /b

	cd %BackupPath%\%arg_backup%

	set /p confirm=Do you really want restore "%arg_backup%" backup? ^(Y/N^) 
	if not %confirm%==Y echo ! Operation canceled by user. & exit /b

	echo.
	call %run_adb% devices

	echo + Stop b2g...
	call %run_adb% shell stop b2g >> %BackupRestoreLog% 2>&1

	echo + Remove old user profile...
	call %run_adb% shell rm -r /data/b2g/mozilla >> %BackupRestoreLog% 2>&1

	echo + Restore Wi-Fi config...
	call %run_adb% push ./wifi /data/misc/wifi >> %BackupRestoreLog% 2>&1
	call %run_adb% shell chown wifi.wifi /data/misc/wifi/wpa_supplicant.conf >> %BackupRestoreLog% 2>&1

	echo + Restore user profile...
	call %run_adb% push ./profile /data/b2g/mozilla >> %BackupRestoreLog% 2>&1

	echo + Restore user local data...
	call %run_adb% push ./local /data/local >> %BackupRestoreLog% 2>&1

	echo + Start b2g...
	call %run_adb% shell start b2g >> %BackupRestoreLog% 2>&1

	echo + Restore done!
	echo.
	echo Check %BackupPath%\%BackupProfileFolder%\%BackupRestoreLog% for details.

goto:eof