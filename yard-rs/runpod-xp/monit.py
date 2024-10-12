#!/usr/bin/env python
import fire
import logging
import os
import runpod
from discord import SyncWebhook
import pexpect

POLL_PERIOD = 5  # 5 seconds
MAX_WAIT_TIME = 60 * 10  # 10 minutes

# 15 minutes to prevent accidental starting a pod and forgot to stop
DEFAULT_STOP_AFTER = 60 * 15
# 24 hours to prevent accidental starting a pod and forgot to terminate
DEFAULT_TERMINATE_AFTER = 60 * 60 * 24

logging.basicConfig(level=os.getenv("LOG_LEVEL", "DEBUG"))

# os.environ["RUNPOD_DEBUG"] = 'true'


def notify_discord(msg):
    webhook = SyncWebhook.from_url(os.getenv("DISCORD_WEBHOOK_URL"))
    webhook.send(msg)


def log_info(msg):
    logging.info(msg)
    notify_discord(msg)


def log_error(msg, exc_info=None):
    logging.error(msg, exc_info=exc_info)
    if exc_info is not None:
        notify_discord(f'{msg}: {exc_info}')
    else:
        notify_discord(msg)


def terminate(pod):
    runpod.terminate_pod(pod['id'])
    log_info(f"Pod {pod['id']} terminated")


def monit_runpod(**kwargs):
    runpod_api_key = os.getenv("RUNPOD_API_KEY")

    if runpod_api_key is None:
        raise ValueError("No RUNPOD_API_KEY environment variable found")

    runpod.api_key = runpod_api_key

    try:
        myself = runpod.get_myself()['myself']

        logging.info(f"RunPod overview: {myself}")

        if myself is not None:
            msg = ""
            pods = myself['pods']
            if len(pods) > 0:
                msg = f"{len(pods)} pods running, spending ${myself['currentSpendPerHr']} per hour:\n```\n" # noqa
                msg += "STATUS\tID          \tCPU%\tMEM%\tGPU%\tVRAM%\tUptime\n" # noqa

                idle_count = 0

                for pod in pods:
                    id = pod['id']
                    runtime = pod['runtime']
                    if runtime is not None:
                        uptime = runtime['uptimeInSeconds']
                        stat = pod['latestTelemetry']
                        cpu = stat['cpuUtilization']
                        ram = stat['memoryUtilization']
                        gpu = stat['averageGpuMetrics']['percentUtilization']
                        vram = stat['averageGpuMetrics']['memoryUtilization']

                        if gpu > 0.8 and vram > 0.5:
                            status = 'Train'
                        elif cpu > 0.5:
                            status = 'Load'
                        else:
                            status = 'Idle'
                            idle_count += 1
                        msg += f'{status}\t{id}\t{cpu}%\t{ram}%\t{gpu}%\t{vram}%\t{uptime / 60.0:.2f} min\n'  # noqa
                    else:
                        msg += f'Booting\t{id}\n'

                msg += "```"

                logging.info(msg)

                if idle_count > 0:
                    log_info(msg)
            else:
                log_info('No pod running, disabling monit')
                pexpect.run('gh workflow disable runpod-monit.yml')
    except Exception as ex:
        log_error("Something went wrong with monit_runpod", exc_info=ex)


if __name__ == "__main__":
    fire.Fire(monit_runpod)
