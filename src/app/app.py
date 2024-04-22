
from starlette.applications import Starlette
import yaml

from adapters.k8s_configmap import FindBRRConfigMapsAdapter
from router.prefix import PrefixBasedRouter

found_configmaps = FindBRRConfigMapsAdapter().data
# print(f'{found_configmaps=}')
ingress_rules_configmaps = [ configmap.data for configmap in found_configmaps ]
# print(f'{ingress_rules_configmaps=}')
rules = [
    rules
    for configmap in ingress_rules_configmaps
        for rules in yaml.safe_load(configmap.get('rules'))
]
# rules = ingress_rules_configmaps

# import json
# # print(f"{rules=}")
# print(json.dumps(rules, indent=2))
router = PrefixBasedRouter(rules).router

# print(router)

app = Starlette(debug=True, routes=router)
