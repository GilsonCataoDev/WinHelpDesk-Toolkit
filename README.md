<div align="center">

# 🛠️ WinHelpDesk Toolkit

**O canivete suíço definitivo em Batch Script (.BAT) para Suporte Técnico, Help Desk e Administradores de Sistemas Windows.**

[![Windows](https://img.shields.io/badge/Windows-10%20%7C%2011%20%7C%20Server-0078D6?logo=windows&logoColor=white)](https://microsoft.com)
[![Shell](https://img.shields.io/badge/Language-Batch%20%2F%20CMD-4EAA25?logo=gnu-bash&logoColor=white)](https://en.wikipedia.org/wiki/Batch_file)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)

*Tudo centralizado em um único arquivo `.bat` autocontido, sem necessidade de instalação de dependências externas.*

</div>

---

## 📌 Visão Geral

O **WinHelpDesk Toolkit** foi desenvolvido para solucionar mais de 90% dos chamados rotineiros de suporte técnico nível 1 e 2 (N1/N2) em ambientes corporativos e domésticos. Ele reúne em um único arquivo scripts de diagnóstico, reparo do sistema, resolução de problemas de rede, liberação de espaço em disco, manutenção de impressoras e ferramentas administrativas.

### ✨ Destaques
- **Tudo em um único arquivo (`WinHelpDesk.bat`)**: Fácil de carregar em um pendrive ou enviar via acesso remoto.
- **Auto-Elevação UAC**: Detecta automaticamente se está como Administrador e solicita permissão de forma transparente.
- **Zero Dependências**: Utiliza ferramentas nativas do Windows (`CMD`, `PowerShell`, `WMI/CIM`, `NETSH`).
- **Modo Quick Fix**: Executa uma bateria completa de limpezas e correções com apenas 1 clique.

---

## 🖥️ Demonstração da Interface

```text
===============================================================================
       __          ___       _    _      _           _____           _    
       \ \        / (_)     | |  | |    | |         |  __ \         | |   
        \ \  /\  / / _ _ __ | |__| | ___| |___  ___| |  | | ___ ___| | __
         \ \/  \/ / | | '_ \|  __  |/ _ \ / __|/ _ \ |  | |/ _ \/ __| |/ /
          \  /\  /  | | | | | |  | |  __| (__|  __| |__| |  __/\__ \   < 
           \/  \/   |_|_| |_|_|  |_|\___|\___|\___|_____/ \___||___/_|\_\

                      CENTRAL DE SUPORTE TECNICO & HELP DESK
===============================================================================
 Usuario: SuporteTI       Computador: DESKTOP-PROD01       Data: 10/11/2026
===============================================================================

  [1]  Rede, Internet e Conectividade
  [2]  Reparo do Sistema e Windows Update
  [3]  Impressao e Destravamento de Spooler
  [4]  Limpeza de Disco, Cache e Otimizacao
  [5]  Diagnostico de Hardware, Bateria e Licenciamento
  [6]  Contas de Usuario, Restauracao e GPO (Dominio)
  [7]  Central de Ferramentas Administrativas (MSC / CPL)
  [8]  MODO VARREDURA AUTOMATICA (Quick Fix Completo)

  [0]  Sair do WinHelpDesk
===============================================================================
```

---

## ⚡ Funcionalidades Detalhadas

### 🌐 1. Rede e Conectividade
- Diagnóstico completo (`ipconfig /all`)
- Teste de latência/ping para Google (8.8.8.8) e Cloudflare (1.1.1.1)
- Limpeza de cache de resolução DNS (`ipconfig /flushdns`)
- Liberação e renovação de concessão DHCP (`release / renew`)
- Redefinição completa da pilha TCP/IP e catálogo Winsock (`netsh winsock reset`)
- Exibição de conexões e portas em escuta (`netstat -ano`)
- Revelação de senhas de redes Wi-Fi salvas na máquina
- Troca rápida de DNS (Google, Cloudflare ou restauração para automático via DHCP)

### 🩺 2. Reparo do Sistema e Windows Update
- Verificador de arquivos de integridade (`sfc /scannow`)
- Diagnóstico e restauração da imagem do Windows (`DISM RestoreHealth`)
- Reset de componentes corrompidos do Windows Update (renomeia `SoftwareDistribution` e `catroot2`)
- Agendamento de verificação e correção de setores de disco (`chkdsk C: /f`)
- Reinicialização limpa do Windows Explorer (`explorer.exe`) para desobstrução de congelamentos visuais

### 🖨️ 3. Impressão e Spooler
- Destravamento da fila de impressão (interrupção do Spooler, expurgo de arquivos presos em `spool\printers` e reinício)
- Listagem detalhada de impressoras instaladas, portas e status
- Acesso rápido à central clássica de dispositivos e impressoras

### 🧹 4. Limpeza de Disco e Cache
- Expurgo de arquivos temporários (`%TEMP%`, `C:\Windows\Temp`, `Prefetch`, `CrashDumps`)
- Limpeza de instaladores obsoletos do Windows Update
- Esvaziamento forçado de lixeira em todas as unidades de disco
- Reconstrução de cache de ícones e miniaturas do Windows (`IconCache.db`)
- Atalho para o utilitário nativo de limpeza (`cleanmgr.exe`)

### 🔍 5. Diagnóstico de Hardware e Licenciamento
- Resumo em tempo real de CPU, Placa-Mãe, Memória RAM e Discos
- Resgate da Chave de Ativação do Windows gravada na BIOS (chave OEM MSDM)
- Checagem de expiração e canal de licenciamento (`slmgr.vbs /xpr` e `/dli`)
- Geração de Relatório de Saúde da Bateria (`batteryreport`) em HTML no Desktop
- Exportação de relatório técnico consolidado em `.txt`

### 👥 6. Contas de Usuário e Domínio (GPO)
- Atualização imediata de diretivas de grupo (`gpupdate /force`)
- Auditoria de políticas aplicadas (`gpresult /r`)
- Consulta de contas de usuário e membros do grupo Administradores local
- Ativação/Desativação da conta oculta de Administrador local integrado
- Criação instantânea de Ponto de Restauração do Windows

### 🧰 7. Central de Ferramentas Administrativas
Acesso a um clique para os principais consoles do Windows:
- `ncpa.cpl` (Adaptadores de Rede)
- `devmgmt.msc` (Gerenciador de Dispositivos)
- `appwiz.cpl` (Desinstalar Programas)
- `services.msc` (Serviços)
- `compmgmt.msc` (Gerenciamento do Computador)
- `eventvwr.msc` (Visualizador de Eventos)
- `regedit` (Editor do Registro)
- `mstsc` (Área de Trabalho Remota)
- `quickassist` (Assistência Rápida)

### 🚀 8. Modo Varredura Automática (Quick Fix)
Executa em lote:
1. Limpeza de caches temporários
2. Esvaziamento de lixeira
3. Flush DNS
4. Redefinição de Winsock e TCP/IP
5. Limpeza e reinício da fila de impressão
6. Verificação de integridade via SFC

---

## 🚀 Como Usar

### Opção 1: Download Direto (Recomendado para Suporte Rápido)
1. Baixe o arquivo [`WinHelpDesk.bat`](WinHelpDesk.bat).
2. Dê um duplo clique sobre ele.
3. Se a janela do UAC for exibida, clique em **Sim** para permitir privilégios de Administrador.
4. Navegue pelo menu utilizando as opções numéricas.

### Opção 2: Via Git
```bash
git clone https://github.com/SEU_USUARIO/WinHelpDesk-Toolkit.git
cd WinHelpDesk-Toolkit
WinHelpDesk.bat
```

---

## 🔒 Segurança e Boas Práticas

- **Código Aberto e Auditável**: O script é 100% legível em texto puro (`.bat`), permitindo auditar cada comando antes de executar.
- **Segurança Operacional**: Não remove dados pessoais, documentos ou arquivos essenciais de usuários.
- **Reversibilidade**: Oferece opção de criação de Ponto de Restauração antes de manutenções críticas.

---

## 🤝 Como Contribuir

Contribuições são muito bem-vindas!
1. Faça um Fork do projeto.
2. Crie uma branch para sua funcionalidade (`git checkout -b feature/NovaFuncao`).
3. Faça commit das alterações (`git commit -m 'Adiciona reparo de servico X'`).
4. Envie para o branch (`git push origin feature/NovaFuncao`).
5. Abra um **Pull Request**.

---

## 📄 Licença

Este projeto está sob a licença [MIT](LICENSE). Sinta-se livre para usar, modificar e distribuir em sua empresa ou consultoria de TI.
