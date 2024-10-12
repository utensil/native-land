import os
import sys
import runpod
sys.path.insert(0, ".")
from common import log_info  # noqa: F403,E402


runpod.api_key = os.getenv("RUNPOD_API_KEY")

pod_id = os.getenv("RUNPOD_POD_ID")

log_info(f"Pod {pod_id} terminated on train error")  # noqa: F405

runpod.terminate_pod(pod_id)
