
from router.route.factory import create_route


class PrefixBasedRouter:
    def __init__(self, rules: list):
        self.rules = rules
        self._router = []
        for rule in self.rules:
            self._router.append(create_route(rule))
    
    @property
    def router(self):
        return self._router
