*** Keywords ***
Form Action Strings
    [Arguments]       ${username}   ${instance}      ${api_resource}   ${request_type}
    ${action} =    Catenate  ${username}   provides   ${api_resource}    making ${request_type} request against   ${instance}
    ${action started} =      Catenate       [STARTED]       ${action}
    ${action successful} =   Catenate       [SUCCESS]       ${action}
    ${action failed} =   Catenate       [FAILURE]       ${action}
    [Return]    ${action started}       ${action successful}        ${action failed}

Log Action Result
    [Arguments]       ${status}     ${response}     ${action successful}       ${action failed}
    Run Keyword If	'${status}' == 'PASS'       Log To Console       ${action successful}
    Run Keyword If	'${status}' == 'FAIL'       Log To Console       ${action failed}
    Run Keyword If	'${status}' == 'FAIL'       Log       ${action failed}
    Run Keyword If	'${status}' == 'FAIL'       Log       ${response}
    Log To Console       ${EMPTY}

Create Api Resource Against Instance
    [Arguments]       ${username}   ${instance}      ${api_resource}        ${headers}      ${continue_on_error}=${false}
    ${action started}       ${action successful}        ${action failed} =
    ...                                 Form Action Strings    ${username}   ${instance}      ${api_resource}    CREATE
    Log To Console       ${EMPTY}
    Log To Console    ${action started}
    ${request_schema}    ${response schema}     Get schemas      json_instance_file=${instance}
    Expect Request          ${request schema}
    Expect Response         ${response schema}
    ${status}   ${response} =    Run Keyword And Ignore Error   POST    /projects       body=${api_resource}     headers=${headers}
    Clear Expectations
    Log Action Result       ${status}     ${response}     ${action successful}       ${action failed}
    Run Keyword If	${continue_on_error} == False      Should Be True      '${status}'=='PASS'
    [Return]    ${status}

Read Api Resource Against Instance
    [Arguments]          ${username}    ${instance}      ${api_resource}     ${headers}     ${continue_on_error}=${false}

    ${action started}       ${action successful}        ${action failed} =
    ...                                         Form Action Strings    ${username}   ${instance}      ${None}   READ
    Log To Console       ${EMPTY}
    Log To Console       ${action started}
    ${request_schema}    ${response schema}     Get schemas      json_instance_file=${instance}
    Expect Request          ${request schema}
    Expect Response         ${response schema}
    ${path with namespace} =    Do url encode  ${api_resource}[path_with_namespace]
    ${status}   ${response} =    Run Keyword And Ignore Error   GET    /projects/${path with namespace}       headers=${headers}
    Clear Expectations
    Log Action Result       ${status}     ${response}     ${action successful}       ${action failed}
    Run Keyword If	${continue_on_error} == False      Should Be True      '${status}'=='PASS'

Update Api Resource Against Instance
    [Arguments]          ${username}    ${instance}      ${api_resource}        ${headers}       ${continue_on_error}=${false}

    ${action started}       ${action successful}        ${action failed} =
    ...                                       Form Action Strings    ${username}   ${instance}      ${api_resource}    UPDATE
    Log To Console       ${EMPTY}
    Log To Console       ${action started}
    ${request_schema}    ${response schema}     Get schemas      json_instance_file=${instance}
    Expect Request          ${request schema}
    Expect Response         ${response schema}
    ${status}   ${response} =    Run Keyword And Ignore Error   PUT    /projects/${PATH WITH NAMESPACE}      body=${api_resource}     headers=${headers}
    Clear Expectations
    Log Action Result       ${status}     ${response}     ${action successful}       ${action failed}
    Run Keyword If	${continue_on_error} == False      Should Be True      '${status}'=='PASS'

Delete Api Resource Against Instance
    [Arguments]         ${username}    ${instance}       ${api_resource}     ${headers}         ${continue_on_error}=${false}

    ${action started}       ${action successful}        ${action failed} =
    ...                                 Form Action Strings    ${username}   ${instance}      ${None}   DELETE
    Log To Console       ${EMPTY}
    Log To Console       ${action started}
    ${path with namespace} =    Do url encode  ${api_resource}[path_with_namespace]
    ${request_schema}    ${response schema}     Get schemas      json_instance_file=${instance}
    Expect Request          ${request schema}
    Expect Response         ${response schema}
    ${status}   ${response} =    Run Keyword And Ignore Error   DELETE    /projects/${path with namespace}      headers=${headers}
    Clear Expectations
    Log Action Result       ${status}     ${response}     ${action successful}       ${action failed}
    Run Keyword If	${continue_on_error} == False      Should Be True      '${status}'=='PASS'

Gather Instance While Making POST Request
    [Arguments]         ${api_resource}      ${headers}        ${instance}
    POST    /projects       body=${api_resource}     headers=${headers}
    Last Rest Instance      file_path=${instance}     sort_keys=True     # instance for the POST request

Gather Instance While Making GET Request
    [Arguments]     ${path with namespace}      ${headers}    ${instance}
    GET    /projects/${PATH WITH NAMESPACE}       headers=${headers}
    Last Rest Instance      file_path=${instance}      sort_keys=True     # instance for the GET request

Gather Instance While Making PUT Request
    [Arguments]     ${path_with_namespace}      ${api_resource}      ${headers}       ${instance}
    PUT    /projects/${path_with_namespace}      body=${api_resource}     headers=${headers}
    Last Rest Instance      file_path=${instance}     sort_keys=True     # instance for the PUT request

Gather Instance While Making DELETE Request
    [Arguments]     ${path with namespace}      ${headers}        ${instance}
    DELETE    /projects/${path with namespace}      headers=${headers}
    Last Rest Instance      file_path=${instance}     sort_keys=True     # instance for the DELETE request