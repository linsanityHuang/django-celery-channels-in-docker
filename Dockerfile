FROM python:3.7.4
ENV PYTHONUNBUFFERED 1

# 安装一些必要的软件
RUN apt-get update && \
    apt-get upgrade -y && \ 	
    apt-get install -y \
    git \
    supervisor \
	nginx \
    net-tools \
    tcpdump \
    sqlite3 && \
   rm -rf /var/lib/apt/lists/*

# 复制supervisor配置文件
COPY supervisor/supervisord.conf /etc/supervisor/supervisord.conf
COPY supervisor/supervisor-app.conf /etc/supervisor/conf.d/

# 创建工作目录
RUN mkdir /mysite

# 切换到工作目录
WORKDIR /mysite

# 将应用目录内的文件复制到工作目录中
ADD ./mysite /mysite

# 更新pip及安装依赖
RUN pip install -i http://pypi.douban.com/simple --trusted-host pypi.douban.com --upgrade pip
RUN pip install -i http://pypi.douban.com/simple --trusted-host pypi.douban.com -r requirements.txt

# 设置环境变量
ENV foo=bar

# 使django 初始化脚本可执行
RUN chmod +x /mysite/start.sh

# 复制Nginx配置文件
COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY nginx/nginx-app.conf /etc/nginx/sites-available/

RUN mkdir -p /run/daphne/

# /etc/nginx/sites-available/default
# 注释listen [::]:80 default_server;
# 覆盖文件/etc/nginx/sites-available/default
COPY nginx/default /etc/nginx/sites-available/default

# 对外暴露端口
EXPOSE 8001 9001

CMD ["supervisord", "-n"]
