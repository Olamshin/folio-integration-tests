Feature: mod-circulation integration tests

  Background:
    * url baseUrl
    * table modules
      | name                      |
      | 'mod-login'               |
      | 'mod-permissions'         |
      | 'mod-circulation'         |
      | 'mod-circulation-storage' |
      | 'mod-inventory'           |
      | 'mod-inventory-storage'   |

    * table adminAdditionalPermissions
      | name |

    * table userPermissions
      | name                                                           |
      | 'accounts.collection.get'                                      |
      | 'accounts.check-pay.post'                                      |
      | 'accounts.pay.post'                                            |
      | 'automated-patron-blocks.collection.get'                       |
      | 'automated-patron-blocks.collection.get'                       |
      | 'check-in-storage.check-ins.collection.get'                    |
      | 'check-in-storage.check-ins.item.get'                          |
      | 'circulation-storage.circulation-rules.put'                    |
      | 'circulation-storage.loan-policies.item.post'                  |
      | 'circulation-storage.loans.item.get'                           |
      | 'circulation-storage.patron-notice-policies.item.post'         |
      | 'circulation-storage.request-policies.item.post'               |
      | 'circulation.check-in-by-barcode.post'                         |
      | 'circulation.check-out-by-barcode.post'                        |
      | 'circulation.loans.collection.get'                             |
      | 'circulation.loans.declare-item-lost.post'                     |
      | 'circulation.requests.collection.get'                          |
      | 'circulation.requests.item.get'                                |
      | 'circulation.requests.item.post'                               |
      | 'feefines.item.post'                                           |
      | 'inventory-storage.contributor-name-types.item.post'           |
      | 'inventory-storage.holdings.item.post'                         |
      | 'inventory-storage.instance-relationships.collection.get'      |
      | 'inventory-storage.instance-relationships.item.delete'         |
      | 'inventory-storage.instance-relationships.item.post'           |
      | 'inventory-storage.instance-relationships.item.put'            |
      | 'inventory-storage.instance-types.item.post'                   |
      | 'inventory-storage.instances.item.get'                         |
      | 'inventory-storage.instances.item.post'                        |
      | 'inventory-storage.items.item.get'                             |
      | 'inventory-storage.loan-types.item.post'                       |
      | 'inventory-storage.location-units.campuses.item.post'          |
      | 'inventory-storage.location-units.institutions.item.post'      |
      | 'inventory-storage.location-units.libraries.item.post'         |
      | 'inventory-storage.locations.item.post'                        |
      | 'inventory-storage.material-types.item.post'                   |
      | 'inventory-storage.preceding-succeeding-titles.collection.get' |
      | 'inventory-storage.preceding-succeeding-titles.item.delete'    |
      | 'inventory-storage.preceding-succeeding-titles.item.post'      |
      | 'inventory-storage.preceding-succeeding-titles.item.put'       |
      | 'inventory-storage.service-points.item.post'                   |
      | 'inventory.instances.item.post'                                |
      | 'inventory.items.item.mark-in-process-non-requestable.post'    |
      | 'inventory.items.item.mark-restricted.post'                    |
      | 'inventory.items.item.post'                                    |
      | 'lost-item-fees-policies.item.post'                            |
      | 'manualblocks.collection.get'                                  |
      | 'overdue-fines-policies.item.post'                             |
      | 'owners.item.post'                                             |
      | 'payments.item.post'                                           |
      | 'usergroups.item.post'                                         |
      | 'users.item.post'                                              |

  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')
