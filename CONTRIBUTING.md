# Guia de Contribuição - WinHelpDesk Toolkit

Obrigado pelo interesse em contribuir com o **WinHelpDesk Toolkit**!

## Diretrizes para Envio de Código

1. **Simplicidade e Portabilidade**:
   - Mantenha tudo no arquivo único `WinHelpDesk.bat` a menos que seja estritamente necessário um script auxiliar.
   - Utilize comandos nativos do Windows (`CMD`, PowerShell embutido, utilitários nativos).
   - Evite dependências de ferramentas externas de terceiros.

2. **Padrão de Codificação**:
   - Garanta a codificação UTF-8 (`chcp 65001`).
   - Mantenha comentários descritivos nos cabeçalhos de cada bloco/função.
   - Trate saídas de erro quando apropriado (redirecionando para `>nul 2>&1` se não for relevante para o operador).

3. **Fluxo de Trabalho**:
   - Crie uma branch para sua modificação: `git checkout -b feature/minha-melhoria`
   - Realize commits com mensagens claras e objetivas.
   - Abra um Pull Request detalhando o cenário de suporte atendido pela nova função.
