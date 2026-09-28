// server.js - Q2 Admin Dashboard Backend (Firebase Database + Nodemailer)
const http = require('http');
const fs = require('fs');
const path = require('path');
const { v4: uuidv4 } = require('uuid');
const QRCode = require('qrcode');
const FirebaseDB = require('./firebase_db');
const { sendQuestionnaireEmail, sendApprovalEmail, sendRejectionEmail, sendOtpEmail, sendRequestReceivedEmail, sendMail } = require('./mailer');

const PORT = process.env.PORT || 3000;
const PUBLIC_DIR = path.join(__dirname, 'public');

function getServerBaseUrl(req) {
  const host = req.headers.host || `localhost:${PORT}`;
  return `http://${host}`;
}

function sendJson(res, statusCode, payload) {
  const body = JSON.stringify(payload);
  res.writeHead(statusCode, {
    'Content-Type': 'application/json; charset=utf-8',
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type',
    'Content-Length': Buffer.byteLength(body),
  });
  res.end(body);
}

function parseBody(req) {
  return new Promise((resolve) => {
    let body = '';
    req.on('data', (c) => { body += c.toString(); });
    req.on('end', () => {
      try { resolve(JSON.parse(body)); } catch { resolve({}); }
    });
  });
}

function normalizeEmail(email) {
  if (!email) return '';
  let clean = email.trim().toLowerCase();
  clean = clean.replace(/@gmail\.c$/i, '@gmail.com');
  clean = clean.replace(/@gmail\.co$/i, '@gmail.com');
  clean = clean.replace(/@gmal\.com$/i, '@gmail.com');
  clean = clean.replace(/@gamil\.com$/i, '@gmail.com');
  clean = clean.replace(/@gmail\.con$/i, '@gmail.com');
  clean = clean.replace(/@gmail\.com\.com$/i, '@gmail.com');
  return clean;
}

const server = http.createServer(async (req, res) => {
  if (req.method === 'OPTIONS') {
    res.writeHead(204, {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type'
    });
    return res.end();
  }

  const parsedUrl = new URL(req.url, `http://${req.headers.host}`);
  const pathname = parsedUrl.pathname;
  const method = req.method;

  try {

    // ─────────────── STATS / DASHBOARD ───────────────
    if (pathname === '/api/data' && method === 'GET') {
      const data = await FirebaseDB.getDashboardData();
      return sendJson(res, 200, data);
    }

    // ─────────────── ACCOUNTS ───────────────
    if (pathname === '/api/accounts' && method === 'GET') {
      const accounts = await FirebaseDB.getAccounts();
      return sendJson(res, 200, accounts.map(a => ({
        id: a.id,
        storeName: a.store_name,
        applicantName: a.applicant_name,
        email: a.email,
        contact: a.contact,
        status: a.status,
        registeredAt: a.created_at
      })));
    }

    const toggleMatch = pathname.match(/^\/api\/accounts\/([^/]+)\/toggle$/);
    if (toggleMatch && method === 'POST') {
      const updated = await FirebaseDB.toggleAccountStatus(toggleMatch[1]);
      if (!updated) return sendJson(res, 404, { error: 'Account not found' });
      return sendJson(res, 200, {
        success: true,
        account: {
          id: updated.id,
          storeName: updated.store_name,
          email: updated.email,
          status: updated.status
        }
      });
    }

    // Archive account
    const archiveMatch = pathname.match(/^\/api\/accounts\/([^/]+)\/archive$/);
    if (archiveMatch && method === 'POST') {
      const updated = await FirebaseDB.archiveAccount(archiveMatch[1]);
      if (!updated) return sendJson(res, 404, { error: 'Account not found' });
      return sendJson(res, 200, {
        success: true,
        account: {
          id: updated.id,
          storeName: updated.store_name,
          email: updated.email,
          status: updated.status
        }
      });
    }

    // Unarchive account
    const unarchiveMatch = pathname.match(/^\/api\/accounts\/([^/]+)\/unarchive$/);
    if (unarchiveMatch && method === 'POST') {
      const updated = await FirebaseDB.unarchiveAccount(unarchiveMatch[1]);
      if (!updated) return sendJson(res, 404, { error: 'Account not found' });
      return sendJson(res, 200, {
        success: true,
        account: {
          id: updated.id,
          storeName: updated.store_name,
          email: updated.email,
          status: updated.status
        }
      });
    }

    // Delete account permanently
    const deleteAccMatch = pathname.match(/^\/api\/accounts\/([^/]+)$/);
    if (deleteAccMatch && method === 'DELETE') {
      const deleted = await FirebaseDB.deleteAccount(deleteAccMatch[1]);
      if (!deleted) return sendJson(res, 404, { error: 'Account not found' });
      return sendJson(res, 200, { success: true, message: 'Account permanently deleted' });
    }

    const checkMatch = pathname.match(/^\/api\/accounts\/check\/(.+)$/);
    if (checkMatch && method === 'GET') {
      const email = decodeURIComponent(checkMatch[1]).toLowerCase();
      const acc = await FirebaseDB.getAccountByEmail(email);
      if (!acc) return sendJson(res, 200, { exists: false, active: false });
      return sendJson(res, 200, {
        exists: true,
        active: acc.status === 'Active',
        account: {
          id: acc.id,
          storeName: acc.store_name,
          email: acc.email,
          status: acc.status
        }
      });
    }

    const qrcodeMatch = pathname.match(/^\/api\/accounts\/([^/]+)\/qrcode$/);
    if (qrcodeMatch && method === 'GET') {
      const accounts = await FirebaseDB.getAccounts();
      const acc = accounts.find(a => a.id === qrcodeMatch[1]);
      if (!acc) return sendJson(res, 404, { error: 'Account not found' });
      const payload = JSON.stringify({
        type: 'q2_store',
        storeId: acc.id,
        storeName: acc.store_name,
        email: acc.email
      });
      try {
        const buf = await QRCode.toBuffer(payload, {
          color: { dark: '#111827', light: '#FFFFFF' },
          width: 512,
          margin: 2
        });
        res.writeHead(200, {
          'Content-Type': 'image/png',
          'Content-Length': buf.length,
          'Cache-Control': 'public, max-age=86400'
        });
        return res.end(buf);
      } catch (err) {
        return sendJson(res, 500, { error: err.message });
      }
    }

    // ─────────────── REQUESTS ───────────────
    if (pathname === '/api/requests' && method === 'GET') {
      const requests = await FirebaseDB.getRequests();
      return sendJson(res, 200, requests.map(r => ({
        id: r.id,
        storeName: r.store_name,
        applicantName: r.applicant_name,
        email: r.email,
        contact: r.contact,
        status: r.status,
        questionnaireSubmitted: !!r.questionnaire_submitted,
        submittedAt: r.submitted_at
      })));
    }

    if (pathname === '/api/requests' && method === 'POST') {
      const body = await parseBody(req);
      const newRequest = {
        id: 'req-' + uuidv4(),
        store_name: body.storeName || '',
        applicant_name: body.applicantName || '',
        email: normalizeEmail(body.email || ''),
        contact: body.contactNumber || body.contact || '',
        status: 'Pending',
        questionnaire_token: null,
        questionnaire_submitted: false,
        submitted_at: new Date().toISOString(),
        reviewed_at: null
      };
      await FirebaseDB.saveRequest(newRequest);

      // Instantly send request receipt confirmation email to applicant
      if (newRequest.email) {
        try {
          await sendRequestReceivedEmail({
            to: newRequest.email,
            applicantName: newRequest.applicant_name,
            storeName: newRequest.store_name
          });
        } catch (err) {
          console.error('Failed to send instant request receipt email:', err.message);
        }
      }

      return sendJson(res, 201, {
        success: true,
        request: {
          id: newRequest.id,
          storeName: newRequest.store_name,
          email: newRequest.email,
          status: newRequest.status
        }
      });
    }

    // Send questionnaire link via email to seller applicant
    const sendQMatch = pathname.match(/^\/api\/requests\/([^/]+)\/send-questionnaire$/);
    if (sendQMatch && method === 'POST') {
      const reqRow = await FirebaseDB.getRequestById(sendQMatch[1]);
      if (!reqRow) return sendJson(res, 404, { error: 'Request not found' });
      
      const token = uuidv4();
      reqRow.questionnaire_token = token;
      reqRow.status = 'Questionnaire Sent';
      await FirebaseDB.saveRequest(reqRow);

      const serverBaseUrl = getServerBaseUrl(req);
      try {
        await sendQuestionnaireEmail({
          to: reqRow.email,
          applicantName: reqRow.applicant_name,
          storeName: reqRow.store_name,
          token,
          serverBaseUrl
        });
        return sendJson(res, 200, { success: true, message: `Questionnaire email sent to ${reqRow.email}` });
      } catch (err) {
        return sendJson(res, 500, { success: false, error: err.message });
      }
    }

    // Get questionnaire answers for a request
    const answersMatch = pathname.match(/^\/api\/requests\/([^/]+)\/answers$/);
    if (answersMatch && method === 'GET') {
      const answers = await FirebaseDB.getAnswersForRequest(answersMatch[1]);
      return sendJson(res, 200, answers);
    }

    // Approve request -> Create active store in Firebase
    const approveMatch = pathname.match(/^\/api\/requests\/([^/]+)\/approve$/);
    if (approveMatch && method === 'POST') {
      const reqRow = await FirebaseDB.getRequestById(approveMatch[1]);
      if (!reqRow) return sendJson(res, 404, { error: 'Request not found' });
      
      reqRow.status = 'Approved';
      reqRow.reviewed_at = new Date().toISOString();
      await FirebaseDB.saveRequest(reqRow);

      // Check if account with same store_name or email already exists to prevent duplicate accounts
      const allAccs = await FirebaseDB.getAccounts();
      let accountToSave = allAccs.find(a => 
        (a.store_name && a.store_name.toLowerCase().trim() === (reqRow.store_name || '').toLowerCase().trim()) ||
        (a.email && a.email.toLowerCase().trim() === (reqRow.email || '').toLowerCase().trim())
      );

      let accId;
      if (accountToSave) {
        accId = accountToSave.id;
        accountToSave.status = 'Active';
        accountToSave.applicant_name = reqRow.applicant_name || accountToSave.applicant_name;
        accountToSave.contact = reqRow.contact || accountToSave.contact;
        accountToSave.updated_at = new Date().toISOString();
      } else {
        accId = 'acc-' + uuidv4();
        accountToSave = {
          id: accId,
          store_name: reqRow.store_name,
          applicant_name: reqRow.applicant_name,
          email: reqRow.email,
          contact: reqRow.contact,
          status: 'Active',
          created_at: new Date().toISOString(),
          updated_at: new Date().toISOString()
        };
      }
      await FirebaseDB.saveAccount(accountToSave);

      let emailStatus = 'sent';
      const recipientEmail = normalizeEmail(reqRow.email);
      try {
        await sendApprovalEmail({
          to: recipientEmail,
          applicantName: reqRow.applicant_name,
          storeName: reqRow.store_name,
          storeId: accId
        });
      } catch (err) {
        emailStatus = 'failed: ' + err.message;
      }

      return sendJson(res, 200, {
        success: true,
        emailStatus,
        account: {
          id: accountToSave.id,
          storeName: accountToSave.store_name,
          email: accountToSave.email,
          status: accountToSave.status
        }
      });
    }

    // ─────────────── AUTH OTP ───────────────
    if (pathname === '/api/auth/send-otp' && method === 'POST') {
      const body = await parseBody(req);
      const { email, pin } = body;
      if (!email || !pin) return sendJson(res, 400, { error: 'email and pin are required' });

      try {
        await sendOtpEmail({ to: email, pin });
        return sendJson(res, 200, { success: true, message: `OTP PIN sent to ${email}` });
      } catch (err) {
        return sendJson(res, 500, { success: false, error: err.message });
      }
    }

    // Reject request
    const rejectMatch = pathname.match(/^\/api\/requests\/([^/]+)\/reject$/);
    if (rejectMatch && method === 'POST') {
      const body = await parseBody(req);
      const reqRow = await FirebaseDB.getRequestById(rejectMatch[1]);
      if (!reqRow) return sendJson(res, 404, { error: 'Request not found' });

      reqRow.status = 'Rejected';
      reqRow.reviewed_at = new Date().toISOString();
      await FirebaseDB.saveRequest(reqRow);

      let emailStatus = 'sent';
      try {
        await sendRejectionEmail({
          to: reqRow.email,
          applicantName: reqRow.applicant_name,
          storeName: reqRow.store_name,
          reason: body.reason || ''
        });
      } catch (err) {
        emailStatus = 'failed: ' + err.message;
      }
      return sendJson(res, 200, { success: true, emailStatus });
    }

    // Archive request
    const archiveReqMatch = pathname.match(/^\/api\/requests\/([^/]+)\/archive$/);
    if (archiveReqMatch && method === 'POST') {
      const updated = await FirebaseDB.archiveRequest(archiveReqMatch[1]);
      if (!updated) return sendJson(res, 404, { error: 'Request not found' });
      return sendJson(res, 200, { success: true, request: updated });
    }

    // Unarchive request
    const unarchiveReqMatch = pathname.match(/^\/api\/requests\/([^/]+)\/unarchive$/);
    if (unarchiveReqMatch && method === 'POST') {
      const updated = await FirebaseDB.unarchiveRequest(unarchiveReqMatch[1]);
      if (!updated) return sendJson(res, 404, { error: 'Request not found' });
      return sendJson(res, 200, { success: true, request: updated });
    }

    // Delete request
    const deleteReqMatch = pathname.match(/^\/api\/requests\/([^/]+)$/);
    if (deleteReqMatch && method === 'DELETE') {
      const deleted = await FirebaseDB.deleteRequest(deleteReqMatch[1]);
      if (!deleted) return sendJson(res, 404, { error: 'Request not found' });
      return sendJson(res, 200, { success: true, message: 'Request deleted' });
    }

    // ─────────────── QUESTIONNAIRE TEMPLATES ───────────────
    if (pathname === '/api/questionnaire/questions' && method === 'GET') {
      const rows = await FirebaseDB.getQuestionnaireTemplates();
      return sendJson(res, 200, rows);
    }

    // Add / update questionnaire question
    if (pathname === '/api/questionnaire/questions' && method === 'POST') {
      const body = await parseBody(req);
      const q = {
        id: body.id || ('q-' + uuidv4()),
        question: body.question,
        is_required: body.isRequired ? 1 : 0,
        sort_order: body.sortOrder || Date.now()
      };
      await FirebaseDB.saveQuestionnaireTemplate(q);
      const updated = await FirebaseDB.getQuestionnaireTemplates();
      return sendJson(res, 200, { success: true, questions: updated });
    }

    // Delete questionnaire question
    const delQMatch = pathname.match(/^\/api\/questionnaire\/questions\/([^/]+)$/);
    if (delQMatch && method === 'DELETE') {
      await FirebaseDB.deleteQuestionnaireTemplate(delQMatch[1]);
      return sendJson(res, 200, { success: true });
    }

    // Verify token and get questionnaire form
    if (pathname === '/api/questionnaire/verify' && method === 'GET') {
      const token = parsedUrl.searchParams.get('token');
      if (!token) return sendJson(res, 400, { error: 'Token required' });

      const reqRow = await FirebaseDB.getRequestByToken(token);
      if (!reqRow) return sendJson(res, 404, { error: 'Invalid or expired questionnaire link' });
      if (reqRow.questionnaire_submitted) {
        return sendJson(res, 200, { alreadySubmitted: true, storeName: reqRow.store_name });
      }

      const questions = await FirebaseDB.getQuestionnaireTemplates();
      return sendJson(res, 200, {
        requestId: reqRow.id,
        storeName: reqRow.store_name,
        applicantName: reqRow.applicant_name,
        questions,
        alreadySubmitted: false
      });
    }

    // Submit questionnaire answers
    if (pathname === '/api/questionnaire/submit' && method === 'POST') {
      const body = await parseBody(req);
      const reqRow = await FirebaseDB.getRequestByToken(body.token);
      if (!reqRow) return sendJson(res, 404, { error: 'Invalid token' });
      if (reqRow.questionnaire_submitted) return sendJson(res, 400, { error: 'Already submitted' });

      await FirebaseDB.saveAnswers(reqRow.id, body.answers);
      reqRow.questionnaire_submitted = true;
      reqRow.status = 'Under Review';
      await FirebaseDB.saveRequest(reqRow);

      return sendJson(res, 200, {
        success: true,
        message: 'Your answers have been submitted. The admin will review and notify you via email.'
      });
    }

    // ─────────────── SELLER PIN AUTH ───────────────
    if (pathname === '/api/seller/send-pin' && method === 'POST') {
      const body = await parseBody(req);
      const email = (body.email || '').toLowerCase().trim();
      const acc = await FirebaseDB.getAccountByEmail(email);

      if (!acc || acc.status !== 'Active') {
        return sendJson(res, 403, {
          success: false,
          error: 'Account not found or inactive. Please contact the administrator.'
        });
      }

      const pin = String(Math.floor(100000 + Math.random() * 900000));
      const expires = new Date(Date.now() + 10 * 60000).toISOString();
      await FirebaseDB.saveSellerPin(email, pin, expires);

      try {
        await sendMail({
          to: email,
          subject: 'Your QR Query Seller Login PIN',
          html: `
            <div style="font-family:Arial,sans-serif;max-width:480px;margin:0 auto;padding:24px;border:1px solid #e0e0e0;border-radius:8px;">
              <h2 style="color:#111827;">QR Query (Q2)</h2>
              <p style="color:#374151;font-size:14px;">Your seller login PIN for <strong>${acc.store_name}</strong>:</p>
              <div style="background:#f3f4f6;border-radius:8px;padding:20px;text-align:center;margin:20px 0;">
                <span style="font-size:36px;font-weight:800;letter-spacing:10px;color:#2563eb;font-family:monospace;">${pin}</span>
              </div>
              <p style="color:#6b7280;font-size:12px;">Expires in 10 minutes. Do not share this PIN.</p>
            </div>
          `
        });
      } catch (err) {
        console.error('PIN email error:', err.message);
      }
      return sendJson(res, 200, { success: true, message: `PIN sent to ${email}`, devPin: pin });
    }

    if (pathname === '/api/seller/verify-pin' && method === 'POST') {
      const body = await parseBody(req);
      const email = (body.email || '').toLowerCase().trim();
      const pinRecord = await FirebaseDB.getSellerPin(email);

      if (!pinRecord) return sendJson(res, 401, { success: false, error: 'No active PIN for this email' });
      if (new Date() > new Date(pinRecord.expires_at)) return sendJson(res, 401, { success: false, error: 'PIN expired' });
      if (pinRecord.pin !== body.pin) return sendJson(res, 401, { success: false, error: 'Invalid PIN' });

      await FirebaseDB.deleteSellerPin(email);
      const acc = await FirebaseDB.getAccountByEmail(email);
      return sendJson(res, 200, {
        success: true,
        account: {
          id: acc?.id,
          storeName: acc?.store_name,
          email: acc?.email,
          status: acc?.status
        }
      });
    }

    // ─────────────── QUESTIONNAIRE HTML PAGE ───────────────
    if (pathname === '/questionnaire') {
      const questionnairePath = path.join(PUBLIC_DIR, 'questionnaire.html');
      if (fs.existsSync(questionnairePath)) {
        res.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8' });
        return fs.createReadStream(questionnairePath).pipe(res);
      }
    }

    // ─────────────── STATIC ASSETS ───────────────
    let filePath = path.join(PUBLIC_DIR, pathname === '/' ? 'index.html' : pathname);
    const extMap = {
      '.html': 'text/html; charset=utf-8',
      '.css': 'text/css',
      '.js': 'text/javascript',
      '.json': 'application/json',
      '.png': 'image/png',
      '.jpg': 'image/jpeg',
      '.svg': 'image/svg+xml'
    };

    if (fs.existsSync(filePath) && fs.statSync(filePath).isFile()) {
      const ext = path.extname(filePath);
      res.writeHead(200, { 'Content-Type': extMap[ext] || 'application/octet-stream' });
      return fs.createReadStream(filePath).pipe(res);
    }

    const fallback = path.join(PUBLIC_DIR, 'index.html');
    if (fs.existsSync(fallback)) {
      res.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8' });
      return fs.createReadStream(fallback).pipe(res);
    }

    res.writeHead(404, { 'Content-Type': 'text/plain' });
    res.end('Not Found');

  } catch (err) {
    console.error('Server error:', err);
    sendJson(res, 500, { error: 'Internal server error', details: err.message });
  }
});

server.listen(PORT, async () => {
  console.log(`\n🔥 Q2 Admin Dashboard running at http://localhost:${PORT}`);
  console.log(`   Database: Firebase Firestore (Collection-based schema)`);
  console.log(`   Seller Questionnaire: http://localhost:${PORT}/questionnaire`);
  try {
    const cleaned = await FirebaseDB.deduplicateAccounts();
    if (cleaned && cleaned.length) {
      console.log(`   🧹 Deduplicated seller accounts: ${cleaned.length} unique accounts remaining.`);
    }
  } catch (e) {
    console.error('Error during startup deduplication:', e.message);
  }
});
