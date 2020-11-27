package org.folio;

import org.folio.testrail.AbstractTestRailIntegrationTest;
import org.folio.testrail.config.TestModuleConfiguration;
import org.folio.testrail.services.TestRailIntegrationService;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

public class InvoicesApiTest extends AbstractTestRailIntegrationTest {

  // default module settings
  private static final String TEST_BASE_PATH = "classpath:domain/mod-invoice/features/";
  private static final String TEST_SUITE_NAME = "mod-invoice";
  private static final long TEST_SECTION_ID = 1387L;
  // TODO: make TEST_SUITE_ID different for each module
  private static final long TEST_SUITE_ID = 111L;

  public InvoicesApiTest() {
    super(new TestRailIntegrationService(
        new TestModuleConfiguration(TEST_BASE_PATH, TEST_SUITE_NAME, TEST_SUITE_ID, TEST_SECTION_ID)));
  }

  @Test
  void checkInvoiceAndLinesDeletionRestrictions() {
    runFeatureTest("check-invoice-and-invoice-lines-deletion-restrictions");
  }

  @Test
  void checkRemainingAmountInvoiceApproval() {
    runFeatureTest("check-remaining-amount-upon-invoice-approval");
  }

  @Test
  void createVoucherLinesExpenseClasses() {
    runFeatureTest("create-voucher-lines-honor-expense-classes");
  }

  @Test
  void exchangeRateUpdateInvoiceApproval() {
    runFeatureTest("exchange-rate-update-after-invoice-approval");
  }

  @Test
  void proratedAdjustmentsSpecialCases() {
    runFeatureTest("prorated-adjustments-special-cases");
  }

  @Test
  void expenseClassesValidation() {
    runFeatureTest("expense-classes-validation");
  }

  @BeforeAll
  public void invoicesApiTestBeforeAll() {
    runFeature("classpath:domain/mod-invoice/invoice-junit.feature");
  }

  @AfterAll
  public void invoicesApiTestAfterAll() {
    runFeature("classpath:common/destroy-data.feature");
  }

}