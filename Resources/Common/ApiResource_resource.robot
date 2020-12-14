*** Keywords ***
Expected and Observed Api Resources Match
    # NOTE: API may return the Api Resource with keys in any order. Basic comparison would not work:
    ${resources are equal} =   Are Api Resources Equal  ${EXPECTED API RESOURCE}      ${OBSERVED API RESOURCE}
    Should Be True  ${resources are equal}

Check That Target Api Resource Got Updated
    @{list} =       Create List     ${OBSERVED API RESOURCE}
    ${exists} =     Is contained in list   api_resource=${MODIFIED TARGET API RESOURCE}      api_resource_list=${list}
    Should Be True      ${exists}

Check That Target Api Resource Did Not Get Updated
    @{list} =       Create List     ${OBSERVED API RESOURCE}
    ${exists} =     Is contained in list   api_resource=${MODIFIED TARGET API RESOURCE}      api_resource_list=${list}
    Should Not Be True      ${exists}

Response Body Contains Target Api Resource, Save It As "Expected Api Resource"
    ${response body} =     Object   response body       # TODO: Why Object returns a list?
    Set Test Variable       ${EXPECTED API RESOURCE}      ${response body}[0]

Response Body Contains Target Api Resource, Save It As "Observed Api Resource"
    ${response body} =     Object   response body      # TODO: Why Object returns a list?
    Set Test Variable       ${OBSERVED API RESOURCE}      ${response body}[0]

Response Body Does Not Contain Target Api Resource
    ${response body} =     Object   response body
    ${contains} =     Contains api resource     ${response body}      ${TARGET API RESOURCE}
    Should Not Be True      ${contains}
