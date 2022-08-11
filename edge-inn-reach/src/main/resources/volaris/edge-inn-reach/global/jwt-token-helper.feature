@ignore
@parallel=false
Feature: Edge inn reach JWT token helper

  Background:
    * url baseUrl

    * callonce login admin
    * def okapitokenUser = okapitoken
    * def okapiTenantUser = testTenant
    * def authToken1 = 'Basic MTczNWVkMmQtYTRhMS00YWE5LWFmYmYtOWUyZjc2YzNkMTZkOjU5YjliMDc1LTVmNjAtNGRlNi04YWIxLTQyODY2M2M4OGI4ZA=='
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'x-okapi-tenant': '#(okapiTenantUser)', 'Authorization' : '#(authToken1)', 'x-to-code': 'fli01', 'x-from-code': '69a3d', 'Accept': 'application/json'  }
    * def invalidHeadersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'x-okapi-tenant': '#(okapiTenantUser)', 'Authorization' : 'WERJjzsdfwe', 'x-to-code': 'fli01', 'x-from-code': '69a3d', 'Accept': 'application/json'  }
    * configure headers = headersUser

  @GetJWTToken
  Scenario: Authenticate credentials and get a new JWT token
    * print 'Authenticate credentials and get a new JWT token'
    # Port needs to be changed to specific port of edge-inn-reach in Vagrant box, when to run on Vagrant.
    Given url 'http://localhost:8081/innreach/v2/oauth2/token'
    And param grant_type = 'client_credentials'
    And param scope = 'innreach_tp'
    When method POST
    Then status 200
    And match response.access_token == '#present'

  @GetInvalidJWTToken
  Scenario: Authenticate credentials and get a new JWT token
    * print 'Authenticate credentials and get a new JWT token'
    * configure headers = invalidHeadersUser
    # Port needs to be changed to specific port of edge-inn-reach in Vagrant box, when to run on Vagrant.
    Given url 'http://localhost:8081/innreach/v2/oauth2/token'
    And param grant_type = 'client_credentials'
    And param scope = 'innreach_tp'
    When method POST
    Then status 401