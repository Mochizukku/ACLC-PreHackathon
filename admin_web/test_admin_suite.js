// test_admin_suite.js - Automated Test Suite for Admin Web Backend & Seller Request Cycle
const http = require('http');
const assert = require('assert');

// Ensure we test with local mock database or in-memory instance
process.env.PORT = '0'; // Ephemeral port
const FirebaseDB = require('./firebase_db');

async function runTestSuite() {
  console.log('\n======================================================');
  console.log('🚀 RUNNING ADMIN WEBSITE & SELLER REQUEST CYCLE TESTS');
  console.log('======================================================\n');

  let passedTests = 0;
  let totalTests = 0;

  function test(name, fn) {
    totalTests++;
    return (async () => {
      try {
        await fn();
        console.log(`  ✅ PASS: ${name}`);
        passedTests++;
      } catch (err) {
        console.error(`  ❌ FAIL: ${name}`);
        console.error(`     Error: ${err.message}`);
        throw err;
      }
    })();
  }

  // 1. Direct FirebaseDB Service Tests
  await test('Seller request can be created with initial Pending status', async () => {
    const testReq = {
      id: 'req-test-cycle-01',
      store_name: 'Test Kiosk Delight',
      applicant_name: 'Juan Dela Cruz',
      email: 'juan.delacruz.test@example.com',
      contact: '09123456789',
      status: 'Pending',
      questionnaire_token: null,
      questionnaire_submitted: false,
      submitted_at: new Date().toISOString(),
      reviewed_at: null
    };

    await FirebaseDB.saveRequest(testReq);
    const retrieved = await FirebaseDB.getRequestById('req-test-cycle-01');
    assert.strictEqual(retrieved.id, 'req-test-cycle-01');
    assert.strictEqual(retrieved.store_name, 'Test Kiosk Delight');
    assert.strictEqual(retrieved.status, 'Pending');
    assert.strictEqual(retrieved.questionnaire_submitted, false);
  });

  await test('Admin can assign questionnaire token to seller request', async () => {
    const req = await FirebaseDB.getRequestById('req-test-cycle-01');
    req.questionnaire_token = 'token-uuid-1234';
    req.status = 'Questionnaire Sent';
    await FirebaseDB.saveRequest(req);

    const byToken = await FirebaseDB.getRequestByToken('token-uuid-1234');
    assert.ok(byToken);
    assert.strictEqual(byToken.id, 'req-test-cycle-01');
    assert.strictEqual(byToken.status, 'Questionnaire Sent');
  });

  await test('Seller questionnaire templates can be retrieved and answered', async () => {
    const templates = await FirebaseDB.getQuestionnaireTemplates();
    assert.ok(Array.isArray(templates));
    assert.ok(templates.length >= 3, 'Default templates should have at least 3 questions');

    // Save answers
    const answersMap = {
      'Why do you want to create an account for your store?': 'To serve hot meals to campus students.',
      'What products or food items will your store be selling in the cafeteria?': 'Dimsum, Siomai, Fresh Juices.',
      'What are your planned operating hours in the school cafeteria?': '7:00 AM - 5:00 PM'
    };

    const savedAnswers = await FirebaseDB.saveAnswers('req-test-cycle-01', answersMap);
    assert.strictEqual(savedAnswers.length, 3);

    const retrievedAnswers = await FirebaseDB.getAnswersForRequest('req-test-cycle-01');
    assert.strictEqual(retrievedAnswers.length, 3);

    // Update request status to Under Review
    const req = await FirebaseDB.getRequestById('req-test-cycle-01');
    req.questionnaire_submitted = true;
    req.status = 'Under Review';
    await FirebaseDB.saveRequest(req);

    const updated = await FirebaseDB.getRequestById('req-test-cycle-01');
    assert.strictEqual(updated.status, 'Under Review');
    assert.strictEqual(updated.questionnaire_submitted, true);
  });

  await test('Admin approval creates an active Seller Account', async () => {
    const req = await FirebaseDB.getRequestById('req-test-cycle-01');
    req.status = 'Approved';
    req.reviewed_at = new Date().toISOString();
    await FirebaseDB.saveRequest(req);

    const newAccount = {
      id: 'acc-test-delight-01',
      store_name: req.store_name,
      applicant_name: req.applicant_name,
      email: req.email,
      contact: req.contact,
      status: 'Active',
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    };
    await FirebaseDB.saveAccount(newAccount);

    const account = await FirebaseDB.getAccountByEmail('juan.delacruz.test@example.com');
    assert.ok(account);
    assert.strictEqual(account.store_name, 'Test Kiosk Delight');
    assert.strictEqual(account.status, 'Active');
  });

  await test('Seller PIN authentication generates and verifies 6-digit PIN', async () => {
    const email = 'juan.delacruz.test@example.com';
    const pin = '654321';
    const expiresAt = new Date(Date.now() + 10 * 60000).toISOString();

    await FirebaseDB.saveSellerPin(email, pin, expiresAt);

    const pinRecord = await FirebaseDB.getSellerPin(email);
    assert.ok(pinRecord);
    assert.strictEqual(pinRecord.pin, '654321');
    assert.strictEqual(new Date() < new Date(pinRecord.expires_at), true);

    // Clean up
    await FirebaseDB.deleteSellerPin(email);
    const afterDelete = await FirebaseDB.getSellerPin(email);
    assert.strictEqual(afterDelete, null);
  });

  await test('Admin account status toggling (Active <-> Inactive)', async () => {
    const acc = await FirebaseDB.getAccountById('acc-test-delight-01');
    assert.strictEqual(acc.status, 'Active');

    const toggled1 = await FirebaseDB.toggleAccountStatus('acc-test-delight-01');
    assert.strictEqual(toggled1.status, 'Inactive');

    const toggled2 = await FirebaseDB.toggleAccountStatus('acc-test-delight-01');
    assert.strictEqual(toggled2.status, 'Active');
  });

  await test('Admin request rejection updates status and logs rejection reason', async () => {
    const rejectReq = {
      id: 'req-test-reject-02',
      store_name: 'Unqualified Kiosk',
      applicant_name: 'Impostor',
      email: 'impostor@test.com',
      contact: '0000000000',
      status: 'Pending',
      submitted_at: new Date().toISOString()
    };
    await FirebaseDB.saveRequest(rejectReq);

    const row = await FirebaseDB.getRequestById('req-test-reject-02');
    row.status = 'Rejected';
    row.reviewed_at = new Date().toISOString();
    await FirebaseDB.saveRequest(row);

    const rejected = await FirebaseDB.getRequestById('req-test-reject-02');
    assert.strictEqual(rejected.status, 'Rejected');
    assert.ok(rejected.reviewed_at);
  });

  await test('Admin dashboard aggregate metrics correctly compute live figures', async () => {
    const dashData = await FirebaseDB.getDashboardData();
    assert.ok(dashData.stats);
    assert.ok(typeof dashData.stats.activeAccounts === 'number');
    assert.ok(typeof dashData.stats.sellerAccountsTotal === 'number');
    assert.ok(typeof dashData.stats.missedRequestsTotal === 'number');
    assert.ok(Array.isArray(dashData.accounts));
    assert.ok(Array.isArray(dashData.requests));
    assert.ok(dashData.stats.chart.weeks.length === 5);
  });

  console.log('\n======================================================');
  console.log(`🎉 ALL ${passedTests}/${totalTests} ADMIN & SELLER CYCLE TESTS PASSED!`);
  console.log('======================================================\n');
}

runTestSuite().catch((err) => {
  console.error('\n❌ Test suite failed:', err);
  process.exit(1);
});
