Feature: Tenant object in mod-consortia api tests

  Background:
    * url baseUrl
    * call read(login) centralUser1
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenant)', 'Accept': 'application/json' }

  Scenario: Attempt to POST a tenant to the consortium
    # cases for 404
    # attempt to create a tenant for consortia before 'central' tenant has been created
    Given path 'consortia', consortiumId, 'tenants'
    And request { id: '1234', code: 'ABC', name: 'test', isCentral: false }
    When method POST
    Then status 404
    And match response == { errors: [{message: 'A central tenant is not found. The central tenant must be created', type: '-1', code: 'NOT_FOUND_ERROR'}] }

    # attempt to create a tenant for non-existing consortium
    Given path 'consortia', '111841e3-e6fb-4191-8fd8-5674a5107c33', 'tenants'
    And request { id: '1234', code: 'ABC', name: 'test', isCentral: true }
    When method POST
    Then status 404
    And match response == { errors: [{message: 'Object with consortiumId [111841e3-e6fb-4191-8fd8-5674a5107c33] was not found', type: '-1', code: 'NOT_FOUND_ERROR'}] }

    # cases for 422
    # attempt to create a tenant without an id
    Given path 'consortia', consortiumId, 'tenants'
    And request { code: 'ABC', name: 'test', isCentral: false }
    When method POST
    Then status 422
    And match response == { errors: [{ message: "'id' validation failed. must not be null", type: '-1', code: 'tenantValidationError'}] }

    # attempt to create a tenant without a code
    Given path 'consortia', consortiumId, 'tenants'
    And request { id: '1234', name: 'test', isCentral: false }
    When method POST
    Then status 422
    And match response == { errors: [{ message: "'code' validation failed. must not be null", type: '-1', code: 'tenantValidationError'}] }

    # attempt to create a tenant without a name
    Given path 'consortia', consortiumId, 'tenants'
    And request { id: '1234', code: 'ABC', isCentral: false }
    When method POST
    Then status 422
    And match response == { errors: [{ message: "'name' validation failed. must not be null", type: '-1', code: 'tenantValidationError'}] }

    # attempt to create a tenant without isCentral
    Given path 'consortia', consortiumId, 'tenants'
    And request { id: '1234', code: 'ABC', name: 'test' }
    When method POST
    Then status 422
    And match response == { errors: [{ message: "'isCentral' validation failed. must not be null", type: '-1', code: 'tenantValidationError'}] }

#    # attempt to create a tenant with a name that has length more than 150 characters and a code with more than 3 characters
#    Given path 'consortia', consortiumId, 'tenants'
#    And request { id: '12345', code: 'TTTT', name: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec auctor, nisl eget ultricies lacinia, nisl nisl aliquet nisl, eget aliquet nisl nisl eget nisl. Donec auctor, nisl eget ultricies lacinia, nisl nisl aliquet nisl, eget aliquet nisl nisl eget nisl.', isCentral: true }
#    When method POST
#    Then status 422
#    And match response.errors[*].message contains ['\'code\' validation failed. Invalid Code length: Must be of 3 alphanumeric characters', '\'name\' validation failed. Invalid Name: Must be of 2 - 150 characters']

  Scenario: Do Create, Read, Update for 'central' tenant (isCentral = true)
    # create 'central' tenant
    Given path 'consortia', consortiumId, 'tenants'
    And request { id: '#(centralTenant)', code: 'ABC', name: 'Central tenants name', isCentral: true }
    When method POST
    Then status 201
    And match response == { id: '#(centralTenant)', code: 'ABC', name: 'Central tenants name', isCentral: true }

    # get tenants by consortiumId
    Given path 'consortia', consortiumId, 'tenants'
    When method GET
    Then status 200
    And match response == { tenants: [{ id: '#(centralTenant)', code: 'ABC', name: 'Central tenants name', isCentral: true }], totalRecords: 1 }

    # update a tenant with a different code
    Given path 'consortia', consortiumId, 'tenants', centralTenant
    And request { id: '#(centralTenant)', code: 'ABD', name: 'Central tenants name', isCentral: true}
    When method PUT
    Then status 200
    And match response == { id: '#(centralTenant)', code: 'ABD', name: 'Central tenants name', isCentral: true }

    # update a tenant with a different name
    Given path 'consortia', consortiumId, 'tenants', centralTenant
    And request { id: '#(centralTenant)', code: 'ABD', name: 'Central tenants name updated', isCentral: true}
    When method PUT
    Then status 200
    And match response == { id: '#(centralTenant)', code: 'ABD', name: 'Central tenants name updated', isCentral: true }

  # At this point we have one record in consortium = { id: '#(centralTenant)', code: 'ABD', name: 'Central tenants name updated', isCentral: true }
  Scenario: Attempt to POST a second tenant with existing 'isCentral' = true or 'id' or 'name' or 'code' in this order
    # cases for 409
    # attempt to create a second central tenant ('isCentral' = true)
    Given path 'consortia', consortiumId, 'tenants'
    And request { id: '#(universityTenant)', code: 'XYZ', name: 'University tenants name', isCentral: true }
    When method POST
    Then status 409
    And match response == { errors : [{ message : 'Object with isCentral [true] is already presented in the system', type : '-1', code: 'DUPLICATE_ERROR' }] }

    # attempt to create a tenant with an existing id
    Given path 'consortia', consortiumId, 'tenants'
    And request { id: '#(centralTenant)', code: 'ABE', name: 'test1', isCentral: false }
    When method POST
    Then status 409
    And match response.errors[0].message == 'Object with id [' + centralTenant +'] is already presented in the system'
    And match response.errors[0].type == '-1'
    And match response.errors[0].code == 'DUPLICATE_ERROR'

#    # attempt to create a tenant with an existing code
#    Given path 'consortia', consortiumId, 'tenants'
#    And request { id: 'non-existing-tenant', code: 'ABD', name: 'test1', isCentral: false }
#    When method POST
#    Then status 409
#    And match response == { errors : [{ message : 'ERROR: duplicate key value violates unique constraint \"tenant_code_key\"\n  Detail: Key (code)=(ABD) already exists.', type : '-1', code: 'VALIDATION_ERROR' }] }
#
#    # attempt to create a tenant with an existing name
#    Given path 'consortia', consortiumId, 'tenants'
#    And request { id: 'non-existing-tenant', code: 'ABE', name: 'Central tenants name updated', isCentral: false }
#    When method POST
#    Then status 409
#    And match response == { errors : [{ message : 'ERROR: duplicate key value violates unique constraint \"tenant_name_key\"\n  Detail: Key (name)=(Central tenants name updated) already exists.', type : '-1', code: 'VALIDATION_ERROR' }] }

  Scenario: Attempt to PUT a non-existing tenant, tenant with different id, with non-existing consortiumId
    # cases for 400
    # attempt to update a tenant with a different id
    Given path 'consortia', consortiumId, 'tenants', centralTenant
    And request { id: '12345', code: 'ABD', name: 'test', isCentral: false}
    When method PUT
    Then status 400
    And match response == { errors: [{ message: 'Request body tenantId and path param tenantId should be identical', type: '-1', code: 'VALIDATION_ERROR' }] }

    # cases for 404
    # attempt to update a tenant for non-existing consortium
    Given path 'consortia', 'd9acad2f-2aac-4b48-9097-e6ab85906b25', 'tenants', '1234'
    And request { id: '12345', code: 'ABD', name: 'test', isCentral: false }
    When method PUT
    Then status 404
    And match response == { errors: [{message: 'Object with consortiumId [d9acad2f-2aac-4b48-9097-e6ab85906b25] was not found', type: '-1', code: 'NOT_FOUND_ERROR'}] }

    # attempt to update non-existing tenant
    Given path 'consortia', consortiumId, 'tenants', '12345'
    And request { id: '12345', code: 'ABD', name: 'test', isCentral: false }
    When method PUT
    Then status 404
    And match response == { errors: [{message: 'Object with id [12345] was not found', type: '-1', code: 'NOT_FOUND_ERROR'}] }

  Scenario: Attempt to DELETE non-existing tenant, with non-existing consortiumId
    # cases for 404
    # attempt to delete non-existing tenant in the consortium
    Given path 'consortia', consortiumId, 'tenants', '1234'
    When method DELETE
    Then status 404
    And match response == { errors: [{message: 'Object with id [1234] was not found', type: '-1', code: 'NOT_FOUND_ERROR'}] }

    # attempt to update non-existing tenant
    Given path 'consortia', 'd9acad2f-2aac-4b48-9097-e6ab85906b25', 'tenants', '12345'
    And request { id: '12345', code: 'ABD', name: 'test', isCentral: false }
    When method DELETE
    Then status 404
    And match response == { errors: [{message: 'Object with consortiumId [d9acad2f-2aac-4b48-9097-e6ab85906b25] was not found', type: '-1', code: 'NOT_FOUND_ERROR'}] }

#  Scenario: Do Create, Read, Update for 'university' tenant  (isCentral = false)
#    # create 'university' tenant
#    Given path 'consortia', consortiumId, 'tenants'
#    And request { id: '#(universityTenant)', code: 'XYZ', name: 'University tenants name', isCentral: false }
#    When method POST
#    Then status 201
#    And match response == { id: '#(universityTenant)', code: 'XYZ', name: 'University tenants name', isCentral: false }
#
#    # get tenants by consortiumId - should get two tenants
#    Given path 'consortia', consortiumId, 'tenants'
#    When method GET
#    Then status 200
#    And match response.totalRecords == 2
#    * match response contains deep { id: '#(centralTenant)', code: 'ABC', name: 'Central tenants name', isCentral: true }
#    * match response contains deep { id: '#(universityTenant)', code: 'XYZ', name: 'University tenants name', isCentral: false }