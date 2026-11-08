# Flux-Agent-Alpine

- 在 Alpine Linux 上一键部署 Flux Agent（开发版），官方的 Flux Agent（开发版）一键命令不支持 Alpine，于是写个专属 Alpine 的脚本。

## 脚本做了什么

- 从官方 Flux Panel 仓库下载对应架构的二进制文件。
- 生成官方格式的 `config.json`（面板地址、节点密钥），以及 `gost.json`（转发规则）。
- 写入 OpenRC 服务脚本，启动服务并设置开机自启。

## 一键安装

```bash
curl -fsSL https://raw.githubusercontent.com/metclose/Flux-Agent-Alpine/main/install.sh | \
  sh -s -- '你的面板地址' '你的节点密钥'
```

## 自定义名称和目录（可选）

- 脚本一键安装提供隐藏 Flux Agent 名称的功能，默认关闭，默认安装目录为 `/etc/flux_agent`，二进制名和服务名都是 `flux_agent`。
- 若想自定义名称和目录，可以通过环境变量覆盖：

```bash
curl -fsSL https://raw.githubusercontent.com/metclose/Flux-Agent-Alpine/main/install.sh | \
  BIN_NAME=自定义二进制名 SVC_NAME=自定义服务名 INSTALL_DIR=自定义目录 \
  sh -s -- '你的面板地址' '你的节点密钥'
```
