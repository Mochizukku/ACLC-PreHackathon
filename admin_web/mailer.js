// mailer.js - Email sending service using Nodemailer
const nodemailer = require('nodemailer');
const fs = require('fs');
const path = require('path');
const QRCode = require('qrcode');

function loadEnv() {
  const envPath = path.join(__dirname, '..', '.env');
  if (!fs.existsSync(envPath)) return {};
  const content = fs.readFileSync(envPath, 'utf8');
  const env = {};
  for (const line of content.split('\n')) {
    const trimmed = line.trim();
    if (!trimmed || trimmed.startsWith('#')) continue;
    const idx = trimmed.indexOf('=');
    if (idx > 0) {
      const key = trimmed.substring(0, idx).trim();
      const value = trimmed.substring(idx + 1).trim().replace(/^"(.*)"$/, '$1');
      env[key] = value;
    }
  }
  return env;
}

function getTransporter() {
  const env = loadEnv();
  const user = env.SMTP_SENDER_EMAIL || process.env.SMTP_SENDER_EMAIL || '';
  const pass = (env.SMTP_APP_PASSWORD || process.env.SMTP_APP_PASSWORD || '').replace(/\s/g, '');

  if (!user || !pass || user === 'your_email@gmail.com') {
    console.warn('⚠️  SMTP not configured. Email sending will be simulated in logs.');
    return null;
  }

  const port = parseInt(env.SMTP_PORT || '587');
  const secure = port === 465;

  return nodemailer.createTransport({
    host: env.SMTP_HOST || 'smtp.gmail.com',
    port,
    secure,
    auth: { user, pass },
    connectionTimeout: 15000,
    greetingTimeout: 10000,
    socketTimeout: 15000,
    tls: { rejectUnauthorized: false },
    family: 4  // Force IPv4 — prevents TLS hang when DNS resolves to IPv6
  });
}

const senderName = () => {
  const env = loadEnv();
  return env.SMTP_DISPLAY_NAME || 'QR Query (Q2) Admin';
};

const senderEmail = () => {
  const env = loadEnv();
  return env.SMTP_SENDER_EMAIL || process.env.SMTP_SENDER_EMAIL || 'noreply@q2.local';
};

async function sendMail({ to, subject, html, text, attachments }) {
  const emailRecord = {
    id: 'email-' + Date.now(),
    to,
    subject,
    text: text || '',
    html,
    timestamp: new Date().toISOString()
  };

  try {
    const logPath = path.join(__dirname, 'data', 'sent_emails.json');
    let logs = [];
    if (fs.existsSync(logPath)) {
      try { logs = JSON.parse(fs.readFileSync(logPath, 'utf8')); } catch (_) {}
    }
    logs.unshift(emailRecord);
    if (logs.length > 50) logs = logs.slice(0, 50);
    fs.writeFileSync(logPath, JSON.stringify(logs, null, 2), 'utf8');
  } catch (err) {
    console.error('Error logging sent email:', err.message);
  }

  const transporter = getTransporter();
  if (!transporter) {
    console.log(`📧 [EMAIL LOGGED] To: ${to} | Subject: ${subject}`);
    return { simulated: true, record: emailRecord };
  }
  try {
    const mailOptions = {
      from: `"${senderName()}" <${senderEmail()}>`,
      to,
      subject,
      text: text || '',
      html,
    };
    if (attachments && attachments.length) {
      mailOptions.attachments = attachments;
    }
    const info = await transporter.sendMail(mailOptions);
    console.log(`📧 Email delivered via SMTP to ${to}: ${info.messageId}`);
    return { ...info, record: emailRecord };
  } catch (err) {
    console.error('Email send error:', err.message);
    throw err;
  }
}

// Send questionnaire link to seller applicant
async function sendQuestionnaireEmail({ to, applicantName, storeName, token, serverBaseUrl }) {
  const link = `${serverBaseUrl}/questionnaire?token=${token}`;
  await sendMail({
    to,
    subject: 'QR Query (Q2) — Complete Your Store Account Application',
    text: `Hi ${applicantName},\n\nThank you for requesting a seller account for "${storeName}" on QR Query (Q2).\n\nPlease complete the questionnaire to proceed:\n${link}\n\nThis link is valid for 7 days.\n\nQR Query Admin Team`,
    html: `
      <div style="font-family: Arial, sans-serif; max-width: 560px; margin: 0 auto; background: #f9fafb; padding: 32px; border-radius: 12px;">
        <div style="text-align: center; margin-bottom: 28px;">
          <h2 style="margin: 0; color: #111827; font-size: 22px; font-weight: 800;">QR Query <span style="color:#2563eb;">(Q2)</span></h2>
          <p style="margin: 4px 0 0; font-size: 12px; color: #9ca3af; letter-spacing: 1px; text-transform: uppercase;">Admin Portal</p>
        </div>
        <div style="background: #fff; border-radius: 10px; padding: 28px; border: 1px solid #e5e7eb;">
          <p style="color: #374151; font-size: 15px; margin: 0 0 12px;">Hi <strong>${applicantName}</strong>,</p>
          <p style="color: #374151; font-size: 14px; line-height: 1.6; margin: 0 0 20px;">
            Thank you for requesting a seller account for <strong>"${storeName}"</strong> on QR Query (Q2).
            The admin team needs to learn a little more about your store before approving your account.
          </p>
          <p style="color: #374151; font-size: 14px; margin: 0 0 24px;">Please click the button below to complete a short questionnaire:</p>
          <div style="text-align: center; margin: 24px 0;">
            <a href="${link}" style="display: inline-block; background: #111827; color: #fff; text-decoration: none; padding: 14px 32px; border-radius: 8px; font-size: 15px; font-weight: 700; letter-spacing: 0.5px;">
              Complete Questionnaire →
            </a>
          </div>
          <p style="font-size: 12px; color: #9ca3af; margin: 16px 0 0;">This link is valid for 7 days. If you did not make this request, please ignore this email.</p>
        </div>
        <p style="text-align: center; font-size: 11px; color: #9ca3af; margin-top: 20px;">QR Query (Q2) Admin System</p>
      </div>
    `,
  });
}

// Notify seller their account was approved & attach QR Code image
async function sendApprovalEmail({ to, applicantName, storeName, storeId }) {
  let attachments = [];
  let qrHtmlSnippet = '';

  try {
    const payload = JSON.stringify({
      type: 'q2_store',
      storeId: storeId || 'acc-' + Date.now(),
      storeName: storeName,
      email: to
    });
    const qrBuffer = await QRCode.toBuffer(payload, {
      color: { dark: '#111827', light: '#FFFFFF' },
      width: 512,
      margin: 2
    });

    const safeFile = storeName.toLowerCase().replace(/[^a-z0-9]/g, '_');
    attachments.push({
      filename: `qrcode_${safeFile}.png`,
      content: qrBuffer,
      cid: 'store_qrcode'
    });

    qrHtmlSnippet = `
      <div style="text-align: center; margin: 24px 0; padding: 20px; background: #f9fafb; border: 2px dashed #e5e7eb; border-radius: 12px;">
        <p style="margin: 0 0 12px; font-weight: 700; color: #111827; font-size: 15px;">📷 Your Store QR Code</p>
        <img src="cid:store_qrcode" alt="${storeName} QR Code" style="width: 220px; height: 220px; border-radius: 8px; display: block; margin: 0 auto; border: 1px solid #e5e7eb;" />
        <p style="margin: 12px 0 0; font-size: 12px; color: #6b7280;">Display or print this QR code at your store counter for customers to scan!</p>
      </div>
    `;
  } catch (err) {
    console.error('Error generating inline QR attachment for approval email:', err.message);
  }

  await sendMail({
    to,
    subject: 'QR Query (Q2) — Your Store Account Has Been Approved! 🎉',
    text: `Hi ${applicantName},\n\nGreat news! Your seller account for "${storeName}" on QR Query (Q2) has been approved.\n\nYou can now log in to the Seller Dashboard using your email: ${to}\nA 6-digit PIN will be sent to you upon login.\n\nWelcome aboard!\n\nQR Query Admin Team`,
    attachments,
    html: `
      <div style="font-family: Arial, sans-serif; max-width: 560px; margin: 0 auto; background: #f9fafb; padding: 32px; border-radius: 12px;">
        <div style="text-align: center; margin-bottom: 28px;">
          <h2 style="margin: 0; color: #111827; font-size: 22px; font-weight: 800;">QR Query <span style="color:#2563eb;">(Q2)</span></h2>
          <p style="margin: 4px 0 0; font-size: 12px; color: #9ca3af; letter-spacing: 1px; text-transform: uppercase;">Admin Portal</p>
        </div>
        <div style="background: #fff; border-radius: 10px; padding: 28px; border: 1px solid #e5e7eb;">
          <div style="text-align: center; margin-bottom: 20px;">
            <span style="font-size: 48px;">🎉</span>
          </div>
          <p style="color: #374151; font-size: 15px; margin: 0 0 12px;">Hi <strong>${applicantName}</strong>,</p>
          <p style="color: #374151; font-size: 14px; line-height: 1.6; margin: 0 0 20px;">
            Great news! Your seller account for <strong>"${storeName}"</strong> on QR Query (Q2) has been <span style="color:#10b981; font-weight:700;">approved</span>.
          </p>
          ${qrHtmlSnippet}
          <div style="background: #f0fdf4; border: 1px solid #bbf7d0; border-radius: 8px; padding: 16px; margin: 16px 0;">
            <p style="margin: 0; font-size: 14px; color: #065f46;"><strong>Your login email:</strong> ${to}</p>
            <p style="margin: 8px 0 0; font-size: 13px; color: #374151;">A 6-digit PIN will be sent to this inbox each time you sign in to the Seller Dashboard.</p>
          </div>
          <p style="font-size: 13px; color: #6b7280; margin: 16px 0 0;">Welcome to QR Query (Q2)! Open the app and choose <strong>Seller</strong> → <strong>Access your Store</strong> to get started.</p>
        </div>
        <p style="text-align: center; font-size: 11px; color: #9ca3af; margin-top: 20px;">QR Query (Q2) Admin System</p>
      </div>
    `,
  });
}

// Send OTP PIN verification email to seller
async function sendOtpEmail({ to, pin }) {
  await sendMail({
    to,
    subject: 'Your QR Query (Q2) Seller Verification PIN',
    text: `Your QR Query (Q2) seller login PIN is: ${pin}\n\nDo not share this PIN with anyone.\n\nQR Query Security Team`,
    html: `
      <div style="font-family: Arial, sans-serif; max-width: 500px; margin: 0 auto; background: #f9fafb; padding: 32px; border-radius: 12px;">
        <div style="text-align: center; margin-bottom: 24px;">
          <h2 style="margin: 0; color: #111827; font-size: 22px; font-weight: 800;">QR Query <span style="color:#2563eb;">(Q2)</span></h2>
          <p style="margin: 4px 0 0; font-size: 12px; color: #9ca3af; letter-spacing: 1px; text-transform: uppercase;">Seller Authentication</p>
        </div>
        <div style="background: #fff; border-radius: 10px; padding: 28px; border: 1px solid #e5e7eb; text-align: center;">
          <p style="color: #374151; font-size: 14px; margin-bottom: 16px;">Use the following 6-digit PIN to sign in to your Seller Account:</p>
          <div style="background: #f3f4f6; border-radius: 8px; padding: 18px; margin: 16px 0; letter-spacing: 6px; font-size: 32px; font-weight: 800; color: #111827; font-family: monospace;">
            ${pin}
          </div>
          <p style="font-size: 12px; color: #9ca3af; margin-top: 16px;">This PIN is valid for 10 minutes. If you did not request this, please ignore this email.</p>
        </div>
      </div>
    `,
  });
}

// Notify seller their account was rejected
async function sendRejectionEmail({ to, applicantName, storeName, reason }) {
  await sendMail({
    to,
    subject: 'QR Query (Q2) — Update on Your Store Account Application',
    text: `Hi ${applicantName},\n\nThank you for your interest in QR Query (Q2).\n\nAfter reviewing your application for "${storeName}", we are unable to approve your account at this time.\n${reason ? 'Reason: ' + reason : ''}\n\nYou may re-apply in the future.\n\nQR Query Admin Team`,
    html: `
      <div style="font-family: Arial, sans-serif; max-width: 560px; margin: 0 auto; background: #f9fafb; padding: 32px; border-radius: 12px;">
        <div style="text-align: center; margin-bottom: 28px;">
          <h2 style="margin: 0; color: #111827; font-size: 22px; font-weight: 800;">QR Query <span style="color:#2563eb;">(Q2)</span></h2>
        </div>
        <div style="background: #fff; border-radius: 10px; padding: 28px; border: 1px solid #e5e7eb;">
          <p style="color: #374151; font-size: 15px; margin: 0 0 12px;">Hi <strong>${applicantName}</strong>,</p>
          <p style="color: #374151; font-size: 14px; line-height: 1.6; margin: 0 0 16px;">
            Thank you for your interest in QR Query (Q2). After careful review of your application for <strong>"${storeName}"</strong>, we are unable to approve your account at this time.
          </p>
          ${reason ? `<div style="background:#fff7f7;border:1px solid #fecaca;border-radius:8px;padding:14px;margin:12px 0;"><p style="margin:0;font-size:13px;color:#7f1d1d;"><strong>Reason:</strong> ${reason}</p></div>` : ''}
          <p style="font-size: 13px; color: #6b7280; margin: 16px 0 0;">You are welcome to re-apply in the future. Thank you for understanding.</p>
        </div>
        <p style="text-align: center; font-size: 11px; color: #9ca3af; margin-top: 20px;">QR Query (Q2) Admin System</p>
      </div>
    `,
  });
}

// Notify seller immediately when their account request is received
async function sendRequestReceivedEmail({ to, applicantName, storeName }) {
  await sendMail({
    to,
    subject: 'QR Query (Q2) — We Received Your Store Account Request 📬',
    text: `Hi ${applicantName},\n\nThank you for requesting a seller account for "${storeName}" on QR Query (Q2).\n\nWe have received your application and our admin team is reviewing it. You will receive an update via email once your application has been reviewed.\n\nThank you for choosing QR Query!\n\nQR Query Admin Team`,
    html: `
      <div style="font-family: Arial, sans-serif; max-width: 560px; margin: 0 auto; background: #f9fafb; padding: 32px; border-radius: 12px;">
        <div style="text-align: center; margin-bottom: 28px;">
          <h2 style="margin: 0; color: #111827; font-size: 22px; font-weight: 800;">QR Query <span style="color:#2563eb;">(Q2)</span></h2>
          <p style="margin: 4px 0 0; font-size: 12px; color: #9ca3af; letter-spacing: 1px; text-transform: uppercase;">Seller Application</p>
        </div>
        <div style="background: #fff; border-radius: 10px; padding: 28px; border: 1px solid #e5e7eb;">
          <p style="color: #374151; font-size: 15px; margin: 0 0 12px;">Hi <strong>${applicantName}</strong>,</p>
          <p style="color: #374151; font-size: 14px; line-height: 1.6; margin: 0 0 16px;">
            Thank you for applying for a seller account for <strong>"${storeName}"</strong> on QR Query (Q2)!
          </p>
          <div style="background: #eff6ff; border: 1px solid #bfdbfe; border-radius: 8px; padding: 16px; margin: 16px 0;">
            <p style="margin: 0; font-size: 14px; color: #1e40af;"><strong>Application Status:</strong> Under Admin Review ⏳</p>
            <p style="margin: 6px 0 0; font-size: 13px; color: #374151;">Our team is reviewing your store details. You will receive an email notification as soon as your account is approved or updated.</p>
          </div>
          <p style="font-size: 13px; color: #6b7280; margin: 16px 0 0;">Thank you for choosing QR Query (Q2)!</p>
        </div>
        <p style="text-align: center; font-size: 11px; color: #9ca3af; margin-top: 20px;">QR Query (Q2) Admin System</p>
      </div>
    `,
  });
}

module.exports = { sendQuestionnaireEmail, sendApprovalEmail, sendRejectionEmail, sendOtpEmail, sendRequestReceivedEmail, sendMail };
