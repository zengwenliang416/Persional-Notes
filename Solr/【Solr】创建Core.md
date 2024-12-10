遇到 `  new_core` 显示 401 错误，通常意味着Solr需要身份验证。以下是几种可能的解决方案：

1. **设置环境变量**：您可以设置环境变量来提供认证信息。例如，在Solr 6中，可以通过设置以下两个环境变量来完成这项工作：
```bash
export SOLR_AUTH_TYPE='basic'
export SOLR_AUTHENTICATION_OPTS='-Dbasicauth=username:password'
export SOLR_AUTHENTICATION_OPTS='-Dbasicauth=admin:nvp_18CL'
```
   这样您就可以在同一个控制台会话中发出 `bin/solr create` 命令了。

2. **禁用安全性**：如果您暂时不需要安全性，可以禁用Solr的安全性来创建core。这涉及到编辑 `webdefault.xml` 文件，注释掉相关的安全配置，然后重启Solr。以下是具体的步骤：
   ```bash
   sudo nano /opt/solr/server/etc/webdefault.xml
   ```
   注释掉 `<security-constraint>` 和 `<login-config>` 部分，然后重启Solr：
   ```bash
   sudo service solr restart
   ```
   创建core后再将安全性配置恢复。

3. **使用正确的身份验证信息**：如果您的Solr服务器配置了基本认证，确保您在创建core时提供了正确的用户名和密码。这可以通过命令行参数或者环境变量来实现。

4. **检查Solr配置**：确保Solr的配置文件 `security.json` 中的设置是正确的，并且您有权限访问Solr的管理界面。

5. **使用API创建Core**：如果命令行工具不起作用，您可以尝试使用Solr的API来创建Core。这通常需要发送一个HTTP请求到Solr的API端点，并包含必要的认证信息。