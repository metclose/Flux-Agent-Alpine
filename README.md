# Flux-Agent-Alpine

- 在 Alpine Linux 上一键部署 Flux Agent（开发版），官方的 Flux Agent 一键命令不支持 Alpine，于是写个专属 Alpine 的脚本。

## 脚本做了什么

- 从官方 Flux Panel 仓库下载对应架构的二进制文件。
- 生成官方格式的 `config.json`（面板地址、节点密钥），并保留 `gost.json` 中的转发规则。
- 写入 OpenRC 服务脚本，启动服务并设置开机自启。

## 一键安装

```bash
curl -fsSL https://raw.githubusercontent.com/metclose/Flux-Panel-Alpine/main/install.sh | \
  sh -s -- 'https://你的面板地址' '你的节点密钥'
