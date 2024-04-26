::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Name:         cpdiff.bat
:: Author:	 Qiyang Geng
:: Created:	 2024/04/24
:: Last edited:	 2024/04/26
:: Usage: 	 <dir1> <dir2> [<output>] [<filter>] [flags]
:: Description:  copies files that are in dir2 but not dir1 into a folder
::			           /o	- output
:: 			           /s   - copies symmetrical difference
::			           /f   - flatten output
:: 			           /c   - clear output folder if exists
::			           /w   - overwrites if outputs exists
::			           /-w  - do not overwrite, overshadows /w flag
::		 when used without any parameters in a folder with exactly 2 folders
::		 excluding the default output folder, will copy the symmetric 
::		 difference of the two files, while clearing the output
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: overwrite     noOverwrite    behavior
:: true		 true		no overwrite without prompt
:: true		 false		overwrite without prompt
:: false	 true		no overwrite without prompt
:: false	 false		prompt

:: if noOverwrite is true, overwrite is overwritten to be false



@echo off
setlocal
setlocal EnableDelayedExpansion

set "defaultOutput=output"

:: TODO maybe add flatten input as well
set "symmetric=false"
set "flatten=false"
set "clearFolder=false"
set "overwrite=false"
set "noOverwrite=false"

set "dir1="
set "dir2="
set "out=%defaultOutput%"

set "self=%~nx0"



:: idk if there's a better way than a double shift flag, shifting inside doesn't work
:loop
	set "doubleShift=false"
	if "%1"=="/s" (
		set "symmetric=true"
	) else if "%1"=="/f" (
		set "flatten=true"
	) else if "%1"=="/c" (
		set "clearFolder=true"
	) else if "%1"=="/w" (
		set "overwrite=true"
	) else if "%1"=="/-w" (
		set "noOverwrite=true"
	) else if "%1"=="/o" (
		if "%2"=="" (
			echo "Could not find output name"
		) else (
			set "out=%2"
		)
		set "doubleShift=true"
	) else if "!dir1!"=="" (
		set "dir1=%~dpnx1"
	) else if "!dir2!"=="" (
		set "dir2=%~dpnx1"
	)
	
	if "%doubleShift%"=="true" (
		shift
		shift
	) else (
		shift
	)
if not "%1"=="" (goto loop)

if "%dir1%"=="" (
	set /a "count=0"
	set /a "hasOutput=0"

	for /d %%d in (*) do (
		if "%%d"=="%defaultOutput%" (
			set /a "hasOutput=1"
		) else if "!d1!"=="" (
			set "d1=%%d"
		) else if "!d2!"=="" (
			set "d2=%%d"
		)

		set /a "count=!count!+1"
	)

	set /a "comp=!count!-!hasOutput!"

	if !comp! equ 2 (
		call "%self%" !d1! !d2! /s /f /c
		exit
	)
)

if "%dir2%"=="" (
	echo "At least two directories needs to be supplied"
	exit
)

if not exist "%dir1%" (
	echo "Directory %dir1% does not exist"
	exit
)

if not exist "%dir2%" (
	echo "Directory %dir2% does not exist"
	exit
)



if exist "%out%" (
	if "%clearFolder%"=="true" (
		rd /s /q "%out%"
		md "%out%"
	)
) else (
	md "%out%"
)

if "%noOverwrite%"=="true" (set "overwrite=false")



:search
for /r "%dir2%" %%f in (*.*) do (
	set "full=%%f"
	set "rel=!full:%dir2%=!"

	If not exist "%dir1%!rel!" (
		echo Diff: !rel!
		if "%flatten%"=="true" (set "dest=%out%\") else (set "dest=%out%\!rel!*")

		if "%overwrite%"=="true" (
			xcopy /q /y "%%f" "!dest!" > nul
		) else if not exist "!dest!%%~nxf" (
			xcopy /q "%%f" "!dest!" > nul
		) else if "%noOverwrite%"=="false" (
			xcopy /q "%%f" "!dest!"
		)
	)
)

if "%symmetric%" == "true" (
	set "td=%dir1%"
	set "dir1=%dir2%"
	set "dir2=!td!"

	set "symmetric=false"

	goto search
)
