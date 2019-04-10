"""Methods related to communication with BFTList nodes."""

# standard
import requests
import time
import asyncio

# local
from node import Node, get_nodes

nodes = get_nodes()


def build_payload(client_id, *args):
    """Builds a NO_OP request object to be sent to all BFTList nodes."""
    return {
        "client_id": client_id,
        "timestamp": int(time.time()),
        "operation": {
            "type": "NO_OP",
            "args": args
        }
    }


async def send_to_node(node: Node, req):
    """
    Sends the given req as a POST request to a Node.

    Tries to send the request up to 5 times with 1 second interval, will
    quit if 5 failed attempts is reached.
    """
    req_injected = False
    tries = 0
    url = f"http://{node.ip}:{node.api_port}/inject-client-req"
    # keep sending client request until API returns 200, max 5 tries
    while not req_injected and tries < 5:
        r = requests.post(url, json=req)
        tries += 1
        if r.status_code != 200:
            print(f"Could not inject req {req} to node {node.id}, re-trying")
            await asyncio.sleep(1)
        else:
            req_injected = True
            return
    print(f"Could not inject request {req}")
    return


async def broadcast(req):
    """Broadcast the request to all running BFTList nodes."""
    nodes = get_nodes()
    tasks = []
    print(f"Client {req['client_id']} ==> Broadcasting req NO_OP to all nodes")
    for _, node in nodes.items():
        tasks.append(send_to_node(node, req))
    # wait for request to be sent to all nodes
    await asyncio.gather(*tasks)
    return


def get_data_for_node(node):
    data = requests.get(f"http://{node.hostname}:{4000+node.id}/data").json()
    return data
