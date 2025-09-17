:: Run this file before starting the experiment.
:: This file would save the previous state and initialize a new experiment by setting a new config file.
@echo off
git add -A
for /f "tokens=2-4 delims=/ " %%a in ('date /t') do set mydate=%%c%%a%%b
:: for /f "tokens=1-3 delims=:.," %%a in ('time /t') do set mytime=%%a%%b%%c
for /f %%a in ('powershell -command "Get-Date -Format 'HHmmss'"') do set mytime=%%a
git commit -m "Create Experiment date %mydate% and time %mytime%, having a fresh start"
git push

:: Create timestamp
set time_date=%mydate%
set time_hour=%mytime%

:: Update existing config file with new timestamp
set exp_config_file_path=.\Yeast_source\matlab_files\exp_config.m

:: Check if config file exists, if not create it with basic structure
if not exist "%exp_config_file_path%" (
    echo function [config_exp] = exp_config(imagingFolderName) > %exp_config_file_path%
    echo. >> %exp_config_file_path%
    echo     %% CONFIGURATION PARAMETERS >> %exp_config_file_path%
    echo     config_exp = []; >> %exp_config_file_path%
    echo     %% EXPERIMENT SPECIFIC PARAMETERS >> %exp_config_file_path%
    echo     config_exp.time_date = '%time_date%'; >> %exp_config_file_path%
    echo     config_exp.time_hour = '%time_hour%'; >> %exp_config_file_path%
    echo     config_exp.organism = 'organism'; >> %exp_config_file_path%
    echo     config_exp.objective_type = 'objective_type'; >> %exp_config_file_path%
    echo     config_exp.magnification = 'magnification'; >> %exp_config_file_path%
    echo     config_exp.strains = 'strains'; >> %exp_config_file_path%
    echo. >> %exp_config_file_path%
    echo end >> %exp_config_file_path%
    echo New config file created at %exp_config_file_path%
) else (
    :: Update only time_date and time_hour lines in existing file
    powershell -command "(Get-Content '%exp_config_file_path%') -replace 'config_exp\.time_date = ''.*'';', 'config_exp.time_date = ''%time_date%'';' | Set-Content '%exp_config_file_path%'"
    powershell -command "(Get-Content '%exp_config_file_path%') -replace 'config_exp\.time_hour = ''.*'';', 'config_exp.time_hour = ''%time_hour%'';' | Set-Content '%exp_config_file_path%'"
    echo Updated timestamp in existing config file at %exp_config_file_path%
)



