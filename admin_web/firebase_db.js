// firebase_db.js - Firebase Database service (Cloud Firestore + Persistent Local Firebase fallback)
const fs = require('fs');
const path = require('path');

let admin = null;
let firestoreDb = null;
let isLiveFirebase = false;

// Check if firebase-admin can be initialized with credentials
try {
  admin = require('firebase-admin');
  const serviceAccountPath = path.join(__dirname, 'serviceAccountKey.json');
  const envServiceAccount = process.env.FIREBASE_SERVICE_ACCOUNT;
  const envProjectId = process.env.FIREBASE_PROJECT_ID;

  if (fs.existsSync(serviceAccountPath)) {
    const serviceAccount = require(serviceAccountPath);
    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount)
    });
    firestoreDb = admin.firestore();
    isLiveFirebase = true;
    console.log('🔥 Connected to Live Firebase Cloud Firestore via serviceAccountKey.json');
  } else if (envServiceAccount) {
    const serviceAccount = JSON.parse(envServiceAccount);
    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount)
    });
    firestoreDb = admin.firestore();
    isLiveFirebase = true;
    console.log('🔥 Connected to Live Firebase Cloud Firestore via FIREBASE_SERVICE_ACCOUNT env');
  } else if (envProjectId && process.env.FIREBASE_PRIVATE_KEY && process.env.FIREBASE_CLIENT_EMAIL) {
    admin.initializeApp({
      credential: admin.credential.cert({
        projectId: envProjectId,
        clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
        privateKey: process.env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, '\n')
      })
    });
    firestoreDb = admin.firestore();
    isLiveFirebase = true;
    console.log('🔥 Connected to Live Firebase Cloud Firestore via project environment credentials');
  } else {
    console.log('🔥 Firebase Database initialized (Persistent Local Firestore Engine).');
    console.log('   Note: Add admin_web/serviceAccountKey.json to automatically sync with a remote Google Cloud Firebase project.');
  }
} catch (err) {
  console.log('🔥 Firebase Database initialized with local file persistence.');
}

const LOCAL_FIREBASE_FILE = path.join(__dirname, 'data', 'firebase_db.json');

// Initialize initial seed data if file doesn't exist
function getInitialData() {
  const now = new Date();
  
  // Seed sample orders for the past 5 weeks to calculate live statistics
  const orders = [];
  const weeklyCounts = [15, 38, 29, 64, 21];
  for (let w = 0; w < 5; w++) {
    const count = weeklyCounts[w];
    const daysAgoStart = (4 - w) * 7;
    for (let i = 0; i < count; i++) {
      const orderDate = new Date(now);
      orderDate.setDate(orderDate.getDate() - (daysAgoStart + (i % 7)));
      orders.push({
        id: `ord-${w}-${i}-${Date.now()}-${Math.random().toString(36).substr(2, 4)}`,
        seller_id: 'acc-kent-001',
        seller_email: 'kentjohnllanita8978@gmail.com',
        amount: parseFloat((Math.random() * 150 + 60).toFixed(2)),
        status: 'Completed',
        ordered_at: orderDate.toISOString()
      });
    }
  }

  return {
    seller_accounts: [
      {
        id: 'acc-kent-001',
        store_name: "Kent's Campus Diner",
        applicant_name: "Kent John Llanita",
        email: "kentjohnllanita8978@gmail.com",
        contact: "+63 917 888 9999",
        status: "Active",
        created_at: new Date(Date.now() - 30 * 86400000).toISOString(),
        updated_at: new Date().toISOString()
      },
      {
        id: 'acc-002',
        store_name: "Campus Cafeteria Hub (Main)",
        applicant_name: "Maria Santos",
        email: "maria.cafeteria@school.edu.ph",
        contact: "+63 918 123 4567",
        status: "Active",
        created_at: new Date(Date.now() - 25 * 86400000).toISOString(),
        updated_at: new Date().toISOString()
      },
      {
        id: 'acc-003',
        store_name: "Kape & Pastry Corner",
        applicant_name: "Angela Reyes",
        email: "angela.reyes@gmail.com",
        contact: "+63 919 444 3322",
        status: "Active",
        created_at: new Date(Date.now() - 18 * 86400000).toISOString(),
        updated_at: new Date().toISOString()
      },
      {
        id: 'acc-004',
        store_name: "Bento Express Bowl",
        applicant_name: "Kenji Sato",
        email: "kenji.bento@gmail.com",
        contact: "+63 922 710 4321",
        status: "Active",
        created_at: new Date(Date.now() - 10 * 86400000).toISOString(),
        updated_at: new Date().toISOString()
      },
      {
        id: 'acc-005',
        store_name: "Green Garden Salads",
        applicant_name: "Elena Rostova",
        email: "elena.green@school.edu.ph",
        contact: "+63 920 334 1122",
        status: "Inactive",
        created_at: new Date(Date.now() - 5 * 86400000).toISOString(),
        updated_at: new Date().toISOString()
      }
    ],
    seller_requests: [
      {
        id: 'req-kent-test',
        store_name: "Kent's Crispy Chicken & Snacks",
        applicant_name: "Kent John Llanita",
        email: "kentjohnllanita8978@gmail.com",
        contact: "+63 917 888 9999",
        status: "Pending",
        questionnaire_token: null,
        questionnaire_submitted: false,
        submitted_at: new Date(Date.now() - 2 * 3600000).toISOString(),
        reviewed_at: null
      },
      {
        id: 'req-002',
        store_name: "Fresh Fruit & Smoothie Bar",
        applicant_name: "Sarah Jenkins",
        email: "sarah.smoothies@gmail.com",
        contact: "+63 919 663 8744",
        status: "Pending",
        questionnaire_token: null,
        questionnaire_submitted: false,
        submitted_at: new Date(Date.now() - 5 * 3600000).toISOString(),
        reviewed_at: null
      }
    ],
    questionnaire_templates: [
      { id: 'q1', question: 'Why do you want to create an account for your store?', is_required: 1, sort_order: 1 },
      { id: 'q2', question: 'What products or food items will your store be selling in the cafeteria?', is_required: 1, sort_order: 2 },
      { id: 'q3', question: 'How long have you been operating or planning to operate this type of food business?', is_required: 1, sort_order: 3 },
      { id: 'q4', question: 'Do you have any existing food safety certifications or permits? (Yes/No and details)', is_required: 0, sort_order: 4 },
      { id: 'q5', question: 'What are your planned operating hours in the school cafeteria?', is_required: 1, sort_order: 5 }
    ],
    questionnaire_answers: [],
    orders: orders,
    seller_pins: []
  };
}

function loadLocalData() {
  try {
    if (fs.existsSync(LOCAL_FIREBASE_FILE)) {
      return JSON.parse(fs.readFileSync(LOCAL_FIREBASE_FILE, 'utf8'));
    }
  } catch (e) {
    console.error('Error loading local Firebase data:', e);
  }
  const init = getInitialData();
  saveLocalData(init);
  return init;
}

function saveLocalData(data) {
  try {
    const dir = path.dirname(LOCAL_FIREBASE_FILE);
    if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
    fs.writeFileSync(LOCAL_FIREBASE_FILE, JSON.stringify(data, null, 2), 'utf8');
  } catch (e) {
    console.error('Error saving local Firebase data:', e);
  }
}

// Ensure database file exists
loadLocalData();

// Database Service API
const FirebaseDB = {
  isLive: () => isLiveFirebase,

  // --- Seller Accounts ---
  async getAccounts() {
    if (isLiveFirebase) {
      const snap = await firestoreDb.collection('seller_accounts').orderBy('created_at', 'desc').get();
      return snap.docs.map(doc => ({ id: doc.id, ...doc.data() }));
    }
    const data = loadLocalData();
    return [...data.seller_accounts].sort((a, b) => new Date(b.created_at) - new Date(a.created_at));
  },

  async getAccountById(id) {
    if (isLiveFirebase) {
      const doc = await firestoreDb.collection('seller_accounts').doc(id).get();
      return doc.exists ? { id: doc.id, ...doc.data() } : null;
    }
    const data = loadLocalData();
    return data.seller_accounts.find(a => a.id === id) || null;
  },

  async getAccountByEmail(email) {
    const cleanEmail = email.toLowerCase().trim();
    if (isLiveFirebase) {
      const snap = await firestoreDb.collection('seller_accounts').where('email', '==', cleanEmail).limit(1).get();
      if (!snap.empty) {
        const doc = snap.docs[0];
        return { id: doc.id, ...doc.data() };
      }
      return null;
    }
    const data = loadLocalData();
    return data.seller_accounts.find(a => a.email.toLowerCase().trim() === cleanEmail) || null;
  },

  async saveAccount(account) {
    if (isLiveFirebase) {
      await firestoreDb.collection('seller_accounts').doc(account.id).set(account, { merge: true });
      return account;
    }
    const data = loadLocalData();
    const idx = data.seller_accounts.findIndex(a => a.id === account.id);
    if (idx >= 0) {
      data.seller_accounts[idx] = { ...data.seller_accounts[idx], ...account, updated_at: new Date().toISOString() };
    } else {
      data.seller_accounts.unshift(account);
    }
    saveLocalData(data);
    return account;
  },

  async toggleAccountStatus(id) {
    const account = await this.getAccountById(id);
    if (!account) return null;
    account.status = account.status === 'Active' ? 'Inactive' : 'Active';
    account.updated_at = new Date().toISOString();
    await this.saveAccount(account);
    return account;
  },

  async archiveAccount(id) {
    const account = await this.getAccountById(id);
    if (!account) return null;
    account.status = 'Archived';
    account.updated_at = new Date().toISOString();
    await this.saveAccount(account);
    return account;
  },

  async unarchiveAccount(id) {
    const account = await this.getAccountById(id);
    if (!account) return null;
    account.status = 'Active';
    account.updated_at = new Date().toISOString();
    await this.saveAccount(account);
    return account;
  },

  async deleteAccount(id) {
    if (isLiveFirebase) {
      await firestoreDb.collection('seller_accounts').doc(id).delete();
      return true;
    }
    const data = loadLocalData();
    const idx = data.seller_accounts.findIndex(a => a.id === id);
    if (idx >= 0) {
      data.seller_accounts.splice(idx, 1);
      saveLocalData(data);
      return true;
    }
    return false;
  },

  async deduplicateAccounts() {
    if (isLiveFirebase) return [];
    const data = loadLocalData();
    if (!data.seller_accounts || !data.seller_accounts.length) return [];
    
    const uniqueMap = new Map();
    for (const acc of data.seller_accounts) {
      const key = (acc.store_name || '').toLowerCase().trim();
      if (!key) continue;
      if (!uniqueMap.has(key)) {
        uniqueMap.set(key, acc);
      } else {
        const existing = uniqueMap.get(key);
        if (existing.status !== 'Active' && acc.status === 'Active') {
          uniqueMap.set(key, acc);
        } else if (existing.status === acc.status && new Date(acc.created_at || 0) > new Date(existing.created_at || 0)) {
          uniqueMap.set(key, acc);
        }
      }
    }

    data.seller_accounts = Array.from(uniqueMap.values());
    saveLocalData(data);

    // Sync admin_data.json
    const adminDataPath = path.join(__dirname, 'data', 'admin_data.json');
    if (fs.existsSync(adminDataPath)) {
      try {
        const adminData = JSON.parse(fs.readFileSync(adminDataPath, 'utf8'));
        adminData.accounts = data.seller_accounts.map(a => ({
          id: a.id,
          storeName: a.store_name,
          applicantName: a.applicant_name,
          email: a.email,
          contact: a.contact,
          status: a.status,
          registeredAt: a.created_at || a.registeredAt
        }));
        adminData.stats.sellerAccountsTotal = adminData.accounts.length;
        adminData.stats.activeAccounts = adminData.accounts.filter(a => a.status === 'Active').length;
        fs.writeFileSync(adminDataPath, JSON.stringify(adminData, null, 2), 'utf8');
      } catch (e) {
        console.error('Error syncing admin_data.json:', e);
      }
    }
    return data.seller_accounts;
  },

  // --- Seller Requests ---
  async getRequests() {
    if (isLiveFirebase) {
      const snap = await firestoreDb.collection('seller_requests').orderBy('submitted_at', 'desc').get();
      return snap.docs.map(doc => ({ id: doc.id, ...doc.data() }));
    }
    const data = loadLocalData();
    return [...data.seller_requests].sort((a, b) => new Date(b.submitted_at) - new Date(a.submitted_at));
  },

  async getRequestById(id) {
    if (isLiveFirebase) {
      const doc = await firestoreDb.collection('seller_requests').doc(id).get();
      return doc.exists ? { id: doc.id, ...doc.data() } : null;
    }
    const data = loadLocalData();
    return data.seller_requests.find(r => r.id === id) || null;
  },

  async getRequestByToken(token) {
    if (isLiveFirebase) {
      const snap = await firestoreDb.collection('seller_requests').where('questionnaire_token', '==', token).limit(1).get();
      if (!snap.empty) {
        const doc = snap.docs[0];
        return { id: doc.id, ...doc.data() };
      }
      return null;
    }
    const data = loadLocalData();
    return data.seller_requests.find(r => r.questionnaire_token === token) || null;
  },

  async saveRequest(request) {
    if (isLiveFirebase) {
      await firestoreDb.collection('seller_requests').doc(request.id).set(request, { merge: true });
      return request;
    }
    const data = loadLocalData();
    const idx = data.seller_requests.findIndex(r => r.id === request.id);
    if (idx >= 0) {
      data.seller_requests[idx] = { ...data.seller_requests[idx], ...request };
    } else {
      data.seller_requests.unshift(request);
    }
    saveLocalData(data);
    return request;
  },

  async archiveRequest(id) {
    const request = await this.getRequestById(id);
    if (!request) return null;
    request.previous_status = request.status;
    request.status = 'Archived';
    await this.saveRequest(request);
    return request;
  },

  async unarchiveRequest(id) {
    const request = await this.getRequestById(id);
    if (!request) return null;
    request.status = request.previous_status || 'Pending';
    await this.saveRequest(request);
    return request;
  },

  async deleteRequest(id) {
    if (isLiveFirebase) {
      await firestoreDb.collection('seller_requests').doc(id).delete();
      return true;
    }
    const data = loadLocalData();
    const idx = data.seller_requests.findIndex(r => r.id === id);
    if (idx >= 0) {
      data.seller_requests.splice(idx, 1);
      saveLocalData(data);
      return true;
    }
    return false;
  },

  // --- Questionnaires ---
  async getQuestionnaireTemplates() {
    if (isLiveFirebase) {
      const snap = await firestoreDb.collection('questionnaire_templates').orderBy('sort_order', 'asc').get();
      return snap.docs.map(doc => ({ id: doc.id, ...doc.data() }));
    }
    const data = loadLocalData();
    return [...data.questionnaire_templates].sort((a, b) => (a.sort_order || 0) - (b.sort_order || 0));
  },

  async saveQuestionnaireTemplate(q) {
    if (isLiveFirebase) {
      await firestoreDb.collection('questionnaire_templates').doc(q.id).set(q, { merge: true });
      return q;
    }
    const data = loadLocalData();
    const idx = data.questionnaire_templates.findIndex(item => item.id === q.id);
    if (idx >= 0) {
      data.questionnaire_templates[idx] = { ...data.questionnaire_templates[idx], ...q };
    } else {
      data.questionnaire_templates.push(q);
    }
    saveLocalData(data);
    return q;
  },

  async deleteQuestionnaireTemplate(id) {
    if (isLiveFirebase) {
      await firestoreDb.collection('questionnaire_templates').doc(id).delete();
      return true;
    }
    const data = loadLocalData();
    data.questionnaire_templates = data.questionnaire_templates.filter(item => item.id !== id);
    saveLocalData(data);
    return true;
  },

  // --- Questionnaire Answers ---
  async saveAnswers(requestId, answersMap) {
    const timestamp = new Date().toISOString();
    const entries = [];
    for (const [question, answer] of Object.entries(answersMap || {})) {
      const item = {
        id: `ans-${Date.now()}-${Math.random().toString(36).substr(2, 6)}`,
        request_id: requestId,
        question: question,
        answer: answer,
        answered_at: timestamp
      };
      entries.push(item);

      if (isLiveFirebase) {
        await firestoreDb.collection('questionnaire_answers').doc(item.id).set(item);
      }
    }

    if (!isLiveFirebase) {
      const data = loadLocalData();
      data.questionnaire_answers.push(...entries);
      saveLocalData(data);
    }
    return entries;
  },

  async getAnswersForRequest(requestId) {
    if (isLiveFirebase) {
      const snap = await firestoreDb.collection('questionnaire_answers').where('request_id', '==', requestId).get();
      return snap.docs.map(doc => ({ id: doc.id, ...doc.data() }));
    }
    const data = loadLocalData();
    return data.questionnaire_answers.filter(a => a.request_id === requestId);
  },

  // --- Orders & Sales Statistics ---
  async getOrders() {
    if (isLiveFirebase) {
      const snap = await firestoreDb.collection('orders').where('status', '==', 'Completed').get();
      return snap.docs.map(doc => ({ id: doc.id, ...doc.data() }));
    }
    const data = loadLocalData();
    return data.orders || [];
  },

  async saveOrder(order) {
    if (isLiveFirebase) {
      await firestoreDb.collection('orders').doc(order.id).set(order);
      return order;
    }
    const data = loadLocalData();
    data.orders.push(order);
    saveLocalData(data);
    return order;
  },

  // --- Seller PIN Verification ---
  async saveSellerPin(email, pin, expiresAt) {
    const cleanEmail = email.toLowerCase().trim();
    const pinRecord = {
      email: cleanEmail,
      pin: pin,
      generated_at: new Date().toISOString(),
      expires_at: expiresAt
    };
    if (isLiveFirebase) {
      await firestoreDb.collection('seller_pins').doc(cleanEmail).set(pinRecord);
      return pinRecord;
    }
    const data = loadLocalData();
    const idx = data.seller_pins.findIndex(p => p.email === cleanEmail);
    if (idx >= 0) {
      data.seller_pins[idx] = pinRecord;
    } else {
      data.seller_pins.push(pinRecord);
    }
    saveLocalData(data);
    return pinRecord;
  },

  async getSellerPin(email) {
    const cleanEmail = email.toLowerCase().trim();
    if (isLiveFirebase) {
      const doc = await firestoreDb.collection('seller_pins').doc(cleanEmail).get();
      return doc.exists ? doc.data() : null;
    }
    const data = loadLocalData();
    return data.seller_pins.find(p => p.email === cleanEmail) || null;
  },

  async deleteSellerPin(email) {
    const cleanEmail = email.toLowerCase().trim();
    if (isLiveFirebase) {
      await firestoreDb.collection('seller_pins').doc(cleanEmail).delete();
      return true;
    }
    const data = loadLocalData();
    data.seller_pins = data.seller_pins.filter(p => p.email !== cleanEmail);
    saveLocalData(data);
    return true;
  },

  // --- Aggregated Live Dashboard Data ---
  async getDashboardData() {
    const accounts = await this.getAccounts();
    const requests = await this.getRequests();
    const orders = await this.getOrders();

    const activeCount = accounts.filter(a => a.status === 'Active').length;
    const totalCount = accounts.length;
    const pendingCount = requests.filter(r => r.status === 'Pending' || r.status === 'Questionnaire Sent' || r.status === 'Under Review').length;

    // Calculate dynamic 5-week sales strictly from actual database orders
    const now = new Date();
    const weeks = [];
    for (let w = 4; w >= 0; w--) {
      const end = new Date(now);
      end.setDate(end.getDate() - w * 7);
      const start = new Date(end);
      start.setDate(start.getDate() - 7);

      const weekSold = orders.filter(o => {
        const orderTime = new Date(o.ordered_at);
        return orderTime >= start && orderTime <= end;
      }).length;

      weeks.push({
        name: `Week ${5 - w}`,
        sold: weekSold
      });
    }

    const maxSold = Math.max(...weeks.map(w => w.sold), 1);
    const yMax = Math.max(100, Math.ceil(maxSold / 10) * 10);

    return {
      stats: {
        activeAccounts: activeCount,
        sellerAccountsTotal: totalCount,
        missedRequestsTotal: pendingCount,
        chart: {
          yMax: yMax,
          yMin: 0,
          label: 'Current Sold this Month',
          weeks: weeks
        }
      },
      accounts: accounts.map(a => ({
        id: a.id,
        storeName: a.store_name,
        applicantName: a.applicant_name,
        email: a.email,
        contact: a.contact,
        status: a.status,
        registeredAt: a.created_at
      })),
      requests: requests.map(r => ({
        id: r.id,
        storeName: r.store_name,
        applicantName: r.applicant_name,
        email: r.email,
        contact: r.contact,
        status: r.status,
        questionnaireSubmitted: !!r.questionnaire_submitted,
        submittedAt: r.submitted_at,
        reviewedAt: r.reviewed_at
      }))
    };
  }
};

module.exports = FirebaseDB;
