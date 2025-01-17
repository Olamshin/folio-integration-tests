# created for https://issues.folio.org/browse/MODORDERS-646
@parallel=false
Feature: Three fund distributions

  Background:
    * url baseUrl

    * callonce loginAdmin testAdmin
    * def okapitokenAdmin = okapitoken

    * callonce loginRegularUser testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json'  }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json'  }

    * configure headers = headersUser

    * callonce variables

    * def fundId = callonce uuid1
    * def budgetId = callonce uuid2
    * def orderId = callonce uuid3
    * def poLineId = callonce uuid4


  Scenario: Create a fund and budget
    * configure headers = headersAdmin
    * call createFund { id: '#(fundId)', ledgerId: '#(globalLedgerId)' }
    * callonce createBudget { id: '#(budgetId)', fundId: '#(fundId)', allocated: 1000 }


  Scenario: Create a composite order
    Given path 'orders/composite-orders'
    And request
    """
    {
      id: '#(orderId)',
      vendor: '#(globalVendorId)',
      orderType: 'One-Time'
    }
    """
    When method POST
    Then status 201


  Scenario: Create an order line
    Given path 'orders/order-lines'

    * def poLine = read('classpath:samples/mod-orders/orderLines/minimal-order-line.json')
    * set poLine.id = poLineId
    * set poLine.purchaseOrderId = orderId
    * set poLine.cost.listUnitPrice = 90
    * set poLine.cost.poLineEstimatedPrice = 90
    * set poLine.fundDistribution[0] = { fundId:"#(fundId)", code :"#(fundId)", distributionType:"amount", value:30.0 }
    * set poLine.fundDistribution[1] = { fundId:"#(fundId)", code :"#(fundId)", distributionType:"amount", value:30.0 }
    * set poLine.fundDistribution[2] = { fundId:"#(fundId)", code :"#(fundId)", distributionType:"amount", value:30.0 }

    And request poLine
    When method POST
    Then status 201


  Scenario: Open the order
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200

    * def order = $
    * set order.workflowStatus = 'Open'

    Given path 'orders/composite-orders', orderId
    And request order
    When method PUT
    Then status 204

