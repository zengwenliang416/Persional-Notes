# 【Mac】文件位置

## 配置文件

| 名称        | 位置                           |
| --------- | ---------------------------- |
| 环境变量文件    | ~/.zshrc                     |
| Redis配置文件 | /opt/homebrew/etc/redis.conf |
| Hosts文件位置 | /ect/hosts                   |
|           |                              |

```bash
ps -a | grep jmeter | grep -v grep | awk '{print $1}' | xargs kill -15

lsof -i :8080 -t | xargs kill -15
```
