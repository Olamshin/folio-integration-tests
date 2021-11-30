Feature: Loans tests

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*'  }
    * def materialTypeId = call uuid1
    * def materialTypeName = 'e-book'
    * callonce read('classpath:vega/mod-circulation/features/util/initData.feature@PostMaterialType') { extMaterialTypeId: #(materialTypeId) }

    * def loanPolicyId = call uuid1
    * def lostItemFeePolicyId = call uuid1
    * def overdueFinePoliciesId = call uuid1
    * def patronPolicyId = call uuid1
    * def requestPolicyId = call uuid1
    * def loanPolicyMaterialId = call uuid1
    * callonce read('classpath:vega/mod-circulation/features/util/initData.feature@PostLoanPolicy') { extLoanPolicyId: #(loanPolicyId) }
    * callonce read('classpath:vega/mod-circulation/features/util/initData.feature@PostLoanPolicy') { extLoanPolicyId: #(loanPolicyMaterialId) }
    * callonce read('classpath:vega/mod-circulation/features/util/initData.feature@PostLostPolicy') { extLostItemFeePolicyId: #(lostItemFeePolicyId) }
    * callonce read('classpath:vega/mod-circulation/features/util/initData.feature@PostOverduePolicy') { extOverdueFinePoliciesId: #(overdueFinePoliciesId) }
    * callonce read('classpath:vega/mod-circulation/features/util/initData.feature@PostPatronPolicy') { extPatronPolicyId: #(patronPolicyId) }
    * callonce read('classpath:vega/mod-circulation/features/util/initData.feature@PostRequestPolicy') { extRequestPolicyId: #(requestPolicyId) }
    * callonce read('classpath:vega/mod-circulation/features/util/initData.feature@PostRulesWithMaterialType') { extLoanPolicyId: #(loanPolicyId), extLostItemFeePolicyId: #(lostItemFeePolicyId), extOverdueFinePoliciesId: #(overdueFinePoliciesId), extPatronPolicyId: #(patronPolicyId), extRequestPolicyId: #(requestPolicyId), extMaterialTypeId: #(materialTypeId), extLoanPolicyMaterialId: #(loanPolicyMaterialId), extOverdueFinePoliciesMaterialId: #(overdueFinePoliciesId), extLostItemFeePolicyMaterialId: #(lostItemFeePolicyId), extRequestPolicyMaterialId: #(requestPolicyId), extPatronPolicyMaterialId: #(patronPolicyId) }

    * def instanceId = call uuid1
    * def servicePointId = call uuid1
    * def locationId = call uuid1
    * def holdingId = call uuid1
    * def itemId = call uuid1
    * def groupId = call uuid1
    * def userId = call uuid1
    * def ownerId = call uuid1
    * def manualChargeId = call uuid1
    * def paymentMethodId = call uuid1
    * def userBarcode = random(100000)
    * def checkOutByBarcodeId = call uuid1
    * def parseObjectToDate = read('classpath:vega/mod-circulation/features/util/parse-object-to-date-function.js')

  Scenario: When patron and item id's entered at checkout, post a new loan using the circulation rule matched
    * def extUserId = call uuid1

    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostInstance')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostServicePoint')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostLocation')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostHoldings')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostItem') { extItemBarcode: 666666, extMaterialTypeId: #(materialTypeId), extItemId: #(itemId) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostGroup')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserId: #(extUserId), extUserBarcode: #(userBarcode) }

    # checkOut
    * def checkOutResponse = call read('classpath:vega/mod-circulation/features/util/initData.feature@PostCheckOut') { extCheckOutUserBarcode: #(userBarcode), extCheckOutItemBarcode: 666666 }

    # get loan and verify
    Given path 'circulation', 'loans'
    And param query = '(userId==' + extUserId + ' and ' + 'itemId==' + itemId + ')'
    When method GET
    Then status 200
    And match response.loans[0].id == checkOutResponse.response.id
    And match response.loans[0].loanPolicyId == loanPolicyMaterialId

  Scenario: Get checkIns records, define current item checkIn record and its status
    * def extInstanceTypeId = call uuid1
    * def extInstitutionId = call uuid1
    * def extCampusId = call uuid1
    * def extLibraryId = call uuid1

    #post an item
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostInstance') { extInstanceTypeId: #(extInstanceTypeId) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostServicePoint')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostLocation') { extInstitutionId: #(extInstitutionId), extCampusId: #(extCampusId), extLibraryId: #(extLibraryId) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostHoldings')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostItem') { extItemBarcode: '555555', extMaterialTypeId: #(materialTypeId), extItemId: #(itemId) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostGroup')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserBarcode: #(userBarcode)  }

    # checkOut an item
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostCheckOut') { extCheckOutUserBarcode: #(userBarcode), extCheckOutItemBarcode: '555555' }

    # checkIn an item with certain itemBarcode
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@CheckInItem') { itemBarcode: '555555' }

    # get check-ins and assert checkedIn record
    Given path 'check-in-storage', 'check-ins'
    When method GET
    Then status 200
    * def checkedInRecord = response.checkIns[response.totalRecords - 1]
    And match checkedInRecord.itemId == itemId

    Given path 'check-in-storage', 'check-ins', checkedInRecord.id
    When method GET
    Then status 200
    And match response.itemStatusPriorToCheckIn == 'Checked out'
    And match response.itemId == itemId

  Scenario: When get loans for a patron is called, return a paged collection of loans for that patron with all data as specified in the circulation/loans API

    * def extUserId = call uuid1
    * def extItemBarcode1 = random(10000)
    * def extItemBarcode2 = random(10000)
    * def extUserBarcode = random(100000)

    # post items
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostInstance')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostServicePoint')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostLocation')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostHoldings')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostItem') { extItemBarcode: #(extItemBarcode1), extMaterialTypeId: #(materialTypeId) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostItem') { extItemBarcode: #(extItemBarcode2), extMaterialTypeId: #(materialTypeId) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostGroup')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserBarcode: #(extUserBarcode), extUserId: #(extUserId) }

    # checkOut the first item
    * def checkOutResponse1 = call read('classpath:vega/mod-circulation/features/util/initData.feature@PostCheckOut') { extCheckOutUserBarcode: #(extUserBarcode), extCheckOutItemBarcode: #(extItemBarcode1) }
    # checkOut the second item
    * def checkOutResponse2 = call read('classpath:vega/mod-circulation/features/util/initData.feature@PostCheckOut') { extCheckOutUserBarcode: #(extUserBarcode), extCheckOutItemBarcode: #(extItemBarcode2) }

    # Get a paged collection of patron
    Given path 'circulation', 'loans'
    And param query = '(userId=="' + extUserId + '")'
    When method GET
    Then status 200
    And match response == { totalRecords: #present, loans: #present }
    And match response.totalRecords == 2
    And match response.loans[0] == { id: #present, lostItemPolicyId: #present, metadata: #present, item: #present, dueDate: #present, checkoutServicePointId: #present, borrower: #present, feesAndFines: #present, userId: #present, patronGroupAtCheckout: #present, overdueFinePolicy: #present, checkoutServicePoint: #present, itemId: #present, loanPolicyId: #present, itemEffectiveLocationIdAtCheckOut: #present, loanDate: #present, action: #present, overdueFinePolicyId: #present, lostItemPolicy: #present, id: #present, loanPolicy: #present, status: #present }
    And match response.loans[0].id == checkOutResponse1.response.id
    And match response.loans[1] == { id: #present, lostItemPolicyId: #present, metadata: #present, item: #present, dueDate: #present, checkoutServicePointId: #present, borrower: #present, feesAndFines: #present, userId: #present, patronGroupAtCheckout: #present, overdueFinePolicy: #present, checkoutServicePoint: #present, itemId: #present, loanPolicyId: #present, itemEffectiveLocationIdAtCheckOut: #present, loanDate: #present, action: #present, overdueFinePolicyId: #present, lostItemPolicy: #present, id: #present, loanPolicy: #present, status: #present }
    And match response.loans[1].id == checkOutResponse2.response.id

  Scenario: When an existing loan is declared lost, update declaredLostDate, item status to declared lost and bill lost item fees per the Lost Item Fee Policy
    * def itemBarcode = random(100000)
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostInstance')
    * def postServicePointResult = call read('classpath:vega/mod-circulation/features/util/initData.feature@PostServicePoint')
    * def servicePointId = postServicePointResult.response.id
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostOwner')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostLocation')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostHoldings')
    * def postItemResult = call read('classpath:vega/mod-circulation/features/util/initData.feature@PostItem') { extItemBarcode: #(itemBarcode), extMaterialTypeId: #(materialTypeId) }
    * def itemId = postItemResult.response.id
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostGroup')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserBarcode: #(userBarcode) }

    * def checkOutResult = call read('classpath:vega/mod-circulation/features/util/initData.feature@PostCheckOut') { extCheckOutUserBarcode: #(userBarcode), extCheckOutItemBarcode: #(itemBarcode) }
    * def loanId = checkOutResult.response.id
    * def declaredLostDateTime = call read('classpath:vega/mod-circulation/features/util/get-time-now-function.js')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@DeclareItemLost') { servicePointId: #(servicePointId), loanId: #(loanId), declaredLostDateTime:#(declaredLostDateTime) }

    Given path '/loan-storage', 'loans', loanId
    When method GET
    Then status 200
    And match parseObjectToDate(response.declaredLostDate) == parseObjectToDate(declaredLostDateTime)

    Given path '/item-storage', 'items', itemId
    When method GET
    Then status 200
    And match response.status.name == 'Declared lost'

    * def lostItemFeePolicyEntity = read('samples/policies/lost-item-fee-policy-entity-request.json')
    Given path 'accounts'
    And param query = 'loanId==' + loanId + ' and feeFineType==Lost item processing fee'
    When method GET
    Then status 200
    And match response.accounts[0].amount == lostItemFeePolicyEntity.lostItemProcessingFee

    Given path 'accounts'
    And param query = 'loanId==' + loanId + ' and feeFineType==Lost item fee'
    When method GET
    Then status 200
    And match response.accounts[0].amount == lostItemFeePolicyEntity.chargeAmountItem.amount

  Scenario: Post item, two patrons, check out item and post a recall request, assert expectedDueDateBeforeRequest and dueDate

    * def groupId = call uuid1
    * def extInstanceTypeId = call uuid1
    * def extInstitutionId = call uuid1
    * def extCampusId = call uuid1
    * def extLibraryId = call uuid1
    * def requestId = call uuid1
    * def extItemId = call uuid1
    * def extUserId = call uuid1
    * def extUserId2 = call uuid1
    * def expectedLoanDate = '2021-10-27T13:25'
    * def expectedDueDateBeforeRequest = '2021-11-17T13:25'

    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostInstance') { extInstanceTypeId: #(extInstanceTypeId) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostServicePoint')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostLocation') { extInstitutionId: #(extInstitutionId), extCampusId: #(extCampusId), extLibraryId: #(extLibraryId) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostHoldings')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostItem') { extItemBarcode: '333333', extMaterialTypeId: #(materialTypeId), extItemId: #(extItemId) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostGroup')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserId: #(extUserId), extUserBarcode: '44441' }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserId: #(extUserId2), extUserBarcode: '44442' }

    # checkOut an item
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostCheckOut') { extCheckOutUserBarcode: '44441', extCheckOutItemBarcode: '333333' }

    # check loan and dueDateChangedByRecall availability
    Given path 'circulation', 'loans'
    And param query = 'status.name=="Open" and itemId==' + extItemId
    When method GET
    Then status 200
    * def loanResponse = response.loans[0]
    Then match loanResponse.dueDateChangedByRecall == '#notpresent'
    Then match loanResponse.loanPolicyId == loanPolicyMaterialId
    Then match loanResponse.loanDate contains expectedLoanDate
    Then match loanResponse.dueDate contains expectedDueDateBeforeRequest

    # post recall request by patron-requester
    * def requestEntityRequest = read('classpath:vega/mod-circulation/features/samples/request-entity-request.json')
    * requestEntityRequest.requesterId = extUserId2
    * requestEntityRequest.itemId = extItemId
    Given path 'circulation' ,'requests'
    And request requestEntityRequest
    When method POST
    Then status 201

    # check loan and dueDateChangedByRecall availability after request
    Given path 'circulation', 'loans'
    And param query = 'status.name=="Open" and itemId==' + extItemId
    When method GET
    Then status 200
    Then match $.loans[0].dueDateChangedByRecall == true
    And match $.loans[0].dueDate contains expectedDueDateBeforeRequest

  Scenario: When an loaned item is checked in at a service point that serves its location and no request exists, change the item status to Available

    * def extItemBarcode = 'fat1003-ibc'
    * def extUserId = call uuid1
    * def extUserBarcode = 'fat1003-ubc'

    # location and service point setup
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostLocation')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostServicePoint')

    # post an item
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostInstance')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostHoldings')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostItem') { extItemId: #(itemId), extItemBarcode: #(extItemBarcode)}

    # post a user
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostGroup')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserBarcode: #(extUserBarcode), extUserId: #(extUserId) }

    # check-out the item
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostCheckOut') { extCheckOutUserBarcode: #(extUserBarcode), extCheckOutItemBarcode: #(extItemBarcode) }

    # verify that no request exist before check-in
    Given path 'circulation', 'requests'
    And param query = '(requesterId==' + extUserId + ' and status=="Open*")'
    When method GET
    Then status 200
    And match response.totalRecords == 0
    And match response.requests == []

    # check-in the item and verify that item status is changed to 'Available'
    * def checkInResponse = call read('classpath:vega/mod-circulation/features/util/initData.feature@CheckInItem') { itemBarcode: #(extItemBarcode) }
    * def item = checkInResponse.response.item
    And match item.id == itemId
    And match item.status.name == 'Available'

  Scenario: When an requested loaned item is checked in at a service point designated as the pickup location of the request, change the item status to awaiting-pickup

    * def extItemBarcode = '12123366'
    * def extUserId1 = call uuid1
    * def extUserId2 = call uuid2
    * def extUserBarcode1 = '3315666'
    * def extUserBarcode2 = '3315669'
    * def extRequestId = call uuid1

    # post a location and service point
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostServicePoint')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostLocation')

    # post an item
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostInstance')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostHoldings')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostItem') { extItemId: #(itemId), extItemBarcode: #(extItemBarcode)}

    # post an user
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostGroup')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserBarcode: #(extUserBarcode1), extUserId: #(extUserId1) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserBarcode: #(extUserBarcode2), extUserId: #(extUserId2) }

    # checkOut the item
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostCheckOut') { extCheckOutUserBarcode: #(extUserBarcode1), extCheckOutItemBarcode: #(extItemBarcode) }

    # post a request for the checked-out-item
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostRequest') { requestId: #(extRequestId), itemId: #(itemId), requesterId: #(extUserId2) }

    # checkIn the item and check if the request status changed to awaiting pickup
    * def checkInResponse = call read('classpath:vega/mod-circulation/features/util/initData.feature@CheckInItem') { itemBarcode: #(extItemBarcode) }
    * def response = checkInResponse.response
    And match response.item.id == itemId
    And match response.item.status.name == 'Awaiting pickup'

    # check the status of the user request whether changed to 'Open-Awaiting pickup'
    Given path 'circulation', 'requests', extRequestId
    When method GET
    Then status 200
    And match response.status == 'Open - Awaiting pickup'

  Scenario:  When a loaned item is checked in at a service point that does not serve its location and no request exists, change the item status to In-transit and destination to primary service point for its location

    * def extItemBarcode = 'fat1004-ibc'
    * def extUserId = call uuid1
    * def extUserBarcode = 'fat1004-ubc'
    * def extServicePointId1 = call uuid1
    * def extServicePointId2 = call uuid1
    * def extInstitutionId1 = call uuid1
    * def extInstitutionId2 = call uuid1
    * def extCampusId1 = call uuid1
    * def extCampusId2 = call uuid1
    * def extLibraryId1 = call uuid1
    * def extLibraryId2 = call uuid1
    * def extLocationId1 = call uuid1
    * def extLocationId2 = call uuid1

    # first location and service point setup
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostLocation') { extLocationId: #(extLocationId1),  extInstitutionId: #(extInstitutionId1), extCampusId: #(extCampusId1), extLibraryId: #(extLibraryId1), extServicePointId: #(extServicePointId1) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostServicePoint') { servicePointId: #(extServicePointId1) }

    # second location and service point setup
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostLocation') { extLocationId: #(extLocationId2), extInstitutionId: #(extInstitutionId2), extCampusId: #(extCampusId2), extLibraryId: #(extLibraryId2), extServicePointId: #(extServicePointId2) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostServicePoint') { servicePointId: #(extServicePointId2) }

    # post an item which is located in the first location
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostInstance')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostHoldings') { extLocationId: #(extLocationId1) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostItem') { extItemId: #(itemId), extItemBarcode: #(extItemBarcode) }

    # post a user
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostGroup')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserBarcode: #(extUserBarcode), extUserId: #(extUserId) }

    # check-out the item
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostCheckOut') { extCheckOutUserBarcode: #(extUserBarcode), extCheckOutItemBarcode: #(extItemBarcode), extServicePointId: #(extServicePointId1) }

    # verify that no request exist before check-in
    Given path 'circulation', 'requests'
    And param query = '(requesterId==' + extUserId + ' and status=="Open*")'
    When method GET
    Then status 200
    And match response.totalRecords == 0
    And match response.requests == []

    # check-in the item from second service point and verify that item status is changed to 'In transit'
    * def checkInResponse = call read('classpath:vega/mod-circulation/features/util/initData.feature@CheckInItem') { itemBarcode: #(extItemBarcode), extServicePointId: #(extServicePointId2) }
    * def item = checkInResponse.response.item
    And match item.id == itemId
    And match item.status.name == 'In transit'
    And match item.inTransitDestinationServicePointId == extServicePointId1

  Scenario: When an item has the status intellectual item, do not allow checkout

    * def extItemBarcode = 'FAT-1007IBC'
    * def extUserBarcode = 'FAT-1007UBC'
    * def extStatusName = 'Intellectual item'

    # location and service point setup
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostLocation')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostServicePoint')

    # post an item
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostInstance')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostHoldings')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostItem') { extItemBarcode: #(extItemBarcode), extStatusName: #(extStatusName) }

    # post a user
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostGroup')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserBarcode: #(extUserBarcode) }

    # check-out the item and verify that checking-out the item is not processable
    * def checkOutByBarcodeEntityRequest = read('samples/check-out-by-barcode-entity-request.json')
    * checkOutByBarcodeEntityRequest.userBarcode = extUserBarcode
    * checkOutByBarcodeEntityRequest.itemBarcode = extItemBarcode
    Given path 'circulation', 'check-out-by-barcode'
    And request checkOutByBarcodeEntityRequest
    When method POST
    Then status 422
    * def error = response.errors[0]
    And match error.message == '#string'
    And match error.message == 'Long Way to a Small Angry Planet (' + materialTypeName + ') (Barcode: ' + extItemBarcode + ') has the item status Intellectual item and cannot be checked out'
    And match error.parameters[0].value == extItemBarcode

  Scenario: When an item that had the status of restricted that was checked out is checked in, set the item status to Available

    * def itemBarcode = '88888'
    * def userBarcode = random(100000)

    # post associated entities and item
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostInstance')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostServicePoint')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostOwner')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostLocation')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostHoldings')
    * def postItemResult = call read('classpath:vega/mod-circulation/features/util/initData.feature@PostItem') { extItemBarcode: #(itemBarcode), extMaterialTypeId: #(materialTypeId) }
    * def itemId = postItemResult.response.id

    # post group and patron
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostGroup')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserBarcode: #(userBarcode) }

    # declare item with restricted status
    Given path 'inventory/items/' + itemId + '/mark-restricted'
    When method POST
    Then status 200
    And match response.status.name == 'Restricted'

    # checkOut an item with certain itemBarcode to created patron
    * def checkOutResult = call read('classpath:vega/mod-circulation/features/util/initData.feature@PostCheckOut') { extCheckOutUserBarcode: #(userBarcode), extCheckOutItemBarcode: #(itemBarcode) }
    * def loanId = checkOutResult.response.id

    # checkIn an item with certain itemBarcode, assert loan as Closed and item status as Available
    * def postCheckInResult = call read('classpath:vega/mod-circulation/features/util/initData.feature@CheckInItem') { itemBarcode: #(itemBarcode) }
    And match postCheckInResult.response.loan.id == loanId
    And match postCheckInResult.response.loan.status.name == 'Closed'
    And match postCheckInResult.response.item.id == itemId
    And match postCheckInResult.response.item.status.name == 'Available'

  Scenario: When an item has the status of in process allow checkout

    * def extItemBarcode = '888777'
    * def extUserBarcode = '334455'
    * def extUserId = call uuid1

    # post a location and service point
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostServicePoint')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostLocation')

    # post an item
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostInstance')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostHoldings')
    * def postItemResult = call read('classpath:vega/mod-circulation/features/util/initData.feature@PostItem') { extItemId: #(itemId), extItemBarcode: #(extItemBarcode) }
    * def itemId = postItemResult.response.id

    # post a group and user
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostGroup')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserBarcode: #(extUserBarcode), extUserId: #(extUserId) }

    # declare item with in process status
    Given path 'inventory/items/' + itemId + '/mark-in-process-non-requestable'
    When method POST
    Then status 200
    And match response.status.name == 'In process (non-requestable)'

    # checkOut the item
    * def checkOutResponse = call read('classpath:vega/mod-circulation/features/util/initData.feature@PostCheckOut') { extCheckOutUserBarcode: #(extUserBarcode), extCheckOutItemBarcode: #(extItemBarcode) }
    And match checkOutResponse.response.item.id == itemId
    And match checkOutResponse.response.item.status.name == 'Checked out'
    And match checkOutResponse.response.loanDate == '#present'

  Scenario:  When a loaned item is checked in at a service point that does not serve its location and a request exists, change the item status to In-transit and destination to pickup location in the request

    * def extItemBarcode = 'fat1005-ibc'
    * def extUserId1 = call uuid1
    * def extUserId2 = call uuid1
    * def extUserBarcode1 = 'fat1005-ubc1'
    * def extUserBarcode2 = 'fat1005-ubc2'
    * def extServicePointId1 = call uuid1
    * def extServicePointId2 = call uuid1
    * def extServicePointId3 = call uuid1
    * def extInstitutionId1 = call uuid1
    * def extInstitutionId2 = call uuid1
    * def extInstitutionId3 = call uuid1
    * def extCampusId1 = call uuid1
    * def extCampusId2 = call uuid1
    * def extCampusId3 = call uuid1
    * def extLibraryId1 = call uuid1
    * def extLibraryId2 = call uuid1
    * def extLibraryId3 = call uuid1
    * def extLocationId1 = call uuid1
    * def extLocationId2 = call uuid1
    * def extLocationId3 = call uuid1
    * def extRequestId = call uuid1

    # first location and service point setup
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostLocation') { extLocationId: #(extLocationId1),  extInstitutionId: #(extInstitutionId1), extCampusId: #(extCampusId1), extLibraryId: #(extLibraryId1), extServicePointId: #(extServicePointId1) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostServicePoint') { servicePointId: #(extServicePointId1) }

    # second location and service point setup
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostLocation') { extLocationId: #(extLocationId2), extInstitutionId: #(extInstitutionId2), extCampusId: #(extCampusId2), extLibraryId: #(extLibraryId2), extServicePointId: #(extServicePointId2) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostServicePoint') { servicePointId: #(extServicePointId2) }

    # third location and service point setup
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostLocation') { extLocationId: #(extLocationId3), extInstitutionId: #(extInstitutionId3), extCampusId: #(extCampusId3), extLibraryId: #(extLibraryId3), extServicePointId: #(extServicePointId3) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostServicePoint') { servicePointId: #(extServicePointId3) }

    # post an item which is located in the first location
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostInstance')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostHoldings') { extLocationId: #(extLocationId1) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostItem') { extItemId: #(itemId), extItemBarcode: #(extItemBarcode) }

    # post two users
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostGroup')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserBarcode: #(extUserBarcode1), extUserId: #(extUserId1) }
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserBarcode: #(extUserBarcode2), extUserId: #(extUserId2) }

    # first user checks-out the item
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostCheckOut') { extCheckOutUserBarcode: #(extUserBarcode1), extCheckOutItemBarcode: #(extItemBarcode), extServicePointId: #(extServicePointId1) }

    # second user posts a request for the checked-out-item
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostRequest') { requestId: #(extRequestId), itemId: #(itemId), requesterId: #(extUserId2), servicePointId: #(extServicePointId2) }

    # check-in the item from third service point and verify that item status is changed to 'In transit'
    * def checkInResponse = call read('classpath:vega/mod-circulation/features/util/initData.feature@CheckInItem') { itemBarcode: #(extItemBarcode), extServicePointId: #(extServicePointId3) }
    * def item = checkInResponse.response.item
    And match item.id == itemId
    And match item.status.name == 'In transit'
    And match item.inTransitDestinationServicePointId == extServicePointId2

  Scenario: When an item has the status of restricted, allow checkout with override

    * def extItemBarcode = 'fat1008-ibc'
    * def extUserBarcode = 'fat1008-ubc'

    # post associated entities and item
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostInstance')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostServicePoint')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostOwner')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostLocation')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostHoldings')
    * def postItemResult = call read('classpath:vega/mod-circulation/features/util/initData.feature@PostItem') { extItemBarcode: #(extItemBarcode), extMaterialTypeId: #(materialTypeId) }
    * def itemId = postItemResult.response.id

    # post group and patron
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostGroup')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserBarcode: #(extUserBarcode) }

    # declare item with restricted status
    Given path 'inventory/items/' + itemId + '/mark-restricted'
    When method POST
    Then status 200
    And match response.status.name == 'Restricted'

    # checkOut an item with certain itemBarcode to created patron
    * def checkOutResult = call read('classpath:vega/mod-circulation/features/util/initData.feature@PostCheckOut') { extCheckOutUserBarcode: #(extUserBarcode), extCheckOutItemBarcode: #(extItemBarcode) }
    * def item = checkOutResult.response.item
    And match item.id == itemId
    And match item.status.name == 'Checked out'

  Scenario: When an item that had the status of in process that was checked out is checked in, set the item status to Available

    * def extItemBarcode = 'FAT-1011IBC'
    * def extUserBarcode = 'FAT-1011UBC'

    # location and service point setup
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostLocation')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostServicePoint')

    # post an item
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostInstance')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostHoldings')
    * def postItemResponse = call read('classpath:vega/mod-circulation/features/util/initData.feature@PostItem') { extItemBarcode: #(extItemBarcode) }
    * def itemId = postItemResponse.response.id

    # post a user
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostGroup')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserBarcode: #(extUserBarcode) }

    # change the item status to In-process
    Given path 'inventory/items/' + itemId + '/mark-in-process-non-requestable'
    When method POST
    Then status 200
    And match response.status.name == 'In process (non-requestable)'

    # check-out the item
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostCheckOut') { extCheckOutUserBarcode: #(extUserBarcode), extCheckOutItemBarcode: #(extItemBarcode) }

    # check-in the item and verify that the item status is Available
    * def checkInResponse = call read('classpath:vega/mod-circulation/features/util/initData.feature@CheckInItem') { itemBarcode: #(extItemBarcode) }
    * def item = checkInResponse.response.item
    And match item.barcode == extItemBarcode
    And match item.status.name == 'Available'

  Scenario: When an item has the status of on order allow checkout

    * def extItemBarcode = 'FAT-1012IBC'
    * def extUserBarcode = 'FAT-1012UBC'
    * def extStatusName = 'On order'

    # location and service point setup
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostLocation')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostServicePoint')

    # post an item
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostInstance')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostHoldings')
    * def postItemResponse = call read('classpath:vega/mod-circulation/features/util/initData.feature@PostItem') { extItemBarcode: #(extItemBarcode), extStatusName: #(extStatusName) }
    * def itemId = postItemResponse.response.id
    And match postItemResponse.response.status.name == extStatusName

    # post a user
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostGroup')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserBarcode: #(extUserBarcode) }

    # checkOut the item
    * def checkOutResponse = call read('classpath:vega/mod-circulation/features/util/initData.feature@PostCheckOut') { extCheckOutUserBarcode: #(extUserBarcode), extCheckOutItemBarcode: #(extItemBarcode) }
    And match checkOutResponse.response.item.id == itemId
    And match checkOutResponse.response.item.status.name == 'Checked out'
    And match checkOutResponse.response.loanDate == '#present'

  Scenario: When an item that had the status of On order that was checked out is checked in, item status should be changed to Available

    * def extItemBarcode = '888555'
    * def extUserBarcode = '334477'
    * def extUserId = call uuid1
    * def extStatusName = 'On order'

    # post a location and service point
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostServicePoint')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostLocation')

    # post an item and assert its status name as On order
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostInstance')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostHoldings')
    * def postItemResponse = call read('classpath:vega/mod-circulation/features/util/initData.feature@PostItem') { extItemId: #(itemId), extItemBarcode: #(extItemBarcode), extStatusName: #(extStatusName) }
    * def itemId = postItemResponse.response.id
    And match postItemResponse.response.status.name == extStatusName

    # post a group and user
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostGroup')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserBarcode: #(extUserBarcode), extUserId: #(extUserId) }

    # checkOut the item and assert its status
    * def checkOutResponse = call read('classpath:vega/mod-circulation/features/util/initData.feature@PostCheckOut') { extCheckOutUserBarcode: #(extUserBarcode), extCheckOutItemBarcode: #(extItemBarcode) }
    * def loanId = checkOutResponse.response.id
    And match checkOutResponse.response.item.id == itemId
    And match checkOutResponse.response.item.status.name == 'Checked out'
    And match checkOutResponse.response.loanDate == '#present'

    # checkIn an item with certain itemBarcode, assert loan as Closed and item status as Available
    * def postCheckInResponse = call read('classpath:vega/mod-circulation/features/util/initData.feature@CheckInItem') { itemBarcode: #(extItemBarcode) }
    And match postCheckInResponse.response.loan.id == loanId
    And match postCheckInResponse.response.loan.status.name == 'Closed'
    And match postCheckInResponse.response.item.id == itemId
    And match postCheckInResponse.response.item.status.name == 'Available'

  Scenario: When an overdue item is returned, an overdue fine is billed per the Overdue Fine Policy

    * def extItemBarcode = 'FAT-1017IBC'
    * def extUserBarcode = 'FAT-1017UBC'
    * def extCheckInDate = '2021-11-17T13:30:46.000Z'

     # location and service point setup
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostLocation')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostServicePoint')

    # post an item
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostInstance')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostHoldings')
    * def postItemResponse = call read('classpath:vega/mod-circulation/features/util/initData.feature@PostItem') { extItemBarcode: #(extItemBarcode) }
    * def itemId = postItemResponse.response.id

    # post a group and user
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostGroup')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostUser') { extUserBarcode: #(extUserBarcode) }

    # post owner, manual charge and payment method
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostOwner')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostManualCharge')
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@PostPaymentMethod')

    # checkOut the item
    * def checkOutResponse = call read('classpath:vega/mod-circulation/features/util/initData.feature@PostCheckOut') { extCheckOutUserBarcode: #(extUserBarcode), extCheckOutItemBarcode: #(extItemBarcode) }
    * def loanId = checkOutResponse.response.id

    # checkIn the item
    * call read('classpath:vega/mod-circulation/features/util/initData.feature@CheckInItem') { itemBarcode: #(extItemBarcode), extCheckInDate: #(extCheckInDate) }

    # get overdue fine by loan id
    Given path 'accounts'
    And param query = 'loanId==' + loanId
    When method GET
    Then status 200
    * def accountInResponse = response.accounts[0]
    And match response.totalRecords == 1
    And match accountInResponse.status.name == 'Open'
    And match accountInResponse.feeFineType == 'Overdue fine'
    And def accountId = accountInResponse.id
    And def overdueFineAmount = accountInResponse.amount

    # check-pay and verify that the fine is possible to be paid
    Given path 'accounts/' + accountId + '/check-pay'
    And request { amount: '#(overdueFineAmount)' }
    When method POST
    Then status 200
    And match response.allowed == true

    # pay overdue fine and verify that the fine is billed fully
    * def postPayResponse = call read('classpath:vega/mod-circulation/features/util/initData.feature@PostPay') { amount: #(overdueFineAmount) }
    * def feefineactionInResponse = postPayResponse.response.feefineactions[0]
    And match feefineactionInResponse.typeAction == 'Paid fully'
    And match feefineactionInResponse.amountAction == overdueFineAmount
    And match feefineactionInResponse.accountId == accountId