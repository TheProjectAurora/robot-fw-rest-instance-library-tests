*** Keywords ***
Gather Instances While Creating Parameterized Api Resources
    [Arguments]     ${record list}
    FOR     ${record}    IN      @{record list}    # NOTE! FOR iterations must be atomic
        POST    /projects       body=${record}[api_resource]    headers=${record}[headers]
        ${instance} =  Last Rest Instance      file_path=${record}[instance]      sort_keys=True     # instance for the POST request
        # if api_resource just got created via POST, then we delete it here to make the FOR iteration atomic
        Run Keyword If    ${instance}[response][status] == 201      Delete Api Resource        api_resource=${instance}[response][body]
        Run Keyword If    ${instance}[response][status] == 201      Sleep    ${TIMEOUT}   # to make SUT to indeed delete the api resource
    END

User provides <API Resource> making CREATE request against <Instance>
    [Arguments]     ${record list}
    ${all iterations passed} =    Set Variable       ${True}
    FOR     ${record}    IN      @{record list}     # NOTE! FOR iterations must be atomic
        ${status} =    Create Api Resource Against Instance        ${record}[user]     ${record}[instance]
        ...                                                        ${record}[api_resource]    ${record}[headers]      ${true}
        # if api_resource just got created via POST, then we delete it here to make the FOR iteration atomic
        ${do go to sleep} =    Authorized User Removes All Api Resources Except Pre-Set Ones
        Run Keyword If  ${do go to sleep}       Sleep    ${TIMEOUT}
        ${all iterations passed} =   Evaluate    ${all iterations passed} and '${status}' == 'PASS'
   END
   Should Be True  ${all iterations passed}
