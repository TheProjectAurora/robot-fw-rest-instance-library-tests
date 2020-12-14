*** Keywords ***
Authorized User Cant Find Target Api Resource In The System
    ${api resources} =   Get All Api Resources For Authorized User
    ${exists} =    Is contained in list   api_resource=${TARGET API RESOURCE}     api_resource_list=${api resources}
    Should Not Be True  ${exists}

Authorized User Can Find Target Api Resource In The System
    ${api resources} =   Get All Api Resources For Authorized User
    ${exists} =    Is contained in list   api_resource=${TARGET API RESOURCE}     api_resource_list=${api resources}
    Should Be True  ${exists}

Authorized User Reads Pre-Set Api Resources
    ${api resources} =   Get All Api Resources For Authorized User
    Set Suite Variable  ${PRE-SET API RESOURCES}    ${api resources}

Authorized User Finds "Expected Api Resource" In The System
    ${api resources} =   Get All Api Resources For Authorized User
    ${exists} =    Is contained in list   api_resource=${EXPECTED API RESOURCE}     api_resource_list=${api resources}
    Should Be True  ${exists}

Authorized User Removes All Api Resources Except Pre-Set Ones
    ${api resources} =   Get All Api Resources For Authorized User
    ${do go to sleep} =     Set Variable       ${FALSE}
    FOR     ${r}  IN  @{api resources}
        ${r is pre-set api resource} =     Is contained in list   api_resource=${r}   api_resource_list=${PRE-SET API RESOURCES}
        Run Keyword Unless      ${r is pre-set api resource}       Delete Api Resource   ${r}
        ${do go to sleep} =    Evaluate       ${do go to sleep} or not ${r is pre-set api resource}
    END
    [Return]   ${do go to sleep}

Delete Api Resource
    [Arguments]   ${api_resource}
    ${path with namespace} =    Do url encode  ${api_resource}[path_with_namespace]
    DELETE    /projects/${path with namespace}      headers=${AUTHORIZED USER}[private_token]

Get All Api Resources For Authorized User
    [Documentation]   TODO: Querying Api Resources for Authorized User may vary depending on the API
    ...               This part needs to be implemented according to the API's spec
    GET     ${AUTHORIZED USER}[user_projects_endpoint]    headers=${AUTHORIZED USER}[private_token]
    ${response body} =       Array   response body       # a list of lists containing projects
    [Return]    ${response body}[0]                      # a list containing projects

Authorized User Creates Target Api Resource
    POST    /projects       body=${TARGET API RESOURCE}    headers=${AUTHORIZED USER}[private_token]
    ${response body} =    Object      response body       # it is a list containing a single project resource
    ${path with namespace} =    Do url encode  ${response body}[0][path_with_namespace]
    Set Test Variable  ${PATH WITH NAMESPACE}      ${path with namespace}

Authorized User Reads Target Api Resource
    GET    /projects/${PATH WITH NAMESPACE}      headers=${AUTHORIZED USER}[private_token]

Authorized User Creating Target Api Resource Against Instance
    Create Api Resource Against Instance      username=${AUTHORIZED USER}[name]
    ...     instance=${AUTHORIZED USER}[CREATE][instance]        api_resource=${AUTHORIZED USER}[CREATE][api_resource]
    ...     headers=${AUTHORIZED USER}[CREATE][headers]

Authorized User Updating Target Api Resource Against Instance
     Update Api Resource Against Instance   username=${AUTHORIZED USER}[name]
     ...    instance=${AUTHORIZED USER}[UPDATE][instance]  api_resource=${MODIFIED TARGET API RESOURCE}
     ...    headers=${AUTHORIZED USER}[UPDATE][headers]

Authorized User Reading Target Api Resource Against Instance
     Read Api Resource Against Instance  username=${AUTHORIZED USER}[name]
     ...    instance=${AUTHORIZED USER}[READ][instance]
     ...    api_resource=${EXPECTED API RESOURCE}   headers=${AUTHORIZED USER}[READ][headers]

Authorized User Deleting Target Api Resource Against Instance
     Delete Api Resource Against Instance   username=${AUTHORIZED USER}[name]
     ...    instance=${AUTHORIZED USER}[DELETE][instance]    api_resource=${EXPECTED API RESOURCE}
     ...    headers=${AUTHORIZED USER}[DELETE][headers]
