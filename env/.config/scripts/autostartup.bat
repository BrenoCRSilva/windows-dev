@echo off
powershell.exe -WindowStyle Hidden -ExecutionPolicy Bypass -Command ^
"try { ^
    [System.Diagnostics.Process]::GetCurrentProcess().PriorityClass = [System.Diagnostics.ProcessPriorityClass]::High; ^
    Start-Process 'komorebi.exe' -WindowStyle Hidden -Priority High; ^
    if (!(Get-Process whkd -ErrorAction SilentlyContinue)) { ^
        Start-Process whkd -WindowStyle Hidden -Priority High ^
    }; ^
    Get-Process komorebi -ErrorAction SilentlyContinue | ForEach-Object { $_.PriorityClass = 'High' }; ^
    Get-Process whkd -ErrorAction SilentlyContinue | ForEach-Object { $_.PriorityClass = 'High' }; ^
} catch { ^
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'; ^
    $errorMessage = $_.Exception.Message; ^
    Add-Content -Path '$env:TEMP\komorebi_startup.log' -Value '$timestamp - Error starting Komorebi: $errorMessage' ^
}"

echo %date% %time% - Komorebi startup script completed >> "%TEMP%\komorebi_startup.log"