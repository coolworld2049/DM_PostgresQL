import json
import os

import pymongo
from sshtunnel import SSHTunnelForwarder

if __name__ == '__main__':
    path_to_report_json = '/temp/client_management_company_REPORT.json'

    with SSHTunnelForwarder(
            ssh_address_or_host=os.environ['VDS_HOST'],
            ssh_username=os.environ['VDS_USER'],
            ssh_password=os.environ['VDS_PASS'],
            remote_bind_address=('127.0.0.1', 27017)) as server:
        with pymongo.MongoClient('127.0.0.1', server.local_bind_port) as client:
            db = client['company']
            collection = db["company"]
            with open(path_to_report_json, 'r') as rf:
                data = rf.readlines()
                if len(data) > 0:
                    for row in data:
                        r = json.loads(row)
                        collection.insert_one(json.loads(row))
                    print(f"DATA ADDED: {data}")
                else:
                    print(f"path_to_report_json: {path_to_report_json}: NO DATA: {data}")
