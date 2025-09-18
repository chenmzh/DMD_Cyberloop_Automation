:: Run this file before starting the experiment.
:: This file would save the previous state and initialize a new experiment by setting a new config file.
@echo off
git add -A
for /f "tokens=2-4 delims=/ " %%a in ('date /t') do set mydate=%%c%%a%%b
for /f %%a in ('powershell -command "Get-Date -Format 'HHmmss'"') do set mytime=%%a
git commit -m "Create Experiment date %mydate% and time %mytime%, having a fresh start"
git push


:: Create timestamp
set time_date=%mydate%
set time_hour=%mytime%

:: Debug output
echo ========== DEBUG INFO ==========
echo time_date = [%time_date%]
echo time_hour = [%time_hour%]
echo mydate = [%mydate%]
echo mytime = [%mytime%]
echo ================================

:: Update existing config file with new timestamp
set exp_config_file_path=.\Yeast_source\matlab_files\exp_config.m

:: Create directory if it doesn't exist
if not exist ".\Yeast_source\matlab_files\" mkdir ".\Yeast_source\matlab_files\"

:: Check if config file exists, if not create it with full structure
if not exist "%exp_config_file_path%" (
    echo Creating new config file...
    (
        echo function [config_exp] = exp_config(imagingFolderName^)
        echo.
        echo     %%%% CONFIGURATION PARAMETERS
        echo     config_exp = [];
        echo     %%%% EXPERIMENT SPECIFIC PARAMETERS
        echo     config_exp.experiment_name = 'Yeast_Git_testcase';
        echo     config_exp.time_date = '%time_date%';
        echo     config_exp.time_hour = '%time_hour%';
        echo     config_exp.organism = 'Yeast';
        echo     config_exp.objective_type = '40x_oil';
        echo     config_exp.magnification = '40x*1.5=60x';
        echo     config_exp.strains = 'strains';
        echo     config_exp.initial_delay = 60*20; %%%% In seconds
        echo     config_exp.experiment_pattern_times = [20, 20, 20, 20, 20] * 60 ;
        echo     config_exp.experiment_pattern_values = [0, 1, 0, 1, 0];
        echo     config_exp.Period = 120;
        echo     config_exp.intensity = 17.3;
        echo     config_exp.light_normalization = 69.2;
        echo     config_exp.imaging.types = {'brightfield','Cy3'};
        echo     config_exp.imaging.groups = {'Channels','Trigger'};
        echo     config_exp.imaging.exposure = {10, 2000};
        echo     config_exp.imaging.zOffsets = {[0,-0.5,+0.5], [0]};
        echo     config_exp.imaging.condenser = {5, 5};
        echo     config_exp.imaging.message = [''];
        echo end
    ) > "%exp_config_file_path%"
    echo New config file created at %exp_config_file_path%
) else (
    echo Updating existing config file...
    
    :: Show current content before update
    echo BEFORE UPDATE - Current time lines:
    findstr "time_date\|time_hour" "%exp_config_file_path%"
    
    :: Method 1: Try PowerShell with more flexible regex
    echo Attempting PowerShell update method 1...
    powershell -command "try { $content = Get-Content '%exp_config_file_path%'; $content = $content -replace 'config_exp\.time_date\s*=\s*''.*''\s*;', 'config_exp.time_date = ''%time_date%'';'; $content = $content -replace 'config_exp\.time_hour\s*=\s*''.*''\s*;', 'config_exp.time_hour = ''%time_hour%'';'; Set-Content '%exp_config_file_path%' $content; Write-Host 'PowerShell method 1 completed' } catch { Write-Host 'PowerShell method 1 failed: ' + $_.Exception.Message; exit 1 }"
    
    if errorlevel 1 (
        echo PowerShell method 1 failed, trying method 2...
        :: Method 2: Pure batch replacement
        echo Creating backup...
        copy "%exp_config_file_path%" "%exp_config_file_path%.backup" >nul
        
        :: Create new file with updated values
        (
            for /f "delims=" %%i in ('type "%exp_config_file_path%.backup"') do (
                set "line=%%i"
                setlocal enabledelayedexpansion
                echo !line! | findstr /C:"config_exp.time_date" >nul
                if !errorlevel! equ 0 (
                    echo     config_exp.time_date = '%time_date%';
                ) else (
                    echo !line! | findstr /C:"config_exp.time_hour" >nul
                    if !errorlevel! equ 0 (
                        echo     config_exp.time_hour = '%time_hour%';
                    ) else (
                        echo !line!
                    )
                )
                endlocal
            )
        ) > "%exp_config_file_path%"
        
        del "%exp_config_file_path%.backup" 2>nul
        echo Batch method completed
    )
    
    :: Show content after update
    echo AFTER UPDATE - New time lines:
    findstr "time_date\|time_hour" "%exp_config_file_path%"
    echo Updated timestamp in existing config file at %exp_config_file_path%
)

set /p "id=All done, press enter to continue: "