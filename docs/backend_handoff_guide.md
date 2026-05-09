# Mudda — Backend Handoff Guide
## Neighbourhood / HOA / RWA Feature

**Version:** 1.0  
**Date:** May 2026  
**Frontend contact:** Mudda Frontend Team  

---

## Overview

This document covers all API contracts the Mudda frontend requires for the **Neighbourhood** feature (accessible via Global/Neighbourhood toggle in the Home feed). It includes both:

1. **Existing community features** (already mocked) — Community Hub, Announcements, Initiatives
2. **New HOA/RWA features** — Grievances, Work Orders, Work History, Budget, Ledger

All amounts are in **INR (₹)**. All timestamps are **ISO 8601 UTC**.

---

## Authentication

All endpoints require:
```
Authorization: Bearer <jwt_token>
```

The JWT must include a `community_id` claim identifying which society/community the user belongs to.

### Roles
Two roles exist in the neighbourhood context:
- **`resident`** — can view all data, submit grievances, RSVP events
- **`hoa_admin`** — can additionally create/update work orders, add ledger entries, manage budgets

The backend should return a `role` field in the user profile response. The frontend uses `isAdmin = (role == 'hoa_admin')` to gate admin-only UI.

---

## Base URL

```
https://api.mudda.app/v1
```

All neighbourhood endpoints are prefixed with `/communities/{community_id}/`.

---

## 1. Community Hub (Existing)

### GET `/communities/{community_id}`
Returns community metadata.

**Response:**
```json
{
  "id": 1,
  "name": "Hillview Estates",
  "description": "A quiet, family-friendly neighborhood.",
  "lat": 28.6139,
  "lng": 77.2090,
  "radius_km": 2.5,
  "member_count": 2450,
  "active_issues_count": 128,
  "banner_url": "https://..."
}
```

### GET `/communities/{community_id}/announcements`
Returns official announcements from HOA admin/City Hall.

**Response:**
```json
[
  {
    "id": "msg-1",
    "title": "Town Hall: Road Safety",
    "content": "Please attend our monthly town hall...",
    "posted_at": "2026-05-08T10:00:00Z",
    "author_name": "HOA Admin"
  }
]
```

### GET `/communities/{community_id}/initiatives`
Returns events and fundraisers.

**Response:**
```json
[
  {
    "id": "init-1",
    "title": "Park Cleanup Drive",
    "description": "Join us this weekend...",
    "type": "event",
    "date": "2026-05-12T09:00:00Z",
    "location_str": "Central Square Gardens",
    "rsvp_count": 42,
    "image_url": "https://...",
    "has_user_rsvp": false,
    "has_user_pledged": false,
    "goal_amount": null,
    "raised_amount": null
  }
]
```

### POST `/communities/{community_id}/initiatives/{initiative_id}/participate`
RSVP to an event or pledge to a fundraiser.

**Body:** `{ "type": "rsvp" | "pledge", "amount": 500 }`  
**Response:** `{ "success": true }`

---

## 2. Grievances

### GET `/communities/{community_id}/grievances`
Returns all grievances. Supports filtering.

**Query params:**
- `status` — `open | in_progress | resolved`
- `category` — `plumbing | electrical | security | common_area | parking | sanitation | other`
- `priority` — `low | medium | high | urgent`

**Response:**
```json
[
  {
    "id": "grv-001",
    "title": "Water leakage in B-Wing corridor",
    "description": "There is a persistent water leak near flat B-204...",
    "category": "plumbing",
    "priority": "urgent",
    "status": "in_progress",
    "submitted_by": "Suresh Nair",
    "unit_no": "B-204",
    "submitted_at": "2026-05-07T08:30:00Z",
    "resolved_at": null,
    "photo_urls": [],
    "resolution_note": null,
    "assigned_to": "Ramesh Plumber",
    "linked_work_order_id": "wo-001"
  }
]
```

### POST `/communities/{community_id}/grievances`
Submit a new grievance. Any resident can submit.

**Body:**
```json
{
  "title": "Water leak near B-204",
  "description": "Describe the issue...",
  "category": "plumbing",
  "priority": "high",
  "unit_no": "B-204",
  "photo_urls": []
}
```

**Response:** The created `Grievance` object with `id` and `status: "open"`.

### PATCH `/communities/{community_id}/grievances/{grievance_id}`
Update grievance status or add resolution note. **HOA Admin only.**

**Body:**
```json
{
  "status": "resolved",
  "resolution_note": "Pipe replaced. Cost: ₹3,500.",
  "assigned_to": "Ramesh Plumber"
}
```

### POST `/communities/{community_id}/grievances/{grievance_id}/photos`
Upload photos for a grievance. `multipart/form-data`.

**Form field:** `photo` (image file)  
**Response:** `{ "url": "https://..." }`

---

## 3. Work Orders

### GET `/communities/{community_id}/work-orders`
Returns all work orders.

**Query params:** `status` — `todo | in_progress | done`

**Response:**
```json
[
  {
    "id": "wo-001",
    "title": "Fix plumbing leak – B Wing corridor",
    "description": "Locate and fix the water pipe leak near B-204.",
    "category": "repair",
    "status": "in_progress",
    "assigned_to": "Ramesh Plumber",
    "created_at": "2026-05-07T09:00:00Z",
    "due_date": "2026-05-10T18:00:00Z",
    "completed_at": null,
    "estimated_cost_inr": 3500,
    "actual_cost_inr": null,
    "linked_grievance_id": "grv-001",
    "notes": null
  }
]
```

### POST `/communities/{community_id}/work-orders`
Create a new work order. **HOA Admin only.**

**Body:**
```json
{
  "title": "Monthly garden trimming",
  "description": "Trim hedges, mow lawns...",
  "category": "landscaping",
  "assigned_to": "Green Thumb Services",
  "due_date": "2026-05-15T18:00:00Z",
  "estimated_cost_inr": 8000,
  "linked_grievance_id": null
}
```

### PATCH `/communities/{community_id}/work-orders/{work_order_id}`
Update work order status or actual cost. **HOA Admin only.**

**Body:**
```json
{
  "status": "done",
  "actual_cost_inr": 7800,
  "completed_at": "2026-05-09T14:00:00Z",
  "notes": "Completed ahead of schedule."
}
```

---

## 4. Work History

### GET `/communities/{community_id}/work-orders?status=done&include_archived=true`
Reuses the work orders endpoint with `status=done`. The frontend groups them by `completed_at` month.

No separate endpoint needed — just ensure completed orders include `completed_at` and `actual_cost_inr`.

---

## 5. Budget

### GET `/communities/{community_id}/budget`
Returns budget periods (last 3 months by default).

**Query params:** `months=3` (number of past months to return)

**Response:**
```json
[
  {
    "period_key": "2026-05",
    "label": "May 2026",
    "total_budget_inr": 120000,
    "categories": [
      {
        "name": "Maintenance & Repair",
        "allocated_amount_inr": 40000,
        "spent_amount_inr": 28500,
        "color": "#6366F1",
        "icon": "build"
      },
      {
        "name": "Housekeeping",
        "allocated_amount_inr": 25000,
        "spent_amount_inr": 22000,
        "color": "#22C55E",
        "icon": "cleaning_services"
      }
    ]
  }
]
```

> **Note:** The `color` and `icon` fields help the frontend render consistent charts. Recommend maintaining a canonical category list server-side that maps names to display properties.

### POST `/communities/{community_id}/budget`
Create a budget period. **HOA Admin only.**

**Body:**
```json
{
  "period_key": "2026-06",
  "label": "June 2026",
  "total_budget_inr": 120000,
  "categories": [
    { "name": "Maintenance & Repair", "allocated_amount_inr": 40000 }
  ]
}
```

---

## 6. Ledger

### GET `/communities/{community_id}/ledger`
Returns all ledger entries, newest first.

**Query params:**
- `type` — `credit | debit`
- `from_date` — ISO date string
- `to_date` — ISO date string
- `page`, `limit` — pagination

**Response:**
```json
[
  {
    "id": "led-001",
    "date": "2026-05-01",
    "title": "Maintenance Collection – May",
    "description": "35 units × ₹3,500 monthly maintenance fee collected.",
    "amount_inr": 122500,
    "type": "credit",
    "category": "Maintenance Fee",
    "receipt_image_url": null,
    "work_order_id": null,
    "recorded_by": "Priya Mehta (Secretary)"
  }
]
```

**Also return summary:**
```json
{
  "entries": [...],
  "summary": {
    "total_credits_inr": 244500,
    "total_debits_inr": 85200,
    "balance_inr": 159300
  }
}
```

### POST `/communities/{community_id}/ledger`
Add a ledger entry. **HOA Admin only.**

**Body:**
```json
{
  "date": "2026-05-09",
  "title": "Plumbing Repair – B Wing",
  "description": "Water pipe leak fix near B-204. Parts + Labour.",
  "amount_inr": 3500,
  "type": "debit",
  "category": "Maintenance & Repair",
  "work_order_id": "wo-001"
}
```

### POST `/communities/{community_id}/ledger/{entry_id}/receipt`
Upload a receipt image. `multipart/form-data`.

**Form field:** `receipt` (image file)  
**Response:** `{ "receipt_image_url": "https://..." }`

---

## 7. Society Info

### GET `/communities/{community_id}/society`
Returns society registration and banking details.

**Response:**
```json
{
  "id": 1,
  "name": "Hillview Estates RWA",
  "registration_no": "RWA/DL/2018/04521",
  "address": "Block A-12, Hillview Estates, Sector 62, Noida – 201309",
  "maintenance_fee_per_unit_inr": 3500,
  "bank_name": "HDFC Bank",
  "bank_account_no": "5020012345678",
  "bank_ifsc": "HDFC0001234",
  "managing_committee": [
    { "name": "Rajesh Sharma", "role": "President", "phone": "+91 98100 00001" },
    { "name": "Priya Mehta", "role": "Secretary", "phone": "+91 98100 00002" },
    { "name": "Amit Verma", "role": "Treasurer", "phone": "+91 98100 00003" }
  ]
}
```

---

## 8. Real-Time Updates (Optional — Phase 2)

For real-time grievance status updates, implement **Server-Sent Events (SSE)**:

```
GET /communities/{community_id}/events
Accept: text/event-stream
Authorization: Bearer <token>
```

**Event types:**
```
event: grievance_status_changed
data: { "grievance_id": "grv-001", "new_status": "resolved", "note": "Fixed!" }

event: work_order_updated
data: { "work_order_id": "wo-001", "new_status": "done" }

event: ledger_entry_added
data: { "entry": { ...LedgerEntry } }

event: announcement_posted
data: { "announcement": { ...CommunityAnnouncement } }
```

---

## 9. Error Format

All errors follow:
```json
{
  "error": {
    "code": "UNAUTHORIZED",
    "message": "Only HOA admins can perform this action.",
    "status": 403
  }
}
```

Standard status codes:
- `400` — Validation error
- `401` — Not authenticated
- `403` — Not authorized (role check failed)
- `404` — Resource not found
- `422` — Unprocessable entity
- `500` — Server error

---

## 10. Frontend ↔ Backend Field Mapping

| Frontend (Dart) | Backend (JSON) |
|---|---|
| `amountInr` | `amount_inr` |
| `estimatedCostInr` | `estimated_cost_inr` |
| `actualCostInr` | `actual_cost_inr` |
| `submittedAt` | `submitted_at` |
| `resolvedAt` | `resolved_at` |
| `completedAt` | `completed_at` |
| `linkedGrievanceId` | `linked_grievance_id` |
| `linkedWorkOrderId` | `linked_work_order_id` |
| `receiptImageUrl` | `receipt_image_url` |
| `recordedBy` | `recorded_by` |
| `periodKey` | `period_key` |
| `totalBudgetInr` | `total_budget_inr` |
| `allocatedAmountInr` | `allocated_amount_inr` |
| `spentAmountInr` | `spent_amount_inr` |
| `maintenanceFeePerUnit` | `maintenance_fee_per_unit_inr` |

---

## 11. Enum Values

### Grievance Status
`open` → `in_progress` → `resolved`

### Grievance Priority
`low`, `medium`, `high`, `urgent`

### Grievance Category
`plumbing`, `electrical`, `security`, `common_area`, `parking`, `sanitation`, `other`

### Work Order Status
`todo` → `in_progress` → `done`

### Work Order Category
`maintenance`, `repair`, `cleaning`, `security`, `landscaping`, `painting`, `other`

### Ledger Entry Type
`credit`, `debit`

---

## 12. PDF Receipt

The frontend generates PDF receipts **entirely client-side** using the `pdf` + `printing` Flutter packages. No backend endpoint required for PDF generation. The receipt pulls data from `GET /communities/{community_id}/ledger/{entry_id}` and any `receipt_image_url` stored on the entry.

---

*Questions? Contact the frontend team or file an issue in the shared Notion project board.*
