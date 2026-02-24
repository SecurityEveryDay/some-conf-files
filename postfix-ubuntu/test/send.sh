#!/bin/bash

apt install swaks jq

# Verificação de argumentos
if [ "$#" -ne 2 ]; then
    echo "Uso: $0 from.txt to.txt"
    echo "Nota: msg.json deve estar no mesmo diretório"
    exit 1
fi

FROM_FILE="$1"
TO_FILE="$2"
#MSG_FILE="msg.json"
MSG_FILE="msg_ext.json"
SMTP_SERVER="mail.hr-system.lab:25"
LOG_FILE="envios_$(date +%Y%m%d_%H%M%S).log"

# Verificar se os arquivos existem
for FILE in "$FROM_FILE" "$TO_FILE" "$MSG_FILE"; do
    if [ ! -f "$FILE" ]; then
        echo "Arquivo não encontrado: $FILE"
        exit 1
    fi
done

# Carregar listas em arrays
mapfile -t FROM_LIST < "$FROM_FILE"
mapfile -t TO_LIST < "$TO_FILE"

TOTAL_FROM=${#FROM_LIST[@]}
TOTAL_TO=${#TO_LIST[@]}

if [ "$TOTAL_FROM" -eq 0 ]; then
    echo "Arquivo $FROM_FILE está vazio."
    exit 1
fi

if [ "$TOTAL_TO" -eq 0 ]; then
    echo "Arquivo $TO_FILE está vazio."
    exit 1
fi

# Ler quantidade de mensagens no JSON
TOTAL_MSGS=$(jq 'length' "$MSG_FILE")

echo "========================================" | tee -a "$LOG_FILE"
echo "Início: $(date)"                          | tee -a "$LOG_FILE"
echo "Remetentes (from): $TOTAL_FROM"           | tee -a "$LOG_FILE"
echo "Destinatários (to): $TOTAL_TO"            | tee -a "$LOG_FILE"
echo "Mensagens encontradas: $TOTAL_MSGS"       | tee -a "$LOG_FILE"
echo "========================================" | tee -a "$LOG_FILE"

# Iterar sobre cada mensagem
for i in $(seq 0 $(( TOTAL_MSGS - 1 ))); do
    SUBJECT=$(jq -r ".[$i].subject" "$MSG_FILE")
    BODY=$(jq -r ".[$i].body" "$MSG_FILE")

    # Selecionar from e to aleatórios
    FROM="${FROM_LIST[$((RANDOM % TOTAL_FROM))]}"

    # Garantir que from e to não sejam iguais
    while true; do
        TO="${TO_LIST[$((RANDOM % TOTAL_TO))]}"
        [ "$FROM" != "$TO" ] && break
    done

    echo "" | tee -a "$LOG_FILE"
    echo "[$(date +%Y-%m-%d\ %H:%M:%S)] Mensagem $((i+1)) de $TOTAL_MSGS" | tee -a "$LOG_FILE"
    echo "  FROM   : $FROM"    | tee -a "$LOG_FILE"
    echo "  TO     : $TO"      | tee -a "$LOG_FILE"
    echo "  SUBJECT: $SUBJECT" | tee -a "$LOG_FILE"

    RESULTADO=$(swaks \
        --from "$FROM" \
        --to "$TO" \
        --server "$SMTP_SERVER" \
        --body "$BODY" \
        --header "Subject: $SUBJECT" 2>&1)

    STATUS=$?

    if [ $STATUS -eq 0 ]; then
        echo "  STATUS : ✅ Enviado com sucesso" | tee -a "$LOG_FILE"
    else
        echo "  STATUS : ❌ Falha no envio (código $STATUS)" | tee -a "$LOG_FILE"
        echo "  ERRO   : $RESULTADO"                         | tee -a "$LOG_FILE"
    fi

done

echo ""                                   | tee -a "$LOG_FILE"
echo "========================================"  | tee -a "$LOG_FILE"
echo "Fim: $(date)"                       | tee -a "$LOG_FILE"
echo "Log salvo em: $LOG_FILE"
