@echo off
rem Double-clic pour envoyer ton travail sur GitHub.
rem
rem La fenetre reste ouverte a la fin, quoi qu il arrive : sans pause, le
rem message qui dit quoi faire disparait avant d avoir pu etre lu. C est
rem exactement ce qui manquait le 02/09/2026, quand le seul chemin protege
rem etait MISE_A_JOUR.bat et que livrer.ps1 lance seul se refermait sur son
rem propre diagnostic.
title Breaking Bad Game - livrer
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0livrer.ps1" %*
echo.
pause
