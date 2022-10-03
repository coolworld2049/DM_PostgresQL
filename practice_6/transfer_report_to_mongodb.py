import json
import os
from collections.abc import Mapping
from contextlib import suppress
from typing import Any

import aiofiles as aiof
from motor.motor_asyncio import AsyncIOMotorClient
from pymongo import MongoClient
from pymongo.collection import Collection
from pymongo.errors import CollectionInvalid
from sshtunnel import SSHTunnelForwarder


async def insert_one(path_to_json_table, cll: Collection[Mapping[str, Any]]):
    async with aiof.open(path_to_json_table, 'r', encoding="utf_8_sig") as wr:
        data = await wr.readlines()
        if len(data) > 0:
            for i, row in enumerate(data):
                cll.insert_one(json.loads(row))
            print(f"path_to_json_table: {path_to_json_table}: DATA ADDED: {data}")
        else:
            print(f"path_to_json_table: {path_to_json_table}: NO DATA: {data}")


async def main(_client: MongoClient):
    db = _client['company']
    collections = {
        "/temp/report.json": db["report"],
        "/temp/clients.json": db["clients"],
        "/temp/employees.json": db["employees"],
        "/temp/task.json": db["task"]
    }
    for path, cl in collections.items():
        with suppress(CollectionInvalid):
            await db.create_collection(cl.name)
        await insert_one(path, cl)


if __name__ == '__main__':
    server = SSHTunnelForwarder(
            ssh_address_or_host=os.environ['VDS_HOST'],
            ssh_username=os.environ['VDS_USER'],
            ssh_password=os.environ['VDS_PASS'],
            remote_bind_address=('127.0.0.1', 27017))
    server.start()
    client: MongoClient = AsyncIOMotorClient('127.0.0.1', server.local_bind_port)
    loop = client.get_io_loop()
    loop.run_until_complete(main(client))
