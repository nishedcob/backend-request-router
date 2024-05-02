
from kubernetes import client, config


class KubernetesAPIAdapter:

    @staticmethod
    def get_client():
        config.load_kube_config()
        return client.CoreV1Api()

    def __init__(self):
        self.client = self.get_client()
