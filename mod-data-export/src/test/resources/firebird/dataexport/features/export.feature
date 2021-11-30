Feature: Tests for uploading "uuids file" and exporting the records

  Background:
    * url baseUrl

    * callonce login testAdmin
    * def okapiAdminToken = okapitoken

    * callonce login testUser
    * def okapiUserToken = okapitoken

    * callonce loadTestVariables

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapiUserToken)', 'Accept': 'application/json'  }
    * def headersUserOctetStream = { 'Content-Type': 'application/octet-stream', 'x-okapi-token': '#(okapiUserToken)', 'Accept': 'application/json'  }
    * configure headers = headersUser
    * configure retry = { interval: 120000, count: 10 }

  #Positive scenarios

  Scenario Outline: test upload file and export flow for instance uuids.
    #should create file definition
    Given path 'data-export/file-definitions'
    And def fileDefinition = {'id':<fileDefinitionId>,'fileName':'<fileName>', 'uploadFormat':'<uploadFormat>'}
    And request fileDefinition
    When method POST
    Then status 201
    And match response.status == 'NEW'
    And match response.uploadFormat == '<uploadFormat>'

    #should return created file definition
    Given path 'data-export/file-definitions', <fileDefinitionId>
    When method GET
    Then status 200
    And match response.status == 'NEW'
    And match response.uploadFormat == '<uploadFormat>'
    And call pause 500

    #should upload file by created file definition id
    Given path 'data-export/file-definitions/',<fileDefinitionId>,'/upload'
    And configure headers = headersUserOctetStream
    And request karate.readAsString('classpath:samples/file-definition/<fileName>')
    When method POST
    Then status 200
    And match response.jobExecutionId == '#present'
    And match response.status == 'COMPLETED'
    And match response.uploadFormat == '<uploadFormat>'
    And match response.sourcePath == '#present'
    And def jobExecutionId = response.jobExecutionId

    #wait until the file will be uploaded to the system before calling further dependent calls
    Given path 'data-export/file-definitions', <fileDefinitionId>
    And retry until response.status == 'COMPLETED'
    When method GET
    Then status 200
    And call pause 120000

    #should export instances and return 204
    Given path 'data-export/export'
    And configure headers = headersUser
    And def requestBody = {'fileDefinitionId':<fileDefinitionId>,'jobProfileId':'#(defaultInstanceJobProfileId)','idType':'instance'}
    And request requestBody
    When method POST
    Then status 204

    #should return job execution by id and wait until the job status will be 'COMPLETED'
    Given path 'data-export/job-executions'
    And param query = 'id==' + jobExecutionId
    And retry until response.jobExecutions[0].status == 'COMPLETED'
    When method GET
    Then status 200
    And match response.jobExecutions[0].status == 'COMPLETED'
    And match response.jobExecutions[0].progress == {exported:1, failed:0, total:1}
    And def fileId = response.jobExecutions[0].exportedFiles[0].fileId
    And call pause 120000

    #should return download link for instance of uploaded file
    Given path 'data-export/job-executions/',jobExecutionId,'/download/',fileId
    When method GET
    Then status 200
    And match response.fileId == '#notnull'
    And match response.link == '#notnull'
    * def downloadLink = response.link

    #download link content should not be empty
    Given url downloadLink
    When method GET
    Then status 200
    And match response == '#notnull'

    Examples:
      | fileName                     | uploadFormat | fileDefinitionId                       |
      | test-export-instance-csv.csv | csv          | '61cef39a-56ea-4ca6-ba0b-cd91f7b2148d' |
      | test-export-instance-cql.cql | cql          | '508c8f1f-61a3-4684-9605-ea9c586c19a6' |

  Scenario: error logs should be empty after successful scenarios
    Given path 'data-export/logs'
    When method GET
    Then status 200
    And match response.totalRecords == 0

  Scenario Outline: test upload file and export flow for holding uuids when related MARC_HOLDING records exist.
    #should create file definition
    Given path 'data-export/file-definitions'
    And def fileDefinition = {'id':<fileDefinitionId>,'fileName':'<fileName>', 'uploadFormat':'<uploadFormat>'}
    And request fileDefinition
    When method POST
    Then status 201
    And match response.status == 'NEW'
    And match response.uploadFormat == '<uploadFormat>'

    #should return created file definition
    Given path 'data-export/file-definitions', <fileDefinitionId>
    When method GET
    Then status 200
    And match response.status == 'NEW'
    And match response.uploadFormat == '<uploadFormat>'

    #should upload file by created file definition id
    Given path 'data-export/file-definitions/',<fileDefinitionId>,'/upload'
    And configure headers = headersUserOctetStream
    And request karate.readAsString('classpath:samples/file-definition/<fileName>')
    When method POST
    Then status 200
    And match response.jobExecutionId == '#present'
    And match response.status == 'COMPLETED'
    And match response.uploadFormat == '<uploadFormat>'
    And match response.sourcePath == '#present'
    And def jobExecutionId = response.jobExecutionId

    #wait until the file will be uploaded to the system before calling further dependent calls
    Given path 'data-export/file-definitions', <fileDefinitionId>
    And retry until response.status == 'COMPLETED'
    When method GET
    Then status 200
    And call pause 500

    #should export instances and return 204
    Given path 'data-export/export'
    And configure headers = headersUser
    And def requestBody = {'fileDefinitionId':<fileDefinitionId>,'jobProfileId':'#(defaultHoldingJobProfileId)','idType':'holding'}
    And request requestBody
    When method POST
    Then status 204

    #should return job execution by id and wait until the job status will be 'COMPLETED'
    Given path 'data-export/job-executions'
    And param query = 'id==' + jobExecutionId
    And retry until response.jobExecutions[0].status == 'COMPLETED'
    When method GET
    Then status 200
    And match response.jobExecutions[0].status == 'COMPLETED'
    And match response.jobExecutions[0].progress == {exported:1, failed:0, total:1}
    And def fileId = response.jobExecutions[0].exportedFiles[0].fileId
    And call pause 500

    #should return download link for instance of uploaded file
    Given path 'data-export/job-executions/',jobExecutionId,'/download/',fileId
    When method GET
    Then status 200
    And match response.fileId == '#notnull'
    And match response.link == '#notnull'
    * def downloadLink = response.link

    #download link content should not be empty
    Given url downloadLink
    When method GET
    Then status 200
    And match response == '#notnull'

    Examples:
      | fileName                    | uploadFormat | fileDefinitionId                       |
      | test-export-holding-csv.csv | csv          | '506fd380-009d-4488-b086-a6a78c7df200' |

  Scenario: error logs should be empty after successful scenarios
    Given path 'data-export/logs'
    When method GET
    Then status 200
    And match response.totalRecords == 0

  Scenario Outline: test handling records that exceeds its max size of 99999 characters length, only invalid instances file
    #create file definition
    Given path 'data-export/file-definitions'
    And def fileDefinition = {'id':<fileDefinitionId>,'fileName':'<fileName>', 'uploadFormat':'<uploadFormat>'}
    And request fileDefinition
    When method POST
    Then status 201
    And match response.status == 'NEW'
    And match response.uploadFormat == '<uploadFormat>'

    #upload file by created file definition id
    Given path 'data-export/file-definitions/',<fileDefinitionId>,'/upload'
    And configure headers = headersUserOctetStream
    And request karate.readAsString('classpath:samples/file-definition/<fileName>')
    When method POST
    Then status 200
    And match response.jobExecutionId == '#present'
    And match response.status == 'COMPLETED'
    And match response.uploadFormat == '<uploadFormat>'
    And match response.sourcePath == '#present'
    And def jobExecutionId = response.jobExecutionId

    #wait until the file will be uploaded to the system before calling further dependent calls
    Given path 'data-export/file-definitions', <fileDefinitionId>
    And retry until response.status == 'COMPLETED'
    When method GET
    Then status 200
    And call pause 120000

    #run export and verify 204
    Given path 'data-export/export'
    And configure headers = headersUser
    And def requestBody = {'fileDefinitionId':<fileDefinitionId>,'jobProfileId':'#(customJobProfileId)','idType':'instance'}
    And request requestBody
    When method POST
    Then status 204

    #should return job execution by id and wait until the job status will be 'FAIL'
    Given path 'data-export/job-executions'
    And param query = 'id==' + jobExecutionId
    And retry until response.jobExecutions[0].status == 'FAIL'
    When method GET
    Then status 200
    And match response.jobExecutions[0].status == 'FAIL'
    And match response.jobExecutions[0].progress == {exported:0, failed:1, total:1}
    And call pause 120000

    Examples:
      | fileName                    | uploadFormat | fileDefinitionId                       |
      | instance_with_100_items.csv | csv          | 'cbb8513d-ff9a-4220-8562-18edf03f023e' |
      | instance_with_100_items.cql | cql          | 'a121e121-d0a9-4fcc-af0d-dcda20321030' |

  Scenario Outline: test handling records that exceeds its max size of 99999 characters length, 1 valid and 1 invalid instance in a file
    #create file definition
    Given path 'data-export/file-definitions'
    And def fileDefinition = {'id':<fileDefinitionId>,'fileName':'<fileName>','uploadFormat':'<uploadFormat>'}
    And request fileDefinition
    When method POST
    Then status 201
    And match response.status == 'NEW'
    And match response.uploadFormat == '<uploadFormat>'

    #upload file by created file definition id
    Given path 'data-export/file-definitions/',<fileDefinitionId>,'/upload'
    And configure headers = headersUserOctetStream
    And request karate.readAsString('classpath:samples/file-definition/<fileName>')
    When method POST
    Then status 200
    And match response.jobExecutionId == '#present'
    And match response.status == 'COMPLETED'
    And match response.uploadFormat == '<uploadFormat>'
    And match response.sourcePath == '#present'
    And def jobExecutionId = response.jobExecutionId

    #wait until the file will be uploaded to the system before calling further dependent calls
    Given path 'data-export/file-definitions', <fileDefinitionId>
    And retry until response.status == 'COMPLETED'
    When method GET
    Then status 200
    And call pause 120000

    #run export and verify 204
    Given path 'data-export/export'
    And configure headers = headersUser
    And def requestBody = {'fileDefinitionId':<fileDefinitionId>,'jobProfileId':'#(customJobProfileId)','idType':'instance'}
    And request requestBody
    When method POST
    Then status 204

    #should return job execution by id and wait until the job status will be 'COMPLETED_WITH_ERRORS'
    Given path 'data-export/job-executions'
    And param query = 'id==' + jobExecutionId
    And retry until response.jobExecutions[0].status == 'COMPLETED_WITH_ERRORS'
    When method GET
    Then status 200
    And match response.jobExecutions[0].status == 'COMPLETED_WITH_ERRORS'
    And match response.jobExecutions[0].progress == {exported:1, failed:1, total:2}
    And call pause 120000

    Examples:
      | fileName            | uploadFormat | fileDefinitionId                       |
      | mixed_instances.csv | csv          | 'b6c831eb-13bf-4f49-93c5-005224ab8a65' |
      | mixed_instances.cql | cql          | 'd3b5754d-75fc-4861-bf38-5e92d2e9fce1' |

  Scenario: error logs should not be empty after export scenarios with failed records presented
    Given path 'data-export/logs'
    When method GET
    Then status 200
    And match response.totalRecords != 0


  Scenario: Should return transformation fields
    Given path 'data-export/transformation-fields'
    When method GET
    Then status 200
    And assert response.transformationFields.length > 0

  #Negative scenarios

  Scenario Outline: test holdings export should fail when not default holding job profiled specified.
    #should create file definition
    Given path 'data-export/file-definitions'
    And def fileDefinition = {'id':<fileDefinitionId>,'fileName':'<fileName>', 'uploadFormat':'<uploadFormat>'}
    And request fileDefinition
    When method POST
    Then status 201
    And match response.status == 'NEW'
    And match response.uploadFormat == '<uploadFormat>'

    #should return created file definition
    Given path 'data-export/file-definitions', <fileDefinitionId>
    When method GET
    Then status 200
    And match response.status == 'NEW'
    And match response.uploadFormat == '<uploadFormat>'

    #should upload file by created file definition id
    Given path 'data-export/file-definitions/',<fileDefinitionId>,'/upload'
    And configure headers = headersUserOctetStream
    And request karate.readAsString('classpath:samples/file-definition/<fileName>')
    When method POST
    Then status 200
    And match response.jobExecutionId == '#present'
    And match response.status == 'COMPLETED'
    And match response.uploadFormat == '<uploadFormat>'
    And match response.sourcePath == '#present'
    And def jobExecutionId = response.jobExecutionId

    #wait until the file will be uploaded to the system before calling further dependent calls
    Given path 'data-export/file-definitions', <fileDefinitionId>
    And retry until response.status == 'COMPLETED'
    When method GET
    Then status 200
    And call pause 500

    #should not export records and complete export with FAIL status
    Given path 'data-export/export'
    And configure headers = headersUser
    And def requestBody = {'fileDefinitionId':<fileDefinitionId>,'jobProfileId':'#(defaultInstanceJobProfileId)','idType':'holding'}
    And request requestBody
    When method POST
    Then status 204

    #should return job execution by id and wait until the job status will be 'FAIL'
    Given path 'data-export/job-executions'
    And param query = 'id==' + jobExecutionId
    And retry until response.jobExecutions[0].status == 'FAIL'
    When method GET
    Then status 200
    And match response.jobExecutions[0].status == 'FAIL'
    And match response.jobExecutions[0].progress == {exported:0, failed:0, total:0}
    And call pause 500

    #error logs should be saved
    Given path 'data-export/logs'
    And param query = "jobExecutionId=" + jobExecutionId
    When method GET
    Then status 200
    And def errorLog = response.errorLogs[0]
    And match errorLog.errorMessageCode == 'error.jobProfile.onlyDefaultHoldingJobProfileIsSupported'
    And match errorLog.errorMessageValues[0] == 'For exporting holding records only the default holding job profile is supported'

    Examples:
      | fileName                    | uploadFormat | fileDefinitionId                       |
      | test-export-holding-csv.csv | csv          | '1c5e4e41-6f5b-46a1-b75d-5c71524050ee' |

  Scenario: test holdings export should fail when cql uploadFormat specified
    #should create file definition
    Given path 'data-export/file-definitions'
    And def fileDefinitionId = uuid()
    And def fileDefinition = {'id':#(fileDefinitionId),'fileName':'test_cql.cql', 'uploadFormat':'cql'}
    And request fileDefinition
    When method POST
    Then status 201
    And match response.status == 'NEW'
    And match response.uploadFormat == 'cql'
    And def fileDefinitionId = response.id

    #should return created file definition
    Given path 'data-export/file-definitions', fileDefinitionId
    When method GET
    Then status 200
    And match response.status == 'NEW'
    And match response.uploadFormat == 'cql'

    #should upload file by created file definition id
    Given path 'data-export/file-definitions/',fileDefinitionId,'/upload'
    And configure headers = headersUserOctetStream
    And request karate.readAsString('classpath:samples/file-definition/test-export-holding-csv.csv')
    When method POST
    Then status 200
    And match response.jobExecutionId == '#present'
    And match response.status == 'COMPLETED'
    And match response.uploadFormat == 'cql'
    And match response.sourcePath == '#present'
    And def jobExecutionId = response.jobExecutionId

    #wait until the file will be uploaded to the system before calling further dependent calls
    Given path 'data-export/file-definitions', fileDefinitionId
    And retry until response.status == 'COMPLETED'
    When method GET
    Then status 200
    And call pause 500

    #should not export records and complete export with FAIL status
    Given path 'data-export/export'
    And configure headers = headersUser
    And def requestBody = {'fileDefinitionId':#(fileDefinitionId),'jobProfileId':'#(defaultHoldingJobProfileId)','idType':'holding'}
    And request requestBody
    When method POST
    Then status 204

    #should return job execution by id and wait until the job status will be 'FAIL'
    Given path 'data-export/job-executions'
    And param query = 'id==' + jobExecutionId
    And retry until response.jobExecutions[0].status == 'FAIL'
    When method GET
    Then status 200
    And match response.jobExecutions[0].status == 'FAIL'
    And match response.jobExecutions[0].progress == {exported:0, failed:0, total:0}
    And call pause 500

    #error logs should be saved
    Given path 'data-export/logs'
    And param query = "jobExecutionId=" + jobExecutionId
    When method GET
    Then status 200
    And def errorLog = response.errorLogs[0]
    And match errorLog.errorMessageCode == 'error.uploadedFile.invalidExtension'
    And match errorLog.errorMessageValues[0] == 'Only csv format is supported for holdings export'

  Scenario Outline: test upload file and export flow for holding uuids when related MARC_HOLDING records don't exist.
    #should create file definition
    Given path 'data-export/file-definitions'
    And def fileDefinition = {'id':<fileDefinitionId>,'fileName':'<fileName>', 'uploadFormat':'<uploadFormat>'}
    And request fileDefinition
    When method POST
    Then status 201
    And match response.status == 'NEW'
    And match response.uploadFormat == '<uploadFormat>'

    #should return created file definition
    Given path 'data-export/file-definitions', <fileDefinitionId>
    When method GET
    Then status 200
    And match response.status == 'NEW'
    And match response.uploadFormat == '<uploadFormat>'

    #should upload file by created file definition id
    Given path 'data-export/file-definitions/',<fileDefinitionId>,'/upload'
    And configure headers = headersUserOctetStream
    And request karate.readAsString('classpath:samples/file-definition/<fileName>')
    When method POST
    Then status 200
    And match response.jobExecutionId == '#present'
    And match response.status == 'COMPLETED'
    And match response.uploadFormat == '<uploadFormat>'
    And match response.sourcePath == '#present'
    And def jobExecutionId = response.jobExecutionId

    #wait until the file will be uploaded to the system before calling further dependent calls
    Given path 'data-export/file-definitions', <fileDefinitionId>
    And retry until response.status == 'COMPLETED'
    When method GET
    Then status 200
    And call pause 500

    #should export instances and return 204
    Given path 'data-export/export'
    And configure headers = headersUser
    And def requestBody = {'fileDefinitionId':<fileDefinitionId>,'jobProfileId':'#(defaultHoldingJobProfileId)','idType':'holding'}
    And request requestBody
    When method POST
    Then status 204

    #should return job execution by id and wait until the job status will be 'COMPLETED'
    Given path 'data-export/job-executions'
    And param query = 'id==' + jobExecutionId
    And retry until response.jobExecutions[0].status == 'FAIL'
    When method GET
    Then status 200
    And match response.jobExecutions[0].status == 'FAIL'
    And match response.jobExecutions[0].progress == {exported:0, failed:0, total:0}
    And call pause 500

    #error logs should be saved
    Given path 'data-export/logs'
    And param query = "jobExecutionId=" + jobExecutionId
    When method GET
    Then status 200
    And def errorLog = response.errorLogs[0]
    And match errorLog.errorMessageCode == 'error.binaryFile.notGenerated'
    And match errorLog.errorMessageValues[0] == 'Nothing to export: no binary file generated'

    Examples:
      | fileName                                        | uploadFormat | fileDefinitionId                       |
      | test-export-holding-without-marc-record-csv.csv | csv          | '27237bef-baad-4e3a-bb41-ae6c49a8caa3' |

  Scenario: should not create a file definition and return 422 when invalid format is posted.
    Given path 'data-export/file-definitions'
    * def fileDefinition = {'fileName':'invalid.txt'}
    And request fileDefinition
    When method POST
    Then status 422
    And match response == 'File name extension does not corresponds csv format'

  Scenario: export should fail and return 400 when invalid job profile specified
    Given path 'data-export/file-definitions'
    And request {'fileName':'test.csv'}
    When method POST
    Then status 201
    And def testFileDefinitionId = response.id

    Given path 'data-export/file-definitions/',testFileDefinitionId,'/upload'
    And configure headers = headersUserOctetStream
    And request karate.readAsString('classpath:samples/file-definition/test-export-instance-csv.csv')
    When method POST
    Then status 200

    Given path 'data-export/export'
    And configure headers = headersUser
    And request {'fileDefinitionId':'#(testFileDefinitionId)', 'jobProfileId':#(uuid()),'idType':'instance'}
    When method POST
    Then status 400
    And match response contains 'JobProfile not found with id'

  Scenario: should fail export and return 400 when invalid file definition id specified
    Given path 'data-export/export'
    And request {'fileDefinitionId':#(uuid()), 'jobProfileId':'#(defaultInstanceJobProfileId)','idType':'instance'}
    When method POST
    Then status 400
    And match response contains 'File definition not found with id'

    #Clear storage folder

    Given path 'data-export/clean-up-files'
    When method POST
    Then status 204