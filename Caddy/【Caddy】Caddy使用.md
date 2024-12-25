# 【Caddy】Caddy使用

## 目录

[1. 目录](#目录)

[2. 安装 Caddy](#安装-caddy)

- [2.1 在 Ubuntu/Debian 上](#在-ubuntudebian-上)

- [2.2 在 macOS 上](#在-macos-上)

[3. 启动文件服务器](#启动文件服务器)

- [3.1 使用命令行启动](#使用命令行启动)

- [3.2 使用 Caddyfile 配置文件](#使用-caddyfile-配置文件)

[4. 反向代理和自动 HTTPS](#反向代理和自动-https)

- [4.1 反向代理](#反向代理)

- [4.2 自动 HTTPS](#自动-https)

[5. 常用命令](#常用命令)

[6. 高级用法](#高级用法)

- [6.1 使用 API 和动态配置](#使用-api-和动态配置)

- [6.2 性能优化](#性能优化)

[7. 插件和扩展](#插件和扩展)

[8. 结论](#结论)



## 安装 Caddy

### 在 Ubuntu/Debian 上

1. 添加 Caddy 的 GPG 密钥和软件源：
```sh
sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
sudo apt update
```

2. 安装 Caddy：
```sh
sudo apt install caddy
```

### 在 macOS 上

使用 Homebrew 安装 Caddy：
```sh
brew install caddy
```

## 启动文件服务器

### 使用命令行启动

假设您的静态文件存放在 `/var/www/html` 目录下。使用以下命令启动文件服务器：

```sh
caddy file-server --root /var/www/html --listen :8080
```

- `--root /var/www/html`：指定文件服务器的根目录。
- `--listen :8080`：指定 Caddy 监听的端口号。

### 使用 Caddyfile 配置文件

1. 创建 `Caddyfile` 文件：
   ```sh
   touch Caddyfile
   ```

2. 添加如下配置：
   ```Caddyfile
   :8080 {
       root * /path/to/files
       file_server
   }
   ```

3. 启动 Caddy：
   ```sh
   caddy run --config Caddyfile
   ```

## 反向代理和自动 HTTPS

### 反向代理

将请求代理到本地服务：

```Caddyfile
example.com {
    reverse_proxy localhost:8080
}
```

### 自动 HTTPS

Caddy 会自动处理和更新 SSL 证书。只需配置域名：

```Caddyfile
example.com {
    root * /var/www
    file_server
}
```

## 常用命令

- `caddy run`: 在前台运行 Caddy。
- `caddy start`: 在后台启动 Caddy。
- `caddy stop`: 停止 Caddy。
- `caddy reload`: 重新加载配置文件。
- `caddy fmt`: 格式化 Caddyfile。

## 高级用法

### 使用 API 和动态配置

Caddy 提供一个 HTTP API，用于动态更新配置：

```sh
curl localhost:2019/config/ -X POST -H "Content-Type: application/json" -d @caddy.json
```

### 性能优化

为高流量网站启用压缩和缓存：

```Caddyfile
example.com {
    encode gzip
    file_server {
        precompressed gzip
    }
}
```

## 插件和扩展

Caddy 支持插件扩展。使用 `xcaddy` 构建自定义版本：

```sh
xcaddy build --with <plugin>
```

## 结论

Caddy 是一个灵活且易于使用的 Web 服务器，适合各种 Web 服务场景。从简单的静态文件托管到复杂的反向代理和 API 网关，Caddy 提供了强大的功能支持。建议查阅 [Caddy 官方文档](https://caddyserver.com/docs/) 以了解更多高级用法和最佳实践。
