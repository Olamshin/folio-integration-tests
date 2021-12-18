Feature: Status

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/vnd.api+json', 'x-okapi-token': '#(okapitoken)' }

    * def credentialId = karate.properties['credentialId']

  Scenario: GET status of currently set KB configuration with 200 on success
    Given path '/eholdings/status'
    When method GET
    Then status 200

  Scenario: GET current status of load holdings job should be Not Started
    Given path '/eholdings/loading/kb-credentials', credentialId, 'status'
    When method GET
    Then status 200
    And match response.data.attributes.status.name == 'Not Started'

  Scenario: GET current status of load holdings job should be In Progress
    Given path '/eholdings/loading/kb-credentials', credentialId
    When method POST
    Then status 204

    Given path '/eholdings/loading/kb-credentials', credentialId, 'status'
    When method GET
    Then status 200
    And match response.data.attributes.status.name == 'In Progress'