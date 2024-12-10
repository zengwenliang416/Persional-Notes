![[Pasted image 20241202105323.png]]
```dockerfile
#使用轻量级基础镜像
FROM solr:8.11.1
#创建工作目录
# WORKDIR /opt/solr
# 在/opt/3olr/server/solr下新建it3p目录
USER root
RUN mkdir -p /var/solr/data/itsp
#覆盖3 ecurity.j3on
COPY security.json /opt/solr-8.11.1/server/solr/security.json
#复制conf文件夹到it3p目录下
RUN cp -r /opt/solr-8.11.1/server/solr/configsets/_default/conf /var/solr/data/itsp/conf
RUN chowr -R solr /var/solr/data/itsp
USER solr
# 暴露端口
EXPOSE 8983
#启动so1r
CMD ["sh","-c","/opt/solr/bin/solr start -f"]
```
