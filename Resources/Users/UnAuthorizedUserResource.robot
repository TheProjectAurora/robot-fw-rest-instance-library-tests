*** Keywords ***
UnAuthorized User Creating Target Api Resource Against Instance
     Create Api Resource Against Instance      username=${UNAUTHORIZED USER}[name]
     ...    instance=${UNAUTHORIZED USER}[CREATE][instance]
     ...    api_resource=${UNAUTHORIZED USER}[CREATE][api_resource]   headers=${UNAUTHORIZED USER}[CREATE][headers]

UnAuthorized User Updating Target Api Resource Against Instance
     Update Api Resource Against Instance   username=${UNAUTHORIZED USER}[name]
     ...    instance=${UNAUTHORIZED USER}[UPDATE][instance]  api_resource=${UNAUTHORIZED USER}[UPDATE][api_resource]
     ...    headers=${UNAUTHORIZED USER}[UPDATE][headers]

UnAuthorized User Reading Target Api Resource Against Instance
     Read Api Resource Against Instance  username=${UNAUTHORIZED USER}[name]
     ...    instance=${UNAUTHORIZED USER}[READ][instance]
     ...    api_resource=${EXPECTED API RESOURCE}
     ...    headers=${UNAUTHORIZED USER}[READ][headers]

UnAuthorized User Deleting Target Api Resource Against Instance
     Delete Api Resource Against Instance   username=${UNAUTHORIZED USER}[name]
     ...    instance=${UNAUTHORIZED USER}[DELETE][instance]
     ...    api_resource=${EXPECTED API RESOURCE}
     ...    headers=${UNAUTHORIZED USER}[DELETE][headers]
