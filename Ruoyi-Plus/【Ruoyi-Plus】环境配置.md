使用4.X分支进行学习

# 前置环境

```
jdk 1.8
```

# node.js

## 安装卸载

**[官方](https://nodejs.org/en/about/previous-releases)下载pkg包**

```
安装：
1，下载官方提供的pkg包
2，安装
卸载：
1，命令行输入：which node #查看node安装位置，一般都在/usr/local/node
2，命令行输入：sudo rm -rf /usr/local/{bin/{node,npm},lib/node_modules/npm,lib/node,share/man/*/node.*}
```

**brew**

```
安装：
1、命令行输入：brew search node #查看可安装版本
2、命令行输入：brew install node@14 #node@14为命令1中获取的可用版本
3、命令行输入：ln -s ~/.nvm/versions/node/ /usr/local/Cellar/ #建立软连接
卸载：
命令行输入：brew uninstall node --force
```

**nvm**

```
安装：
1、命令行输入：brew install nvm  #安装nvm
1.1、修改 ～/. bash_profile中环境变量
1.2、变量内容为：
  export NVM_DIR="$HOME/.nvm"
  [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && . "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
  [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && . "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" 
1.3、命令行输入：source ~/.bash_profile
2、命令行输入：nvm ls-remote #查看可安装node版本
3、命令行输入：nvm install v12.13.0 #安装node12.13.0版本
nvm常用命令：
nvm uninstall [version] #卸载指定版本
nvm use [--silent] [version] #切换到指定版本
nvm ls #查看已安装版本
```

## 多版本管理

```
sudo npm install -g n
# 更换源
export N_NODE_MIRROR=https://npm.taobao.org/mirrors/node
sudo -E n 18.15.0
sudo n list
sudo n
```

![image.png](./imgs/1704728456314-ed2d2db5-bc77-4f38-a487-b450255e535c.png)

# Redis

```
# %redisName %redisPassword 这里我没有设置密码
docker run -itd --name %redisName -p 6379:6379 redis --requirepass %redisPassword
```

同时安装redis管理工具：Another Redis Desktop Manager