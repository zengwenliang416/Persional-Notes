# 【AAS-6296】SSI找不到文件

## Tomcat报错

### web.xml配置

```xml
<?xml version="1.0" encoding="UTF-8"?>
<web-app xmlns="http://xmlns.jcp.org/xml/ns/javaee"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://xmlns.jcp.org/xml/ns/javaee http://xmlns.jcp.org/xml/ns/javaee/web-app_4_0.xsd"
         version="4.0">
    <servlet>
        <servlet-name>ssi</servlet-name>
        <servlet-class>
            org.apache.catalina.ssi.SSIServlet
        </servlet-class>
        <init-param>
            <param-name>buffered</param-name>
            <param-value>1</param-value>
        </init-param>
        <init-param>
            <param-name>debug</param-name>
            <param-value>0</param-value>
        </init-param>
        <init-param>
            <param-name>expires</param-name>
            <param-value>666</param-value>
        </init-param>
        <init-param>
            <param-name>isVirtualWebappRelative</param-name>
            <!--这里不修改为true的话hui'chu-->
            <param-value>true</param-value>
        </init-param>
        <!--手动配置编码-->
        <init-param>
            <param-name>inputEncoding</param-name>
            <param-value>UTF-8</param-value>
        </init-param>
        <init-param>
            <param-name>outputEncoding</param-name>
            <param-value>UTF-8</param-value>
        </init-param>

        <load-on-startup>4</load-on-startup>
    </servlet>
    <servlet-mapping>
        <servlet-name>ssi</servlet-name>
        <url-pattern>*.shtml</url-pattern>
        <url-pattern>*.html</url-pattern>
    </servlet-mapping>
    <mime-mapping>
        <extension>shtml</extension>
        <mime-type>text/html</mime-type>
    </mime-mapping>
    <welcome-file-list>
        <welcome-file>index.jsp</welcome-file>
    </welcome-file-list>
</web-app>
```

## 文件目录

![image-20240117103206830](./imgs/image-20240117103206830.png)

**index.jsp**

```jsp
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<jsp:forward page="/pages/index.shtml"></jsp:forward>
```

**index.shtml**

```html
<!-- index.shtml -->
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>My SSI Page</title>
</head>
<body>
<h1>Welcome to My SSI-enabled Page!</h1>
<!--#include virtual="/common/header.html"-->
<p>This is the body of your web page.</p>
<!--#include virtual="/common/footer.html"-->
</body>
</html>
```

**header.html**

```html
<!-- header.html -->
<header>
  <h2>This is the header.</h2>
</header>
```

**footer.html**

```html
<!-- footer.html -->
<footer>
  <p>&copy; 2023 My Website</p>
</footer>
```

访问http://localhost:8080/ssi_war_exploded/显示如下：

![image-20240117103520949](./imgs/image-20240117103520949.png)

控制台报错如下：

![image-20240117103831022](./imgs/image-20240117103831022.png)

这里的报错是因为

## AAS逻辑以及出错原因分析

