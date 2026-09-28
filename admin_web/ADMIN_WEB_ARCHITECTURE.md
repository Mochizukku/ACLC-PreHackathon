# Admin Web Architecture & Access Relocation Plan

## Overview
All **Admin Portal** operations (reviewing seller account applications, issuing questionnaires, reviewing applicant answers, approving/rejecting store registrations, managing active seller accounts, and monitoring sales performance) are **exclusively centralized in the `admin_web` project**.

The mobile Flutter application (`lib/`) is strictly designed for **Customers** (scanning QR codes, placing orders) and **Sellers** (store dashboard, product management, order processing). No administrative screens or passcode dialogs exist on the mobile app.

---

## `admin_web` System Architecture

```
                               ┌─────────────────────────────┐
                               │   Mobile App (Flutter)      │
                               │  - Seller Account Request   │
                               └──────────────┬──────────────┘
                                              │ HTTP POST /api/requests
                                              ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                           admin_web (Node.js Server)                            │
│                                  Port 3000                                      │
├───────────────────────────────┬─────────────────────────────────────────────────┤
│ Frontend (public/)            │ Backend (server.js)                             │
│ - index.html                  │ - REST API Router                               │
│ - app.js                      │ - Firebase Firestore Adapter (firebase_db.js)  │
│ - style.css                   │ - Nodemailer Service (mailer.js)                │
│ - questionnaire.html          │                                                 │
└───────────────────────────────┴─────────────────────────────────────────────────┘
                                              │
                                              ▼
                               ┌─────────────────────────────┐
                               │  Firebase Cloud Firestore   │
                               │  - requests                 │
                               │  - accounts                 │
                               │  - seller_pins              │
                               │  - questionnaire_templates  │
                               └─────────────────────────────┘
```

---

## Core Capabilities & Features

### 1. Store Account Request Review
- **Live Stream:** Pending store account requests automatically populate on the Admin Dashboard (`http://localhost:3000`).
- **Actionable Buttons:**
  - **📧 Send Questionnaire:** Sends a unique questionnaire form link to the seller applicant via email.
  - **📋 View Answers:** Displays submitted questionnaire responses.
  - **✓ Approve:** Marks application as approved, creates active store account in Firebase, and sends approval email.
  - **✕ Reject:** Prompts for optional rejection reason, updates request status to `Rejected`, and sends notification email.

### 2. Seller Account Management Directory
- **Active / Inactive Toggle:** Administrators can instantly activate or deactivate registered stores.
- **Account Overview:** Displays store name, applicant name, contact details, email, and registration timestamp.

### 3. Dynamic Questionnaire Manager
- **Custom Questions:** Administrators can add, edit, or delete questions sent to prospective sellers.
- **Public Form Endpoint:** Prospective sellers complete their answers at `http://localhost:3000/questionnaire?token=<TOKEN>`.

### 4. Live Statistics & Performance
- **Sales Overview:** Monthly orders, weekly average order count, peak sales week, and active store count.

---

## API Reference (`server.js`)

| Method | Endpoint | Description |
| :--- | :--- | :--- |
| `GET` | `/api/data` | Fetch current dashboard statistics, accounts count, and request totals |
| `GET` | `/api/requests` | List all seller account registration requests |
| `POST` | `/api/requests` | Submit a new seller account request (from mobile app or test suite) |
| `POST` | `/api/requests/:id/send-questionnaire` | Issue questionnaire email to applicant |
| `GET` | `/api/requests/:id/answers` | Retrieve questionnaire answers submitted by applicant |
| `POST` | `/api/requests/:id/approve` | Approve seller request & create active account |
| `POST` | `/api/requests/:id/reject` | Reject seller request with optional reason note |
| `GET` | `/api/accounts` | List all seller store accounts |
| `POST` | `/api/accounts/:id/toggle` | Activate or deactivate seller store account |
| `GET` | `/api/questionnaire/questions` | Get questionnaire template questions |
| `POST` | `/api/questionnaire/questions` | Add or update a questionnaire question |
| `DELETE` | `/api/questionnaire/questions/:id` | Delete a questionnaire question |
