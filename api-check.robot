*** Settings ***
Documentation    Testing API request 
Library          RequestsLibrary
# Library          JSONLibrary          #for parsing and validating JSON responses 
Library          Collections          #for validating dict/list structures in JSON 

*** Variables ***
${BASE_URL}     https://jsonplaceholder.typicode.com
&{HEADERS}        Content-Type=application/json 

*** Test Cases ***
# case 1: retrieve a single post (GET)
Verify GET Single Post 
    [Documentation]    Tests retrieving a single post and validate its content 
    Create Session     jsonplaceholder    ${base_url}
    ${response}=         GET On Session     jsonplaceholder      /posts/1     headers=&{headers}

    #Assertions 
    Status Should Be      200     ${response}      #if 200 not returned keyword fails automatically
    ${json_body}=         BuiltIn.Set Variable     ${response.json()}       #let variable json_body take response.json
    Should Be Equal As Strings    ${json_body['id']}    1           #since we are retrieving /posts/1
    Should Be Equal As Strings    ${json_body['userId']}      1    #jsonplaceholder puts first 10 files under first user 
    Dictionary Should Contain Key    ${json_body}       title       #json_body should contain the word title 

# case 2: create a new post (POST)
Verify POST Single update 
    [Documentation]     Create an element 
    Create Session      jsonplaceholder     ${base_url}
    &{data}=            Create Dictionary   userId=101      id=1      title=Robot Framework    body=This is a new post      #content to update, need to match JSON format (define new dictionary)
    ${response}         POST On Session     jsonplaceholder    /posts       json=${data}       headers=&{headers}       #json=${data} to POST

    #Assertions 
    Status Should Be     201       ${response}    #post status is 201 
    ${json_body}=        BuiltIn.Set Variable      ${response.json()}
    Should Be Equal As Strings     ${json_body['title']}       Robot Framework        #check if title was updated 
    Dictionary Should Contain Key  ${json_body}     id     #newly created id 

# case 3: update an existing post (PUT)
Verify PUT Update Data 
    [Documentation]    Update an element 
    Create Session     jsonplaceholder    ${base_url}
    &{update_data}=    Create Dictionary  title=Updated Robot Framework       #updating the title 
    ${response}        PUT On Session     jsonplaceholder    /posts/1     json=${update_data}    headers=&{headers}  #update the content 

    #Assertions 
    Status Should Be    200     ${response}
    ${json_body}=       BuiltIn.Set Variable     ${response.json()}
    Should Be Equal As Strings     ${json_body['title']}     Updated Robot Framework 

# case 4: Delete a post (DELETE)
Verify DELETE Single Data 
    [Documentation]    Delete a single data 
    Create Session     jsonplaceholder    ${base_url}
    ${response}        DELETE On Session     jsonplaceholder     /posts/1      headers=${headers}

    Status Should Be     200      ${response}
#jsonplaceholder - allows us to reuse the connection for multiple requests 
