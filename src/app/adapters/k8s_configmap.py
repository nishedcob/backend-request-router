
from typing import Callable

from adapters.k8s_api import KubernetesAPIAdapter


class FindKubernetesConfigMapsAdapter(KubernetesAPIAdapter):
    def __init__(self, adapter_filter: Callable = None):
        super().__init__()
        self.filter = adapter_filter
        if self.filter is None:
            self.filter = lambda configmap: True
        self._data = list(filter(self.filter, self.find_config_maps()))
        self.client = None

    def find_config_maps(self):
        return self.client.list_config_map_for_all_namespaces().items
    
    @property
    def data(self):
        return self._data


class FindBRRConfigMapsAdapter(FindKubernetesConfigMapsAdapter):
    def __init__(self):
        super().__init__(lambda configmap: configmap.metadata.name == 'ingress-rules')


class KubernetesConfigMapAdapter(KubernetesAPIAdapter):
    def __init__(self, namespace, name):
        super().__init__()
        self.namespace = namespace
        self.name = name
        self._data = self.client.read_namespaced_config_map(name, namespace).data
        self.client = None
    
    @property
    def data(self):
        return self._data


