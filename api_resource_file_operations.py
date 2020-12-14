import os
import re

path_to_resources_common = f'{os.getcwd()}{os.path.sep}Resources{os.path.sep}Common{os.path.sep}'
api_resource_keys_file = 'ApiResourceKeys.txt'
parameterized_api_resources_file = 'ParameterizedApiResources.txt'

def write_to_file(filename, item_list):
    file_path = f'{path_to_resources_common}{filename}'
    with open(file_path, 'w') as f:
        for item in item_list:
            f.write(f'{item}\n')

def get_api_resource_keys():
    api_resource_keys = []
    file_path = f'{path_to_resources_common}{api_resource_keys_file}'
    with open(file_path, 'r') as f:
        for line in f:
            pattern = re.compile(r'^(.+)$')
            match = re.search(pattern, line)
            api_resource_keys.append(match.group(1))
    return api_resource_keys