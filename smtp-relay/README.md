# SMTP 中继服务器

这是一个用 Go 编写的 SMTP 中继服务器，主要用于隐藏源 IP 地址，防止在邮件的 `Received` 头部中暴露真实的源 IP。

!> **注意**: 生产环境强烈建议使用单独服务器部署本服务,因为本服务器IP会暴露在邮件头部中.同时,服务器应通过防火墙或安全组限制仅允许可信IP连接.

## 功能特性
- **项目类型**: 免费不开源
- **隐藏源 IP 地址**：移除邮件中可能暴露源 IP 的头部信息
- **TLS 支持**：支持上游 SMTP 服务器的 TLS 连接
- **IP 白名单**：可配置允许连接的客户端 IP 列表
- **可配置的监听端口**和上游 SMTP 服务器
- **环境变量配置**
- 项目地址: [https://github.com/xyhelper/xyhelper-smtp-relay-deploy](https://github.com/xyhelper/xyhelper-smtp-relay-deploy)


## 工作原理

1. **客户端连接**：客户端连接到中继服务器
2. **SMTP 协议处理**：中继服务器处理标准 SMTP 命令
3. **邮件数据接收**：接收完整的邮件数据
4. **头部清理**：移除可能暴露源 IP 的信息：
   - `Received` 头部
   - `X-Originating-IP` 头部
   - `X-Remote-IP` 头部
   - `X-Real-IP` 头部
   - `X-Forwarded-For` 头部
   - `X-Sender-IP` 头部
   - `X-Source-IP` 头部
5. **添加中继头部**：添加中继服务器自己的 `Received` 头部
6. **上游转发**：通过上游 SMTP 服务器发送邮件

## 部署

- 服务器要求
  - 1核1G内存(x86架构)
  - 10G硬盘
  - Ubuntu 22.04+
  - 已安装 Docker 和 Docker-Compose
  - 服务商未限制SMTP协议的使用
  - 服务器已安装curl和git


### 一键部署脚本
```bash
bash <(curl -sSL https://xyhelper.cn/script/install-smtp-relay.sh)
```
### 配置文件

在 `smtp-relay` 目录下，有一个 `.env.example` 文件，您可以根据需要复制一份并重命名为 `.env`，然后编辑该文件以配置 SMTP 中继服务。

本示例演示为使用腾讯企业邮箱的配置，您可以根据实际使用的 SMTP 服务器进行调整。

腾讯企业邮箱(支持自定义域名),可通过申请免费的企业微信组织来获取.

```env
# .env文件内容示例
SMTP_HOST=smtp.exmail.qq.com # SMTP服务器地址
SMTP_PORT=465              # SMTP服务器端口
SMTP_USERNAME=support@xxxxx.com # SMTP用户名
SMTP_PASSWORD=xxxxxxxxxxx # SMTP密码
SENDER_EMAIL=support@xxxxx.com # 发件人邮箱地址
RELAY_LISTEN_PORT=2525     # 中继服务器监听端口
RELAY_ENABLE_TLS=true     # 是否启用TLS
RELAY_ALLOWED_CLIENTS=127.0.0.1,::1,localhost # 允许连接的客户端IP地址列表,逗号分隔
```
### 启动/更新服务
```bash
cd smtp-relay
./deploy.sh
```
### 查看日志
```bash
cd smtp-relay
docker-compose logs -f --tail=100
```
### 停止服务
```bash
cd smtp-relay
docker-compose down
```
### 重启服务
```bash
cd smtp-relay
docker-compose restart
```
### 测试服务
```bash
./simple_send.py youremail@domain.com
```
### 常见问题

1. **连接被拒绝**
   - 检查端口是否正确
   - 检查防火墙设置
   - 检查服务是否正在运行

2. **认证失败**
   - 检查上游 SMTP 服务器凭据
   - 检查网络连接

3. **邮件发送失败**
   - 检查上游服务器配置
   - 查看详细日志信息


## 扩展阅读


### 服务器直接使用SMTP协议发送邮件会暴露源IP问题解析

在日常运维和开发中，很多服务器需要通过SMTP协议发送邮件，例如报警通知、注册验证等。然而，直接在服务器上使用SMTP协议发送邮件，往往会带来一个被忽视的安全隐患——服务器的真实IP地址可能会被暴露。


#### SMTP协议简介

SMTP（Simple Mail Transfer Protocol，简单邮件传输协议）是互联网中用于传输电子邮件的标准协议。服务器通过SMTP协议将邮件发送到收件人邮箱服务器。


#### 源IP暴露的原理

当服务器通过SMTP协议直接向外部邮件服务器（如Gmail、QQ邮箱等）发送邮件时，邮件头部会自动记录邮件的传输路径。常见的邮件头字段如`Received`，会包含每一跳服务器的IP地址和主机名。

例如：

```
Received: from example.com (example.com [203.0.113.1])
	by mx.google.com with ESMTPS id ...
```

其中`203.0.113.1`就是发件服务器的真实公网IP。


#### 暴露源IP的风险

1. **隐私泄露**：攻击者可以通过邮件头分析出服务器的真实IP，进而定位服务器位置。
2. **被攻击风险增加**：一旦IP暴露，服务器更容易成为DDoS、暴力破解等攻击的目标。
3. **绕过防护**：即使服务器做了CDN、WAF等防护，邮件头中的真实IP依然可能被泄漏。


#### 如何规避源IP暴露

1. **使用第三方邮件服务**：如SendGrid、Mailgun、阿里云邮件推送等，服务器只需通过API或SMTP中继发送邮件，外部收件人看到的IP为第三方服务的IP。
2. **自建SMTP中继服务器**：在专用的跳板机或云函数上搭建SMTP中继，所有邮件先发到中继服务器，再由中继服务器转发到外部邮箱。
3. **邮件头处理**：部分中继服务支持清理或伪装`Received`等头部信息，但并非所有服务都支持，且部分收件方会因头部异常判定为垃圾邮件。


#### 实践建议

- 生产环境下，尽量避免服务器直接对外发邮件。
- 推荐使用专业的邮件中继服务，既能保护源IP，又能提升送达率。
- 定期检查邮件头，确保没有泄漏敏感信息。


#### 总结

直接使用SMTP协议发送邮件虽然方便，但存在源IP暴露的安全隐患。通过合理配置邮件中继或使用第三方服务，可以有效保护服务器的真实IP，降低被攻击风险。

