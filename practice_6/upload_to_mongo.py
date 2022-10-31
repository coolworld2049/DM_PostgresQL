import json
import logging
from collections.abc import Mapping
from contextlib import suppress
from typing import Any

import aiofiles as aiof
from motor.motor_asyncio import AsyncIOMotorClient
from pymongo import MongoClient
from pymongo.collection import Collection
from pymongo.errors import CollectionInvalid

from config import MONGO_URI

logging.basicConfig(encoding='utf-8', level=logging.INFO)


async def insert_one(path_to_json_table, cll: Collection[Mapping[str, Any]]):
    async with aiof.open(path_to_json_table, 'r', encoding="utf_8_sig") as wr:
        data = await wr.readlines()
        if len(data) > 0:
            for i, row in enumerate(data):
                cll.insert_one(json.loads(row))
            logging.info(f"path_to_json_table: {path_to_json_table}: DATA ADDED: {data}")
        else:
            logging.info(f"path_to_json_table: {path_to_json_table}: NO DATA: {data}")


async def upload_db_report(_client: MongoClient):
    db = _client['company']
    collections = {
        "/temp/report.json": db["report"],
    }
    for path, cl in collections.items():
        with suppress(CollectionInvalid):
            await db.create_collection(cl.name)
        await insert_one(path, cl)


if __name__ == '__main__':
    client: MongoClient = AsyncIOMotorClient(MONGO_URI)
    loop = client.get_io_loop()
    loop.run_until_complete(upload_db_report(client))
