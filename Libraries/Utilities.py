import urllib.parse
from robot.api.deco import keyword
from robot.api import logger
import json
import jsonpickle
from api_resource_file_operations import get_api_resource_keys

@keyword
def do_url_encode(path_with_namespace):
    """ For url encoding, refer to:
        https://www.urlencoder.io/python/ """
    return urllib.parse.quote(path_with_namespace, safe='')  # safe='' states that / character is not safe

@keyword
def is_contained_in_list(api_resource, api_resource_list):
    """
    api resource can either be a dictionary or a JSON string containing dictionary elements
    If the latter, then this function converts the api resource into a python object (i.e. dictionary) [1]
    Checks if the dictionary object [1] has the description and name values matching any member of projects
    If so returns True, otherwise returns False

    Parameters:
        - api_resource: (JSON string) dictionary
        - api_resource_list: A list of api resource objects, which are themselves dictionaries
    """
    logger.info(f'api_resource: {api_resource},  type(api_resource): {type(api_resource)}')
    if type(api_resource) is dict:
        pass
    elif type(api_resource) is str:
        api_resource = jsonpickle.decode(api_resource)  # turn it into dictionary
    else:
        raise AssertionError(f"Unexpected api_resource type: {type(api_resource)}")

    result = False
    for ar in api_resource_list:
        result = partial_compare(api_resource, ar)
        if result:
            break
    return result

def partial_compare(a, b):
    """ This method compares two dictionaries a and b. It is upto the test logic on decide what makes them partially equal"""
    logger.info(f'{a} and its type is {type(a)}')
    logger.info(f'{b} and its type is {type(b)}')
    if type(a) is not dict:
        raise AssertionError(f"Unexpected type: {type(a)} for {a}")
    if type(b) is not dict:
        raise AssertionError(f"Unexpected type: {type(b)} for {b}")
    if 'name' not in a or 'name' not in b or 'description' not in a or 'description' not in b:
        return False
    return a['name'] == b['name'] and a['description'] == b['description']

@keyword
def are_api_resources_equal(expected_resource, observed_resource):
    """
    Does full comparison of two resources as dictionaries
    https://medium.com/@stschindler/comparing-nested-python-dictionaries-with-no-hassle-9ffe35ae076e
    """
    json_expected_resource = json.dumps(expected_resource, sort_keys=True)
    json_observed_resource = json.dumps(observed_resource, sort_keys=True)
    logger.info(json_expected_resource)
    logger.info(json_observed_resource)
    return json_expected_resource == json_observed_resource

@keyword
def get_schemas(json_instance_file):
    with open(json_instance_file, 'r') as f:
        instance = jsonpickle.decode(f.read())  # instance as a dictinary
    return jsonpickle.encode(instance['schema']['properties']['request']), jsonpickle.encode(instance['schema']['properties']['response'])

@keyword
def contains_api_resource(response_body, api_resource):
    logger.info(f'{response_body} and its type is {type(response_body)}')

    if type(api_resource) is dict:
        pass
    elif type(api_resource) is str:
        api_resource = jsonpickle.decode(api_resource)  # turn it into dictionary
    else:
        raise AssertionError(f"Unexpected api_resource type: {type(api_resource)}")

    result = False
    if type(response_body) is list:
        for item in response_body:
           result = partial_compare(item, api_resource)
           if result:
               break
    elif type(response_body) is dict:
        result = partial_compare(response_body, api_resource)
    else:
        raise AssertionError(f"Unexpected response_body type: {type(response_body)}")

    return result