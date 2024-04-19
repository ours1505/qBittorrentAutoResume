# qBittorrent 进种暂停后自动恢复
## 引言
_可恶的HDSKY，盒子刷流居然前1小时不给计入流量！！太坏了！我们要想办法防止自己被白嫖！_

## 思路
监听qbittorrent的种子状态，当状态为`Paused`，且添加时长大于设定时间时，开始种子

## 话不多说，开始吧
这里是一个配合RSS使用的脚本，在RSS任务中需要勾选`添加种子时暂停`选项。  
``` shell
bash <(wget -qO- https://raw.githubusercontent.com/ours1505/qBittorrentAutoResume/master/main.sh)
```
按照提示输入相关信息即可 程序会自动运行，每60秒检测一次  
后续日志查看：
```shell
journalctl -u qBittorrentAutoResume.service
```
开启：
```shell
systemctl start qBittorrentAutoResume.service
```
关闭：
```shell
systemctl stop qBittorrentAutoResume.service
```
重载
```shell
systemctl restart qBittorrentAutoResume.service
```
## 配置文件
```shell
vim /opt/qBittorrentAutoResume/config.ini
```
## 注意
如果qbittorrent运行在docker中，127.0.0.1将无法连接到qb！请使用dockerIP或者直接使用主机公网IP  
设置图片
![1713535735686.png](https://img2.imgtp.com/2024/04/19/pykysAIG.png)