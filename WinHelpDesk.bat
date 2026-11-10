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
echo   *           CENTRAL COMPLETA DE SUPORTE TECNICO & HELP DESK             *
echo   =========================================================================
echo ===============================================================================
echo  Usuario: %USERNAME%       Computador: %COMPUTERNAME%       Data: %DATE%
echo ===============================================================================
echo.
echo   [1]  Rede, Internet e Conectividade (IP, DNS, Wi-Fi, Reset de Rede)
echo   [2]  Reparo do Sistema, Windows Update e Winget (SFC, DISM, Updates)
echo   [3]  Impressao e Destravamento de Spooler
echo   [4]  Limpeza de Disco, Cache, TRIM e Otimizacao de Energia
echo   [5]  Diagnostico de Hardware, Saude de SSD/Disco, BIOS e Bateria
echo   [6]  Contas de Usuario, Senhas Locais, Restauracao e GPO
echo   [7]  Audio, Bluetooth, Servicos e Perifericos (Reiniciar Som/Drivers)
echo   [8]  Seguranca, Windows Defender e Firewall
echo   [9]  Central de Ferramentas Administrativas [MSC / CPL]
echo  [10]  MODO VARREDURA AUTOMATICA [Quick Fix N1 Completo]
echo.
echo   [0]  Sair do WinHelpDesk
echo ===============================================================================
set "opt="
set /p opt="Escolha uma categoria [0-10]: "

if "%opt%"=="1" goto MENU_REDE
if "%opt%"=="2" goto MENU_SISTEMA
if "%opt%"=="3" goto MENU_IMPRESSAO
if "%opt%"=="4" goto MENU_LIMPEZA
if "%opt%"=="5" goto MENU_HARDWARE
if "%opt%"=="6" goto MENU_USUARIO_GPO
if "%opt%"=="7" goto MENU_AUDIO_PERIF
if "%opt%"=="8" goto MENU_SEGURANCA
if "%opt%"=="9" goto MENU_ATALHOS
if "%opt%"=="10" goto VARREDURA_AUTO
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
echo   1. Informacoes de Rede Local (IP, Mascara, Gateway, DNS, MAC)
echo   2. Consultar Endereco IP Publico / Externo (Provedor)
echo   3. Teste de Conectividade e Latencia (Ping Google, Cloudflare, Gateway)
echo   4. Rastreamento de Rota de Pacotes (Tracert para 8.8.8.8)
echo   5. Limpar Cache do Resolvedor DNS (ipconfig /flushdns)
echo   6. Liberar e Renovar Endereco IP (Release / Renew)
echo   7. Resetar Pilha TCP/IP e Catalogo Winsock (Restauracao completa de rede)
echo   8. Reiniciar Adaptadores de Rede Ativos (Desativa e reativa placas de rede)
echo   9. Visualizar Senhas de Redes Wi-Fi Salvas neste PC
echo  10. Fazer Backup das Chaves Wi-Fi em XML na Area de Trabalho
echo  11. Alterar DNS Rapidamente (Google 8.8.8.8 / Cloudflare 1.1.1.1 / DHCP)
echo  12. Listar Portas Abertas e Conexoes Ativas (netstat -ano)
echo.
echo   0. Voltar ao Menu Principal
echo ===============================================================================
set "opt_rede="
set /p opt_rede="Escolha uma opcao [0-12]: "

if "%opt_rede%"=="1" goto REDE_INFO
if "%opt_rede%"=="2" goto REDE_IP_PUBLICO
if "%opt_rede%"=="3" goto REDE_PING
if "%opt_rede%"=="4" goto REDE_TRACERT
if "%opt_rede%"=="5" goto REDE_FLUSHDNS
if "%opt_rede%"=="6" goto REDE_RENEW
if "%opt_rede%"=="7" goto REDE_RESET
if "%opt_rede%"=="8" goto REDE_RESTART_ADAPTERS
if "%opt_rede%"=="9" goto REDE_WIFI
if "%opt_rede%"=="10" goto REDE_BACKUP_WIFI
if "%opt_rede%"=="11" goto REDE_MUDAR_DNS
if "%opt_rede%"=="12" goto REDE_NETSTAT
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

:REDE_IP_PUBLICO
cls
echo ===============================================================================
echo CONSULTANDO IP PUBLICO / EXTERNO NA INTERNET:
echo ===============================================================================
echo Aguarde...
powershell -NoProfile -Command "try { $ip = (Invoke-RestMethod -Uri 'https://api.ipify.org' -TimeoutSec 4).Trim(); Write-Host 'Seu IP Publico e:' -ForegroundColor Green; Write-Host $ip -ForegroundColor Yellow } catch { Write-Host 'Nao foi possivel obter o IP publico. Verifique a conexao com a internet.' -ForegroundColor Red }"
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

:REDE_TRACERT
cls
echo ===============================================================================
echo RASTREANDO ROTA DE REDE (TRACERT PARA 8.8.8.8)
echo (Pressione Ctrl+C para interromper a qualquer momento)
echo ===============================================================================
tracert -d -h 15 8.8.8.8
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

:REDE_RESTART_ADAPTERS
cls
echo ===============================================================================
echo REINICIANDO ADAPTADORES DE REDE ATIVOS (RESET DE PLACA)
echo ===============================================================================
powershell -NoProfile -Command "Get-NetAdapter | Where-Object Status -eq 'Up' | ForEach-Object { Write-Host 'Reiniciando adaptador:' $_.Name; Restart-NetAdapter -Name $_.Name -Confirm:$false }"
echo.
echo [OK] Adaptadores reiniciados com sucesso!
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

:REDE_BACKUP_WIFI
cls
echo ===============================================================================
echo EXPORTANDO PERFIS E CHAVES DE WI-FI PARA A AREA DE TRABALHO
echo ===============================================================================
netsh wlan export profile folder="%USERPROFILE%\Desktop" key=clear >nul 2>&1
echo [OK] Perfis de rede Wi-Fi salvos em formato XML na sua Area de Trabalho!
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

:REDE_NETSTAT
cls
echo Listando conexoes ativas e portas ouvindo (Pressione Ctrl+C para interromper)...
echo.
netstat -ano | more
echo.
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
echo   3. Reparar Imagem do Windows Online (DISM RestoreHealth)
echo   4. Redefinir Componentes e Cache do Windows Update (SoftwareDistribution)
echo   5. Resetar Cache da Microsoft Store (wsreset.exe)
echo   6. Atualizar Todos os Programas do PC via Gerenciador Winget
echo   7. Agendar Verificacao de Integridade do Disco (CHKDSK C: /F)
echo   8. Reiniciar o Windows Explorer (Destravar barra de tarefas e tela)
echo.
echo   0. Voltar ao Menu Principal
echo ===============================================================================
set "opt_sis="
set /p opt_sis="Escolha uma opcao [0-8]: "

if "%opt_sis%"=="1" goto SIS_SFC
if "%opt_sis%"=="2" goto SIS_DISM_CHECK
if "%opt_sis%"=="3" goto SIS_DISM_RESTORE
if "%opt_sis%"=="4" goto SIS_RESET_WU
if "%opt_sis%"=="5" goto SIS_WSRESET
if "%opt_sis%"=="6" goto SIS_WINGET_UPGRADE
if "%opt_sis%"=="7" goto SIS_CHKDSK
if "%opt_sis%"=="8" goto SIS_RESTART_EXPLORER
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

:SIS_WSRESET
cls
echo Resetando cache da Microsoft Store...
start /wait wsreset.exe
echo [OK] Cache da Loja Microsoft resetado com sucesso!
echo.
pause
goto MENU_SISTEMA

:SIS_WINGET_UPGRADE
cls
echo ===============================================================================
echo ATUALIZANDO PROGRAMAS INSTALADOS VIA WINGET
echo ===============================================================================
powershell -NoProfile -Command "if (Get-Command winget -ErrorAction SilentlyContinue) { winget upgrade --all --include-unknown } else { Write-Host 'Winget nao esta instalado neste sistema operacional.' -ForegroundColor Red }"
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
echo   2. Reiniciar Servico de Spooler de Impressao
echo   3. Listar Todas as Impressoras Instaladas, Portas e Status
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
echo            [4] LIMPEZA DE DISCO, CACHE, TRIM E OTIMIZACAO DE ENERGIA
echo ===============================================================================
echo.
echo   1. Limpeza Completa de Arquivos Temporarios (Temp, Windows Temp, Prefetch)
echo   2. Limpar Cache de Downloads do Windows Update (SoftwareDistribution)
echo   3. Esvaziar Lixeira de Todas as Unidades
echo   4. Limpar e Reconstruir Cache de Icones e Miniaturas do Windows
echo   5. Otimizar Armazenamento / TRIM em SSDs e Desfragmentar HDDs (defrag /O)
echo   6. Desativar Hibernacao (Libera espaco do arquivo hiberfil.sys)
echo   7. Ativar Hibernacao
echo   8. Ativar Plano de Energia de Desempenho Maximo (Ultimate Performance)
echo   9. Abrir Ferramenta Nativa de Limpeza de Disco (cleanmgr.exe)
echo.
echo   0. Voltar ao Menu Principal
echo ===============================================================================
set "opt_cln="
set /p opt_cln="Escolha uma opcao [0-9]: "

if "%opt_cln%"=="1" goto CLN_TEMP
if "%opt_cln%"=="2" goto CLN_WU_DOWNLOADS
if "%opt_cln%"=="3" goto CLN_LIXEIRA
if "%opt_cln%"=="4" goto CLN_ICONES
if "%opt_cln%"=="5" goto CLN_TRIM
if "%opt_cln%"=="6" goto CLN_HIBER_OFF
if "%opt_cln%"=="7" goto CLN_HIBER_ON
if "%opt_cln%"=="8" goto CLN_ULTIMATE_PWR
if "%opt_cln%"=="9" goto CLN_CLEANMGR
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

:CLN_TRIM
cls
echo Otimizando volumes de disco e executando comando TRIM em SSDs...
defrag C: /O
echo.
pause
goto MENU_LIMPEZA

:CLN_HIBER_OFF
cls
echo Desativando hibernacao...
powercfg -h off
echo [OK] Hibernacao desativada! O espaco do arquivo hiberfil.sys foi liberado.
echo.
pause
goto MENU_LIMPEZA

:CLN_HIBER_ON
cls
echo Reativando hibernacao...
powercfg -h on
echo [OK] Hibernacao reativada com sucesso.
echo.
pause
goto MENU_LIMPEZA

:CLN_ULTIMATE_PWR
cls
echo Ativando plano de energia de Desempenho Maximo...
powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 >nul 2>&1
echo [OK] Esquema de energia Desempenho Maximo habilitado no Windows!
echo.
pause
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
echo            [5] DIAGNOSTICO DE HARDWARE, SAUDE DE SSD/DISCO E BIOS
echo ===============================================================================
echo.
echo   1. Resumo Completo de Hardware (CPU, RAM, Placa-Mae, Discos)
echo   2. Diagnostico de Saude dos Discos SSD / HDD (Status SMART e Saude Fisica)
echo   3. Consultar Ultimos Erros Criticos / Tela Azul no Visualizador de Eventos
echo   4. Resgatar Chave de Ativacao do Windows gravada na BIOS (OEM Key)
echo   5. Verificar Status e Validade da Licenca do Windows (slmgr)
echo   6. Gerar Relatorio de Saude da Bateria (HTML na Area de Trabalho)
echo   7. Gerar Relatorio Completo de Diagnostico em TXT no Desktop
echo   8. Abrir Monitor de Recursos e Desempenho em Tempo Real (resmon)
echo.
echo   0. Voltar ao Menu Principal
echo ===============================================================================
set "opt_hw="
set /p opt_hw="Escolha uma opcao [0-8]: "

if "%opt_hw%"=="1" goto HW_RESUMO
if "%opt_hw%"=="2" goto HW_DISCO_SMART
if "%opt_hw%"=="3" goto HW_EVENTOS_CRITICOS
if "%opt_hw%"=="4" goto HW_OEM_KEY
if "%opt_hw%"=="5" goto HW_STATUS_LICENCA
if "%opt_hw%"=="6" goto HW_BATERIA
if "%opt_hw%"=="7" goto HW_RELATORIO_COMPLETO
if "%opt_hw%"=="8" goto HW_RESMON
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

:HW_DISCO_SMART
cls
echo ===============================================================================
echo SAUDE DOS DISCOS FISICOS (SSD / HDD - STATUS SMART):
echo ===============================================================================
powershell -NoProfile -Command "Get-PhysicalDisk | Select-Object DeviceId, FriendlyName, MediaType, OperationalStatus, HealthStatus | Format-Table -AutoSize"
echo.
pause
goto MENU_HARDWARE

:HW_EVENTOS_CRITICOS
cls
echo ===============================================================================
echo ULTIMOS EVENTOS CRITICOS E ERROS DE SISTEMA REGISTRADOS:
echo ===============================================================================
powershell -NoProfile -Command "Get-WinEvent -FilterHashtable @{LogName='System'; Level=1,2} -MaxEvents 6 -ErrorAction SilentlyContinue | Select-Object TimeCreated, Id, Message | Format-List"
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
echo            [6] CONTAS DE USUARIO, SENHAS LOCAIS, RESTAURACAO E GPO
echo ===============================================================================
echo.
echo   1. Forcar Atualizacao de Diretivas de Grupo (gpupdate /force)
echo   2. Exibir Relatorio de Diretivas Aplicadas (gpresult /r)
echo   3. Listar Usuarios Locais e Membros do Grupo Administradores
echo   4. Redefinir Senha de um Usuario Local
echo   5. Criar Novo Usuario Local Administrador para Suporte
echo   6. Ativar Conta de Administrador Local Integrada
echo   7. Desativar Conta de Administrador Local Integrada
echo   8. Criar Ponto de Restauracao do Sistema Imediato
echo.
echo   0. Voltar ao Menu Principal
echo ===============================================================================
set "opt_usr="
set /p opt_usr="Escolha uma opcao [0-8]: "

if "%opt_usr%"=="1" goto USR_GPUPDATE
if "%opt_usr%"=="2" goto USR_GPRESULT
if "%opt_usr%"=="3" goto USR_LISTAR
if "%opt_usr%"=="4" goto USR_RESET_SENHA
if "%opt_usr%"=="5" goto USR_CRIAR_SUPORTE
if "%opt_usr%"=="6" goto USR_ADMIN_ON
if "%opt_usr%"=="7" goto USR_ADMIN_OFF
if "%opt_usr%"=="8" goto USR_CRIAR_PONTO
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

:USR_RESET_SENHA
cls
echo ===============================================================================
echo REDEFINIR SENHA DE USUARIO LOCAL
echo ===============================================================================
net user
echo.
set "alvo_usr="
set /p alvo_usr="Digite o nome do usuario que tera a senha alterada: "
if "%alvo_usr%"=="" goto MENU_USUARIO_GPO
net user "%alvo_usr%" *
echo.
pause
goto MENU_USUARIO_GPO

:USR_CRIAR_SUPORTE
cls
echo ===============================================================================
echo CRIAR CONTA DE SUPORTE TECNICO LOCAL
echo ===============================================================================
set "novo_usr="
set /p novo_usr="Digite o nome de login da nova conta (ex: SuporteLocal): "
if "%novo_usr%"=="" goto MENU_USUARIO_GPO
set "nova_pwd="
set /p nova_pwd="Digite a senha para essa conta: "
net user "%novo_usr%" "%nova_pwd%" /add
net localgroup administrators "%novo_usr%" /add
echo.
echo [OK] Usuario criado e adicionado ao grupo de Administradores!
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
:: 7. MENU DE AUDIO, BLUETOOTH E PERIFERICOS
:: ============================================================================
:MENU_AUDIO_PERIF
cls
echo ===============================================================================
echo         [7] AUDIO, BLUETOOTH, SERVICOS E PERIFERICOS
echo ===============================================================================
echo.
echo   1. Reiniciar Servicos de Audio do Windows (Corrige som e microfone travados)
echo   2. Reiniciar Servico de Bluetooth
echo   3. Forcar Deteccao de Novos Dispositivos Plug and Play (pnputil)
echo   4. Listar Compartilhamentos de Rede Ativos neste PC (net share)
echo.
echo   0. Voltar ao Menu Principal
echo ===============================================================================
set "opt_aud="
set /p opt_aud="Escolha uma opcao [0-4]: "

if "%opt_aud%"=="1" goto AUD_RESTART
if "%opt_aud%"=="2" goto BTH_RESTART
if "%opt_aud%"=="3" goto PNP_SCAN
if "%opt_aud%"=="4" goto NET_SHARE_LIST
if "%opt_aud%"=="0" goto MAIN_MENU
goto MENU_AUDIO_PERIF

:AUD_RESTART
cls
echo ===============================================================================
echo REINICIANDO SUBSISTEMA DE AUDIO DO WINDOWS
echo ===============================================================================
net stop AudioEndpointBuilder /y >nul 2>&1
net stop AudioSrv /y >nul 2>&1
net start AudioEndpointBuilder >nul 2>&1
net start AudioSrv >nul 2>&1
echo [OK] Servicos de audio reiniciados com sucesso!
echo.
pause
goto MENU_AUDIO_PERIF

:BTH_RESTART
cls
echo Reiniciando servico de Bluetooth...
net stop bthserv /y >nul 2>&1
net start bthserv >nul 2>&1
echo [OK] Servico de Bluetooth reiniciado!
echo.
pause
goto MENU_AUDIO_PERIF

:PNP_SCAN
cls
echo Executando varredura por alteracoes de hardware e novos dispositivos...
pnputil /scan-devices
echo.
pause
goto MENU_AUDIO_PERIF

:NET_SHARE_LIST
cls
echo ===============================================================================
echo COMPARTILHAMENTOS DE REDE ATIVOS NESTE PC:
echo ===============================================================================
net share
echo.
pause
goto MENU_AUDIO_PERIF


:: ============================================================================
:: 8. MENU DE SEGURANCA, WINDOWS DEFENDER E FIREWALL
:: ============================================================================
:MENU_SEGURANCA
cls
echo ===============================================================================
echo              [8] SEGURANCA, WINDOWS DEFENDER E FIREWALL
echo ===============================================================================
echo.
echo   1. Atualizar Assinaturas de Virus do Windows Defender
echo   2. Executar Varredura Rapida de Antivirus com Windows Defender
echo   3. Restaurar Regras Padrao do Windows Firewall (netsh advfirewall reset)
echo   4. Verificar Status Atual dos Perfis do Firewall
echo.
echo   0. Voltar ao Menu Principal
echo ===============================================================================
set "opt_sec="
set /p opt_sec="Escolha uma opcao [0-4]: "

if "%opt_sec%"=="1" goto SEC_UPDATE_DEFENDER
if "%opt_sec%"=="2" goto SEC_SCAN_DEFENDER
if "%opt_sec%"=="3" goto SEC_RESET_FIREWALL
if "%opt_sec%"=="4" goto SEC_STATUS_FIREWALL
if "%opt_sec%"=="0" goto MAIN_MENU
goto MENU_SEGURANCA

:SEC_UPDATE_DEFENDER
cls
echo Baixando atualizacoes mais recentes de definicoes do Windows Defender...
"%ProgramFiles%\Windows Defender\MpCmdRun.exe" -SignatureUpdate
echo [OK] Atualizacao de definicoes concluida!
echo.
pause
goto MENU_SEGURANCA

:SEC_SCAN_DEFENDER
cls
echo Iniciando varredura rapida do Windows Defender...
"%ProgramFiles%\Windows Defender\MpCmdRun.exe" -Scan -ScanType 1
echo.
pause
goto MENU_SEGURANCA

:SEC_RESET_FIREWALL
cls
echo Restaurando configuracoes padrao do Firewall do Windows...
netsh advfirewall reset
echo [OK] Regras do Firewall restauradas para o padrao de fabrica.
echo.
pause
goto MENU_SEGURANCA

:SEC_STATUS_FIREWALL
cls
echo ===============================================================================
echo STATUS DOS PERFIS DO FIREWALL DO WINDOWS:
echo ===============================================================================
netsh advfirewall show allprofiles
echo.
pause
goto MENU_SEGURANCA


:: ============================================================================
:: 9. MENU DE ATALHOS ADMINISTRATIVOS RAPIDOS
:: ============================================================================
:MENU_ATALHOS
cls
echo ===============================================================================
echo            [9] CENTRAL DE FERRAMENTAS ADMINISTRATIVAS RAPIDAS
echo ===============================================================================
echo.
echo   1. Conexoes de Rede (ncpa.cpl)
echo   2. Gerenciador de Dispositivos (devmgmt.msc)
echo   3. Programas e Recursos / Desinstalar (appwiz.cpl)
echo   4. Gerenciador de Tarefas (taskmgr)
echo   5. Servicos do Windows (services.msc)
echo   6. Gerenciamento do Computador (compmgmt.msc)
echo   7. Visualizador de Eventos (eventvwr.msc)
echo   8. Editor do Registro (regedit)
echo   9. Conexao de Area de Trabalho Remota (mstsc)
echo  10. Assistencia Rapida (quickassist)
echo  11. Painel de Controle Classico (control)
echo  12. Configuracao do Sistema (msconfig)
echo.
echo   0. Voltar ao Menu Principal
echo ===============================================================================
set "opt_ctl="
set /p opt_ctl="Selecione o atalho desejado [0-12]: "

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
if "%opt_ctl%"=="12" start msconfig & goto MENU_ATALHOS
if "%opt_ctl%"=="0" goto MAIN_MENU
goto MENU_ATALHOS


:: ============================================================================
:: 10. MODO VARREDURA AUTOMATICA (QUICK FIX)
:: ============================================================================
:VARREDURA_AUTO
cls
echo ===============================================================================
echo                 [10] MODO VARREDURA AUTOMATICA [QUICK FIX N1]
echo ===============================================================================
echo Esta rotina automatica executa os seguintes passos em sequencia:
echo  1. Limpeza de temporarios (Temp, Windows Temp, Prefetch, CrashDumps)
echo  2. Esvaziamento da Lixeira
echo  3. Limpeza de cache DNS (Flush DNS)
echo  4. Redefinicao de catalogo Winsock e TCP/IP
echo  5. Destravamento e limpeza do Spooler de Impressao
echo  6. Reinicializacao dos servicos de Audio
echo  7. Verificacao de integridade de arquivos do Windows (SFC /Scannow)
echo ===============================================================================
echo.
set "confirm="
set /p confirm="Deseja iniciar a varredura completa agora? (S/N): "
if /i not "%confirm%"=="S" goto MAIN_MENU

echo.
echo [1/7] Limpando pastas temporarias e caches...
del /s /f /q "%temp%\*.*" >nul 2>&1
del /s /f /q "C:\Windows\Temp\*.*" >nul 2>&1
del /s /f /q "C:\Windows\Prefetch\*.*" >nul 2>&1
del /s /f /q "%LOCALAPPDATA%\CrashDumps\*.*" >nul 2>&1

echo [2/7] Esvaziando Lixeira...
powershell -NoProfile -Command "Clear-RecycleBin -Force -ErrorAction SilentlyContinue" >nul 2>&1

echo [3/7] Limpando cache do resolvedor DNS...
ipconfig /flushdns >nul 2>&1

echo [4/7] Redefinindo Winsock e pilha TCP/IP...
netsh winsock reset >nul 2>&1
netsh int ip reset >nul 2>&1

echo [5/7] Limpando fila e reiniciando Spooler de Impressao...
net stop spooler >nul 2>&1
del /q /f /s "%systemroot%\System32\spool\printers\*.*" >nul 2>&1
net start spooler >nul 2>&1

echo [6/7] Reiniciando subsistema de audio...
net stop AudioEndpointBuilder /y >nul 2>&1
net stop AudioSrv /y >nul 2>&1
net start AudioEndpointBuilder >nul 2>&1
net start AudioSrv >nul 2>&1

echo [7/7] Executando SFC /Scannow (Aguarde alguns minutos)...
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
