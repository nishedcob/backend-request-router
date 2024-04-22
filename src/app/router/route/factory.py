
import requests
from starlette.responses import Response
from starlette.routing import Route


def create_route(route_config: dict):
    path_config = route_config.get('path')
    origin_config = path_config.get('origin')
    path = "/" + origin_config.get('prefix') + "/" + origin_config.get('environment') + "/" + origin_config.get('service') + "/{path:path}"
    destination_config = path_config.get('destination')
    destination = "http://" + destination_config.get('service') + "." + destination_config.get('namespace') + ":" + str(destination_config.get('port'))
    print(f"{path} => {destination}")
    async def route(request):
        requested_path = request.url.path
        # request_path = requested_path[len(path) - 1:]
        path = request.path_params['path']
        print(f"{requested_path} => {destination}/{path}")
        body = await request.body()
        response = requests.request(
            method=request.method,
            url=destination + "/" + path,
            headers=request.headers,
            data=body
        )
        return Response(
            content=response.content,
            status_code=response.status_code,
            headers=response.headers
        )
    return Route(path, route)
