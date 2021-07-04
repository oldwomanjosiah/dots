import subprocess
import time

from i3notifier.config import Config
from i3notifier.utils import RunAsyncFactory

class DefaultConfig(Config):
    pre_action_hooks = [
        # Start a script to listen for urgent workspaces & switch to it
        RunAsyncFactory(lambda n: subprocess.call("switch-to-urgent.py")),
        # Wait for the script become available
        lambda n: time.sleep(0.2),
    ]


config_list = [
    DefaultConfig,
]


theme = "upper" # sidebar or widget
