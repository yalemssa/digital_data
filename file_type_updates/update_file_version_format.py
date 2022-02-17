#/usr/bin/python3

import json
import requests
import traceback
from concurrent.futures import ThreadPoolExecutor
from utilities import utilities as u

def create_backups(dirpath, uri, record_json):
    with open(f"{dirpath}/{uri[1:].replace('/','_')}.json", 'a', encoding='utf8') as outfile:
        json.dump(record_json, outfile, sort_keys=True, indent=4)

def update_file_versions(row, sesh, headers, api_url, dirpath):
    try:
        uri = row[0]
        file_uri = row[1]
        file_format_name = row[2]
        is_rep = row[3]
        is_thumb = row[4]
        record_json = sesh.get(f"{api_url}{uri}", headers=headers).json()
        create_backups(dirpath, uri, record_json)
        for file_version in record_json.get('file_versions'):
            if file_version.get('file_uri') == file_uri:
                if (file_version.get('file_format_name') is None and file_format_name != 'NULL'):
                    file_version['file_format_name'] = file_format_name
                if is_rep == '1':
                    file_version['is_representative'] = True
                if is_rep == 'NULL':
                    file_version['is_representative'] = False
                if is_thumb == '1':
                    file_version['is_display_thumbnail'] = True
                if is_thumb == 'NULL':
                    file_version['is_display_thumbnail'] = False
        record_post = sesh.post(f"{api_url}{uri}", headers=headers, json=record_json).json()
        print(record_post)
        if record_post.get('error') == {'db_error': ['Database integrity constraint conflict: Java::ComMysqlJdbcExceptionsJdbc4::MySQLTransactionRollbackException: Deadlock found when trying to get lock; try restarting transaction']}:
            update_file_versions(row, sesh, headers, api_url)
    except Exception:
        print(traceback.format_exc())

def main():
    api_url, headers = u.login()
    dirpath = 'test_do_backups_v3'
    header_row, csvfile = u.opencsv('file_version_data_test.csv')
    try:
        print('Starting session...')
        with requests.Session() as sesh:
            print('Session started.')
            with ThreadPoolExecutor(max_workers=4) as pool:
                print('Starting ThreadPoolExecutor...')
                for row in csvfile:
                    pool.submit(update_file_versions, row, sesh, headers, api_url, dirpath)
    except Exception:
        print(traceback.format_exc())



if __name__ == "__main__":
    main()