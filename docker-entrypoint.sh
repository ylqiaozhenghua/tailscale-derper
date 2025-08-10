#!/bin/bash

set -e

# 使用环境变量设置默认值
DOMAIN_NAME=${DOMAIN_NAME:-"127.0.0.1"}
DERPER_PORT=${DERPER_PORT:-443}
COMMAND_LINE=${COMMAND_LINE:-""}
ADVANCED_MODE=${ADVANCED_MODE:-"false"}

# 函数：检查端口是否为有效整数
is_integer() {
    [[ $1 =~ ^[0-9]+$ ]] && [ "$1" -ge 0 ] && [ "$1" -le 65535 ]
}

# 检查 DERPER_PORT 是否为有效整数
if ! is_integer "$DERPER_PORT"; then
    echo "Error: DERPER_PORT must be an integer between 0 and 65535."
    exit 1
fi

# SSL 文件路径
CRT_BASE_PATH="/opt/ssl"
KEY_FILE="$CRT_BASE_PATH/$DOMAIN_NAME.key"
CRT_FILE="$CRT_BASE_PATH/$DOMAIN_NAME.crt"

# 输出信息
print_input_info() {
    echo "Your input domain name is: $DOMAIN_NAME"
    echo "Your input derper port is: $DERPER_PORT"
    echo "Advanced mode is set to: $ADVANCED_MODE"
    echo "Your input derper add-on command line is: $COMMAND_LINE"
}

# 函数：检查输入是否为有效的IP地址
is_ip() {
    local ip="$1"
    [[ "$ip" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]
}

check_ssl_cert() {
    # 检查密钥和证书文件是否存在
    if [ -f "$KEY_FILE" ] && [ -f "$CRT_FILE" ]; then
        echo "SSL certificate and key already exist. Skipping certificate generation."
    else
	# 根据输入类型生成 SSL 证书
        if is_ip "$DOMAIN_NAME"; then
            # 生成 IP 地址证书
            openssl req -x509 -newkey rsa:4096 -sha256 -days 3650 -nodes \
                -keyout "$KEY_FILE" \
                -out "$CRT_FILE" \
                -subj "/CN=$DOMAIN_NAME" \
                -addext "subjectAltName=IP:$DOMAIN_NAME"
        else
            # 生成域名证书
            openssl req -x509 -newkey rsa:4096 -sha256 -days 3650 -nodes \
                -keyout "$KEY_FILE" \
                -out "$CRT_FILE" \
                -subj "/CN=$DOMAIN_NAME" \
                -addext "subjectAltName=DNS:$DOMAIN_NAME"
        fi
    fi
}

print_input_info

# 启动 derper，根据高级模式选择参数
if [[ "$ADVANCED_MODE" == "true" ]]; then
    echo "Running derper in advanced mode with command line: $COMMAND_LINE"
    derper $COMMAND_LINE
else
    echo "Running derper in normal mode."
    check_ssl_cert
    derper -certmode manual -certdir $CRT_BASE_PATH -hostname $DOMAIN_NAME -a :$DERPER_PORT $COMMAND_LINE
fi
