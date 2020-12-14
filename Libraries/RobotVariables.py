import os
import re

def get_project_directory():
    return os.getcwd()

def get_parameterized_resources_file_path():
    return f'{get_project_directory()}{os.path.sep}Resources{os.path.sep}Common{os.path.sep}ParameterizedApiResources.txt'

def get_instances_directory(username):
    return f'{get_project_directory()}{os.path.sep}Instances{os.path.sep}{username}{os.path.sep}'

def get_full_path_to_instance_file(username, line_number, http_request_method):
    if line_number is None:
        return f'{get_instances_directory(username)}target_api_resource_on_{http_request_method}_instance.json'
    else:
        return f'{get_instances_directory(username)}{line_number}_on_{http_request_method}_instance.json'

def get_api_resource(line):
    json_targeting_pattern = re.compile(r'^(\{.*\})')
    match = re.search(json_targeting_pattern, line)
    if match:
        return match.group(1)
    return None

def create_record(username, api_resource, headers, http_request_method, line_number=None):
    record = dict()
    record['user'] = username
    record['api_resource'] = api_resource
    record['headers'] = headers
    record['http_request_method'] = http_request_method
    record['instance'] = get_full_path_to_instance_file(username, line_number, http_request_method)
    return record

def create_record_catalog(username, private_token):
    record_catalog = dict()
    record_catalog['CREATE'] = []
    record_catalog['READ'] = []
    record_catalog['UPDATE'] = []
    record_catalog['DELETE'] = []
    headers = '{"Private-Token":'+ f'"{private_token}"' + '}'   # must be in JSON format
    with open(get_parameterized_resources_file_path(), 'r') as f:
        line_number = 1
        for line in f:
            api_resource = get_api_resource(line)
            if api_resource:
                record_catalog['CREATE'].append(create_record(username, api_resource, headers, 'post', line_number))
                record_catalog['READ'].append(create_record(username, api_resource, headers, 'get', line_number))
                record_catalog['UPDATE'].append(create_record(username, api_resource, headers, 'put', line_number))
                record_catalog['DELETE'].append(create_record(username, api_resource, headers, 'delete', line_number))
                line_number+=1

    return record_catalog

def create_user_profile(username, user_id, private_token, target_api_resource, modified_target_api_resource):
    user_profile = dict()
    user_profile['name'] = username
    user_profile['user_id'] = user_id
    user_profile['user_projects_endpoint'] = f'/users/{user_id}/projects'     # a relative URL pointing to projects

    headers = '{"Private-Token":'+ f'"{private_token}"' + '}'   # must be in JSON format
    user_profile['private_token'] = headers
    user_profile['CREATE'] = create_record(username, target_api_resource, headers, 'post')
    user_profile['READ'] = create_record(username, target_api_resource, headers, 'get')
    user_profile['UPDATE'] = create_record(username, modified_target_api_resource, headers, 'put')
    user_profile['DELETE'] = create_record(username, target_api_resource, headers, 'delete')

    return user_profile

def get_variables():

    authorized_user_username="AuthorizedUser"           # do not use spaces, bcoz it is used as a directory name
    unauthorized_user_username="UnAuthorizedUser"       # do not use spaces, bcoz it is used as a directory name
    target_api_resource = '{"name":"target-project", "description":"my target project description"}'   # to be passed to POST, must be in JSON format
    modified_target_api_resource = '{"name":"target-project", "description":"my modified target project description"}' # to be passed to PUT

    variables = {"AUTHORIZED USER RECORDS" :   create_record_catalog(username=authorized_user_username, private_token='<your private gitlab api token>'),
                 "UNAUTHORIZED USER RECORDS" : create_record_catalog(username=unauthorized_user_username, private_token=''),
                 "TARGET API RESOURCE" : target_api_resource,
                 "MODIFIED TARGET API RESOURCE" : modified_target_api_resource,
                 "TIMEOUT" : "15s",   # time it takes to wait in between tests, needed since atomic tests do delete the api resource, which is a process taking time
                 "AUTHORIZED USER": create_user_profile(username=authorized_user_username, user_id=<your private gitlab user id number>, private_token='<your private gitlab api token>', target_api_resource=target_api_resource, modified_target_api_resource=modified_target_api_resource),
                 "UNAUTHORIZED USER": create_user_profile(username=unauthorized_user_username, user_id=<your private gitlab user id number>, private_token='', target_api_resource=target_api_resource, modified_target_api_resource=modified_target_api_resource),
                 }
    return variables