#!/usr/bin/env python
import fire
import logging
import os
import sys
import runpod
import pexpect
sys.path.insert(0, ".")
from common import log_info, log_error  # noqa: F403,E402

# os.environ["RUNPOD_DEBUG"] = 'true'


def monit(**kwargs):
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
    fire.Fire(monit)
