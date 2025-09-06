# 快速开始

欢迎使用XYHELPER，以下是一些快速开始的资源和组件列表，帮助您快速上手。


## 项目介绍
XYHELPER是一个集成多种服务的解决方案，旨在为用户提供便捷的工具和服务。通过模块化设计，用户可以根据需求选择和部署所需的组件。
项目部署架构图如下：

![XYHELPER架构图](../images/xyhelper-architecture.png)

## 部署顺序
1. 部署`SMTP-RELAY`服务，用于邮件发送。
2. 部署`Authorizer`服务，负责用户注册和登录。
3. 部署`Ucenter`服务，进行用户和权限管理。
4. （可选）部署`Claude-Share`服务，用于共享Claude账号。
5. （可选）部署`Grok-Share`服务，用于共享Grok账号。
6. （可选）部署`ChatGPT-Share`服务，用于共享ChatGPT账号。

!> **注意**：ChatGPT-Share 暂未实现与 Ucenter 的集成，用户管理和权限管理需要在 ChatGPT-Share 内部单独配置。

## 组件列表

* [Ucenter](/ucenter/) - 用户中心，提供用户管理、权限管理，业务购买等功能
* [Authorizer](/authorizer/) - 授权服务，负责用户注册、登录等功能
* [SMTP-RELAY](/smtp-relay/) - SMTP中继服务，用于保护主服务IP地址
* [Claude-Share](/claude-share/) - Claude共享服务，用于共享Claude账号
* [Grok-Share](/grok-share/) - Grok共享服务，用于共享Grok账号
* [ChatGPT-Share](/chatgpt-share/) - ChatGPT共享服务，用于共享ChatGPT账号

