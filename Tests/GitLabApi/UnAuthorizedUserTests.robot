*** Settings ***
Library             REST      https://gitlab.com/api/v4
Library             Utilities
Resource            ${EXECDIR}${/}Resources${/}Common${/}ApiResource_resource.robot
Resource            ${EXECDIR}${/}Resources${/}Common${/}CRUD_resource.robot
Resource            ${EXECDIR}${/}Resources${/}Common${/}UserResource.robot
Resource            ${EXECDIR}${/}Resources${/}Users${/}AuthorizedUserResource.robot
Resource            ${EXECDIR}${/}Resources${/}Users${/}UnAuthorizedUserResource.robot
Suite Setup         Authorized User Reads Pre-Set Api Resources
Test Setup          Clear Expectations
Test Teardown       Run Keywords    Authorized User Removes All Api Resources Except Pre-Set Ones  AND
...                                 Sleep  ${TIMEOUT}

*** Test cases ***
Gathering Instances While Creating Parameterized Api Resources
    [Tags]      get_instance
    [Template]      Gather Instances While Creating Parameterized Api Resources
    ${UNAUTHORIZED USER RECORDS}[CREATE]

Gathering Instance While Creating Target Api Resource
    [Documentation]   curl --request POST --header "Private-Token: <your private gitlab api token>" --header "Content-Type: application/json" --data '{"name":"test-project-2", "description":"my second test project"}' "https://gitlab.com/api/v4/projects"
    [Tags]      get_instance
    [Setup]     Authorized User Cant Find Target Api Resource In The System
    [Template]  Gather Instance While Making POST Request
    ${UNAUTHORIZED USER}[CREATE][api_resource]   ${UNAUTHORIZED USER}[CREATE][headers]    ${UNAUTHORIZED USER}[CREATE][instance]

Gathering Instance While Reading Target Api Resource
    [Documentation]    curl --request GET --header "Private-Token: <your private gitlab api token>" "https://gitlab.com/api/v4/projects/<your private gitlab username>%2Ftest-resource"
    [Tags]      get_instance
    [Setup]     Run Keywords    Authorized User Cant Find Target Api Resource In The System   AND
                ...             Authorized User Creates Target Api Resource
    [Template]  Gather Instance While Making GET Request
    ${PATH WITH NAMESPACE}      ${UNAUTHORIZED USER}[READ][headers]    ${UNAUTHORIZED USER}[READ][instance]

Gathering Instance While Updating Target Api Resource
    [Documentation]     curl --request PUT --header "Private-Token: <your private gitlab api token>" --header "Content-Type: application/json" --data '{"name":"test-resource-2", "description":"project description modified"}' "https://gitlab.com/api/v4/projects/<your private gitlab username>%2Ftest-resource-2"
    [Tags]      get_instance
    [Setup]     Run Keywords    Authorized User Cant Find Target Api Resource In The System   AND
                ...             Authorized User Creates Target Api Resource
    [Template]  Gather Instance While Making PUT Request
    ${PATH WITH NAMESPACE}      ${MODIFIED TARGET API RESOURCE}     ${UNAUTHORIZED USER}[UPDATE][headers]    ${UNAUTHORIZED USER}[UPDATE][instance]

Gathering Instance While Deleting Target Api Resource
    [Documentation]     curl --request DELETE --header "Private-Token: <your private gitlab api token>" "https://gitlab.com/api/v4/projects/<your private gitlab username>%2Ftest-resource-2"
    [Tags]      get_instance
    [Setup]     Run Keywords    Authorized User Cant Find Target Api Resource In The System   AND
                ...             Authorized User Creates Target Api Resource
    [Template]  Gather Instance While Making DELETE Request
    ${PATH WITH NAMESPACE}      ${UNAUTHORIZED USER}[DELETE][headers]    ${UNAUTHORIZED USER}[DELETE][instance]

Creating Target Api Resource Should Fail & Instance Validation Should Pass
    [Tags]      BAT         (C)RUD      CI
    Given Authorized User Cant Find Target Api Resource In The System
    When UnAuthorized User Creating Target Api Resource Against Instance
        Then Response Body Does Not Contain Target Api Resource
    Then Authorized User Cant Find Target Api Resource In The System

Reading Target Api Resource Should Fail & Instance Validation Should Pass
    [Tags]      BAT         C(R)UD      CI
    Given Authorized User Cant Find Target Api Resource In The System
    Given Authorized User Creates Target Api Resource
        Given Response Body Contains Target Api Resource, Save It As "Expected Api Resource"
    When UnAuthorized User Reading Target Api Resource Against Instance
        Then Response Body Does Not Contain Target Api Resource

Updating Target Api Resource Should Fail & Instance Validation Should Pass
    [Tags]      BAT         CR(U)D      CI
    Given Authorized User Cant Find Target Api Resource In The System
    Given Authorized User Creates Target Api Resource
    When UnAuthorized User Updating Target Api Resource Against Instance
    Then Authorized User Reads Target Api Resource
        Then Response Body Contains Target Api Resource, Save It As "Observed Api Resource"
    Then Check That Target Api Resource Did Not Get Updated

Deleting Target Api Resource Should Fail & Instance Validation Should Pass
    [Tags]      BAT         CRU(D)      CI
    Given Authorized User Cant Find Target Api Resource In The System
    Given Authorized User Creates Target Api Resource
        Given Response Body Contains Target Api Resource, Save It As "Expected Api Resource"
    When UnAuthorized User Deleting Target Api Resource Against Instance
    Then Authorized User Can Find Target Api Resource In The System

UnAuthorized User provides <API Resource> making CREATE request against <Instance>
    [Tags]      (C)RUD     parameterized_api_resources      CI
    [Template]      User provides <API Resource> making CREATE request against <Instance>
    ${UNAUTHORIZED USER RECORDS}[CREATE]

