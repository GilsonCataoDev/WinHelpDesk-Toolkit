<#
.SYNOPSIS
    Le e, quando o firmware permitir, reseta o contador de tinta residual
    (waste ink pad) de impressoras Epson da familia L1250/L3250 (L3250,
    L3251, ET-2810, ET-2814 e variantes), pela rede (SNMP), sem Python nem
    pacotes externos - so .NET/PowerShell nativo do Windows.

.DESCRIPTION
    Porte para PowerShell do modo de rede do projeto
    https://github.com/GilsonCataoDev/epson-l3250-reset-br (fork de
    epson_waste_ink, que por sua vez usa o protocolo e o mapa de EEPROM do
    projeto epson_print_conf). So o modo de rede (SNMP) foi portado; o modo
    USB depende de um pacote Python (epson-usb) sem equivalente nativo aqui.

    AVISO: o contador nao e o pad fisico. Resetar o contador nao limpa nem
    substitui a almofada de tinta. Se ela estiver realmente saturada, a
    tinta pode vazar dentro da impressora. Troque ou limpe a almofada (ou
    use um reservatorio externo) antes do reset.

    Firmware novo tende a travar a EEPROM pela rede. Se o Status reportar
    bloqueio, so o cabo USB (fora do escopo deste script) ainda pode
    funcionar - use o projeto Python original nesse caso.

.PARAMETER Action
    status | reset | temp-reset | restore

.PARAMETER Target
    Endereco IP da impressora na rede.

.PARAMETER AuthorizedBy
    Nome de quem autoriza a acao nesta impressora. Obrigatorio para
    'reset' e 'temp-reset' quando a impressora nao e do proprio operador
    (oficina/suporte); se vazio, o script pergunta no terminal. Fica
    registrado em consent_log.jsonl (ao lado deste script).

.PARAMETER BackupFile
    Caminho do arquivo JSON de backup, usado por 'restore'.

.PARAMETER AssumeYes
    Pula a confirmacao interativa do passo de escrita. NAO dispensa
    -AuthorizedBy: sem nome de autorizacao, a acao e recusada mesmo com
    -AssumeYes.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('status', 'reset', 'temp-reset', 'restore')]
    [string]$Action,

    [Parameter(Mandatory = $true)]
    [string]$Target,

    [string]$AuthorizedBy = '',

    [string]$BackupFile = '',

    [switch]$AssumeYes,

    [int]$Port = 161,

    [string]$Community = 'public',

    [double]$TimeoutSeconds = 3.0
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

# ----------------------------------------------------------------------------
# Mapa de EEPROM da familia L1250/L3250 (mesmos valores do epson_print_conf /
# epson_waste_ink). SPDX-License-Identifier: EUPL-1.2 (mapa herdado).
# ----------------------------------------------------------------------------
$EpsonCtrlOid    = '1.3.6.1.4.1.1248.1.2.2.44.1.1.2.1'
$OidDeviceDescr  = '1.3.6.1.2.1.25.3.2.1.3.1'

$ReadKey   = @(74, 54)
$WriteKey  = [byte[]][System.Text.Encoding]::ASCII.GetBytes('Maribaya')

$Levels = [ordered]@{
    'main pad'       = @{ Addrs = @(48, 49, 47);  Divider = 63.46 }
    'borderless pad' = @{ Addrs = @(50, 51, 47);  Divider = 34.16 }
    'third pad'      = @{ Addrs = @(252, 253, 254); Divider = 13.0 }
}

# Hashtable normal (NAO [ordered]): OrderedDictionary tem um indexador
# posicional que colide com chaves inteiras - "$dict[48]" seria lido como
# "elemento na posicao 48" (ArgumentOutOfRangeException), nao "chave 48".
# A ordem de escrita destes enderecos nao importa (cada um e independente).
$RawWasteReset = @{
    48 = 0; 49 = 0; 47 = 0; 52 = 0; 53 = 0; 54 = 94; 50 = 0; 51 = 0
    55 = 94; 28 = 0; 252 = 0; 253 = 0; 254 = 0; 255 = 94
}
$CommitMasks = @{ 256 = 0xFE }           # 0x100 = 256
$SerialAddrs = 1604..1613

$SupportedModelPattern = '\b(L12[5-9]\d|L32[5-6]\d|ET-28[1-2]\d)\b'

$StatusNames = @{ 0 = 'Error'; 1 = 'Self printing'; 2 = 'Busy'; 3 = 'Waiting'; 4 = 'Idle'; 5 = 'Paused' }
$ErrorNames  = @{
    0x10 = 'Waste ink pad counter overflow (ink pad full)'
    0x2C = 'Ink cartridge overflow error'
    0x41 = 'Maintenance request'
    0x4A = 'Maintenance box near end'
}
$BoxStates = @{ 0 = 'not full'; 1 = 'near full'; 2 = 'FULL' }

# ----------------------------------------------------------------------------
# BER/ASN.1 minimo (so o necessario para um SNMPv1 GET e seu GetResponse)
# ----------------------------------------------------------------------------
function Get-BerLength {
    param([int]$Length)
    if ($Length -lt 0x80) { return [byte[]]@($Length) }
    $bytes = [System.Collections.Generic.List[byte]]::new()
    $n = $Length
    while ($n -gt 0) { $bytes.Insert(0, [byte]($n -band 0xFF)); $n = $n -shr 8 }
    return [byte[]](@([byte](0x80 -bor $bytes.Count)) + $bytes.ToArray())
}

function New-Tlv {
    param([byte]$Tag, [byte[]]$Payload)
    # IMPORTANTE: nunca usar "-not $Payload" aqui - um array de 1 byte com
    # valor 0x00 (ex.: o inteiro BER zero) seria convertido pelo PowerShell
    # para o escalar 0, que e "falsy", apagando o payload por engano.
    if ($null -eq $Payload) { $Payload = [byte[]]@() }
    return [byte[]]((@($Tag)) + (Get-BerLength $Payload.Length) + $Payload)
}

function ConvertTo-BerInt {
    param([int]$Value)
    # inteiro BER com sinal, tamanho minimo (igual a Python int.to_bytes signed=True)
    if ($Value -eq 0) { return (New-Tlv 0x02 ([byte[]]@(0))) }
    $bytes = [System.Collections.Generic.List[byte]]::new()
    $v = $Value
    $negative = $Value -lt 0
    for ($i = 0; $i -lt 8; $i++) {
        $bytes.Insert(0, [byte]($v -band 0xFF))
        $v = $v -shr 8
        if ($negative) { if ($v -eq -1 -and ($bytes[0] -band 0x80)) { break } }
        else { if ($v -eq 0 -and -not ($bytes[0] -band 0x80)) { break } }
    }
    # remove bytes de preenchimento redundantes mantendo o sinal correto
    while ($bytes.Count -gt 1) {
        if ($negative -and $bytes[0] -eq 0xFF -and ($bytes[1] -band 0x80)) { $bytes.RemoveAt(0) }
        elseif (-not $negative -and $bytes[0] -eq 0x00 -and -not ($bytes[1] -band 0x80)) { $bytes.RemoveAt(0) }
        else { break }
    }
    return (New-Tlv 0x02 $bytes.ToArray())
}

function ConvertTo-BerOid {
    param([string]$Oid)
    $parts = $Oid.Split('.') | ForEach-Object { [int]$_ }
    $out = [System.Collections.Generic.List[byte]]::new()
    $out.Add([byte]($parts[0] * 40 + $parts[1]))
    for ($i = 2; $i -lt $parts.Count; $i++) {
        $p = [long]$parts[$i]
        $chunk = [System.Collections.Generic.List[byte]]::new()
        $chunk.Add([byte]($p -band 0x7F))
        $p = $p -shr 7
        while ($p -gt 0) {
            $chunk.Add([byte](0x80 -bor ($p -band 0x7F)))
            $p = $p -shr 7
        }
        $chunk.Reverse()
        $out.AddRange($chunk)
    }
    return (New-Tlv 0x06 $out.ToArray())
}

function New-SnmpGetPacket {
    param([string]$Oid, [byte[]]$Community, [int]$RequestId)
    $varbind = New-Tlv 0x30 ((ConvertTo-BerOid $Oid) + [byte[]]@(0x05, 0x00))
    $pduBody = (ConvertTo-BerInt $RequestId) + (ConvertTo-BerInt 0) + (ConvertTo-BerInt 0) + (New-Tlv 0x30 $varbind)
    $pdu = New-Tlv 0xA0 $pduBody
    $msgBody = (ConvertTo-BerInt 0) + (New-Tlv 0x04 $Community) + $pdu
    return (New-Tlv 0x30 $msgBody)
}

function Read-BerLength {
    param([byte[]]$Data, [ref]$Pos)
    $ln = $Data[$Pos.Value]; $Pos.Value++
    if ($ln -band 0x80) {
        $n = $ln -band 0x7F
        $ln = 0
        for ($i = 0; $i -lt $n; $i++) { $ln = ($ln -shl 8) -bor $Data[$Pos.Value + $i] }
        $Pos.Value += $n
    }
    return $ln
}

function Read-Tlv {
    param([byte[]]$Data, [ref]$Pos)
    $tag = $Data[$Pos.Value]; $Pos.Value++
    $len = Read-BerLength -Data $Data -Pos $Pos
    # Dois niveis de @() sao necessarios: um para a indexacao de 1 elemento
    # (que devolve escalar), outro porque o if/else-como-expressao tambem
    # desembrulha um array de 1 elemento na captura "$var = if {...} else {...}".
    $value = @( if ($len -eq 0) { [byte[]]@() } else { [byte[]]@($Data[$Pos.Value..($Pos.Value + $len - 1)]) } )
    $Pos.Value += $len
    return @{ Tag = $tag; Value = $value }
}

function Read-BerSequence {
    param([byte[]]$Data)
    $items = [System.Collections.Generic.List[object]]::new()
    $pos = 0
    $posRef = [ref]$pos
    while ($posRef.Value -lt $Data.Length) {
        $items.Add((Read-Tlv -Data $Data -Pos $posRef))
    }
    return $items
}

function Resolve-SnmpResponse {
    param([byte[]]$Packet)
    $pos = 0; $posRef = [ref]$pos
    $msg = Read-Tlv -Data $Packet -Pos $posRef
    $items = Read-BerSequence -Data $msg.Value
    $pduItem = $items[2]
    if ($pduItem.Tag -ne 0xA2) { throw 'Resposta nao e um SNMP GetResponse' }
    $pduItems = Read-BerSequence -Data $pduItem.Value
    $requestId = 0; foreach ($b in $pduItems[0].Value) { $requestId = ($requestId -shl 8) -bor $b }
    $errStatus = 0; foreach ($b in $pduItems[1].Value) { $errStatus = ($errStatus -shl 8) -bor $b }
    $varbindList = Read-BerSequence -Data $pduItems[3].Value
    $varbind = Read-BerSequence -Data $varbindList[0].Value
    $valueTlv = $varbind[1]
    $value = $null
    if ($valueTlv.Tag -eq 0x04) { $value = $valueTlv.Value }
    return @{ RequestId = $requestId; ErrorStatus = $errStatus; Value = $value }
}

# ----------------------------------------------------------------------------
# Transporte SNMP (UDP) + comandos EPSON-CTRL tunelados em OID
# ----------------------------------------------------------------------------
function Invoke-SnmpGet {
    param([string]$TargetIp, [int]$TargetPort, [string]$Oid, [string]$CommunityStr, [double]$Timeout)
    $communityBytes = [System.Text.Encoding]::ASCII.GetBytes($CommunityStr)
    $requestId = Get-Random -Minimum 1 -Maximum 0x7FFFFFFF
    $packet = New-SnmpGetPacket -Oid $Oid -Community $communityBytes -RequestId $requestId

    $udp = New-Object System.Net.Sockets.UdpClient
    try {
        $udp.Client.ReceiveTimeout = [int]($Timeout * 1000)
        $udp.Connect($TargetIp, $TargetPort)
        for ($attempt = 0; $attempt -le 2; $attempt++) {
            $udp.Send($packet, $packet.Length) | Out-Null
            $deadline = (Get-Date).AddSeconds($Timeout)
            while ((Get-Date) -lt $deadline) {
                try {
                    $remote = New-Object System.Net.IPEndPoint ([System.Net.IPAddress]::Any, 0)
                    $data = $udp.Receive([ref]$remote)
                    $resp = Resolve-SnmpResponse -Packet $data
                    if ($resp.RequestId -eq $requestId) {
                        if ($resp.ErrorStatus -ne 0) { return $null }
                        return $resp.Value
                    }
                } catch [System.Net.Sockets.SocketException] {
                    break
                } catch {
                    continue
                }
            }
        }
    } finally {
        $udp.Close()
    }
    throw "Sem resposta SNMP de ${TargetIp}:${TargetPort}"
}

function Send-EpsonCtrl {
    <# Envia um frame EPSON-CTRL (cmd de 2 bytes + len little-endian + payload),
       tunelado como sufixo do OID vendor, igual ao projeto original. #>
    param([string]$TargetIp, [byte[]]$Frame)
    $oidSuffix = ($Frame | ForEach-Object { [int]$_ }) -join '.'
    $oid = "$EpsonCtrlOid.$oidSuffix"
    return Invoke-SnmpGet -TargetIp $TargetIp -TargetPort $Port -Oid $oid -CommunityStr $Community -Timeout $TimeoutSeconds
}

function New-CtrlFrame {
    param([byte[]]$Cmd, [byte[]]$Payload)
    $len = [BitConverter]::GetBytes([uint16]$Payload.Length)  # little-endian na maioria dos .NET/Windows
    return [byte[]]($Cmd + $len + $Payload)
}

# ----------------------------------------------------------------------------
# Comandos de alto nivel contra a impressora
# ----------------------------------------------------------------------------
function Get-PrinterModel {
    param([string]$TargetIp)
    $reply = Send-EpsonCtrl -TargetIp $TargetIp -Frame (New-CtrlFrame -Cmd ([byte[]][System.Text.Encoding]::ASCII.GetBytes('di')) -Payload ([byte[]]@(1)))
    if ($null -eq $reply -or $reply.Length -eq 0) { return $null }
    $text = [System.Text.Encoding]::GetEncoding('ISO-8859-1').GetString($reply)
    if ($text -match 'MDL:([^;]+);') { return $Matches[1].Trim() }
    return $null
}

function Get-PrinterStatusBlock {
    param([string]$TargetIp)
    $reply = Send-EpsonCtrl -TargetIp $TargetIp -Frame (New-CtrlFrame -Cmd ([byte[]][System.Text.Encoding]::ASCII.GetBytes('st')) -Payload ([byte[]]@(1)))
    if ($null -eq $reply -or $reply.Length -eq 0) { return $null }
    $marker = [System.Text.Encoding]::ASCII.GetBytes("@BDC ST2`r`n")
    $start = -1
    for ($i = 0; $i -le $reply.Length - $marker.Length; $i++) {
        $match = $true
        for ($j = 0; $j -lt $marker.Length; $j++) { if ($reply[$i + $j] -ne $marker[$j]) { $match = $false; break } }
        if ($match) { $start = $i; break }
    }
    if ($start -lt 0) { return $null }
    $pos = $start + $marker.Length
    $blockLen = [BitConverter]::ToUInt16($reply, $pos)
    $pos += 2
    $end = [Math]::Min($reply.Length, $pos + $blockLen)
    $info = @{ Boxes = @() }
    while ($pos + 2 -le $end) {
        $ftype = $reply[$pos]; $ln = $reply[$pos + 1]
        # ($pos+2)..($pos+1+$ln) seria uma faixa DESCENDENTE quando $ln=0
        # (pos+2 > pos+1) e leria bytes errados; e quando $ln=1 a indexacao
        # devolve o byte isolado (escalar), nao um array - por isso o @().
        # O @() externo e indispensavel: um "if/else" usado como expressao
        # que devolve um array de 1 elemento e desembrulhado de volta para
        # um escalar na captura "$var = if (...) {...} else {...}" - o
        # [byte[]] interno sozinho nao basta para evitar isso.
        $item = @( if ($ln -eq 0) { [byte[]]@() } else { [byte[]]@($reply[($pos + 2)..($pos + 1 + $ln)]) } )
        $pos += 2 + $ln
        if ($null -eq $item -or $item.Length -eq 0) { continue }
        switch ($ftype) {
            0x01 { $info.Status = $item[0] }
            0x02 { $info.ErrorCode = $item[0] }
            0x37 {
                $step = $item[0]
                if ($step -in 1, 2) {
                    for ($i = 1; $i -le $item.Length - $step; $i += $step) {
                        $resets = if ($step -eq 2) { $item[$i + 1] } else { $null }
                        $info.Boxes += @{ State = $item[$i]; Resets = $resets }
                    }
                }
            }
            0x40 {
                $chars = $item | Where-Object { $_ -gt 0x20 -and $_ -lt 0x7F } | ForEach-Object { [char]$_ }
                if ($chars) { $info.Serial = -join $chars }
            }
        }
    }
    return $info
}

function Read-EepromByte {
    param([string]$TargetIp, [int]$Addr)
    $payload = [byte[]]($ReadKey + @(0x41, 0xBE, 0xA0, ($Addr -band 0xFF), ($Addr -shr 8)))
    $reply = Send-EpsonCtrl -TargetIp $TargetIp -Frame (New-CtrlFrame -Cmd ([byte[]][System.Text.Encoding]::ASCII.GetBytes('||')) -Payload $payload)
    if ($null -eq $reply) { throw "Sem resposta ao ler o endereco EEPROM $Addr" }
    $text = [System.Text.Encoding]::ASCII.GetString($reply)
    if ($text -notmatch 'EE:([0-9A-Fa-f]{4})([0-9A-Fa-f]{2})') { return $null }  # EEPROM bloqueada
    $gotAddr = [Convert]::ToInt32($Matches[1], 16)
    if ($gotAddr -ne $Addr) { throw "Endereco EEPROM nao corresponde: pedi $Addr, veio 0x$($Matches[1])" }
    return [Convert]::ToInt32($Matches[2], 16)
}

function Write-EepromByte {
    param([string]$TargetIp, [int]$Addr, [int]$Value)
    $key = $WriteKey | ForEach-Object { if ($_ -eq 0) { 0 } else { [byte](($_ + 1) % 256) } }
    $payload = [byte[]]($ReadKey + @(0x42, 0xBD, 0x21, ($Addr -band 0xFF), ($Addr -shr 8), $Value) + $key)
    $reply = Send-EpsonCtrl -TargetIp $TargetIp -Frame (New-CtrlFrame -Cmd ([byte[]][System.Text.Encoding]::ASCII.GetBytes('||')) -Payload $payload)
    $text = if ($null -ne $reply -and $reply.Length -gt 0) { [System.Text.Encoding]::ASCII.GetString($reply) } else { '' }
    if ($text -notmatch ':OK;') { return $false }
    return (Read-EepromByte -TargetIp $TargetIp -Addr $Addr) -eq $Value
}

function Get-EepromSerial {
    param([string]$TargetIp)
    $values = $SerialAddrs | ForEach-Object { Read-EepromByte -TargetIp $TargetIp -Addr $_ }
    if ($values -contains $null) { return $null }
    return -join ($values | ForEach-Object { [char]$_ })
}

function Get-WasteLevels {
    param([string]$TargetIp)
    $result = [ordered]@{}
    foreach ($name in $Levels.Keys) {
        $cfg = $Levels[$name]
        $vals = $cfg.Addrs | ForEach-Object { Read-EepromByte -TargetIp $TargetIp -Addr $_ }
        if ($vals -contains $null) { return $null }
        $raw = $vals[0] -bor ($vals[1] -shl 8) -bor ($vals[2] -shl 16)
        $result[$name] = [Math]::Round($raw / $cfg.Divider, 2)
    }
    return $result
}

function Send-TemporaryReset {
    param([string]$TargetIp, [string]$Serial)
    $sha1 = [System.Security.Cryptography.SHA1]::Create()
    $hash = $sha1.ComputeHash([System.Text.Encoding]::ASCII.GetBytes($Serial))
    $payload = [byte[]]([BitConverter]::GetBytes([uint16]1) + $hash)
    $reply = Send-EpsonCtrl -TargetIp $TargetIp -Frame (New-CtrlFrame -Cmd ([byte[]][System.Text.Encoding]::ASCII.GetBytes('rw')) -Payload $payload)
    if ($null -eq $reply -or $reply.Length -eq 0) { return $false }
    $text = [System.Text.Encoding]::ASCII.GetString($reply)
    return ($text -match 'rw:') -and ($text -match ':OK;')
}

# ----------------------------------------------------------------------------
# Consentimento e log de auditoria (consent_log.jsonl, ao lado deste script)
# ----------------------------------------------------------------------------
$ConsentLogPath = Join-Path $PSScriptRoot 'consent_log.jsonl'

function Request-Consent {
    param([string]$ActionName, [string]$Model, [string]$Serial)
    $operator = $AuthorizedBy.Trim()
    if (-not $operator) {
        if ($AssumeYes) {
            throw "O modo -AssumeYes nao registra quem autoriza. Rode sem -AssumeYes, ou use -AuthorizedBy `"Nome Completo`"."
        }
        $operator = (Read-Host "Nome de quem autoriza este $ActionName nesta impressora (dono/responsavel pelo equipamento)").Trim()
        if (-not $operator) { throw 'Consentimento recusado: nome em branco.' }
    }
    $entry = [ordered]@{
        timestamp = (Get-Date).ToString('yyyy-MM-ddTHH:mm:ss')
        action    = $ActionName
        model     = $Model
        serial    = $Serial
        operator  = $operator
    }
    ($entry | ConvertTo-Json -Compress) | Add-Content -Path $ConsentLogPath -Encoding utf8
    return $entry
}

function Confirm-Action {
    param([string]$Question)
    if ($AssumeYes) { return $true }
    $answer = Read-Host "$Question [s/N]"
    return $answer -match '^(s|si|sim|y|yes)$'
}

# ----------------------------------------------------------------------------
# Acoes de linha de comando
# ----------------------------------------------------------------------------
function Show-PrinterStatus {
    param([string]$TargetIp)
    $model = Get-PrinterModel -TargetIp $TargetIp
    Write-Host "Modelo         : $(if ($model) { $model } else { 'desconhecido' })"
    $st = Get-PrinterStatusBlock -TargetIp $TargetIp
    if (-not $st) { Write-Host 'Status         : sem resposta de status'; return @{ Model = $model; Status = $null } }
    Write-Host "Numero de serie: $(if ($st.Serial) { $st.Serial } else { 'desconhecido' })"
    if ($st.ContainsKey('Status')) {
        $name = $StatusNames[[int]$st.Status]
        Write-Host "Estado         : $(if ($name) { $name } else { "codigo $($st.Status)" })"
    }
    if ($st.ContainsKey('ErrorCode')) {
        $name = $ErrorNames[[int]$st.ErrorCode]
        Write-Host "Erro           : $(if ($name) { $name } else { ('codigo 0x{0:X2}' -f $st.ErrorCode) })"
    }
    for ($i = 0; $i -lt $st.Boxes.Count; $i++) {
        $box = $st.Boxes[$i]
        $name = $BoxStates[[int]$box.State]
        Write-Host "Almofada $($i + 1)      : $(if ($name) { $name } else { "desconhecido ($($box.State))" })"
    }
    return @{ Model = $model; Status = $st }
}

function Invoke-StatusAction {
    param([string]$TargetIp)
    $result = Show-PrinterStatus -TargetIp $TargetIp
    $levels = Get-WasteLevels -TargetIp $TargetIp
    if ($null -eq $levels) {
        Write-Host ''
        Write-Host 'Contadores EEPROM: acesso recusado pelo firmware da impressora (bloqueada).'
        Write-Host "Firmware novo costuma travar isso pela rede; tente via cabo USB (fora deste script - use o projeto Python original) ou 'temp-reset'."
        return 0
    }
    Write-Host ''
    Write-Host 'Contadores de tinta residual (100% = almofada considerada cheia):'
    foreach ($name in $levels.Keys) { Write-Host ("  {0,-15}: {1}%" -f $name, $levels[$name]) }
    return 0
}

function Invoke-TempResetAction {
    param([string]$TargetIp)
    $result = Show-PrinterStatus -TargetIp $TargetIp
    $serial = $result.Status.Serial
    if (-not $serial) { Write-Host ''; Write-Host 'Nao foi possivel ler o numero de serie no status.'; return 1 }
    if (-not ($result.Status.Boxes | Where-Object { $_.State -eq 2 })) {
        Write-Host ''
        Write-Host 'Nota: a impressora nao reporta almofada cheia; o reset temporario so tem efeito quando ela esta.'
    }
    Write-Host ''
    Write-Host 'O reset temporario deixa a impressora funcionar de novo ate ela ser desligada.'
    try { Request-Consent -ActionName 'temp-reset' -Model 'desconhecido' -Serial $serial | Out-Null }
    catch { Write-Host ''; Write-Host "Abortado: $($_.Exception.Message)"; return 1 }
    if (-not (Confirm-Action 'Enviar o reset temporario agora?')) { return 1 }
    if (Send-TemporaryReset -TargetIp $TargetIp -Serial $serial) {
        Write-Host 'Feito. A impressora aceitou o reset temporario (nao desligue ela).'
        return 0
    }
    Write-Host 'A impressora recusou o reset temporario.'
    return 1
}

function Invoke-ResetAction {
    param([string]$TargetIp)
    $result = Show-PrinterStatus -TargetIp $TargetIp
    $model = $result.Model
    $st = $result.Status
    if (-not $model -or $model -notmatch $SupportedModelPattern) {
        Write-Host ''
        Write-Host "Abortado: este mapa de EEPROM e para a familia L1250/L3250, nao '$model'."
        return 1
    }

    $eepromSerial = Get-EepromSerial -TargetIp $TargetIp
    if ($null -eq $eepromSerial) {
        Write-Host ''
        Write-Host 'Abortado: a impressora recusa acesso a EEPROM pela rede.'
        Write-Host "Firmware novo costuma travar isso pela rede; conecte o cabo USB e use o projeto Python original (modo USB nao esta neste script)."
        return 2
    }
    $statusSerial = $st.Serial
    if ($statusSerial -and $statusSerial -ne $eepromSerial) {
        Write-Host ''
        Write-Host "Abortado: serial da EEPROM '$eepromSerial' nao corresponde ao serial do status '$statusSerial'; o mapa nao serve para esta impressora."
        return 1
    }

    $addrs = @($RawWasteReset.Keys) + @($CommitMasks.Keys)
    $backup = [ordered]@{}
    foreach ($a in $addrs) {
        $v = Read-EepromByte -TargetIp $TargetIp -Addr $a
        if ($null -eq $v) { Write-Host ''; Write-Host 'Abortado: alguns enderecos da EEPROM nao puderam ser lidos.'; return 1 }
        $backup[[string]$a] = $v
    }
    $stamp = (Get-Date).ToString('yyyyMMdd_HHmmss')
    $backupName = Join-Path $PSScriptRoot "backup_${eepromSerial}_${stamp}.json"
    @{ model = $model; serial = $eepromSerial; eeprom = $backup } | ConvertTo-Json -Depth 4 | Set-Content -Path $backupName -Encoding utf8
    Write-Host ''
    Write-Host "Backup dos valores atuais da EEPROM salvo em $backupName"

    Write-Host ''
    Write-Host 'Contadores de tinta residual antes do reset:'
    $levelsBefore = Get-WasteLevels -TargetIp $TargetIp
    foreach ($name in $levelsBefore.Keys) { Write-Host ("  {0,-15}: {1}%" -f $name, $levelsBefore[$name]) }
    Write-Host ''
    Write-Host 'AVISO: o contador so registra quanto de tinta foi para a almofada. Resetar'
    Write-Host 'nao esvazia a almofada; uma almofada realmente cheia pode vazar tinta dentro'
    Write-Host 'da impressora. Troque/limpe a almofada ou instale um reservatorio externo.'

    try { Request-Consent -ActionName 'reset' -Model $model -Serial $eepromSerial | Out-Null }
    catch { Write-Host ''; Write-Host "Abortado: $($_.Exception.Message)"; return 1 }
    if (-not (Confirm-Action "`nEscrever o reset na EEPROM agora?")) { return 1 }

    foreach ($addr in $RawWasteReset.Keys) {
        if (-not (Write-EepromByte -TargetIp $TargetIp -Addr $addr -Value $RawWasteReset[$addr])) {
            Write-Host "Falha ao escrever no endereco $addr. Restaure com: -Action restore -BackupFile `"$backupName`""
            return 1
        }
    }
    foreach ($addr in $CommitMasks.Keys) {
        $mask = $CommitMasks[$addr]
        $current = Read-EepromByte -TargetIp $TargetIp -Addr $addr
        if ($null -eq $current) { Write-Host "Nao foi possivel ler o endereco $addr. Restaure com: -Action restore -BackupFile `"$backupName`""; return 1 }
        if (($current -band $mask) -ne $current) {
            if (-not (Write-EepromByte -TargetIp $TargetIp -Addr $addr -Value ($current -band $mask))) {
                Write-Host "Falha ao escrever no endereco $addr. Restaure com: -Action restore -BackupFile `"$backupName`""
                return 1
            }
        }
    }
    Write-Host ''
    Write-Host "Reset feito e verificado. Desligue e ligue a impressora, depois rode -Action status."
    return 0
}

function Invoke-RestoreAction {
    param([string]$TargetIp, [string]$Path)
    if (-not $Path -or -not (Test-Path $Path)) { throw "Arquivo de backup nao encontrado: $Path" }
    $data = Get-Content $Path -Raw -Encoding utf8 | ConvertFrom-Json
    $eepromSerial = Get-EepromSerial -TargetIp $TargetIp
    if ($null -eq $eepromSerial) { Write-Host 'A impressora recusa acesso a EEPROM.'; return 2 }
    if ($eepromSerial -ne $data.serial) {
        Write-Host "Abortado: backup e do serial $($data.serial), a impressora e $eepromSerial."
        return 1
    }
    $pairs = $data.eeprom.PSObject.Properties
    if (-not (Confirm-Action "Escrever $($pairs.Count) bytes de `"$Path`" de volta na EEPROM?")) { return 1 }
    foreach ($p in $pairs) {
        if (-not (Write-EepromByte -TargetIp $TargetIp -Addr ([int]$p.Name) -Value ([int]$p.Value))) {
            Write-Host "Falha ao escrever no endereco $($p.Name)."
            return 1
        }
    }
    Write-Host 'Restauracao feita e verificada. Desligue e ligue a impressora.'
    return 0
}

# ----------------------------------------------------------------------------
switch ($Action) {
    'status'     { exit (Invoke-StatusAction -TargetIp $Target) }
    'temp-reset' { exit (Invoke-TempResetAction -TargetIp $Target) }
    'reset'      { exit (Invoke-ResetAction -TargetIp $Target) }
    'restore'    { exit (Invoke-RestoreAction -TargetIp $Target -Path $BackupFile) }
}
