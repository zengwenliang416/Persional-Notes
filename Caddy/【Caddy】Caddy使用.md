# 【Caddy】Caddy使用

Caddy 是一个功能强大的 Web 服务器，能够轻松地托管静态文件和反向代理服务。本文档将指导您如何安装 Caddy、启动文件服务器、配置 HTTPS，以及其基本用法和常见场景。

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
