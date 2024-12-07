# 编译
FROM golang:alpine AS builder

# 切换模块源为中国Go模块代理服务器
# RUN go env -w GOPROXY=https://goproxy.cn,direct \
#     && go env -w CGO_ENABLED=0

# 拉取代码
RUN go env -w CGO_ENABLED=0 && \
    go install tailscale.com/cmd/derper@latest

# 去除域名验证（使用 sed 查找然后直接删除域名验证三行代码）
RUN sed -i '/if hi.ServerName != m.hostname && !m.noHostname {/,+2d' /go/pkg/mod/tailscale.com@*/cmd/derper/cert.go

# 编译
RUN derper_dir=$(find /go/pkg/mod/tailscale.com@*/cmd/derper -type d) && \
	cd $derper_dir && \
    go build -o /opt/derp/derper

# 生成最终镜像
FROM alpine:latest

WORKDIR /apps

COPY --from=builder /opt/derp/derper /bin/derper

RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo 'Asia/Shanghai' > /etc/timezone

ENV LANG=C.UTF-8

# 创建软链接 解决二进制无法执行问题 Amd架构必须执行，Arm不需要执行
# RUN mkdir /lib64 && ln -s /lib/libc.musl-x86_64.so.1 /lib64/ld-linux-x86-64.so.2

# 添加源
# RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories

# 安装openssl
RUN apk add openssl bash && mkdir /opt/ssl/

# 暴露 TCP 和 UDP 端口
EXPOSE 443/tcp
EXPOSE 3478/udp

COPY ./docker-entrypoint.sh /apps/docker-entrypoint.sh

ENTRYPOINT ["./docker-entrypoint.sh"]
