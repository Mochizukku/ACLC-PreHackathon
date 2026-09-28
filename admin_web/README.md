# QR Query (Q2) — Admin Web Dashboard

Web-based Administrative Dashboard for managing store account requests, seller account statuses, seller questionnaires, and real-time sales metrics.

---

## 🚀 Quick Start Guide

### Prerequisites
- Node.js (v18+)

### Installation & Execution
```bash
# Navigate to admin_web directory
cd admin_web

# Install dependencies (if not already installed)
npm install

# Start the Admin Web Dashboard server
npm start
# or
node server.js
```

The server will start at **`http://localhost:3000`**.

---

## 📂 Project Structure

```
admin_web/
├── server.js                   # Main Node.js HTTP/Express API server (Port 3000)
├── firebase_db.js              # Firebase Cloud Firestore database adapter
├── mailer.js                   # Nodemailer service for sending questionnaire & approval emails
├── public/                     # Frontend web interface
│   ├── index.html              # Main Admin Dashboard HTML UI
│   ├── app.js                  # Dashboard state, REST API integration & modal handlers
│   ├── style.css               # Clean modern admin UI stylesheet
│   └── questionnaire.html      # Public applicant questionnaire form
├── data/
│   └── admin_data.json         # Local fallback database store
├── ADMIN_WEB_ARCHITECTURE.md   # Architectural documentation & REST API specs
└── package.json                # Project manifest & dependencies
```

---

## 🔗 Integration with Mobile App & Firebase

- **Store Requests:** When a prospective seller fills out the **Register your Store** form on the Flutter mobile app, the mobile app sends the request to Firebase Firestore (`store_requests` collection) and/or `http://localhost:3000/api/requests`.
- **Admin Review:** Administrators review pending requests directly on this web dashboard at `http://localhost:3000`, send questionnaires, view applicant responses, and issue instant approvals or rejections.
