@echo off
chcp 65001 >nul
cd /d "%~dp0"
echo.
echo ==================================================
echo   PODA JURISTAM  -  139 articulos fuera
echo ==================================================
echo.
git rev-parse --git-dir >nul 2>&1
if errorlevel 1 (
  echo ERROR: este .bat tiene que estar DENTRO de la carpeta juristam-web.
  pause
  exit /b 1
)
if not exist "poda-juristam.patch" (
  echo ERROR: falta poda-juristam.patch en esta misma carpeta.
  pause
  exit /b 1
)
echo Creando la rama claude/poda...
git checkout -b claude/poda 2>nul
if errorlevel 1 git checkout claude/poda
echo.
echo Comprobando el parche...
git apply --check poda-juristam.patch
if errorlevel 1 (
  echo.
  echo ERROR: el parche no aplica. Probablemente tienes cambios sin guardar.
  echo Haz commit o descartalos y vuelve a intentar.
  pause
  exit /b 1
)
git apply poda-juristam.patch
echo.
echo ==================================================
echo   LISTO
echo ==================================================
echo.
echo Estas en la rama claude/poda con los cambios aplicados.
echo Nada se subio a GitHub todavia.
echo.
echo Revisa el diff en VS Code. Si te convence:
echo     git add -A
echo     git commit -m "Poda: 139 articulos sin valor comercial"
echo     git checkout main
echo     git merge claude/poda
echo     git push
echo.
echo Si NO te convence:  git checkout main
echo.
pause
