@echo off
chcp 65001 >nul
cd /d C:\АРАГ\platinum-house-master
set GIT_TERMINAL_PROMPT=0

echo === git status (чисто? есть ли наши дизайн-правки ^= незакоммичено) ===
git status --short

echo.
echo === 1) есть ли незакоммиченные правки css — если да, коммитим ===
git add -A
git commit -m "Дизайн: премиальный люкс (золото, неон-рамка галереи, лайтбокс без обрезки, navbar с blur)" >nul 2>&1

echo.
echo === 2) push с ретраями (сеть у вас рвётся) ===
set /a n=0
:retry
set /a n+=1
git push origin master 2>push_err.txt
set RC=%ERRORLEVEL%
type push_err.txt
if %RC%==0 goto ok
if %n% geq 7 goto fail
echo   ... сеть: повтор push №%n%
timeout /t 18 /nobreak >nul
goto retry
:ok
echo.
echo >>> PUSH OK: дизайн-коммит уехал на GitHub
goto verify
:fail
echo.
echo !!! Push не прошёл за 7 попыток — ниже ошибка из буфера
goto done
:verify
echo.
echo === 3) живые проверки (Pages пересобирает ~1 мин) ===
set BASE=https://ramazan2005555-ai.github.io/platinum-house
for /l %%i in (1,1,6) do (
  call :check %%i
  timeout /t 12 /nobreak >nul
)
goto done
:check
for %%f in (img/menu/main-menu.jpeg img/menu/breakfasts.jpeg img/menu/mangal.jpeg img/menu/bar-card.jpeg) do (
  for /f %%c in ('curl -s -o NUL -w "%%{http_code}" --connect-timeout 15 "%BASE%/%%f"') do (
    if "%%c"=="200" (echo   %~1) [%%f]=200 OK) else (echo   %~1) [%%f]=%%c WAIT)
  )
)
exit /b
:done
echo.
echo === 4) финально: QR/URL ===
curl -s --connect-timeout 15 "%BASE%/index.html" | findstr /i "og:url base href" 
echo.
echo ** ГОТОВО: если всё выше с [200 OK] — сайт и QR работают **
