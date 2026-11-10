@echo off
:: ============================================================================
:: PROJETO: WinHelpDesk-Toolkit
:: ARQUIVO: WinHelpDesk.bat
:: DESCRICAO: Kit All-in-One de Suporte Tecnico e Help Desk para Windows
:: AUTOR: Equipe de TI / Suporte
:: LICENCA: MIT
:: ============================================================================

setlocal EnableExtensions
chcp 65001 >nul
title WinHelpDesk Toolkit - Central de Suporte e Diagnostico
color 1F

:: ----------------------------------------------------------------------------
:: Verificacao e Auto-Elevacao para Administrador
:: ----------------------------------------------------------------------------
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo.
    echo ===============================================================================
    echo  [AVISO] Privilegios de Administrador necessarios para tarefas de Help Desk.
    echo  Solicitando confirmacao de Administrador [UAC]...
    echo ===============================================================================
    powershell -NoProfile -Command "Start-Process cmd.exe -ArgumentList '/k `\"%~f0`\"' -Verb RunAs" 2>nul
    if %errorLevel% neq 0 (
        echo.
        echo [ERRO] Nao foi possivel obter privilegios de Administrador automaticamente.
        echo.
        echo DICA: Clique com o BOTAO DIREITO em WinHelpDesk.bat e escolha:
        echo       "Executar como administrador"
        echo.
        pause
    )
    exit /b
)

:: ----------------------------------------------------------------------------
:: MENU PRINCIPAL
:: ----------------------------------------------------------------------------
:MAIN_MENU
cls
echo ===============================================================================
echo   =========================================================================
echo   *                     WINHELPDESK TOOLKIT 2026                          *
echo   *                 CENTRAL DE SUPORTE TECNICO E TI                       *
echo   =========================================================================
echo ===============================================================================
echo  Usuario: %USERNAME%       Computador: %COMPUTERNAME%       Data: %DATE%
echo ===============================================================================
echo.
echo   [1]  Rede, Internet e Conectividade
echo   [2]  Reparo do Sistema e Windows Update
echo   [3]  Impressao e Destravamento de Spooler
echo   [4]  Limpeza de Disco, Cache e Otimizacao
echo   [5]  Diagnostico de Hardware, Bateria e Licenciamento
echo   [6]  Contas de Usuario, Restauracao e GPO [Dominio]
echo   [7]  Central de Ferramentas Administrativas [MSC / CPL]
echo   [8]  MODO VARREDURA AUTOMATICA [Quick Fix Completo]
echo.
echo   [0]  Sair do WinHelpDesk
echo ===============================================================================
set "opt="
set /p opt="Escolha uma categoria [0-8]: "

if "%opt%"=="1" goto MENU_REDE
if "%opt%"=="2" goto MENU_SISTEMA
if "%opt%"=="3" goto MENU_IMPRESSAO
if "%opt%"=="4" goto MENU_LIMPEZA
if "%opt%"=="5" goto MENU_HARDWARE
if "%opt%"=="6" goto MENU_USUARIO_GPO
if "%opt%"=="7" goto MENU_ATALHOS
if "%opt%"=="8" goto VARREDURA_AUTO
if "%opt%"=="0" goto SAIR

echo [ERRO] Opcao invalida. Tente novamente.
timeout /t 1 >nul
goto MAIN_MENU


:: ============================================================================
:: 1. MENU DE REDE E INTERNET
:: ============================================================================
:MENU_REDE
cls
echo ===============================================================================
echo                      [1] REDE, INTERNET E CONECTIVIDADE
echo ===============================================================================
echo.
echo   1. Informacoes Completas de Rede (IP, Gateway, DNS, MAC)
echo   2. Teste de Conectividade Completo (Ping Roteador, Google, Cloudflare)
echo   3. Limpar Cache DNS (ipconfig /flushdns)
echo   4. Liberar e Renovar Endereco IP (Release / Renew)
echo   5. Resetar Pilha TCP/IP e Catalogo Winsock
echo   6. Listar Portas Abertas e Conexoes Ativas (netstat)
echo   7. Visualizar Senhas de Redes Wi-Fi Salvas
echo   8. Alterar DNS Rapidamente (Google 8.8.8.8 / Cloudflare 1.1.1.1 / DHCP)
echo.
echo   0. Voltar ao Menu Principal
echo ===============================================================================
set "opt_rede="
set /p opt_rede="Escolha uma opcao [0-8]: "

if "%opt_rede%"=="1" goto REDE_INFO
if "%opt_rede%"=="2" goto REDE_PING
if "%opt_rede%"=="3" goto REDE_FLUSHDNS
if "%opt_rede%"=="4" goto REDE_RENEW
if "%opt_rede%"=="5" goto REDE_RESET
if "%opt_rede%"=="6" goto REDE_NETSTAT
if "%opt_rede%"=="7" goto REDE_WIFI
if "%opt_rede%"=="8" goto REDE_MUDAR_DNS
if "%opt_rede%"=="0" goto MAIN_MENU
goto MENU_REDE

:REDE_INFO
cls
echo ===============================================================================
echo CONFIGURACOES DE REDE DETALHADAS:
echo ===============================================================================
ipconfig /all
echo.
pause
goto MENU_REDE

:REDE_PING
cls
echo ===============================================================================
echo TESTANDO CONECTIVIDADE COM A INTERNET E DNS:
echo ===============================================================================
echo [1/3] Testando comunicacao com DNS Google (8.8.8.8)...
ping -n 4 8.8.8.8
echo.
echo [2/3] Testando comunicacao com DNS Cloudflare (1.1.1.1)...
ping -n 4 1.1.1.1
echo.
echo [3/3] Testando resolucao de nomes (www.google.com)...
ping -n 4 www.google.com
echo.
pause
goto MENU_REDE

:REDE_FLUSHDNS
cls
echo Limpando cache do resolvedor DNS...
ipconfig /flushdns
echo [OK] Cache DNS limpo com sucesso!
echo.
pause
goto MENU_REDE

:REDE_RENEW
cls
echo Liberando concessao de IP atual...
ipconfig /release
echo Solicitando nova concessao de IP via DHCP...
ipconfig /renew
echo.
echo [OK] Endereco IP renovado com sucesso!
echo.
pause
goto MENU_REDE

:REDE_RESET
cls
echo ===============================================================================
echo REDEFININDO COMPONENTES DE REDE DO WINDOWS
echo ===============================================================================
echo [1/4] Redefinindo catalogo Winsock...
netsh winsock reset
echo [2/4] Redefinindo pilha TCP/IP...
netsh int ip reset
echo [3/4] Liberando e renovando IP...
ipconfig /release >nul 2>&1
ipconfig /renew >nul 2>&1
echo [4/4] Limpando cache DNS...
ipconfig /flushdns
echo.
echo [CONCLUIDO] A pilha de rede foi restaurada. Reinicie o sistema se necessario.
echo.
pause
goto MENU_REDE

:REDE_NETSTAT
cls
echo Listando conexoes ativas e portas ouvindo (Pressione Ctrl+C para interromper)...
echo.
netstat -ano | more
echo.
pause
goto MENU_REDE

:REDE_WIFI
cls
echo ===============================================================================
echo RECUPERACAO DE SENHAS DE REDES WI-FI SALVAS NESTE COMPUTADOR
echo ===============================================================================
echo ATENCAO: use apenas em computadores que voce administra e com autorizacao
echo do responsavel. As senhas serao exibidas na tela.
set /p CONF_WIFI=Deseja continuar? (S/N): 
if /i not "%CONF_WIFI%"=="S" goto MENU_REDE
powershell -NoProfile -Command "(netsh wlan show profiles) | Select-String '\:(.+)$' | ForEach-Object { $name = $_.Matches.Groups[1].Value.Trim(); $_ } | ForEach-Object { $profile = (netsh wlan show profile name=\"$name\" key=clear); $pass = ($profile | Select-String 'Key Content\s*:\s*(.+)$'); if ($pass) { [PSCustomObject]@{ 'Rede Wi-Fi' = $name; 'Senha' = $pass.Matches.Groups[1].Value.Trim() } } else { [PSCustomObject]@{ 'Rede Wi-Fi' = $name; 'Senha' = '[Sem Senha / Aberta]' } } } | Format-Table -AutoSize"
echo.
pause
goto MENU_REDE

:REDE_MUDAR_DNS
cls
echo ===============================================================================
echo CONFIGURAR SERVIDORES DNS RAPIDAMENTE
echo ===============================================================================
echo   1. Google DNS [8.8.8.8 e 8.8.4.4]
echo   2. Cloudflare DNS [1.1.1.1 e 1.0.0.1]
echo   3. Restaurar para Automatico [DHCP]
echo   0. Cancelar
echo.
set "opt_dns="
set /p opt_dns="Opcao: "
if "%opt_dns%"=="1" goto DNS_GOOGLE
if "%opt_dns%"=="2" goto DNS_CLOUDFLARE
if "%opt_dns%"=="3" goto DNS_DHCP
goto MENU_REDE

:DNS_GOOGLE
powershell -NoProfile -Command "Get-NetAdapter | Where-Object Status -eq 'Up' | ForEach-Object { Set-DnsClientServerAddress -InterfaceIndex $_.InterfaceIndex -ServerAddresses ('8.8.8.8','8.8.4.4') }"
echo [OK] DNS configurado para Google DNS [8.8.8.8 / 8.8.4.4]
pause
goto MENU_REDE

:DNS_CLOUDFLARE
powershell -NoProfile -Command "Get-NetAdapter | Where-Object Status -eq 'Up' | ForEach-Object { Set-DnsClientServerAddress -InterfaceIndex $_.InterfaceIndex -ServerAddresses ('1.1.1.1','1.0.0.1') }"
echo [OK] DNS configurado para Cloudflare DNS [1.1.1.1 / 1.0.0.1]
pause
goto MENU_REDE

:DNS_DHCP
powershell -NoProfile -Command "Get-NetAdapter | Where-Object Status -eq 'Up' | ForEach-Object { Set-DnsClientServerAddress -InterfaceIndex $_.InterfaceIndex -ResetServerAddresses }"
echo [OK] DNS restaurado para obtencao automatica [DHCP]
pause
goto MENU_REDE


:: ============================================================================
:: 2. MENU DE REPARO DO SISTEMA E WINDOWS UPDATE
:: ============================================================================
:MENU_SISTEMA
cls
echo ===============================================================================
echo                 [2] REPARO DO SISTEMA E WINDOWS UPDATE
echo ===============================================================================
echo.
echo   1. Verificador de Arquivos de Sistema (SFC /Scannow)
echo   2. Verificar Saude da Imagem do Windows (DISM CheckHealth / ScanHealth)
echo   3. Reparar Imagem do Windows (DISM RestoreHealth)
echo   4. Redefinir Componentes do Windows Update (Correcao de falhas de update)
echo   5. Agendar Verificacao de Integridade do Disco (CHKDSK C: /F)
echo   6. Reiniciar o Windows Explorer (Destravar barra de tarefas)
echo.
echo   0. Voltar ao Menu Principal
echo ===============================================================================
set "opt_sis="
set /p opt_sis="Escolha uma opcao [0-6]: "

if "%opt_sis%"=="1" goto SIS_SFC
if "%opt_sis%"=="2" goto SIS_DISM_CHECK
if "%opt_sis%"=="3" goto SIS_DISM_RESTORE
if "%opt_sis%"=="4" goto SIS_RESET_WU
if "%opt_sis%"=="5" goto SIS_CHKDSK
if "%opt_sis%"=="6" goto SIS_RESTART_EXPLORER
if "%opt_sis%"=="0" goto MAIN_MENU
goto MENU_SISTEMA

:SIS_SFC
cls
echo Executando Verificador de Arquivos de Sistema (SFC)...
echo Aguarde, isso pode levar alguns minutos...
echo.
sfc /scannow
echo.
pause
goto MENU_SISTEMA

:SIS_DISM_CHECK
cls
echo Analisando saude da imagem do sistema...
dism /online /cleanup-image /checkhealth
dism /online /cleanup-image /scanhealth
echo.
pause
goto MENU_SISTEMA

:SIS_DISM_RESTORE
cls
echo Executando reparo online da imagem do Windows (DISM)...
echo Aguarde, esta operacao baixa pacotes saudaveis do Windows Update...
echo.
dism /online /cleanup-image /restorehealth
echo.
pause
goto MENU_SISTEMA

:SIS_RESET_WU
cls
echo ===============================================================================
echo REDEFININDO COMPONENTES DO WINDOWS UPDATE
echo ===============================================================================
echo [1/4] Parando servicos do Windows Update...
net stop wuauserv >nul 2>&1
net stop cryptSvc >nul 2>&1
net stop bits >nul 2>&1
net stop msiserver >nul 2>&1

echo [2/4] Renomeando pastas SoftwareDistribution e catroot2...
ren %systemroot%\SoftwareDistribution SoftwareDistribution.old >nul 2>&1
ren %systemroot%\System32\catroot2 catroot2.old >nul 2>&1

echo [3/4] Reiniciando servicos essenciais...
net start wuauserv >nul 2>&1
net start cryptSvc >nul 2>&1
net start bits >nul 2>&1
net start msiserver >nul 2>&1

echo.
echo [SUCESSO] Cache e componentes do Windows Update foram resetados!
echo.
pause
goto MENU_SISTEMA

:SIS_CHKDSK
cls
echo ===============================================================================
echo AGENDAMENTO DE VERIFICACAO DE DISCO (CHKDSK)
echo ===============================================================================
echo Sera agendada a correcao de erros do disco C: para a proxima inicializacao.
echo.
chkdsk C: /f
echo.
pause
goto MENU_SISTEMA

:SIS_RESTART_EXPLORER
cls
echo Finalizando processo explorer.exe...
taskkill /f /im explorer.exe >nul 2>&1
timeout /t 2 /nobreak >nul
echo Reiniciando Windows Explorer...
start explorer.exe
echo [OK] Windows Explorer reiniciado com sucesso!
timeout /t 2 >nul
goto MENU_SISTEMA


:: ============================================================================
:: 3. MENU DE IMPRESSAO E SPOOLER
:: ============================================================================
:MENU_IMPRESSAO
cls
echo ===============================================================================
echo                  [3] IMPRESSAO E DESTRAVAMENTO DE SPOOLER
echo ===============================================================================
echo.
echo   1. Destravar Fila de Impressao (Limpa trabalhos presos e reinicia servico)
echo   2. Reiniciar Servico de Spooler
echo   3. Listar Todas as Impressoras Instaladas e Portas
echo   4. Abrir Central de Dispositivos e Impressoras
echo.
echo   0. Voltar ao Menu Principal
echo ===============================================================================
set "opt_prt="
set /p opt_prt="Escolha uma opcao [0-4]: "

if "%opt_prt%"=="1" goto PRT_DESTRAVAR
if "%opt_prt%"=="2" goto PRT_REINICIAR
if "%opt_prt%"=="3" goto PRT_LISTAR
if "%opt_prt%"=="4" goto PRT_ABRIR_PAINEL
if "%opt_prt%"=="0" goto MAIN_MENU
goto MENU_IMPRESSAO

:PRT_DESTRAVAR
cls
echo ===============================================================================
echo DESTRAVANDO FILA DE IMPRESSAO
echo ===============================================================================
echo [1/3] Parando servico Spooler...
net stop spooler
echo [2/3] Excluindo arquivos temporarios de impressao...
del /q /f /s "%systemroot%\System32\spool\printers\*.*" >nul 2>&1
echo [3/3] Reiniciando servico Spooler...
net start spooler
echo.
echo [OK] Fila limpa e servico reiniciado com sucesso!
echo.
pause
goto MENU_IMPRESSAO

:PRT_REINICIAR
cls
echo Reiniciando servico Spooler de Impressao...
net stop spooler
net start spooler
echo [OK] Servico reiniciado.
echo.
pause
goto MENU_IMPRESSAO

:PRT_LISTAR
cls
echo ===============================================================================
echo IMPRESSORAS INSTALADAS:
echo ===============================================================================
powershell -NoProfile -Command "Get-Printer | Select-Object Name, Type, DriverName, PortName, Shared, PrinterStatus | Format-Table -AutoSize"
echo.
pause
goto MENU_IMPRESSAO

:PRT_ABRIR_PAINEL
start control printers
goto MENU_IMPRESSAO


:: ============================================================================
:: 4. MENU DE LIMPEZA E OTIMIZACAO
:: ============================================================================
:MENU_LIMPEZA
cls
echo ===============================================================================
echo                   [4] LIMPEZA DE DISCO, CACHE E OTIMIZACAO
echo ===============================================================================
echo.
echo   1. Limpeza Completa de Arquivos Temporarios (Temp, Windows Temp, Prefetch)
echo   2. Limpar Cache de Downloads do Windows Update
echo   3. Esvaziar Lixeira de Todas as Unidades
echo   4. Limpar e Reconstruir Cache de Icones e Miniaturas do Windows
echo   5. Abrir Ferramenta Nativa de Limpeza de Disco (cleanmgr.exe)
echo.
echo   0. Voltar ao Menu Principal
echo ===============================================================================
set "opt_cln="
set /p opt_cln="Escolha uma opcao [0-5]: "

if "%opt_cln%"=="1" goto CLN_TEMP
if "%opt_cln%"=="2" goto CLN_WU_DOWNLOADS
if "%opt_cln%"=="3" goto CLN_LIXEIRA
if "%opt_cln%"=="4" goto CLN_ICONES
if "%opt_cln%"=="5" goto CLN_CLEANMGR
if "%opt_cln%"=="0" goto MAIN_MENU
goto MENU_LIMPEZA

:CLN_TEMP
cls
echo ===============================================================================
echo EXECUTANDO LIMPEZA DE ARQUIVOS TEMPORARIOS
echo ===============================================================================
echo Limpando pasta Temp do usuario...
del /s /f /q "%temp%\*.*" >nul 2>&1
for /d %%p in ("%temp%\*.*") do rmdir /s /q "%%p" >nul 2>&1

echo Limpando pasta Temp do Windows...
del /s /f /q "C:\Windows\Temp\*.*" >nul 2>&1
for /d %%p in ("C:\Windows\Temp\*.*") do rmdir /s /q "%%p" >nul 2>&1

echo Limpando pasta Prefetch...
del /s /f /q "C:\Windows\Prefetch\*.*" >nul 2>&1

echo Limpando relatorios de erros do Windows (CrashDumps)...
del /s /f /q "%LOCALAPPDATA%\CrashDumps\*.*" >nul 2>&1

echo.
echo [SUCESSO] Arquivos temporarios e caches obsoletos foram removidos!
echo.
pause
goto MENU_LIMPEZA

:CLN_WU_DOWNLOADS
cls
echo Parando servico do Windows Update...
net stop wuauserv >nul 2>&1
echo Excluindo pacotes baixados ja instalados...
del /s /f /q "%systemroot%\SoftwareDistribution\Download\*.*" >nul 2>&1
net start wuauserv >nul 2>&1
echo [OK] Cache de pacotes de atualizacao limpo com sucesso!
echo.
pause
goto MENU_LIMPEZA

:CLN_LIXEIRA
cls
echo Esvaziando Lixeira de todas as unidades...
powershell -NoProfile -Command "Clear-RecycleBin -Force -ErrorAction SilentlyContinue"
echo [OK] Lixeira esvaziada!
echo.
pause
goto MENU_LIMPEZA

:CLN_ICONES
cls
echo Reconstruindo cache de icones do Windows...
taskkill /f /im explorer.exe >nul 2>&1
del /f /q "%LOCALAPPDATA%\IconCache.db" >nul 2>&1
del /f /q "%LOCALAPPDATA%\Microsoft\Windows\Explorer\thumbcache_*.db" >nul 2>&1
start explorer.exe
echo [OK] Cache de icones reconstruido!
timeout /t 2 >nul
goto MENU_LIMPEZA

:CLN_CLEANMGR
start cleanmgr.exe
goto MENU_LIMPEZA


:: ============================================================================
:: 5. MENU DE DIAGNOSTICO, HARDWARE E LICENCIAMENTO
:: ============================================================================
:MENU_HARDWARE
cls
echo ===============================================================================
echo            [5] DIAGNOSTICO DE HARDWARE, BATERIA E LICENCIAMENTO
echo ===============================================================================
echo.
echo   1. Exibir Resumo Rapido de Hardware (CPU, RAM, Placa-Mae, Discos)
echo   2. Resgatar Chave de Ativacao do Windows gravada na BIOS (OEM Key)
echo   3. Verificar Status e Validade da Licenca do Windows
echo   4. Gerar Relatorio de Saude da Bateria (HTML na Area de Trabalho)
echo   5. Gerar Relatorio Completo de Diagnostico em TXT no Desktop
echo   6. Abrir Monitor de Recursos e Desempenho (resmon)
echo.
echo   0. Voltar ao Menu Principal
echo ===============================================================================
set "opt_hw="
set /p opt_hw="Escolha uma opcao [0-6]: "

if "%opt_hw%"=="1" goto HW_RESUMO
if "%opt_hw%"=="2" goto HW_OEM_KEY
if "%opt_hw%"=="3" goto HW_STATUS_LICENCA
if "%opt_hw%"=="4" goto HW_BATERIA
if "%opt_hw%"=="5" goto HW_RELATORIO_COMPLETO
if "%opt_hw%"=="6" goto HW_RESMON
if "%opt_hw%"=="0" goto MAIN_MENU
goto MENU_HARDWARE

:HW_RESUMO
cls
echo ===============================================================================
echo RESUMO DE HARDWARE:
echo ===============================================================================
echo Computador: %COMPUTERNAME%  ^|  Usuario: %USERNAME%
echo.
echo [PROCESSADOR]
powershell -NoProfile -Command "Get-CimInstance Win32_Processor | Select-Object Name, NumberOfCores, NumberOfLogicalProcessors | Format-List"
echo [MEMORIA RAM]
powershell -NoProfile -Command "Get-CimInstance Win32_OperatingSystem | Select-Object @{Name='RAM Total (GB)';Expression={[math]::Round($_.TotalVisibleMemorySize/1MB,2)}}, @{Name='RAM Livre (GB)';Expression={[math]::Round($_.FreePhysicalMemory/1MB,2)}} | Format-List"
echo [PLACA-MAE E BIOS]
powershell -NoProfile -Command "Get-CimInstance Win32_BaseBoard | Select-Object Manufacturer, Product, SerialNumber | Format-List"
echo [DISCOS DE ARMAZENAMENTO]
powershell -NoProfile -Command "Get-CimInstance Win32_LogicalDisk -Filter 'DriveType=3' | Select-Object DeviceID, VolumeName, @{Name='Tam (GB)';Expression={[math]::Round($_.Size/1GB,2)}}, @{Name='Livre (GB)';Expression={[math]::Round($_.FreeSpace/1GB,2)}} | Format-Table -AutoSize"
echo.
pause
goto MENU_HARDWARE

:HW_OEM_KEY
cls
echo ===============================================================================
echo CONSULTA DE CHAVE OEM DO WINDOWS NA BIOS
echo ===============================================================================
powershell -NoProfile -Command "$key = (Get-CimInstance SoftwareLicensingService).OA3xOriginalProductKey; if ($key) { Write-Host 'Chave OEM encontrada na BIOS:' -ForegroundColor Green; Write-Host $key -ForegroundColor Yellow } else { Write-Host 'Nenhuma chave OEM encontrada na tabela MSDM da BIOS.' -ForegroundColor Red }"
echo.
pause
goto MENU_HARDWARE

:HW_STATUS_LICENCA
cls
echo Consultando status de expiracao e canal da licenca...
cscript //nologo %systemroot%\System32\slmgr.vbs /xpr
cscript //nologo %systemroot%\System32\slmgr.vbs /dli
echo.
pause
goto MENU_HARDWARE

:HW_BATERIA
cls
echo Gerando relatorio de bateria [battery report]...
powercfg /batteryreport /output "%USERPROFILE%\Desktop\Relatorio_Bateria_%COMPUTERNAME%.html" >nul 2>&1
if not exist "%USERPROFILE%\Desktop\Relatorio_Bateria_%COMPUTERNAME%.html" goto BATERIA_FALHA

echo [SUCESSO] Relatorio salvo na sua Area de Trabalho:
echo %USERPROFILE%\Desktop\Relatorio_Bateria_%COMPUTERNAME%.html
start "" "%USERPROFILE%\Desktop\Relatorio_Bateria_%COMPUTERNAME%.html"
pause
goto MENU_HARDWARE

:BATERIA_FALHA
echo [AVISO] Nao foi possivel gerar o relatorio. Este dispositivo pode nao possuir bateria [Desktop].
echo.
pause
goto MENU_HARDWARE

:HW_RELATORIO_COMPLETO
cls
set "OUT_TXT=%USERPROFILE%\Desktop\Diagnostico_%COMPUTERNAME%.txt"
echo Gerando relatorio completo em: %OUT_TXT%
echo Aguarde alguns instantes...

(
    echo ===============================================================================
    echo RELATORIO DE DIAGNOSTICO TECNICO
    echo Computador: %COMPUTERNAME%  ^|  Data: %DATE% %TIME%
    echo ===============================================================================
    echo.
    echo --- INFORMACOES GERAIS DO SISTEMA ---
    systeminfo
    echo.
    echo --- CONFIGURACOES DE REDE ---
    ipconfig /all
    echo.
    echo --- DISCOS E PARTICIONAMENTO ---
    wmic logicaldisk get deviceid,volumename,size,freespace,filesystem 2>nul
    echo.
    echo --- PROGRAMAS COM INICIO AUTOMATICO ---
    wmic startup get caption,command,user 2>nul
) > "%OUT_TXT%"

echo [CONCLUIDO] Relatorio salvo com sucesso na Area de Trabalho!
echo.
pause
goto MENU_HARDWARE

:HW_RESMON
start resmon.exe
goto MENU_HARDWARE


:: ============================================================================
:: 6. MENU DE CONTAS DE USUARIO, RESTAURACAO E GPO
:: ============================================================================
:MENU_USUARIO_GPO
cls
echo ===============================================================================
echo            [6] CONTAS DE USUARIO, RESTAURACAO E GPO [DOMINIO]
echo ===============================================================================
echo.
echo   1. Forcar Atualizacao de Diretivas de Grupo (gpupdate /force)
echo   2. Exibir Relatorio de Diretivas Aplicadas (gpresult /r)
echo   3. Listar Usuarios Locais e Membros do Grupo Administradores
echo   4. Ativar Conta de Administrador Local Integrada
echo   5. Desativar Conta de Administrador Local Integrada
echo   6. Criar Ponto de Restauracao do Sistema Imediato
echo.
echo   0. Voltar ao Menu Principal
echo ===============================================================================
set "opt_usr="
set /p opt_usr="Escolha uma opcao [0-6]: "

if "%opt_usr%"=="1" goto USR_GPUPDATE
if "%opt_usr%"=="2" goto USR_GPRESULT
if "%opt_usr%"=="3" goto USR_LISTAR
if "%opt_usr%"=="4" goto USR_ADMIN_ON
if "%opt_usr%"=="5" goto USR_ADMIN_OFF
if "%opt_usr%"=="6" goto USR_CRIAR_PONTO
if "%opt_usr%"=="0" goto MAIN_MENU
goto MENU_USUARIO_GPO

:USR_GPUPDATE
cls
echo Atualizando politicas de grupo [GPO]...
gpupdate /force
echo.
pause
goto MENU_USUARIO_GPO

:USR_GPRESULT
cls
echo Gerando relatorio de diretivas aplicadas...
gpresult /r
echo.
pause
goto MENU_USUARIO_GPO

:USR_LISTAR
cls
echo ===============================================================================
echo USUARIOS LOCAIS:
net user
echo.
echo ===============================================================================
echo MEMBROS DO GRUPO ADMINISTRADORES:
net localgroup administrators
echo.
pause
goto MENU_USUARIO_GPO

:USR_ADMIN_ON
cls
echo ATENCAO: ativar o Administrador local reduz a seguranca do computador.
set /p CONF_ADM=Deseja ativar a conta? (S/N): 
if /i not "%CONF_ADM%"=="S" goto MENU_USUARIO_GPO
net user Administrator /active:yes >nul 2>&1
net user Administrador /active:yes >nul 2>&1
echo [OK] Conta de Administrador local ativada.
echo.
pause
goto MENU_USUARIO_GPO

:USR_ADMIN_OFF
cls
set /p CONF_ADM=Deseja desativar a conta de Administrador local? (S/N): 
if /i not "%CONF_ADM%"=="S" goto MENU_USUARIO_GPO
net user Administrator /active:no >nul 2>&1
net user Administrador /active:no >nul 2>&1
echo [OK] Conta de Administrador local desativada.
echo.
pause
goto MENU_USUARIO_GPO

:USR_CRIAR_PONTO
cls
echo Criando ponto de restauracao do sistema...
powershell -NoProfile -Command "Checkpoint-Computer -Description 'WinHelpDesk_RestorePoint' -RestorePointType 'MODIFY_SETTINGS'" >nul 2>&1
echo [OK] Ponto de restauracao criado com sucesso!
echo.
pause
goto MENU_USUARIO_GPO


:: ============================================================================
:: 7. MENU DE ATALHOS ADMINISTRATIVOS RAPIDOS
:: ============================================================================
:MENU_ATALHOS
cls
echo ===============================================================================
echo            [7] CENTRAL DE FERRAMENTAS ADMINISTRATIVAS RAPIDAS
echo ===============================================================================
echo.
echo   1. Conexoes de Rede (ncpa.cpl)
echo   2. Gerenciador de Dispositivos (devmgmt.msc)
echo   3. Programas e Recursos (appwiz.cpl)
echo   4. Gerenciador de Tarefas (taskmgr)
echo   5. Servicos do Windows (services.msc)
echo   6. Gerenciamento do Computador (compmgmt.msc)
echo   7. Visualizador de Eventos (eventvwr.msc)
echo   8. Editor do Registro (regedit)
echo   9. Conexao de Area de Trabalho Remota (mstsc)
echo  10. Assistencia Rapida (quickassist)
echo  11. Painel de Controle Classico (control)
echo.
echo   0. Voltar ao Menu Principal
echo ===============================================================================
set "opt_ctl="
set /p opt_ctl="Selecione o atalho desejado [0-11]: "

if "%opt_ctl%"=="1" start ncpa.cpl & goto MENU_ATALHOS
if "%opt_ctl%"=="2" start devmgmt.msc & goto MENU_ATALHOS
if "%opt_ctl%"=="3" start appwiz.cpl & goto MENU_ATALHOS
if "%opt_ctl%"=="4" start taskmgr & goto MENU_ATALHOS
if "%opt_ctl%"=="5" start services.msc & goto MENU_ATALHOS
if "%opt_ctl%"=="6" start compmgmt.msc & goto MENU_ATALHOS
if "%opt_ctl%"=="7" start eventvwr.msc & goto MENU_ATALHOS
if "%opt_ctl%"=="8" start regedit & goto MENU_ATALHOS
if "%opt_ctl%"=="9" start mstsc & goto MENU_ATALHOS
if "%opt_ctl%"=="10" start quickassist & goto MENU_ATALHOS
if "%opt_ctl%"=="11" start control & goto MENU_ATALHOS
if "%opt_ctl%"=="0" goto MAIN_MENU
goto MENU_ATALHOS


:: ============================================================================
:: 8. MODO VARREDURA AUTOMATICA (QUICK FIX)
:: ============================================================================
:VARREDURA_AUTO
cls
echo ===============================================================================
echo                     MODO VARREDURA AUTOMATICA [QUICK FIX]
echo ===============================================================================
echo Esta rotina automatica executa os seguintes passos em sequencia:
echo  1. Limpeza de temporarios (Temp, Windows Temp, Prefetch)
echo  2. Esvaziamento da Lixeira
echo  3. Limpeza de cache DNS (Flush DNS)
echo  4. Redefinicao de catalogo Winsock e TCP/IP
echo  5. Destravamento e limpeza do Spooler de Impressao
echo  6. Verificacao de integridade de arquivos do Windows (SFC /Scannow)
echo ===============================================================================
echo.
set "confirm="
set /p confirm="Deseja iniciar a varredura completa agora? (S/N): "
if /i not "%confirm%"=="S" goto MAIN_MENU

echo.
echo [1/6] Limpando pastas temporarias e caches...
del /s /f /q "%temp%\*.*" >nul 2>&1
del /s /f /q "C:\Windows\Temp\*.*" >nul 2>&1
del /s /f /q "C:\Windows\Prefetch\*.*" >nul 2>&1

echo [2/6] Esvaziando Lixeira...
powershell -NoProfile -Command "Clear-RecycleBin -Force -ErrorAction SilentlyContinue" >nul 2>&1

echo [3/6] Limpando cache do resolvedor DNS...
ipconfig /flushdns >nul 2>&1

echo [4/6] Redefinindo Winsock e pilha TCP/IP...
netsh winsock reset >nul 2>&1
netsh int ip reset >nul 2>&1

echo [5/6] Limpando fila e reiniciando Spooler de Impressao...
net stop spooler >nul 2>&1
del /q /f /s "%systemroot%\System32\spool\printers\*.*" >nul 2>&1
net start spooler >nul 2>&1

echo [6/6] Executando SFC /Scannow (Aguarde alguns minutos)...
sfc /scannow

echo.
echo ===============================================================================
echo [CONCLUIDO] Varredura automatica finalizada com sucesso!
echo Recomenda-se reiniciar a maquina para aplicar todas as otimizacoes.
echo ===============================================================================
echo.
pause
goto MAIN_MENU


:: ============================================================================
:: SAIR
:: ============================================================================
:SAIR
cls
echo Encerrando o WinHelpDesk Toolkit...
timeout /t 1 >nul
exit /b
