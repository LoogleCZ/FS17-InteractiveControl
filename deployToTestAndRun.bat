@echo off

setlocal EnableDelayedExpansion

set testFile=.\files.txt
set game=C:\Program Files (x86)\Farming Simulator 2017\FarmingSimulator2017.exe

set files=

for /f ^"usebackq^ eol^=^

^ delims^=^" %%a in (%testFile%) do (
	set line=%%a
	if "!line:~0,6!"=="COPY: " (
		set files=!line:~6!
	) else (
		if not "!files!"=="" (
			xcopy "!files!" "%%a" /Y
		)
	)
)

"%game%"
