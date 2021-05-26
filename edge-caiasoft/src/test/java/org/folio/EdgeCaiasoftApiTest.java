package org.folio;

import org.folio.test.TestBase;
import org.folio.test.config.TestModuleConfiguration;
import org.folio.test.services.TestIntegrationService;
import org.junit.jupiter.api.Test;

public class EdgeCaiasoftApiTest extends TestBase {

  private static final String TEST_BASE_PATH = "classpath:domain/edge-caiasoft/features/";

  public EdgeCaiasoftApiTest() {
    super(new TestIntegrationService(
      new TestModuleConfiguration(TEST_BASE_PATH)));
  }

  @Test
  void testAccessionIfItemWithinHoldingWithRemoteLocation() {
    runFeatureTest("accession-when-item-within-holding-with-remote-location");
  }

  @Test
  void testAccessionIfItemsWithinHoldingHaveRemoteLocation() {
    runFeatureTest("accession-when-items-have-remote-location-within-holding");
  }

  @Test
  void testAccessionIfInstanceHaveHoldingWithRemoteLocation() {
    runFeatureTest("accession-while-moving-item-to-exist-holding");
  }

  @Test
  void testAccessionWithHoldingDublication() {
    runFeatureTest("accession-with-holding-dublication");
  }

  @Test
  void testAccessionWhenItemWithoutLocationGetPermanentLocationFromHolding() {
    runFeatureTest("accession_when_item_without_location_get_permanent_location_from_holding");
  }
}
