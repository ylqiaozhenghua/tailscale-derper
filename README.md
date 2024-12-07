# tailscale-derper

The original tailscale-derper tool added the validation mechanism of the SSL certificate, which made the self-signed certificate unusable, and the following validation mechanism was turned off to make the Derper tool run normally.

https://github.com/tailscale/tailscale/blob/main/cmd/derper/cert.go

```go
func (m *manualCertManager) getCertificate(hi *tls.ClientHelloInfo) (*tls.Certificate, error) {
	if hi.ServerName != m.hostname && !m.noHostname {
		return nil, fmt.Errorf("cert mismatch with hostname: %q", hi.ServerName)
	}
    ...
```

The image integrates the automatic certificate generator and automatically generates the SSL self-signed certificate of the corresponding configured domain name according to the CMD parameters in the Dokcerfile, and the default CMD parameters are:

You can control the working behavior of the derper through environment variables.
By default, four environment variables are received, and the specific names and functions are as follows.

1. `DOMAIN_NAME`[dafault:`derper.example.com`]
    - You should modify this environment variable according to your own needs, notice it is a self-signed SSL certificate.
    - The default storage location for certificates is /opt/ssl/ You can pass in the certificates you need as needed.
    - Self-signed IP address certificates are supported.
2. `DERPER_PORT`[default:`443`]
    - The port that derper runs on, you can modify it according to your needs.
3. `COMMAND_LINE`
    - For additional derper argument commands, you should enter the derper command arguments as they are, and multiple arguments should be included in double quotes.
4. `ADVANCED_MODE`[default:false]
    - SSL certificates are not automatically generated in advanced mode, and you need to manually specify all the Derper run parameters explicitly in command_line

example docker run command⌘

```bash
docker run -it --rm -e DOMAIN_NAME=test.com -e DERPER_PORT=2333 -p 2333:2333 ghcr.io/expoli/tailscale-derper:main
```

## tailscale ACL config example

```json
	// ... other parts of ACL/Policy JSON
	"derpMap": {
		// "OmitDefaultRegions": true,
		"Regions": {
			"900": {
				"RegionID":   900,
				"RegionCode": "cn",
				"RegionName": "my-cn-derps",
				"Nodes": [
					{
						"Name":             "Tencent Beijing 1",
						"RegionID":         900,
						"HostName":         "xxx.xxx.xxx.xxx",
						"IPv4":             "xxx.xxx.xxx.xxx",
						"DERPPort":         443,
						"STUNPort":         3478,
						"InsecureForTests": true,
						"CanPort80":        false,
					},
				],
			},
		},
	},
```

---

tailscale-derper 原始工具添加了 ssl 证书的验查机制，导致自签名证书无法使用，通过关闭下面的验查机制让 derper 工具能够正常运行。

https://github.com/tailscale/tailscale/blob/main/cmd/derper/cert.go

```go
func (m *manualCertManager) getCertificate(hi *tls.ClientHelloInfo) (*tls.Certificate, error) {
	if hi.ServerName != m.hostname && !m.noHostname {
		return nil, fmt.Errorf("cert mismatch with hostname: %q", hi.ServerName)
	}
    ...
```

该镜像集成了证书自动生成程序，并根据所传入的环境变量自动生成对应配置域名的 ssl 自签证书，你可以通过环境变量来控制 derper 的工作行为。
默认接收四个环境变量具体的名称与作用如下

1. `DOMAIN_NAME`[默认值:derper.example.com]
    - 第一个参数为自签证书的域名，你应该根据自己的需求去修改它，注意这是自签名证书。
    - 证书默认存储位置 `/opt/ssl/` 你可以根据需要自己传入自己需要的证书
    - 支持自签 IP 地址证书
2. `DERPER_PORT`[默认值:443]
    - 第二个参数为 derper 程序运行的端口，根据自己的需求去修改定制
3. `COMMAND_LINE`[默认为空]
    - 其他额外的 derper 参数命令，你应该原样输入 derper 命令参数，多个参数应该使用双引号包括起来
4. `ADVANCED_MODE`[默认值:false]
    - 高级模式，高级模式下，derper 所有的参数都从 COMMAND_LINE 环境变量中读取，不再自动自签证书。

docker 运行命令示例⌘

```bash
docker run -it --rm -e DOMAIN_NAME=test.com -e DERPER_PORT=2333 -p 2333:2333 ghcr.io/expoli/tailscale-derper:main
```

## tailscale ACL 配置示例

```json
	// ... other parts of ACL/Policy JSON
	"derpMap": {
		// "OmitDefaultRegions": true,
		"Regions": {
			"900": {
				"RegionID":   900,
				"RegionCode": "cn",
				"RegionName": "my-cn-derps",
				"Nodes": [
					{
						"Name":             "Tencent Beijing 1",
						"RegionID":         900,
						"HostName":         "xxx.xxx.xxx.xxx",
						"IPv4":             "xxx.xxx.xxx.xxx",
						"DERPPort":         443,
						"STUNPort":         3478,
						"InsecureForTests": true,
						"CanPort80":        false,
					},
				],
			},
		},
	},
```
