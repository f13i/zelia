# PRD — Lucinda Returns Module ("Returns")

> Status: v1 spec, approved decisions locked 2026-07-31
> Owner: Farhan (CAO). Runs inside **Lucinda** (family chief of staff, sibling to Zelia).
> System of record: **Gmail labels + Google Calendar only** — no database, no repo storage of purchase data.

---

## 1. Problem

Farhan buys a lot online — Amazon and third-party merchants. Some of it needs to
go back (bought two purses; Kanwal keeps one, the other must be returned). Return
windows are short and easy to miss. When a window is missed he has to renegotiate
with the merchant. Today nothing tracks purchases, return windows, or the return
process end to end, so returns slip and money is lost.

**One line:** find every purchase in email, stay ahead of every return deadline,
and drive returns (and renegotiations) to done.

## 2. Goal

Lucinda proactively:
1. **Finds** every purchase in Farhan's inbox (Amazon + 3rd party).
2. **Logs** each item and its return window (Gmail labels + a calendar deadline).
3. **Surfaces** returns *before* the deadline and **asks Farhan which to return** —
   because she can't know intent (the purse case).
4. **Executes** an approved return where the channel allows.
5. **Renegotiates** when a window is missed or closing — drafts the ask and tracks
   the back-and-forth to resolution.

## 3. Non-goals (v1)

- Not a budgeting / expense tracker (future Lucinda module).
- Not a warranty / repair / recall tracker (future).
- No separate database, sheet, or repo file of purchases — labels + calendar are it.
- Never reads or writes the f13i or personal-brain Obsidian vaults.
- Never texts Kanwal (Lucinda hard rule).

## 4. Users

- **Farhan** — primary. Decides what to return, approves outbound.
- **Kanwal** — indirectly decides keep/return on shared items (purses, home goods).
  Lucinda surfaces these to Farhan; she never messages Kanwal.

## 5. Locked decisions

| Decision | Choice |
|---|---|
| **Return intent** | Track **all** purchases with a return window; flag **every** closing window. Farhan decides what to actually return. |
| **Autonomy** | **Full-auto on execution** where the channel allows. The *decision to return* is always Farhan's — she surfaces and asks. One "yes, return X" authorizes Lucinda to complete that item's mechanics (submit Amazon return, send the merchant email) without further gating. Blanket/mass sends never. |
| **Ledger** | **Gmail labels + Calendar only.** No sheet, no file. State is reconstructable from labels on every run (idempotent). |
| **Renegotiation** | **Draft + track the back-and-forth.** Draft the exception ask, then follow the thread — log replies, draft each follow-up for approval — until resolved. |

## 6. System of record — Gmail label taxonomy

One parent label `Returns/` with mutually-exclusive status children. A purchase
thread carries **exactly one** status label at a time; Lucinda moves it as state
changes, so she can rebuild the full picture from labels alone (no DB needed).

| Label | Meaning | Terminal? |
|---|---|---|
| `Returns/Tracked` | Purchase logged, window open, no decision yet | no |
| `Returns/To-Return` | Farhan said return it; action pending | no |
| `Returns/In-Progress` | Return initiated (Amazon RMA / merchant emailed) | no |
| `Returns/Renegotiating` | Window missed/closing; exception request in flight | no |
| `Returns/Kept` | Decided to keep — stop surfacing | yes |
| `Returns/Done` | Refunded / return closed | yes |

Labels are created on first run if absent.

## 7. Calendar

For each tracked item with a return deadline, one **all-day, Free / non-blocking**
event (matches Lucinda's existing calendar contract):

- Title: `🛍️ Return closes — <item> (<merchant>)`
- Date: the return deadline.
- Reminders: day-before popup; morning-of if the window is ≤3 days out.
- Description: order #, item, price, merchant, and how the deadline was derived
  (stated vs. assumed).
- **Dedup** against existing calendar events on that date/order before creating.
- Guest: **none** for returns (it's Farhan's admin task, not a shared family event).

## 8. Deriving the return deadline

Order emails rarely state a return-by date, so Lucinda derives it:

1. If the email **states** a return-by date → use it (authoritative).
2. Else `deadline = (delivery date, or order date if no delivery) + merchant window`,
   from a small policy table:
   - Amazon: 30 days (note holiday-extended windows when the order date falls in
     the extended-return period).
   - Common merchants: table in the agent file; extend over time.
   - Unknown merchant: assume **30 days** and mark the calendar event + digest
     line as **"assumed — verify"**.
3. Amazon "final sale"/non-returnable items → flag, no deadline event.

## 9. Workflows (Modes D1–D4)

### D1 — Purchase sweep (find & log)
Trigger: "track my returns" / "find my purchases" / scheduled weekly / backfill
("go through all my emails").
- Gmail search for order/receipt signals (Amazon senders + generic order/receipt
  subjects — see agent file for the query set).
- For each **new** order thread (not already under `Returns/`): extract merchant,
  order #, item(s), price, order date, delivery date. Apply `Returns/Tracked`,
  derive the deadline, create the calendar event.
- **Backfill**: widen the date window (e.g. `newer_than:1y`) for the first catch-up.
- **Dedup** by order number so re-runs never double-log.

### D2 — Proactive surfacing (text reminder → decision)
Trigger: scheduled weekday check + on demand.
- Find `Returns/Tracked` items whose deadline is within the alert window
  (≤7 days) or already passed.
- **Send Farhan an iMessage reminder** — conversational, one text, asking whether
  he wants to act. Each item on its own line with merchant + days left, and — for
  multi-item orders (the purse case) — each unit listed separately.
  > "Heads up — 2 return windows close soon. 1) Black purse — Nordstrom — 4d left.
  > 2) Tan purse — Nordstrom — 4d left. Return coming up, need me to do anything?
  > Reply which to return / keep."
- **His reply drives execution.** "Return the black one, keep the tan" → relabel
  each unit (`To-Return` / `Kept`) and go straight to D3 for the ones to return.
- These decision reminders are **texts to Farhan himself, which he has
  pre-authorized** (see autonomy contract) — Lucinda auto-sends them. Still
  **Farhan only, never Kanwal.**

### D3 — Execute a return
Trigger: Farhan approves an item from the digest, or says "return the black purse."
- **Amazon:** initiate the return via Amazon's returns flow (item, reason, refund
  method, label) — full-auto after approval. Where a headless submission isn't
  possible, degrade to a **pre-filled, exact step-by-step** and surface it. Relabel
  `In-Progress`; add the ship-by/dropoff to calendar.
- **3rd party:** complete the portal steps, or draft + send a return request to
  merchant support (order #, item, reason). Send after the one OK. Relabel
  `In-Progress`.
- On a refund-confirmation email → relabel `Done`.

### D4 — Renegotiate (missed / closing window)
Trigger: window passed with the item still open, or "they won't take it back."
- Draft a polite-but-firm exception request: order #, purchase/delivery date,
  reason, ask for a courtesy return / extension / store credit. Send after approval.
- Relabel `Renegotiating`. **Track the thread**: on each merchant reply, log it and
  draft the next follow-up for approval, until resolved — refund/credit → `Done`,
  firm no → surface options and mark `Kept`.

## 10. Autonomy contract (returns)

- **Auto, silent:** logging, labeling, calendar events (non-destructive).
- **Auto-send (pre-authorized):** the D2 **decision-reminder text to Farhan** — he
  explicitly asked for proactive "return coming up, need me to do anything?" texts,
  so these send without a per-text approval. **Farhan only, never Kanwal.**
- **Always ask:** which items to actually return (the reminder *is* the ask).
- **After his one reply, full-auto for that item:** submit the Amazon return / send
  the merchant email. No blanket or mass sends, ever.
- Never texts Kanwal. Reads only order/receipt/merchant mail surfaced by the search.
- **Send-from is always `fmanjiyani@gmail.com`, never `me@f13i.com`** — returns are
  personal, so every merchant email/renegotiation goes from the personal Gmail.
- iMessage requires Farhan's Mac online + Claude desktop app open; if unreachable,
  hold the text and surface the digest in-session instead.

## 11. Data & privacy

No purchase data leaves Gmail/Calendar. The repo holds only agent logic + this PRD —
no receipts, prices, or order numbers are committed.

## 12. Success metrics

- **Zero missed windows** for items Farhan wanted to return.
- Every purchase with a return window logged within a day of the email arriving.
- Every renegotiation tracked to a resolution (refund, credit, or explicit keep).

## 13. Risks / open items

- **Amazon programmatic returns** may require the browser + login (like the photo
  module's Mac dependency). Where headless submission isn't possible in-session, D3
  degrades to pre-filled step-by-step. → feasibility spike before claiming full auto.
- **Deadline derivation is heuristic** — "assumed" deadlines are flagged so Farhan
  can correct them.
- **Merchant coverage** — the sweep query is broad but not exhaustive; obscure
  senders may be missed. Query set grows over time from misses Farhan reports.

## 14. Rollout

- **v1:** D1 sweep + D2 surfacing + D3 (Amazon step-by-step / 3rd-party email) +
  D4 renegotiation. Amazon full-headless-return = spike.
- **Schedule:** a weekday-morning returns check (own cadence, or folded into
  Lucinda's existing 7:30 CT daycare run). See README for the cron.
- **Future:** warranty/recall tracking, price-drop refunds, budgeting tie-in.

Each mode plugs into Lucinda's existing spine: **monitor → classify → act → approve.**
