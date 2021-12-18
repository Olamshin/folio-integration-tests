Feature: Destroy test data for kb-ebsco-java

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = {'x-okapi-token': '#(okapitoken)'}

    * def credentialId = karate.properties['credentialId']
    * def packageId = karate.properties['packageId']

  @DestroyPackage
  Scenario: Destroy package
    * if (packageId == null) karate.abort()
    Given path '/eholdings/packages', packageId
    When method DELETE
    Then status 204

  @DestroyCredentials
  Scenario: Destroy kb-credentials
    * if (credentialId == null) karate.abort()
    Given path '/eholdings/kb-credentials', credentialId
    When method DELETE
    And status 204

  @Ignore
  @DestroyResources
  Scenario: Destroy resources
    * if (resourceId == null) karate.abort()
    Given path '/eholdings/resources', resourceId
    When method DELETE
    And status 204

  #Destroy resource package
    * if (packageForResourceId == null) karate.abort()
    Given path '/eholdings/packages', packageForResourceId
    When method DELETE
    Then status 204