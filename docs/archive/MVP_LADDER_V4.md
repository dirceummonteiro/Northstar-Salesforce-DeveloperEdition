# NORTHSTAR — MVP LADDER V4
## Visible-first delivery plan (supersedes V3 §2.1, §55, §55.1 and §56)

**Status:** binding. Where this document and `NORTHSTAR_SALESFORCE_MASTER_SCOPE_V3.md` disagree, **this one wins**. V3 remains the reference for *how* things are built (data model, personas, agent contracts, git rules, guardrails). V4 decides *what* gets built, *in what order*, and *when we stop*.

---

## ORDERS FOR HELIX — READ FIRST

Read this document in full before acting. It supersedes V3 §2.1, §55, §55.1 and §56.

Your diagnosis was right: the Lightning app was required by V3 §8 and never scheduled, and nothing visible was planned before M10. V4 fixes the ladder rather than patching one milestone.

Do these in order:

1. **Commit V4** to the repo on `main`.
2. **Retire the M0–M13 numbering.** Report progress only against the V4 ruler: `n/9`, counting V0 through V8. RC-1 and RC-2 are reported separately and never folded into that number. Two rulers in one message violates §4.
3. **Rewrite `docs/PROGRESSO.md`** against the V4 rungs. Archive the old ladder rather than deleting it.
4. **Move every deferred V3 section into `docs/BACKLOG.md`** — territories, quotas, attainment, portal, partner deals, contracts, cases, Big Object logging — so no agent picks them up by accident.
5. **Reconcile the app you are building now against V0 as written:** 8 tabs, not 18 (Home, Leads, Accounts, Contacts, Opportunities, Products, Discount Requests, Reports). A tab pointing at a deferred object makes the org look broken. Drop the extras.
6. **Record the Big Object change** from §5 in `docs/DECISIONS.md`: integration logs move to a standard custom object for this execution.

**Standing rule, from §1, applied to every rung from now on:** a rung is not complete until a screenshot is committed to `docs/EVIDENCIA/Vn-*.png` and `docs/PROGRESSO.md` states, in one line, what a person can now click that they could not click before. No rung starts before the previous one is clickable.

**Do not begin V1 until V0 is deployed and I have confirmed the screenshot.**

**Reply with your reconciliation plan and wait for my approval before executing.**

---

## 0. WHY THIS DOCUMENT EXISTS

The V3 ladder was ordered by technical dependency. The result: the org has been running for days, 49 components and ~1,051 records exist, and a human opening Salesforce sees an empty-looking org. The Lightning app was required by V3 §8 but never scheduled. The first visible artifact on the plan was at M10.

That is a planning defect, not an execution defect.

V4 reorders the work so that **every rung produces something a non-technical person can see on a screen**.

---

## 1. PRIME DIRECTIVE

> A milestone is not complete until someone can open Salesforce, click through it, and see the result without reading code, XML, or logs.

Three consequences:

1. **Screen proof is a deliverable.** Each rung ends with a screenshot committed to `docs/EVIDENCIA/Vn-*.png` and one line in `docs/PROGRESSO.md` saying what a user can now click that they could not click before.
2. **No rung starts before the previous one is clickable.** Building ahead of the shell is how we got here.
3. **Declarative first.** Apex only where configuration genuinely cannot do the job. Every Apex class must be reachable from something visible on screen within the same rung.

---

## 2. WHAT ALREADY EXISTS (baseline, do not rebuild)

- Data model and permission sets from V3 M1.
- ~1,051 seeded records: ~93 accounts with segment and tier, ~131 opportunities with margin fields, discount request records.
- 2 Apex classes, both pre-existing samples. Treat the Apex layer as **not started**.
- No Lightning app, no record pages, no list views, no reports. This is the gap V4 closes first.

---

## 3. THE MVP LADDER

Nine rungs. In order. One ruler.

| # | Rung | What it delivers | Screen proof |
|---|---|---|---|
| **V0** | **App shell** | Lightning app *Northstar Revenue Operations*. **8 tabs only** (Home, Leads, Accounts, Contacts, Opportunities, Products, Discount Requests, Reports). Record pages for Account and Opportunity with fields grouped into named sections. Compact layouts. Meaningful list views (columns that show segment, tier, margin, stage). | Open the app, click an account, see Commercial / Credit / Integration sections populated with real seeded values |
| **V1** | **Reports & dashboards** | Three dashboards on existing data: Rep, Manager, Executive. Six to eight reports feeding them. No new objects, no Apex. | Home tab shows a populated dashboard on first load |
| **V2** | **Opportunity Workspace (read-only)** | One LWC on the Opportunity record page showing the commercial summary: amount, cost, gross margin, tier, current checks. Reads existing fields only. | A rep opens an opportunity and sees the deal explained in one panel |
| **V3** | **Pricing engine** | Custom Metadata driven pricing (tier discount, volume discount, margin calculation). Apex service invoked from the record page. Workspace now shows the calculated price **and the name of the rule that produced it**. | Change a Custom Metadata row, reload the opportunity, see a different price with no deploy |
| **V4** | **Margin & discount guardrails** | Validation of discount ceiling and margin floor, with a message written for a salesperson, not a developer. | Type an over-limit discount, get blocked on screen with a readable explanation |
| **V5** | **Deal Desk approvals** | Discount request lifecycle, approval matrix by threshold, Deal Desk console list view or LWC. Approval invalidated when material terms change. | Submit a request as a rep, approve it as a manager, watch the status change |
| **V6** | **Lead slice** | Lead capture, a simple scoring formula, ownership assignment, conversion to Account / Contact / Opportunity. Declarative only. | A lead becomes an opportunity that lands in the pipeline dashboard from V1 |
| **V7** | **Quote → Order** | Quote from an approved opportunity, quote versioning, order generated from the accepted quote. | Closed-won opportunity produces an order visible on the account |
| **V8** | **Integration simulation + monitor** | Deterministic mocks for ERP, inventory and credit. Success, failure and retry paths. Logs in a **standard custom object** (see §5), surfaced in an Integration Monitor list view or LWC with a reprocess action. | Force a failure, see the error appear, click reprocess, watch it recover |

**CUT LINE — the MVP claim ends at V8.**

Everything above this line is what "functional MVP" means. Nothing else may be presented as MVP scope.

### Release candidate (after the cut line, only if V0–V8 are clean)

| # | Rung | What it delivers |
|---|---|---|
| **RC-1** | Test hardening + evidence package | ≥85% coverage on Apex written in this project, boundary and negative tests, evidence package per V3 §68 |
| **RC-2** | CR-DEMO-001 | The live change request from V3 §69.2, executed end to end with every agent participating |

---

## 4. SINGLE PROGRESS METRIC

```
rungs completed and validated
─────────────────────────────
              9
```

Counts V0 through V8 only. RC rungs are reported separately and never folded into this number. Never report two rulers in one message. Progress *inside* a rung is not progress on the project.

The V3 M0–M13 numbering is **retired**. Do not report against it.

---

## 5. SIMPLIFICATIONS MADE (deliberate, documented)

| V3 said | V4 says | Why |
|---|---|---|
| 18 navigation tabs (§8) | 8 tabs | Tabs pointing at deferred objects make the app look broken. Add tabs as the objects earn them. |
| Big Objects for integration logs | Standard custom object | Big Objects are not reportable in the normal report builder and are awkward to show on screen. The demo needs a visible, filterable log. Big Objects return in the backlog. |
| Territory Management, quota engine, attainment | Out | Already deferred in V3 §2.2. Confirmed out. Also remove from the presentation deck. |
| Customer portal, partner deals, contracts, cases | Out | Already deferred in V3 §2.2. Confirmed out. |
| Pricing engine at M5, after leads and pipeline | Pricing at V3, before leads | It is the highest-value showpiece. It should exist early, not late. |
| Apex from M3 onward | No Apex before V3 (rung) | Nothing built in Apex before there is a screen to show it on. |

**FLS is a feature, not a bug.** The credit fields are hidden from the sales-rep profile. Do not work around this. Demonstrate it: log in as a rep, show the section is absent; log in as an admin, show it present. That is the security model proving itself on screen.

---

## 6. SCOPE FREEZE

From the moment this document is committed, the ladder above is closed.

Anything new goes to `docs/BACKLOG.md` with the date and the reason, **except** two cases:

1. It blocks the demo spine (lead → opportunity → price → approval → quote → order → integration).
2. Something already stated in the presentation or the spec became false and must be corrected.

No agent reopens scope on its own. Helix records the justification in `docs/DECISIONS.md` and escalates per V3 §5.0.1.

---

## 7. THE DEMO SPINE

This is the five-minute story the whole ladder exists to support. If a rung does not serve it, it is below the cut line.

1. A lead arrives, is scored and routed, and converts.
2. The opportunity is built with products; the workspace explains the deal.
3. Pricing rules calculate the price and name the rule that fired.
4. An over-limit discount is blocked on screen.
5. A discount request goes to Deal Desk and is approved.
6. The quote becomes an order.
7. The ERP call fails, the error is visible, reprocess recovers it.
8. Dashboards reflect all of it.

---

## 8. START HERE

The order of work is in **ORDERS FOR HELIX** at the top of this document. Follow it exactly: reconciliation plan first, approval, then V0.

When V0 lands, the report reads like this and nothing more:

```
1/9 — V0 complete. You can now open the app and click through
93 accounts and 131 opportunities.
Screenshot: docs/EVIDENCIA/V0-app-shell.png
```
