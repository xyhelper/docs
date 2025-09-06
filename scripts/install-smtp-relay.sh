#!/bin/bash
# 检查依赖
if ! command -v curl &> /dev/null || ! command -v git &> /dev/null; then
    echo "请先安装 curl 和 git"
    exit 1
fi
# 检查是否已安装 Docker 
if ! command -v docker &> /dev/null; then
    echo "请先安装 Docker"
    exit 1
fi
# 检查是否已经支持新版的 docker compose
if ! docker compose version &> /dev/null; then
    echo "请先安装支持新版的 docker compose"
    exit 1
fi
# 克隆仓库
git clone --depth=1 https://github.com/xyhelper/xyhelper-smtp-relay-deploy.git smtp-relay
cd smtp-relay || { echo "进入目录失败"; exit 1; }
if [ ! -f .env.sample ]; then
    echo "未找到 .env.sample 文件，请检查仓库内容或手动创建 .env 文件"
    exit 1
fi
cp .env.sample .env
# 提示用户编辑.env文件
echo "安装完成,请编辑 .env 文件以配置 SMTP 中继服务"
