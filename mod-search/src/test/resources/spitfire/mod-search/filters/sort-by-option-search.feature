Feature: Tests that sorted by fields

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = {'Content-Type': 'application/json', 'Accept': '*/*', 'x-okapi-token': #(okapitoken)}

  @Ignore
  @SortByOption
  Scenario: Can sort by option
    Given path '/search/' + recordsType
    And param query = 'cql.allRecords=1 sortBy ' + sortOption+'/sort.' + order
    And param expandAll = true
    When method GET
    Then status 200
    And def actualOrder = karate.jsonPath(response, "$."+ recordsType +'[*].'+ sortPath)
    Then match actualOrder == expectedOrder

  @Ignore
  @SortInTwoOrders
  Scenario: Can sort by option
    * def order = 'ascending'
    * call read('sort-by-option-search.feature@SortByOption')

    * expectedOrder.reverse()
    * def order = 'descending'
    * call read('sort-by-option-search.feature@SortByOption')

#   ================= Instance test cases =================

  Scenario: Can sort by title
    * def sortOption = "title"
    * def sortPath = sortOption
    * def recordsType = "instances"
    * def expectedOrder = new Array(15);

    * expectedOrder[0] = 'A semantic web primer'
    * expectedOrder[1] = 'Test Instance#10'
    * expectedOrder[2] = 'Test Instance#11'
    * expectedOrder[3] = 'Test Instance#12'
    * expectedOrder[4] = 'Test Instance#13'
    * expectedOrder[5] = 'Test Instance#14'
    * expectedOrder[6] = 'Test Instance#15'
    * expectedOrder[7] = 'Test Instance#3'
    * expectedOrder[8] = 'Test Instance#4'
    * expectedOrder[9] = 'Test Instance#5'
    * expectedOrder[10] = 'Test Instance#6'
    * expectedOrder[11] = 'Test Instance#7'
    * expectedOrder[12] = 'Test Instance#8'
    * expectedOrder[13] = 'Test Instance#9'
    * expectedOrder[14] = 'The web of metaphor :studies in the imagery of Montaigne Essais /by Carol Clark.'
    * call read('sort-by-option-search.feature@SortInTwoOrders')

  Scenario: Can sort by contributors
    * def sortOption = "contributors"
    * def sortPath = "contributors[*].name"
    * def order = 'ascending'
    * def recordsType = "instances"
    * def expectedOrder = new Array(2);

    * expectedOrder[0] = 'Antoniou, Grigoris'
    * expectedOrder[1] = 'Van Harmelen, Frank'
    * expectedOrder[2] = 'Clark, Carol (Carol E.)'
    * call read('sort-by-option-search.feature@SortByOption')

  Scenario: Can sort by items.status.name
    * def sortOption = "items.status.name"
    * def sortPath = "items[*].status.name"
    * def order = 'ascending'
    * def recordsType = "instances"
    * def expectedOrder = new Array(26);

    * expectedOrder.fill('Available', 0, 26)
    * expectedOrder[26] = 'Checked out'
    * call read('sort-by-option-search.feature@SortByOption')


#   ================= Authority test cases =================

  Scenario: Can sort by headingRef
    * def sortOption = "headingRef"
    * def sortPath = sortOption
    * def recordsType = "authorities"
    * def expectedOrder = new Array(21);

    * expectedOrder[0] = 'a conference title'
    * expectedOrder[1] = 'a corporate title'
    * expectedOrder[2] = 'a genre term'
    * expectedOrder[3] = 'a geographic name'
    * expectedOrder[4] = 'a personal title'

    * expectedOrder[5] = 'a saft conference title'
    * expectedOrder[6] = 'a saft corporate title'
    * expectedOrder[7] = 'a saft genre term'
    * expectedOrder[8] = 'a saft geographic name'
    * expectedOrder[9] = 'a saft personal title'
    * expectedOrder[10] = 'a saft topical term'
    * expectedOrder[11] = 'a saft uniform title'

    * expectedOrder[12] = 'a sft conference title'
    * expectedOrder[13] = 'a sft corporate title'
    * expectedOrder[14] = 'a sft genre term'
    * expectedOrder[15] = 'a sft geographic name'
    * expectedOrder[16] = 'a sft personal title'
    * expectedOrder[17] = 'a sft topical term'
    * expectedOrder[18] = 'a sft uniform title'
    * expectedOrder[19] = 'a topical term'
    * expectedOrder[20] = 'an uniform title'

    * call read('sort-by-option-search.feature@SortInTwoOrders')

  Scenario: Can sort by headingType
    * def sortOption = "headingType"
    * def sortPath = sortOption
    * def recordsType = "authorities"
    * def expectedOrder = new Array(21);

    * expectedOrder.fill('Conference Name', 0, 3)
    * expectedOrder.fill('Corporate Name', 3, 6)
    * expectedOrder.fill('Genre', 6, 9)
    * expectedOrder.fill('Geographic Name', 9, 12)
    * expectedOrder.fill('Personal Name', 12, 15)
    * expectedOrder.fill('Topical', 15, 18)
    * expectedOrder.fill('Uniform Title', 18, 21)
    * call read('sort-by-option-search.feature@SortInTwoOrders')

  Scenario: Can sort by authRefType
    * def sortOption = "authRefType"
    * def sortPath = sortOption
    * def recordsType = "authorities"
    * def expectedOrder = new Array(21);

    * expectedOrder.fill('Auth/Ref', 0, 7)
    * expectedOrder.fill('Authorized', 7, 14)
    * expectedOrder.fill('Reference', 14, 21)
    * call read('sort-by-option-search.feature@SortInTwoOrders')