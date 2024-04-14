import configparser
import qbittorrentapi
import logging
import time

logging.basicConfig(level=logging.INFO, format='%(levelname)s - %(message)s')


def read_config():
    config = configparser.ConfigParser()
    try:
        config.read('config.ini', encoding='utf-8')
    except configparser.Error as e:
        logging.error(f"配置文件读取错误: {e}")
        raise

    conn_info = {
        'host': config.get('qbittorrent', 'host'),
        'port': config.get('qbittorrent', 'port'),
        'username': config.get('qbittorrent', 'username'),
        'password': config.get('qbittorrent', 'password'),
    }

    resume_time = int(config.get('qbittorrent', 'ResumeTime'))
    if resume_time <= 0:
        logging.error("ResumeTime配置错误，需要一个大于0的值")
        raise ValueError("ResumeTime配置错误")

    return conn_info, resume_time


def auth_and_listen(qbt_client, resume_time):
    try:
        qbt_client.auth_log_in()
    except qbittorrentapi.exceptions as e:
        logging.error(f"登录失败: {e}")
        return

    while True:
        logging.info("正在检查种子状态...")
        try:
            for torrent in qbt_client.torrents_info(status_filter='paused'):
                # 检测种子添加时间是否超过设定时间
                if time.time() > (torrent.added_on + resume_time):
                    # 开始下载种子
                    qbt_client.torrents_resume(torrent.hash)
                    logging.info(f"{torrent.name} 添加时间超过{resume_time}秒，开始下载")
        except qbittorrentapi.exceptions as e:
            logging.error(f"API调用错误: {e}")
        logging.info("检查完成，等待下一次检查...")
        time.sleep(60)  # 减轻API调用频率，每分钟检查一次


def main():
    conn_info, resume_time = read_config()
    try:
        qbt_client = qbittorrentapi.Client(**conn_info)
    except qbittorrentapi.exceptions as e:
        logging.error(f"客户端初始化失败: {e}")
        return

    auth_and_listen(qbt_client, resume_time)


if __name__ == "__main__":
    main()
