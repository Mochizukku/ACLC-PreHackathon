// mailer.js - Email sending service using Nodemailer
const nodemailer = require('nodemailer');
const fs = require('fs');
const path = require('path');

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

  return nodemailer.createTransport({
    host: env.SMTP_HOST || 'smtp.gmail.com',
    port: 465,
    secure: true,
    auth: { user, pass },
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

async function sendMail({ to, subject, html, text }) {
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
    const info = await transporter.sendMail({
      from: `"${senderName()}" <${senderEmail()}>`,
      to,
      subject,
      text: text || '',
      html,
    });
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

// Notify seller their account was approved
async function sendApprovalEmail({ to, applicantName, storeName }) {
  await sendMail({
    to,
    subject: 'QR Query (Q2) — Your Store Account Has Been Approved! 🎉',
    text: `Hi ${applicantName},\n\nGreat news! Your seller account for "${storeName}" on QR Query (Q2) has been approved.\n\nYou can now log in to the Seller Dashboard using your email: ${to}\nA 6-digit PIN will be sent to you upon login.\n\nWelcome aboard!\n\nQR Query Admin Team`,
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

module.exports = { sendQuestionnaireEmail, sendApprovalEmail, sendRejectionEmail, sendMail };
