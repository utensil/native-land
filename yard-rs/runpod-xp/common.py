import os
import logging
from discord import SyncWebhook

logging.basicConfig(level=os.getenv("LOG_LEVEL", "INFO"))


# TODO: avoid code dup
def notify_discord(msg):
    webhook = SyncWebhook.from_url(os.getenv("DISCORD_WEBHOOK_URL"))
    return webhook.send(msg, wait=True)


def log_info(msg):
    logging.info(msg)
    return notify_discord(msg)


def log_error(msg, exc_info=None):
    logging.error(msg, exc_info=exc_info)
    if exc_info is not None:
        return notify_discord(f'{msg}: {exc_info}')
    else:
        return notify_discord(msg)


def edit_discord_message(last_msg, msg):
    if last_msg is None:
        return notify_discord(msg)
    else:
        return last_msg.edit(content=msg)
