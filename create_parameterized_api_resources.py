import itertools
import os
import json
from api_resource_file_operations import write_to_file, api_resource_keys_file, parameterized_api_resources_file

def get_json_api_resource(resource_items):
    # form json_api_resource from resource_items
    return '{' + ','.join(resource_items) + '}'

def get_keys_item(key, value):
    if type(value) is int or type(value) is float:
        item = f'"{key}":{value}'       # e.g. "description":100.0
    elif type(value) is str:
        item = f'"{key}":"{value}"'     # e.g. "name":"['1','2','3']"
    elif type(value) is dict:
        # https://stackoverflow.com/questions/18283725/how-to-create-a-python-dictionary-with-double-quotes-as-default-quote-format
        item = f'"{key}":{json.dumps(value)}'   #  e.g. "name":{"key": "value"}
    elif type(value) is bool:
        if value: # if True
            item = f'"{key}":true'
        else : # if False
            item = f'"{key}":false'
    elif type(value) is list:
        item = f'"{key}": {value}'
    elif value is None:
        item = f'"{key}": null'
    else:
        raise AssertionError(f'create_resources(): item cannot be formed based on type(value): {type(value)}')
    return item

def create_resources(key_combination, values):
    """
    key_combination: a tuple containing a key names' combination (e.g. ('name',) or ('description',) or ('name', 'description'))
    values = a list of values which will be combined against key_combination's items (e.g. ['null', '[]'] )

    For example, if key_combination=('name', 'description') and values=['null', '[]'] then the outcome will be:
    [
        {"name":"null","description":"null"},
        {"name":"null","description":"[]"},
        {"name":"[]","description":"null"},
        {"name":"[]","description":"[]"},
    ]
    """
    list_of_lists = []
    for key in key_combination: # e.g. key_combination = ('name', 'description') & key = 'name'
        keys_items = []
        for value in values:  # e.g. values = ['null', '[]']
            keys_items.append(get_keys_item(key, value))  # e.g. keys_items = ['"name":"null"', '"name":"[]"']
        list_of_lists.append(keys_items)    # e.g. list_of_lists = [['"name":"null"', '"name":"[]"'], ['"description":"null"', '"description":"[]"']]
    # create a cross combination of items in list_of_lists
    # https://stackoverflow.com/questions/798854/all-combinations-of-a-list-of-lists
    iterable = itertools.product(*list_of_lists)
    result = []
    for resource_items in iterable:  # e.g. iterable will be (('"name":"null"', '"description":"null"'), ('"name":"null"', '"description":"[]"'),('"name":"[]"', '"description":"null"'), ('"name":"[]"', '"description":"[]"'))
        # resource_items will be e.g. ('"name":"null"', '"description":"null"')
        json_api_resource = get_json_api_resource(resource_items)  # e.g. '{"name":"null","description":"null"}'
        # do a final check: did get_json_api_resource() method return a valid json?
        # https://stackoverflow.com/questions/5508509/how-do-i-check-if-a-string-is-valid-json-in-python
        json.loads(json_api_resource)
        result.append(json_api_resource)
    return result

def create_parameterized_resources(keys, values):
    """
    keys: a list containing key names for the API resource (e.g. ["name", "description"])
    values: a list containing different key values (e.g. ['null', '[]'])

    The output sum of all keys' combinations of length r (r from 0 to len(keys)) vs. values

    For example: Given keys=["name", "description"] and values=['null', '[]']
    The output is:
    [
        '{}',
        '{"name":"null"}',
        '{"name":"[]"}',
        '{"description":"null"}',
        '{"description":"[]"}',
        '{"name":"null","description":"null"}',
        '{"name":"null","description":"[]"}',
        '{"name":"[]","description":"null"}',
        '{"name":"[]","description":"[]"}'
    ]

    Note that each item in the output list is a JSON representation of an API resource

    """
    result = ["{}"]  # an empty resource must always be the first; it represents 0.th length combinations of keys items
    l = 1
    while l <= len(keys):  # e.g. l = 1
        # calculate combinations of length l for keys items
        # https://www.geeksforgeeks.org/permutation-and-combination-in-python/
        combs = itertools.combinations(keys, l)
        for key_combination in list(combs):  # e.g. list(combs) = [('name',), ('description',)]
            result += create_resources(key_combination, values)  # e.g. key_combination: ('name',)
        l+=1
    return result



def get_keys():
    i = 1
    keys = []
    while True:
        key_name = input(f'Enter {i}.th key name in API resource, or press ENTER only to stop: ')
        if len(key_name) > 0:  # not pressed ENTER => a valid key_name
            keys.append(key_name)
        else:
            break              # pressed ENTER
    return keys


if __name__ == '__main__':
    values = [None, [], [1,2,3], True, False, {}, {"key":"value"}, 0, -1, 1, 1.0E+2, "valid string" ]
    keys = get_keys()
    print(f'Overwriting {api_resource_keys_file}')
    write_to_file(filename=api_resource_keys_file, item_list=keys)
    json_parameterized_resource_list = create_parameterized_resources(keys, values)
    print(f'Overwriting {parameterized_api_resources_file}')
    write_to_file(filename=parameterized_api_resources_file, item_list=json_parameterized_resource_list)
    print("""Re-run gather_all_instances at the project root to re-new the instances,\nafter which you can run run_all_tests in the project root\nDone""")




