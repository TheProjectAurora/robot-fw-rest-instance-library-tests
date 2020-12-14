# robot_fw_rest_instance_library_tests
In this project, using RESTInstance Robot FW plugin, we test GitLab API in a contract based fashion

Refer to the blog below on how this project implements the contract based API testing
https://medium.com/contract-based-json-restful-api-testing-using/contract-based-json-restful-api-testing-using-restinstance-robot-framework-6b6c1b183d88

# Installation instructions for Ubuntu & Python 3.8.5
1. create a directory named RESTinstanceEnv and cd into that directory in command line
2  Create virtual environment with under folder named .venv:  python3 -m venv .venv/dev
3. Activate the virtual environment: source .venv/dev/bin/activate
4. Clone the RESTInstance fork project into the root of (3):
   https://github.com/TeddyTeddy/RESTinstance
5. cd into (4)'s root
6. pip install -r requirements-dev.txt
7. pip install --editable .
8. At this stage, RESTInstance module & its dependencies have been installed on the virtual env
9. Clone this project (robot_fw_rest_instance_library_tests) into the root of the venv
10. In (9), the following placeholders must be replaced with actual values:
   <your private gitlab username>        (your GitLab username)
   <YourName YourSurname>                (the one you provided to GitLab)
   <your private gitlab user id number>  (the one that is found under your profile settings)
   <your private gitlab api token>       (you need to generate a token of your own using your profile settings)

# How to execute the test suite in Ubuntu
We assume that you read the blog at this point. 
There are 3 executable shell files in the project root:
a. create_parameterized_api_resources
b. gather_all_instances
c. run_all_tests

## create_parameterized_api_resources shell file
This shell file creates robot_fw_rest_instance_library_tests/Resources/Common/ParameterizedApiResources.txt
The txt file contains all the parameterized api resources line by line. 

Keeping Gitlab API as our main target, we can say that a GitLab project is an API resource.
Once you execute the shell file, you will be prompted to enter
key names for the api resource (i.e. project). The api requires at minimum "name" and "description" keys for "project":

```
Enter 1.th key name in API resource: name
Enter 2.th key name in API resource: description
Enter 3.th key name in API resource:
```
!!! Important: Currently ParameterizedApiResources.txt file contains already the Gitlab API's resources to be used readily. 
    Executing create_parameterized_api_resources will overwrite the txt file, which is not necessary unless
    you modify create_parameterized_api_resources.py to extend the parameterized resources further or you create
    a new ParameterizedApiResources.txt for another API under test (e.g. BookStore API with book as the API resource, which has
    "title", "description", "ISBN", "authors" etc as keys)

# gather_all_instances shell file
Once we have ParameterizedApiResources.txt ready, you can invoke ```gather_all_instances```. Note that there are 3 lines in gather_all_instances:
```
# robot --include get_instance --pythonpath Libraries/ --pythonpath . --variablefile Libraries/RobotVariables.py -d Results Tests/GitLabApi/AuthorizedUserTests.robot
robot --include get_instance --pythonpath Libraries/ --pythonpath . --variablefile Libraries/RobotVariables.py -d Results Tests/GitLabApi/UnAuthorizedUserTests.robot
# robot --include get_instance --pythonpath Libraries/ --pythonpath . --variablefile Libraries/RobotVariables.py -d Results Tests/GitLabApi/
```
Only one of the lines must be commented out, the rest must be commented in.

When invoking gather_all_instances, the test suite will execute test cases with "get_instance" tags only. 
The eligable tests will make calls to the GitLab API, for each call, after receiving response , they will store the corresponding contract under the folder:
```
robot_fw_rest_instance_library_tests/Instances
```
!!! Important: Currently, those contracts are already stored in instance files under Instances folder. 
Once we stored the contracts, we reviewed and editied some of them, because those automatically generated contracts 
did not fit our API requirements. Note that reviweing the contract files and editing/fixing them when necessary is the part of API test development.

# run_all_tests shell file
Once we have the instance files under Instances folder reviewed and edited when necessary,
we have the requirement specifications ready for GitLab API (or any other API under test).

Referring to the run_all_tests file contents, we see that there are 3 lines:
```
# robot --include CI --pythonpath Libraries/ --pythonpath . -d Results --variablefile Libraries/RobotVariables.py -t "Authorized User provides <API Resource> making CREATE request against <Instance>" Tests/GitLabApi/AuthorizedUserTests.robot
# robot --include CI --pythonpath Libraries/ --pythonpath . -d Results --variablefile Libraries/RobotVariables.py Tests/GitLabApi/UnAuthorizedUserTests.robot
robot --include parameterized_api_resources --pythonpath Libraries/ --pythonpath . -d Results --variablefile Libraries/RobotVariables.py Tests/GitLabApi/
```
To run the tests tagged with parameterized_api_resources in AuthorizedUserTests & UnAuthorizedUserTests suites, we use the last line.
Note that we can change the tag to CI to run BAT tests + parameterized_api_resources tests.

We have instance files stored in Instances/AuthorizedUser and Instances/UnAuthorizedUser folders.
When you execute the run_all_tests shell file, it will execute only test cases tagged with parameterized_api_resources tag.
The eligible tests in AuthorizedUserTests & UnAuthorizedUserTests suites will use their own instance files
stored in Instances/AuthorizedUser and Instances/UnAuthorizedUser folders respectively.
Each instance file used contains a request/response pair plus the contract required for the pair.
The eligible test cases will make the request, receive the response and then check if the request/response pair matches the contract required.
If the pair does not validate against its required contract, then that step will fail and test execution will go and make the next request/response
pair from the next instance file and so on.. This processs continues until all the instance files are consumed for that particular 
AuthorizedUserTests/UnAuthorizedUserTests suite. If any of the steps has failed during test execution, then test case fails, otherwise
eligible test case (i.e. the one with parameterized_api_resources) passes.














