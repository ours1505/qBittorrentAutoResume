#!/usr/bin/env bash

# 安装依赖
apt install -y python3-pip
pip3 install qbittorrent-api --break-system-packages

mkdir /opt/qBittorrentAutoResume

wget -qO- https://raw.githubusercontent.com/ours1505/qBittorrentAutoResume/master/main.py > /opt/qBittorrentAutoResume/main.py

# 读取用户输入并进行基础验证
echo 请输入您的qbittorrent的IP地址：（如果qbittorrent运行在docker中，127.0.0.1将无法连接到qb！请使用dockerIP或者直接使用主机公网IP）
read qbittorrent_ip
[[ $qbittorrent_ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]] || { echo "无效的IP地址"; exit 1; }

echo 请输入您的qbittorrent的端口：（默认为8080）
read qbittorrent_port
[[ $qbittorrent_port =~ ^[1-9][0-9]{0,4}$ ]] || { echo "无效的端口号"; exit 1; }

echo 请输入您的qbittorrent的用户名：（默认为admin）
read qbittorrent_username

echo 请输入您的qbittorrent的密码：
read qbittorrent_password
echo

echo 请输入您想要多长时间后启动种子（单位为秒）：（因为汇报有延迟，所以建议提前十分钟，即输入3000）
read resume_time
[[ $resume_time =~ ^[1-9][0-9]*$ ]] || { echo "无效的时间间隔"; exit 1; }

cat <<EOF > /opt/qBittorrentAutoResume/config.ini
[qbittorrent]
host = $qbittorrent_ip
port = $qbittorrent_port
username = $qbittorrent_username
password = $qbittorrent_password
ResumeTime = $resume_time
EOF

# 检查配置文件写入是否成功
[[ -f /opt/qBittorrentAutoResume/config.ini ]] || { echo "写入配置文件失败"; exit 1; }

# 创建系统服务配置文件，并检查是否成功
cat <<EOF > /etc/systemd/system/qBittorrentAutoResume.service
[Unit]
Description=qBittorrentAutoResume
After=network.target

[Service]
Type=simple
WorkingDirectory=/opt/qBittorrentAutoResume
ExecStart=/usr/bin/python3 /opt/qBittorrentAutoResume/main.py
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

# 检查服务单元文件写入是否成功
[[ -f /etc/systemd/system/qBittorrentAutoResume.service ]] || { echo "写入服务单元文件失败"; exit 1; }
chmod +x /etc/systemd/system/qBittorrentAutoResume.service
# 通知系统重新加载配置，并启动服务
systemctl daemon-reload
systemctl enable --now qBittorrentAutoResume.service
echo "服务已启动，请检查是否正常运行。"
systemctl status qBittorrentAutoResume.service
