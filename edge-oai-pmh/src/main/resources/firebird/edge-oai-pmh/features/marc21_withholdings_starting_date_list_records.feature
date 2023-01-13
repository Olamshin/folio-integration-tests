Feature: edge-oai-pmh feature
  Background:
    * url edgeUrl
    * callonce read('init_data/init_marc21_withholdings_starting_date_list_records.feature')

  Scenario: List records in marc21_withholdings format with from param
    Given path 'oai'
    And param apikey = apikey
    And param metadataPrefix = 'marc21_withholdings'
    And param verb = 'ListRecords'
    And param from = '2023-01-10'
    When method GET
    Then status 200
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='952']/*[local-name()='subfield'][@code='a'] == 'Københavns Universitet'
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='952']/*[local-name()='subfield'][@code='b'] == 'City Campus'
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='952']/*[local-name()='subfield'][@code='c'] == 'Datalogisk Institut'
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='952']/*[local-name()='subfield'][@code='d'] == 'SECOND FLOOR'
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='952']/*[local-name()='subfield'][@code='e'] == 'D15.H63 A3 2002'
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='952']/*[local-name()='subfield'][@code='f'] == 'call number prefix'
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='952']/*[local-name()='subfield'][@code='g'] == 'call number suffix'
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='952']/*[local-name()='subfield'][@code='h'] == 'UDC'
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='952']/*[local-name()='subfield'][@code='j'] == 'volume'
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='952']/*[local-name()='subfield'][@code='k'] == 'enumeration'
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='952']/*[local-name()='subfield'][@code='l'] == 'chronology'
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='952']/*[local-name()='subfield'][@code='i'] == 'book'
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='952']/*[local-name()='subfield'][@code='m'] == '645398607547'
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='952']/*[local-name()='subfield'][@code='n'] == 'Copy 2'

    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='856']/*[local-name()='subfield'][@code='u'] == ['uri6','uri3','uri4','uri5','uri1','uri2']
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='856']/*[local-name()='subfield'][@code='3'] == ['materialsSpecification6','materialsSpecification3','materialsSpecification4','materialsSpecification5','materialsSpecification1','materialsSpecification2']
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='856']/*[local-name()='subfield'][@code='z'] == ['publicNote6','publicNote3','publicNote4','publicNote5','publicNote1','publicNote2']

    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='856' and @ind1='4' and @ind2='2']/*[local-name()='subfield'][@code='y'] == 'Related resource'
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='856' and @ind1='4' and @ind2='0']/*[local-name()='subfield'][@code='y'] == 'Resource'
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='856' and @ind1='4' and @ind2='8']/*[local-name()='subfield'][@code='y'] == 'No display constant generated'
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='856' and @ind1='4' and @ind2=' ']/*[local-name()='subfield'][@code='y'] == ['empty value','No information provided']
    And match response//metadata/*[local-name()='record']/*[local-name()='datafield'][@tag='856' and @ind1='4' and @ind2='1']/*[local-name()='subfield'][@code='y'] == 'Version of resource'

  Scenario: List records does not exist for from param
    Given path 'oai', apikey
    And param metadataPrefix = 'marc21_withholdings'
    And param verb = 'ListRecords'
    And param from = '2100-01-01'
    When method GET
    Then status 200
    And match response count(/OAI-PMH/ListRecords/record) == 0