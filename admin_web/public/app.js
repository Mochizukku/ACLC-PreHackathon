// app.js — Admin Dashboard Frontend Logic
let dashData = null;
let rejectTargetId = null;

const fmt = n => new Intl.NumberFormat().format(n ?? '—');

async function fetchData() {
  try {
    const r = await fetch('/api/data');
    if (!r.ok) throw new Error(r.statusText);
    dashData = await r.json();
    updateCards();
    document.getElementById('sync-label').textContent = 'Live · Firebase Database';
  } catch (e) {
    document.getElementById('sync-label').textContent = 'Offline — server unreachable';
  }
}

function updateCards() {
  if (!dashData) return;
  const s = dashData.stats;

  document.getElementById('val-active').textContent = fmt(s.activeAccounts);
  document.getElementById('val-total').textContent = fmt(s.sellerAccountsTotal);
  document.getElementById('val-missed').textContent = fmt(s.missedRequestsTotal);

  // Rebuild chart
  const weeks = s.chart?.weeks || [];
  const yMax = s.chart?.yMax || 10;
  document.getElementById('y-max').textContent = yMax;
  document.getElementById('chart-caption').textContent = s.chart?.label || 'Current Sold this Month';

  const plotEl = document.getElementById('bar-plot');
  const xlabelEl = document.getElementById('x-labels');
  plotEl.innerHTML = weeks.map(w => {
    const pct = Math.max(4, Math.min(100, (w.sold / yMax) * 100));
    return `<div class="bar-col" title="${w.name}: ${w.sold} orders"><div class="bar-rect" style="height:${pct}%"></div></div>`;
  }).join('');
  xlabelEl.innerHTML = weeks.map(w => `<span class="x-label">${w.name}</span>`).join('');
}

// ── Modals ──
function openModal(id) { document.getElementById(id).classList.add('open'); }
function closeModal(id) { document.getElementById(id).classList.remove('open'); }

window.addEventListener('click', e => {
  if (e.target.classList.contains('modal-overlay')) e.target.classList.remove('open');
});

function switchTab(showId, btnId) {
  ['tab-pending','tab-all'].forEach(id => document.getElementById(id).style.display = 'none');
  ['req-tab-btn-pending','req-tab-btn-all'].forEach(id => document.getElementById(id).classList.remove('active'));
  document.getElementById(showId).style.display = '';
  document.getElementById(btnId).classList.add('active');
}

// ── Requests Modal ──
function openRequestsModal() {
  renderRequests();
  openModal('modal-requests');
}

function renderRequests() {
  const all = dashData?.requests || [];
  const pending = all.filter(r => r.status === 'Pending' || r.status === 'Questionnaire Sent' || r.status === 'Under Review');
  document.getElementById('tab-pending').innerHTML = pending.length
    ? pending.map(reqCard).join('')
    : `<div style="text-align:center;padding:32px;color:#6b7280;font-size:14px;">No pending requests.</div>`;
  document.getElementById('tab-all').innerHTML = all.length
    ? all.map(reqCard).join('')
    : `<div style="text-align:center;padding:32px;color:#6b7280;font-size:14px;">No requests yet.</div>`;
}

function badgeClass(status) {
  const map = { 'Pending':'badge-pending','Questionnaire Sent':'badge-sent','Under Review':'badge-review','Approved':'badge-approved','Rejected':'badge-rejected' };
  return 'badge ' + (map[status] || 'badge-pending');
}

function reqCard(r) {
  const isPending = r.status === 'Pending';
  const isSent    = r.status === 'Questionnaire Sent';
  const isReview  = r.status === 'Under Review';
  const isPendingOrSent = isPending || isSent;
  const isActionable = isPendingOrSent || isReview;
  const date = new Date(r.submittedAt).toLocaleString();

  return `
    <div class="req-card" id="reqcard-${r.id}">
      <div class="req-card-head">
        <span class="req-store">${r.storeName}</span>
        <span class="${badgeClass(r.status)}">${r.status}</span>
      </div>
      <div class="req-meta">
        <strong>Applicant:</strong> ${r.applicantName} &bull;
        <strong>Email:</strong> ${r.email}<br>
        <strong>Contact:</strong> ${r.contact || 'N/A'} &bull;
        <strong>Submitted:</strong> ${date}
        ${r.questionnaireSubmitted ? ' &bull; <span style="color:#6d28d9;font-weight:600;">✓ Questionnaire submitted</span>' : ''}
      </div>
      <div class="req-actions">
        ${isPending ? `<button class="btn-primary" onclick="sendQuestionnaire('${r.id}','${r.email}')">📧 Send Questionnaire</button>` : ''}
        ${r.questionnaireSubmitted ? `<button class="btn-secondary-sm" onclick="viewAnswers('${r.id}','${r.storeName}')">📋 View Answers</button>` : ''}
        ${isActionable ? `<button class="btn-success" onclick="approveRequest('${r.id}')">✓ Approve</button>` : ''}
        ${isActionable ? `<button class="btn-danger" onclick="openRejectModal('${r.id}')">✕ Reject</button>` : ''}
      </div>
    </div>`;
}

async function sendQuestionnaire(id, email) {
  try {
    const r = await fetch(`/api/requests/${id}/send-questionnaire`, { method: 'POST' });
    const d = await r.json();
    if (d.success) {
      toast(`📧 Questionnaire link sent to ${email}`, 'success');
      await fetchData();
      renderRequests();
    } else {
      toast('Failed: ' + (d.error || 'Unknown error'), 'error');
    }
  } catch { toast('Network error', 'error'); }
}

async function viewAnswers(reqId, storeName) {
  document.getElementById('answers-title').textContent = `Answers — ${storeName}`;
  document.getElementById('answers-body').innerHTML = '<p style="color:#6b7280;font-size:13px;">Loading…</p>';
  openModal('modal-answers');
  try {
    const r = await fetch(`/api/requests/${reqId}/answers`);
    const answers = await r.json();
    if (!answers.length) {
      document.getElementById('answers-body').innerHTML = '<p style="color:#6b7280;font-size:13px;">No answers recorded yet.</p>';
    } else {
      document.getElementById('answers-body').innerHTML = answers.map(a => `
        <div class="answer-block">
          <div class="answer-q">${a.question}</div>
          <div class="answer-a">${a.answer || '<em style="color:#9ca3af;">No answer given</em>'}</div>
        </div>`).join('');
    }
  } catch { document.getElementById('answers-body').innerHTML = '<p style="color:red;">Failed to load answers.</p>'; }
}

async function approveRequest(id) {
  if (!confirm('Approve this seller application? An approval email will be sent.')) return;
  try {
    const r = await fetch(`/api/requests/${id}/approve`, { method: 'POST' });
    const d = await r.json();
    if (d.success) {
      toast('✅ Application approved! Store account created & email sent.', 'success');
      await fetchData();
      renderRequests();
    } else {
      toast('Error: ' + (d.error || ''), 'error');
    }
  } catch { toast('Network error', 'error'); }
}

function openRejectModal(id) {
  rejectTargetId = id;
  document.getElementById('reject-reason').value = '';
  openModal('modal-reject');
}

async function confirmReject() {
  if (!rejectTargetId) return;
  const reason = document.getElementById('reject-reason').value.trim();
  try {
    const r = await fetch(`/api/requests/${rejectTargetId}/reject`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ reason })
    });
    const d = await r.json();
    if (d.success) {
      toast('Application rejected. Rejection email sent.', 'success');
      closeModal('modal-reject');
      rejectTargetId = null;
      await fetchData();
      renderRequests();
    } else {
      toast('Error: ' + (d.error || ''), 'error');
    }
  } catch { toast('Network error', 'error'); }
}

// ── Accounts Modal ──
function openAccountsModal() {
  renderAccounts();
  openModal('modal-accounts');
}

function renderAccounts() {
  const accounts = dashData?.accounts || [];
  const tbody = document.getElementById('accounts-tbody');
  if (!accounts.length) {
    tbody.innerHTML = `<tr><td colspan="5" style="text-align:center;padding:24px;color:#6b7280;">No accounts in database.</td></tr>`;
    return;
  }
  tbody.innerHTML = accounts.map(a => {
    const isActive = a.status === 'Active';
    return `<tr>
      <td style="font-weight:600;">${a.storeName}</td>
      <td>${a.applicantName}</td>
      <td style="color:#4b5563;">${a.email}</td>
      <td class="${isActive ? 'status-active' : 'status-inactive'}">${a.status}</td>
      <td>
        <button class="${isActive ? 'btn-deactivate' : 'btn-activate'}" onclick="toggleAccount('${a.id}')">
          ${isActive ? 'Deactivate' : 'Activate'}
        </button>
      </td>
    </tr>`;
  }).join('');
}

async function toggleAccount(id) {
  try {
    const r = await fetch(`/api/accounts/${id}/toggle`, { method: 'POST' });
    const d = await r.json();
    if (d.success) {
      toast(`Account status → ${d.account.status}`, 'success');
      await fetchData();
      renderAccounts();
    }
  } catch { toast('Network error', 'error'); }
}

// ── Statistics Modal ──
function openStatsModal() {
  const s = dashData?.stats;
  const weeks = s?.chart?.weeks || [];
  const total = weeks.reduce((acc, w) => acc + w.sold, 0);
  const avg   = weeks.length ? Math.round(total / weeks.length) : 0;
  const peak  = weeks.reduce((a, w) => w.sold > a.sold ? w : a, { name: '—', sold: 0 });

  document.getElementById('stats-modal-body').innerHTML = `
    <div class="stats-grid">
      <div class="stat-box"><div class="stat-box-label">Total Orders (Month)</div><div class="stat-box-val">${fmt(total)}</div></div>
      <div class="stat-box"><div class="stat-box-label">Weekly Average</div><div class="stat-box-val">${fmt(avg)}</div></div>
      <div class="stat-box"><div class="stat-box-label">Peak Week</div><div class="stat-box-val">${peak.name}</div></div>
      <div class="stat-box"><div class="stat-box-label">Active Stores</div><div class="stat-box-val">${fmt(s?.activeAccounts)}</div></div>
    </div>
    <h3 style="font-size:14px;margin-bottom:12px;color:#111;">Weekly Breakdown</h3>
    <table class="acc-table" style="margin-bottom:0;">
      <thead><tr><th>Period</th><th>Orders Sold</th><th>Performance</th></tr></thead>
      <tbody>
        ${weeks.map(w => `
          <tr>
            <td><strong>${w.name}</strong></td>
            <td>${w.sold}</td>
            <td style="color:${w.sold >= (s?.chart?.yMax * 0.5) ? '#059669' : '#6b7280'};font-weight:600;">
              ${w.sold >= (s?.chart?.yMax * 0.5) ? '↑ Above average' : '↓ Normal'}
            </td>
          </tr>`).join('')}
      </tbody>
    </table>`;
  openModal('modal-stats');
}

// ── Questions Manager ──
async function openQuestionsModal() {
  await loadQuestions();
  openModal('modal-questions');
}

async function loadQuestions() {
  const r = await fetch('/api/questionnaire/questions');
  const qs = await r.json();
  document.getElementById('questions-list').innerHTML = qs.map(q => `
    <div class="q-item">
      <span class="q-text">${q.question}</span>
      ${q.is_required ? '<span class="q-required">Required</span>' : ''}
      <button class="q-del" onclick="deleteQuestion('${q.id}')" title="Delete">×</button>
    </div>`).join('') || '<p style="color:#9ca3af;font-size:13px;">No questions yet. Add one below.</p>';
}

async function addQuestion() {
  const input = document.getElementById('new-q-input');
  const q = input.value.trim();
  if (!q) { toast('Please enter a question.', 'error'); return; }
  const isRequired = document.getElementById('new-q-required').checked;
  await fetch('/api/questionnaire/questions', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ question: q, isRequired })
  });
  input.value = '';
  toast('Question added!', 'success');
  await loadQuestions();
}

async function deleteQuestion(id) {
  if (!confirm('Delete this question?')) return;
  await fetch(`/api/questionnaire/questions/${id}`, { method: 'DELETE' });
  toast('Question deleted.', 'success');
  await loadQuestions();
}

// ── Toast ──
function toast(msg, type = 'success') {
  const el = document.getElementById('toast');
  el.textContent = msg;
  el.className = `toast ${type} show`;
  clearTimeout(el._t);
  el._t = setTimeout(() => el.classList.remove('show'), 3800);
}

// ── Simulate Mobile Request ──
async function simulateMobileRequest() {
  const sample = {
    storeName: "Kent's Special Grill & Burger",
    applicantName: "Kent John Llanita",
    email: "kentjohnllanita8978@gmail.com",
    contactNumber: "+63 917 888 9999"
  };
  try {
    const r = await fetch('/api/requests', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(sample)
    });
    const d = await r.json();
    if (d.success) {
      toast(`📱 New mobile request received for "${sample.storeName}"!`, 'success');
      await fetchData();
      openRequestsModal();
    }
  } catch {
    toast('Error sending test request', 'error');
  }
}

// ── Init ──
fetchData();
setInterval(fetchData, 4000);
