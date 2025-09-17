:: Run this file before starting the experiment.
:: This file would save the previous state and initialize a new experiment by setting a new config file.
@echo off
git add -A
for /f "tokens=2-4 delims=/ " %%a in ('date /t') do set mydate=%%c-%%a-%%b
for /f "tokens=1-2 delims=/:" %%a in ('time /t') do set mytime=%%a:%%b
git commit -m "Create Experiment date %mydate% and time %mytime%, having a fresh start"
git push

:: Create timestamp
set timestamp=%mydate%_%mytime%

:: Make a new file with path
set exp_config_file_path=./Yeast_source/matlab_files/exp_config.m

:: Create the MATLAB config_exp function
echo function [config_exp] = exp_config(imagingFolderName) > %exp_config_file_path%
echo. >> %exp_config_file_path%
echo     %% CONFIGURATION PARAMETERS >> %exp_config_file_path%
echo     config_exp = []; >> %exp_config_file_path%
echo     %% EXPERIMENT SPECIFIC PARAMETERS >> %exp_config_file_path%
echo     config_exp.timestamp = '%timestamp%'; >> %exp_config_file_path%
echo     config_exp.organism = 'organism'; >> %exp_config_file_path%
echo     config_exp.objective_type = 'objective_type'; >> %exp_config_file_path%
echo     config_exp.magnification = 'magnification'; >> %exp_config_file_path%
echo     config_exp.strains = 'strains'; >> %exp_config_file_path%
echo. >> %exp_config_file_path%
echo end >> %exp_config_file_path%

echo Config file created successfully at %exp_config_file_path%



