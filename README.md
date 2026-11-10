<div align="center">

# 🛠️ WinHelpDesk Toolkit

**O canivete suíço definitivo em Batch Script (.BAT) para Suporte Técnico, Help Desk e Administradores de Sistemas Windows.**

[![Windows](https://img.shields.io/badge/Windows-10%20%7C%2011%20%7C%20Server-0078D6?logo=windows&logoColor=white)](https://microsoft.com)
[![Shell](https://img.shields.io/badge/Language-Batch%20%2F%20CMD-4EAA25?logo=gnu-bash&logoColor=white)](https://en.wikipedia.org/wiki/Batch_file)
[![GitHub Repo](https://img.shields.io/badge/GitHub-GilsonCataoDev%2FWinHelpDesk--Toolkit-blue?logo=github)](https://github.com/GilsonCataoDev/WinHelpDesk-Toolkit)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)

*Tudo centralizado em um único arquivo `.bat` autocontido com mais de 50 funções práticas de Help Desk e zero dependências externas.*

</div>

---

## 📌 Visão Geral

O **WinHelpDesk Toolkit** foi projetado para analistas de suporte técnico e administradores de TI que precisam de agilidade e confiabilidade na resolução de chamados em máquinas Windows 10, 11 e Windows Server.

### ✨ Diferenciais
- **100% Autocontido em arquivo único (`WinHelpDesk.bat`)**: Ideal para carregar em pendrives de suporte técnico ou transferir via acesso remoto.
- **Auto-Elevação com UAC Seguro**: Detecta privilégios de Administrador e requisita elevação via UAC sem fechar o terminal nem travar.
- **Nativo e Leve**: Utiliza estritamente os comandos e subsistemas nativos do Windows (`CMD`, `PowerShell`, `WMI/CIM`, `NETSH`, `DISM`, `MpCmdRun`).
- **Modo Quick Fix N1**: Bateria completa de limpezas, reparos e reinício de serviços com apenas 1 clique.

---

## 🖥️ Demonstração da Interface

```text
===============================================================================
  =========================================================================
  *                     WINHELPDESK TOOLKIT 2026                          *
  *           CENTRAL COMPLETA DE SUPORTE TECNICO & HELP DESK             *
  =========================================================================
===============================================================================
 Usuario: SuporteTI       Computador: DESKTOP-PROD01       Data: 10/11/2026
===============================================================================

  [1]  Rede, Internet e Conectividade (IP, DNS, Wi-Fi, Reset de Rede)
  [2]  Reparo do Sistema, Windows Update e Winget (SFC, DISM, Updates)
  [3]  Impressao e Destravamento de Spooler
  [4]  Limpeza de Disco, Cache, TRIM e Otimizacao de Energia
  [5]  Diagnostico de Hardware, Saude de SSD/Disco, BIOS e Bateria
  [6]  Contas de Usuario, Senhas Locais, Restauracao e GPO
  [7]  Audio, Bluetooth, Servicos e Perifericos (Reiniciar Som/Drivers)
  [8]  Seguranca, Windows Defender e Firewall
  [9]  Central de Ferramentas Administrativas [MSC / CPL]
 [10]  MODO VARREDURA AUTOMATICA [Quick Fix N1 Completo]

  [0]  Sair do WinHelpDesk
===============================================================================
```

---

## ⚡ Módulos e Funcionalidades

| Módulo | Descrição das Ações |
| :--- | :--- |
| **1. Rede & Internet** | Diagnóstico IP/DNS/MAC, consulta de IP Público, Ping (Google/Cloudflare), Tracert, Flush DNS, Release/Renew DHCP, Reset TCP/IP e Winsock, Reset de Placa de Rede, Revelador de senhas Wi-Fi, Backup de perfis Wi-Fi em XML e monitor de portas (`netstat`). |
| **2. Reparo do Sistema** | `sfc /scannow`, `DISM RestoreHealth` e `CheckHealth`, Reset de componentes do Windows Update (`SoftwareDistribution`/`catroot2`), Reset da Microsoft Store (`wsreset`), Atualização de todos os programas via Winget, `chkdsk` agendado e reinício limpo do `explorer.exe`. |
| **3. Impressão & Spooler** | Destravamento forçado da fila de impressão (interrupção do Spooler, exclusão de arquivos retidos em `spool\printers` e reinício), listagem de impressoras instaladas e acesso à central clássica. |
| **4. Limpeza & Otimização** | Expurgo de `%TEMP%`, `Windows\Temp`, `Prefetch` e `CrashDumps`, limpeza de atualizações antigas, esvaziamento de lixeira, rebuild do cache de ícones (`IconCache.db`), TRIM para SSDs e defrag para HDDs (`defrag /O`), desativação de hibernação (`hiberfil.sys`) e plano de energia Ultimate Performance. |
| **5. Diagnóstico & Hardware** | Resumo de CPU, RAM, Placa-Mãe e Discos, auditoria SMART e integridade física de SSD/HDD (`Get-PhysicalDisk`), consulta de erros críticos e BlueScreens recentes no Event Log, resgate de chave OEM do Windows gravada na BIOS (MSDM), auditoria de licença (`slmgr`), relatório de bateria em HTML e exportação completa em TXT. |
| **6. Usuários & Diretivas (GPO)** | `gpupdate /force`, auditoria de diretivas aplicadas (`gpresult /r`), listagem de usuários e administradores locais, redefinição direta de senha local, criação expressa de usuário suporte administrador, toggle de administrador oculto e criação de Ponto de Restauração. |
| **7. Áudio, Bluetooth & Drivers** | Reinicialização completa dos serviços de áudio (`AudioSrv` e `AudioEndpointBuilder` - resolve microfones e som travados em reuniões), reinício de Bluetooth, varredura Plug and Play de hardware (`pnputil /scan-devices`) e lista de compartilhamentos (`net share`). |
| **8. Segurança & Firewall** | Atualização forçada das assinaturas do Windows Defender (`MpCmdRun.exe -SignatureUpdate`), varredura rápida de antivírus nativa, restauração padrão do Firewall do Windows (`netsh advfirewall reset`) e auditoria de perfis de rede. |
| **9. Central Administrativa** | Atalhos rápidos a 1 clique: `ncpa.cpl`, `devmgmt.msc`, `appwiz.cpl`, `taskmgr`, `services.msc`, `compmgmt.msc`, `eventvwr.msc`, `regedit`, `mstsc`, `quickassist`, `control` e `msconfig`. |
| **10. Quick Fix N1 (Automático)** | Executa rotina em lote: Limpeza de temporários + Esvaziamento de Lixeira + Flush DNS + Reset Winsock e TCP/IP + Destravamento de Impressão + Reinício de Áudio + Varredura SFC. |

---

## 🚀 Como Usar

### Opção 1: Download Direto (Recomendado para Suporte Rápido)
1. Baixe o arquivo [`WinHelpDesk.bat`](WinHelpDesk.bat).
2. Dê um duplo clique sobre ele (ou clique com botão direito e selecione **"Executar como Administrador"**).
3. Se a janela do UAC for exibida, clique em **Sim** para permitir privilégios de Administrador.
4. Navegue pelo menu utilizando as opções numéricas.

### Opção 2: Via Git
```bash
git clone https://github.com/GilsonCataoDev/WinHelpDesk-Toolkit.git
cd WinHelpDesk-Toolkit
WinHelpDesk.bat
```

---

## 🔒 Segurança e Boas Práticas

- **Código Aberto e Auditável**: O script é 100% legível em texto puro (`.bat`), permitindo auditar cada comando antes de executar em qualquer máquina corporativa.
- **Segurança Operacional**: Não apaga documentos nem arquivos pessoais. A limpeza atua estritamente em arquivos temporários (`%temp%`, `Windows\Temp`, `Prefetch`, `CrashDumps`) e na Lixeira.
- **Uso Responsável**: Recursos como recuperação de chaves Wi-Fi e gerenciamento de contas de usuário exigem privilégios administrativos e devem ser utilizados em conformidade com as políticas da sua organização.
- **Reversibilidade**: Permite a criação instantânea de Pontos de Restauração antes de manutenções no sistema.

---

## 🤝 Como Contribuir

Pull Requests e sugestões de melhorias são muito bem-vindos!
1. Faça um Fork do projeto.
2. Crie uma branch para sua funcionalidade: `git checkout -b feature/NovaFuncao`
3. Faça commit das alterações: `git commit -m 'feat: adiciona reparo X'`
4. Envie para o GitHub: `git push origin feature/NovaFuncao`
5. Abra um **Pull Request**.

---

## 📄 Licença

Este projeto é distribuído sob a licença [MIT](LICENSE). Sinta-se livre para utilizar, customizar e distribuir em sua empresa, equipe ou consultoria de TI.
