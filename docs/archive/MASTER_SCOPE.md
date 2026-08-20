# NORTHSTAR DISTRIBUTION GROUP
# Salesforce Enterprise Transformation — Master Build Specification

**Document type:** Complete implementation scope / source-of-truth specification  
**Purpose:** Autonomous multi-agent Salesforce delivery prototype  
**Target environment:** Dedicated Salesforce Developer Org / scratch orgs / integration org  
**Delivery model:** OpenClaw multi-agent squad + Git + Salesforce CLI (`sf`)  
**Project codename:** Northstar Revenue Cloud Prototype (NRCP)  
**Version:** 3.0 (Developer Edition edition — escopo ajustado e reduzido)  
**Status:** Build-ready / agent-team aligned baseline

> **Esta é a única fonte de verdade do projeto.** Não existe adendo, anexo nem documento complementar. Tudo que vale está aqui.

---

## 0. DOCUMENT MANDATE

This document is the authoritative build specification for the Northstar Distribution Group Salesforce prototype. The agent squad MUST treat this file as the primary scope and requirements source unless a later approved ADR, change request, or explicit coordinator instruction supersedes a section.

The objective is not to generate isolated Salesforce examples. The objective is to build a coherent, integrated, enterprise-style Salesforce implementation that demonstrates an autonomous software engineering team performing requirements analysis, architecture, implementation, testing, review, deployment, documentation, and iterative maintenance.

The finished system MUST be demonstrable end-to-end and MUST include realistic data, permissions, business rules, failure cases, integrations, automated tests, and operational evidence.

### 0.1 Core delivery principles

1. Git is the source of truth.
2. No agent may use Production.
3. The target org exists only for development/integration/demo purposes.
4. **All work happens on `main`. No agent creates branches or worktrees.**
5. Metadata and code changes require validation before integration.
6. Critical Apex logic must be bulk-safe.
7. Business policy should be configuration-driven where practical.
8. No secrets may be committed to source control.
9. Automated tests are part of implementation, not an afterthought.
10. Security must follow least privilege.
11. Integrations must have deterministic mocks for automated testing/demo.
12. Failed deployments/tests are feedback loops to be fixed, not bypassed.
13. The project must remain maintainable by agents that did not author the original feature.
14. Every epic must leave documentation sufficient for another agent to continue the work.

---

# 1. BUSINESS CONTEXT

## 1.1 Fictional company

**Northstar Distribution Group (NDG)** is a fictional Brazilian B2B distributor of industrial equipment, replacement parts, consumables, and maintenance/service contracts.

NDG sells through:

- direct enterprise sales;
- regional SMB sales teams;
- strategic/national account teams;
- partner/reseller channels;
- inside sales;
- renewals/account management.

### 1.2 Simulated scale — NARRATIVE ONLY

The numbers below describe the fictional company for storytelling purposes. **They are NOT a data-loading target.**

- ~1,200 employees.
- 220 sales representatives.
- 35 sales managers.
- 8 regional directors.
- RevOps and Deal Desk teams.
- ~18,000 active B2B customer accounts.
- ~25,000 products/SKUs.
- Hundreds of channel partners.
- Simulated annual pipeline: R$1.2B.
- Multiple warehouses/distribution centers.

> **CRITICAL:** The target org is a Salesforce **Developer Edition** with **5 MB of data storage**, which fits roughly **2,500 records in total across all objects**. Never attempt to seed the volumes above. The binding seed-data budget is in **section 33**, and it is mandatory.

### 1.3 Existing business problems

NDG currently suffers from:

- fragmented customer information;
- lead distribution by spreadsheet/email;
- quotas managed in spreadsheets;
- inconsistent sales forecasting;
- duplicate accounts and contacts;
- manual price calculations;
- uncontrolled discounting;
- margin leakage;
- slow Deal Desk approval;
- sales reps switching between CRM and ERP screens;
- poor visibility into inventory and credit status;
- manual order creation;
- poor renewal tracking;
- partner deal conflicts;
- limited executive analytics;
- weak integration observability;
- inconsistent permission management.

### 1.4 Transformation goal

Implement Salesforce as the central commercial platform for the full lead-to-order and renewal lifecycle while integrating with simulated external systems for ERP, inventory, credit, and logistics.

---

### 1.5 THE REAL ORG — measured limits

These are measured values from the actual target org, not estimates.

| Resource | Limit | In use | Free |
|---|---|---|---|
| Data storage | 5.0 MB | 344 KB (7%) | ~4.65 MB |
| File storage | 20.0 MB | 17 KB | ~20 MB |
| Big Objects | 1,000,000 records | 0 | 1,000,000 |

Other Developer Edition limits that shape this project:

- **2 Salesforce licenses.** One real user per persona is impossible. See section 30.2.
- **15,000 API calls per day.** Every `sf` CLI deploy and query consumes them. Batch deploys; never deploy file by file.
- **No sandbox, no Change Sets.** Metadata deploys through the CLI only.
- **One org.** No scratch orgs, no separate integration org. See section 7.3.

#### What 5 MB actually means

Salesforce counts most records at **2 KB each**, regardless of how many fields are filled.

```
4.65 MB free ÷ 2 KB ≈ 2,380 records TOTAL
```

That is the ceiling for **all objects combined**, not per object.

#### Two escape hatches that do NOT consume that space

These two change the design of this project and are mandatory:

1. **Custom Metadata Types do not count against data storage.** Every pricing policy, discount tier, approval rule and integration configuration MUST live in Custom Metadata, never in a custom object. This also satisfies the requirement that business policy be configurable without changing Apex.

2. **Big Objects have their own 1,000,000-record allocation.** Integration logs, retry history and operational evidence MUST go to Big Objects, never to regular custom objects. This is what allows full observability without exhausting the 5 MB.

---

# 2. PROJECT OBJECTIVES

This execution delivers a **coherent, demonstrable slice** of the lead-to-order lifecycle. The list below is the binding scope.

## 2.1 IN SCOPE — this execution

1. Customer 360 (Account, Contact, hierarchy).
2. Lead capture, qualification, scoring, routing, and conversion.
3. Opportunity pipeline management.
4. Product and price book management.
5. **Configurable pricing engine driven by Custom Metadata.** This is the highest-value showpiece of the project.
6. Discount and margin controls.
7. Deal Desk approvals.
8. Quote lifecycle.
9. Order lifecycle.
10. ERP, inventory and credit integration simulation with deterministic mocks.
11. Integration observability and retry, logged to **Big Objects**.
12. Automated Apex and LWC test suite.
13. Repeatable Salesforce CLI deployment.
14. Reports and dashboards for rep, manager and executive.
15. Documentation and agent traceability.

## 2.2 DEFERRED — not this execution

None of these are cancelled. They are **postponed**, and MUST be recorded in `docs/PENDENCIAS.md` with the reason.

| Item | Why deferred |
|---|---|
| Customer self-service portal (Experience Cloud) | Entire external security model, limited licenses on Developer Edition, and not required to demonstrate the squad. |
| Partner/channel sales and deal registration | Depends on the same community/portal model. |
| Contracts and renewals | Separate lifecycle; not needed for lead-to-order. |
| Cases and customer support | Separate domain from commercial. |
| Formal Territory Management | Replaced by simple account ownership plus permission sets. |
| Quota management and attainment calculation | Replaced by a target field on the team, only if a report needs it. |
| Advanced RevOps and executive analytics | Basic reports and dashboards cover the demonstration. |

Sections 12, 13, 23, 24, 25, 26 and the corresponding epics, LWCs, objects and delivery-map entries elsewhere in this document describe **deferred** work. Read them as future reference, not as this execution's backlog.

**Rule:** if during execution a deferred item appears necessary, Helix records the justification in `docs/DECISIONS.md` and escalates to `sfable` before bringing it back. No agent reopens scope on its own.

---

# 3. OUT OF SCOPE

Unless explicitly added through a change request:

- real payment processing;
- real financial posting;
- real ERP credentials;
- real credit bureau integrations;
- production customer PII;
- CPQ managed package dependency;
- Salesforce Billing;
- Marketing Cloud;
- Data Cloud;
- MuleSoft runtime dependency;
- real logistics provider integration;
- Production deployment.

The prototype may emulate CPQ-like capabilities using custom Salesforce functionality.

---

# 4. USER PERSONAS

## 4.1 Sales Representative

Needs to:

- manage assigned leads/accounts;
- create opportunities;
- add products;
- request pricing;
- inspect stock;
- see credit status;
- request discount approval;
- create quotes;
- close opportunities;
- monitor personal quota attainment;
- see renewals/tasks.

## 4.2 Sales Manager

Needs to:

- see team pipeline;
- inspect rep performance;
- manage forecast;
- approve commercial exceptions within authority;
- see quota attainment;
- identify stalled/at-risk deals.

## 4.3 Regional Director

Needs aggregated territory metrics, forecast, quota attainment, margin, and exception visibility.

## 4.4 Deal Desk Analyst

Needs to:

- review pricing exceptions;
- understand requested versus permitted discounts;
- see margin impact;
- approve/reject/request changes;
- track approval SLA.

## 4.5 RevOps Administrator

Needs to manage:

- quotas;
- territories;
- commercial policies;
- product/price configuration;
- dashboards;
- operational exceptions.

## 4.6 Integration Administrator

Needs to:

- monitor outbound/inbound integration attempts;
- inspect errors;
- retry eligible messages;
- view external identifiers and timestamps.

## 4.7 Customer Portal User

Needs to:

- see own account information;
- see orders;
- request quotes;
- open/view cases;
- view relevant contract/renewal information.

## 4.8 Executive

Needs read-only high-level KPIs and trends.

## 4.9 Salesforce Administrator

Needs elevated configuration/diagnostic access.

---

# 5. AGENT SQUAD AND RESPONSIBILITIES

This project MUST be executed by the following OpenClaw squad. These names and ownership boundaries are canonical for this specification.

## 5.0 CANONICAL AGENT IDs

These are the only valid `agentId` values for `sessions_spawn`. Using any other value fails.

```
helix · schema · kernel · pixel · bridge · pulse · probe · sfable
```

Note two things:

- The declarative metadata agent is **`schema`** (identity: Schema). If any part of this document or any external material refers to it as "Forge", that name is obsolete and belongs to a different team on the same host.
- The escalation agent is **`sfable`**, not `fable`. Where this document says "Fable", the agentId is `sfable`.

## 5.0.1 Escalation path

The specialists do **not** call `sfable` directly. They end their turn reporting to Helix, stating precisely: what the problem is, what they already tried, and which decision is blocked. Helix calls `sfable` and returns the result.

Reason: direct second-layer spawning is not reliable on this OpenClaw installation.

## 5.0.2 Autonomy

This project runs with **full autonomy**. No agent stops to ask the owner anything.

When something is not specified here, decide following this document's direction and priority order, record the decision in `docs/DECISIONS.md`, and move on. Never stop, never wait for approval, never end an execution saying "awaiting instructions".

---

The operating model intentionally uses a compact specialist team. **Helix** owns coordination and architecture. **Schema, Kernel, Pixel, Bridge, Pulse and Probe** execute specialist work. **Fable (`sfable`) is not a normal delivery agent**; it is an escalation resource invoked by Helix only when the team reaches a difficult architectural decision, persistent blocker, ambiguous trade-off, or high-impact conflict that cannot be resolved safely by the normal squad.

## 5.1 Helix — Coordination / Salesforce Architecture

**Primary mission:** Own the project end-to-end as coordinator, Salesforce architect and technical decision authority.

Helix owns:

- decomposition of business scope into epics, capabilities, stories and executable tasks;
- project sequencing and dependency management;
- architecture and design decisions;
- solution boundaries between declarative automation, Apex, LWC and integrations;
- Salesforce object/data model architecture;
- security and sharing architecture;
- platform-limit awareness and governor-limit strategy;
- approval of cross-domain design changes;
- assignment of work to Schema, Kernel, Pixel, Bridge, Pulse and Probe;
- task acceptance and integration readiness;
- conflict resolution between agents;
- review of changes that alter shared contracts;
- ownership of ADRs or delegation of ADR drafts to specialists;
- release-go/no-go coordination;
- change-request decomposition;
- escalation to Fable when required.

Helix MUST:

1. read this master specification before assigning implementation tasks;
2. preserve the functional intent of the scope;
3. keep the task graph explicit;
4. prevent two agents from unknowingly editing the same metadata or shared contract;
5. require test evidence before accepting critical work;
6. prefer configuration-driven and maintainable Salesforce solutions;
7. maintain an architecture decision log;
8. ensure that all features remain deployable through source control and Salesforce CLI;
9. stop and escalate instead of silently inventing a major business assumption;
10. invoke Fable only for genuine escalation conditions.

Helix SHOULD NOT routinely implement feature code. It MAY create small integration fixes, documentation or coordination metadata when necessary, but it should preserve its role as system-level coordinator and architect.

### Helix deliverables

- epic/task breakdown;
- dependency map;
- architecture diagrams;
- ADRs;
- object ownership matrix;
- security model;
- automation strategy;
- shared interface contracts;
- review decisions;
- release acceptance report;
- final project delivery report.

---

## 5.2 Schema — Declarative Metadata Engineer

**Primary mission:** Build and maintain Salesforce metadata and declarative automation without unnecessary Apex.

Schema owns, when appropriate:

- custom objects;
- custom fields;
- relationships;
- record types;
- compact layouts;
- Lightning record pages;
- page layouts where still required;
- Dynamic Forms configuration;
- validation rules;
- formulas;
- roll-up summaries where supported;
- Flow automation;
- subflows;
- approval-process metadata where applicable;
- queues;
- public groups when required by design;
- permission sets and permission-set groups as assigned by Helix;
- custom metadata types and records;
- custom settings only when specifically justified;
- list views;
- reports and dashboards where metadata-driven;
- app/navigation metadata;
- tabs;
- email templates/alerts for prototype workflows where useful;
- declarative parts of Experience Cloud where included in the available org;
- metadata documentation and field descriptions.

Schema MUST NOT:

- implement complex logic in Flow when Apex is materially safer or easier to maintain;
- duplicate business rules already centralized in Apex or Custom Metadata;
- change shared object contracts without Helix approval;
- weaken security simply to make a feature work;
- create unmanaged one-off configuration directly in the org without retrieving/committing it.

### Schema quality expectations

- all fields and objects have clear descriptions;
- automation naming is consistent;
- flows have fault paths where meaningful;
- declarative automation avoids recursion;
- automation order is understood and documented;
- custom metadata is preferred for mutable policy configuration;
- profile-specific permissions are avoided when permission sets can be used;
- metadata is source-controlled.

---

## 5.3 Kernel — Apex Engineer

**Primary mission:** Own server-side Salesforce code and non-trivial transactional business logic.

Kernel owns:

- Apex service layer;
- trigger architecture;
- trigger handlers;
- selectors/query classes where justified;
- repositories/data-access abstractions where justified;
- domain/business services;
- DTOs;
- controllers used by LWC;
- REST resources;
- Queueable Apex;
- Batch Apex;
- Scheduled Apex;
- Platform Event producers/consumers if selected by Helix;
- transaction-safe business rules;
- idempotency support used by integrations;
- Apex tests for owned code;
- reusable test-data factories where appropriate.

Kernel MUST:

- bulkify all trigger/service logic;
- avoid SOQL/DML in loops;
- consider CPU, heap, query, DML and callout limits;
- enforce CRUD/FLS/sharing according to the selected architecture;
- make business logic testable outside triggers;
- keep controllers thin;
- use deterministic tests;
- test success, failure, bulk and edge cases;
- avoid hard-coded IDs and mutable policy values;
- use Custom Metadata/configuration where business policy should vary.

Kernel coordinates with:

- Schema on metadata/automation boundaries;
- Pixel on Apex controller contracts;
- Bridge on callout/integration service contracts;
- Pulse on query and bulk/performance design;
- Probe on test failures and release defects;
- Helix on architectural exceptions.

---

## 5.4 Pixel — LWC Engineer

**Primary mission:** Build the Salesforce user experience for sales, managers, Deal Desk, RevOps and operational personas.

Pixel owns:

- Lightning Web Components;
- component composition;
- UI state management;
- Lightning Data Service usage;
- wire/adapters;
- imperative Apex interactions;
- reusable UI primitives;
- Lightning Message Service when useful;
- client-side validation;
- loading states;
- empty states;
- error states;
- accessibility basics;
- responsive behavior within Salesforce-supported surfaces;
- interaction patterns for the major business workspaces;
- Jest tests where the project tooling supports them.

Pixel MUST:

- prefer standard Lightning base components;
- avoid exposing data the user is not authorized to access;
- provide understandable errors rather than raw server exceptions;
- avoid excessive sequential server calls;
- work with Kernel to define stable DTO/controller contracts;
- work with Schema for Lightning page composition;
- preserve usability with realistic seed data and large record lists.

Primary Pixel deliverables include:

- Sales Command Center;
- Opportunity Workspace;
- Quota Cockpit;
- Deal Desk Console;
- Manager Forecast;
- Integration Monitor;
- shared reusable components required by these applications.

---

## 5.5 Bridge — Integration Engineer

**Primary mission:** Own Salesforce-to-external-system integration design and implementation.

Bridge owns:

- ERP integration contracts;
- inventory integration;
- credit-status integration;
- simulated logistics/integration endpoints where included;
- Named Credential / External Credential strategy when supported;
- HTTP callout clients;
- integration DTOs and serializers;
- mock callout behavior;
- retry patterns;
- idempotency patterns;
- external IDs;
- correlation IDs;
- error normalization;
- integration status transitions;
- integration documentation;
- request/response examples;
- failure simulations used by the demo.

Bridge MUST:

- never hard-code secrets;
- make mocks deterministic;
- distinguish retryable from non-retryable failure;
- preserve enough diagnostic information for troubleshooting without exposing secrets;
- design around Salesforce transaction/callout limits;
- coordinate async execution with Kernel;
- coordinate operational data/log design with Pulse;
- provide Probe with deterministic failure and recovery scenarios.

---

## 5.6 Pulse — Data & Performance Engineer

**Primary mission:** Own data quality, realistic data volume, query efficiency and performance engineering.

Pulse owns:

- seed-data architecture;
- deterministic data generators/import datasets;
- large-data-volume assumptions;
- SOQL review;
- selectivity review;
- query-plan considerations where tooling/org supports inspection;
- duplicate-data scenarios;
- data migration/import scripts;
- indexing/external-ID recommendations;
- batch sizing recommendations;
- performance test scenarios;
- report/dashboard data realism;
- data cleanup and repeatable reset strategy for the prototype;
- performance-risk documentation.

Pulse MUST review:

- high-volume Apex queries;
- aggregation used by quota and forecasting;
- integration log growth;
- product/price queries;
- portal/customer filtering where applicable;
- reports likely to become expensive;
- any implementation expected to process hundreds/thousands of records per transaction or scheduled run.

Pulse coordinates with Kernel on code optimization, Schema on field/index/data-model implications, Bridge on integration volumes, Pixel on pagination/loading strategies, and Probe on scale-oriented validation.

---

## 5.7 Probe — QA / Deployment / Salesforce CLI / Git Engineer

**Primary mission:** Be the team's independent quality and delivery gate, and operate the source-control/deployment toolchain.

Probe owns:

### Quality assurance

- project test strategy;
- regression matrix;
- acceptance tests;
- negative tests;
- permission/persona tests;
- bulk tests;
- integration success/failure/retry tests;
- defect reproduction;
- release validation evidence;
- test result summaries;
- coverage monitoring;
- smoke tests after deployment.

### Git / source-control operations

- repository hygiene;
- branch conventions;
- worktree guidance;
- merge preparation;
- conflict detection/escalation;
- protected-branch rules where available;
- release tags where useful;
- change manifests;
- ensuring the org is not treated as source of truth.

### Salesforce CLI / deployment

- Salesforce CLI (`sf`) availability and version verification;
- non-production org authentication setup/runbook;
- metadata retrieve/deploy/validate operations;
- Apex test execution;
- deployment logs;
- package.xml/manifests where useful;
- destructive change safeguards;
- environment diagnostics;
- release validation;
- integration-org deployment;
- post-deploy smoke checks.

Probe MUST NOT:

- make a failing build green by weakening tests;
- bypass test failures without an explicit documented waiver approved by Helix;
- deploy unreviewed high-risk work merely because it compiles;
- authenticate to Production;
- commit credentials/auth URLs/private keys;
- resolve semantic merge conflicts by guessing intended business behavior.

Probe is the final operational gate before a build is called deployable. Helix remains the final architecture/product acceptance authority.

---

## 5.8 Fable — Escalation Specialist (On Demand Only)

**Primary mission:** Resolve exceptional blockers or difficult decisions that the normal team cannot safely settle.

Fable is NOT part of the normal sequential implementation flow. Helix invokes Fable only when one or more of the following are true:

- a critical architectural decision has multiple plausible solutions with major trade-offs;
- a blocker persists after reasonable attempts by the owning specialist;
- two specialists disagree on a high-impact design and Helix wants an independent analysis;
- Salesforce platform limits force redesign of a major capability;
- an integration/security/performance decision has unusually high risk;
- repeated deployments/tests fail without a clear root cause;
- a requirement is materially ambiguous and choosing incorrectly would invalidate substantial work;
- Helix needs a second-opinion design review before a major irreversible change.

### Fable invocation contract

Helix MUST send Fable:

```text
ESCALATION ID:
BUSINESS CONTEXT:
CURRENT DESIGN:
BLOCKER / DECISION:
OPTIONS ALREADY CONSIDERED:
EVIDENCE / ERRORS:
CONSTRAINTS:
AFFECTED METADATA / CODE:
RISK IF WRONG:
QUESTION TO RESOLVE:
```

Fable returns:

```text
ASSESSMENT:
ROOT CAUSE OR DECISION FRAME:
RECOMMENDED OPTION:
ALTERNATIVES:
TRADE-OFFS:
IMPLEMENTATION IMPACT:
TEST / VALIDATION IMPACT:
RISKS:
CONFIDENCE:
```

Helix decides whether to adopt the recommendation and records a material decision as an ADR when appropriate.

---

# 6. DELIVERY ARCHITECTURE

```text
                         HELIX
                Coordination / Architecture
                            |
        +-----------+-------+-------+-----------+-----------+
        |           |               |           |           |
      FORGE       KERNEL          PIXEL       BRIDGE      PULSE       PROBE
   Declarative      Apex            LWC     Integrations   Data &      QA
    Metadata                                              Performance  Deploy
                                                                       sf CLI
                                                                         Git
                            |
                            v
                          FABLE
                   escalation on difficult
                  decision/blocker via Helix
```

The diagram represents **ownership**, not a rigid waterfall. Helix may run multiple specialist tasks in parallel once shared contracts are stable.

## 6.1 Normal feature flow

```text
Requirement / Change Request
          |
        Helix
          |
Architecture + task boundaries
          |
  +-------+--------+---------+---------+------+
  |                |         |         |      |
Schema            Kernel    Pixel     Bridge  Pulse
  |                |         |         |      |
  +----------------+---------+---------+------+
                         |
                       Probe
                QA + Git + sf CLI gate
                         |
                       Helix
                  acceptance decision
                         |
             Developer / Integration Org
```

## 6.2 Escalation flow

```text
Specialist blocker
      |
    Helix
      |
Can Helix resolve safely?
  |              |
 YES             NO
  |              |
normal flow    Fable
                 |
          recommendation
                 |
              Helix
                 |
            ADR / decision
                 |
           specialist resumes
```

## 6.3 Ownership rule

An agent may edit another domain only when:

1. Helix explicitly assigns the cross-domain change; or
2. the edit is a minimal compile/test repair required by the assigned task and is documented in the completion report.

Shared contracts — object fields, Apex DTOs, integration schemas, permission model, core Custom Metadata and reusable LWC APIs — require Helix awareness before breaking changes.

---

# 7. SOURCE CONTROL AND ENVIRONMENT STRATEGY

## 7.1 Repository

One Salesforce DX-format Git repository.

Recommended structure:

```text
northstar-salesforce/
├── force-app/
│   └── main/
│       └── default/
├── config/
├── data/
├── docs/
│   ├── architecture/
│   ├── adr/
│   ├── integrations/
│   ├── testing/
│   └── runbooks/
├── scripts/
│   ├── apex/
│   ├── data/
│   └── shell/
├── manifest/
├── sfdx-project.json
├── README.md
└── NORTHSTAR_SALESFORCE_MASTER_SCOPE.md
```

## 7.2 Branch strategy — MAIN ONLY

**All work happens on `main`. No agent creates branches or worktrees.**

Reason: with a single squad and frequent commits, parallel branches create more confusion than isolation, and make it harder for the owner to follow progress.

What still applies:

- Never commit a broken project. If it is broken, fix it before committing.
- Validate before integrating (`sf project deploy validate`).
- Commit per completed and validated unit of work, not once a day.
- Descriptive commit messages with task ID, per section 65.
- Push regularly so progress is visible from outside.
- Never force push.

## 7.3 Environments — ONE ORG

There is exactly one org: a **Salesforce Developer Edition**, already authenticated through the `sf` CLI.

- No scratch orgs.
- No separate integration org.
- No QA org.

Deploy goes straight to that org, always preceded by validation:

```bash
sf project deploy validate --source-dir force-app --test-level RunLocalTests
sf project deploy start --source-dir force-app
```

Validation exists because a deploy that fails halfway leaves the org inconsistent.

## 7.4 Authentication

Use secure Salesforce CLI authentication. Authentication material MUST NOT be committed.

---

# 8. SALESFORCE APPLICATION STRUCTURE

Create a Lightning app:

**Northstar Revenue Operations**

Navigation should expose, according to permission:

- Home;
- Leads;
- Accounts;
- Contacts;
- Opportunities;
- Products;
- Price Books;
- Quotes / Commercial Proposals;
- Orders;
- Contracts;
- Sales Quotas;
- Discount Requests;
- Partner Deals;
- Cases;
- Integration Monitor;
- Reports;
- Dashboards;
- Admin Configuration.

---

# 9. DATA MODEL

## 9.1 Standard objects

Use where appropriate:

- Account
- Contact
- Lead
- Opportunity
- OpportunityLineItem
- Product2
- Pricebook2
- PricebookEntry
- Order
- OrderItem
- Contract
- Case
- User
- Task
- Event
- ContentDocument / Files

Quotes may use the available standard Quote model if enabled/suitable; otherwise implement a clearly documented prototype custom quote model.

## 9.2 Account additions

Suggested fields:

- `Customer_Segment__c` — Picklist: SMB, Mid-Market, Enterprise, Strategic.
- `Customer_Tier__c` — Picklist: Bronze, Silver, Gold, Platinum.
- `ERP_Customer_Id__c` — Text, External ID, Unique.
- `Credit_Status__c` — Picklist: Unknown, Approved, Review, Blocked.
- `Credit_Limit__c` — Currency.
- `Current_Exposure__c` — Currency.
- `Primary_Territory_Code__c` — Text.
- `Channel_Type__c` — Direct, Partner, Hybrid.
- `Strategic_Account__c` — Checkbox.
- `Last_ERP_Sync__c` — Datetime.

## 9.3 Opportunity additions

Suggested fields:

- `Gross_Margin_Amount__c`
- `Gross_Margin_Percent__c`
- `Total_Discount_Percent__c`
- `Pricing_Status__c`
- `Deal_Desk_Status__c`
- `Credit_Check_Status__c`
- `Inventory_Check_Status__c`
- `Competitor_Primary__c`
- `Loss_Reason__c`
- `Next_Step_Date__c`
- `Partner_Sourced__c`
- `Partner_Deal__c`
- `Quote_Version__c`
- `External_Order_Id__c`

## 9.4 Sales_Quota__c

Purpose: store assigned quota.

Fields:

- Name / generated quota number.
- `Owner_User__c` — Lookup User.
- `Manager_User__c` — Lookup User.
- `Territory_Code__c` — Text.
- `Product_Family__c` — optional Picklist/Text.
- `Period_Type__c` — Month / Quarter / Year.
- `Period_Start__c` — Date.
- `Period_End__c` — Date.
- `Quota_Amount__c` — Currency.
- `CurrencyIsoCode` if multicurrency enabled.
- `Status__c` — Draft / Active / Closed.
- `Version__c` — Number.
- `Source__c` — Manual / Import / Generated.

Uniqueness must prevent accidental duplicate active quotas for the same user/period/dimension.

## 9.5 Quota_Attainment__c

Purpose: materialized/summary attainment where useful.

Fields:

- `Sales_Quota__c` — Master-detail/Lookup.
- `User__c`.
- `Period_Start__c`.
- `Won_Revenue__c`.
- `Open_Pipeline__c`.
- `Commit_Amount__c`.
- `Best_Case_Amount__c`.
- `Attainment_Percent__c`.
- `Gap_To_Quota__c`.
- `Last_Calculated__c`.

Architecture may choose calculated-on-read versus materialized summaries, but the decision MUST be documented.

## 9.6 Territory_Assignment__c

Fields:

- `Territory_Code__c`.
- `Territory_Name__c`.
- `Region__c`.
- `State__c`.
- `Customer_Segment__c`.
- `Product_Family__c` optional.
- `Assigned_User__c`.
- `Manager_User__c`.
- `Priority__c`.
- `Effective_From__c`.
- `Effective_To__c`.
- `Active__c`.

## 9.7 Pricing_Rule__c

Prefer Custom Metadata if rules are deployment-time configuration; use custom objects if runtime business users need record-based administration. Architect decides and documents.

Required conceptual fields:

- rule code;
- active flag;
- customer tier;
- segment;
- product family;
- minimum quantity;
- maximum quantity;
- discount percent;
- effective dates;
- priority;
- stacking behavior.

## 9.8 Margin_Policy__c

Fields/concepts:

- product family;
- customer segment;
- minimum gross margin percent;
- manager approval threshold;
- director approval threshold;
- Deal Desk threshold;
- effective dates.

## 9.9 Discount_Request__c

Fields:

- `Opportunity__c`.
- `Requested_By__c`.
- `Requested_Discount__c`.
- `Policy_Discount__c`.
- `Current_Margin_Percent__c`.
- `Requested_Margin_Percent__c`.
- `Reason__c`.
- `Status__c` — Draft, Submitted, Manager Review, Deal Desk Review, Director Review, Approved, Rejected, Changes Requested, Cancelled.
- `Current_Approver__c`.
- `Submitted_At__c`.
- `Decision_At__c`.
- `Decision_Notes__c`.
- `Approval_Level__c`.

## 9.10 Inventory_Snapshot__c

Fields:

- Product lookup/external product id.
- Warehouse code.
- Available quantity.
- Reserved quantity.
- Expected replenishment date.
- Source timestamp.
- Last synchronized datetime.

## 9.11 Credit_Status__c

Fields:

- Account.
- External reference.
- Status.
- Credit limit.
- Exposure.
- Available credit.
- Reason code.
- Source timestamp.

## 9.12 ERP_Sync_Log__c

Fields:

- correlation id;
- entity type;
- Salesforce record id;
- external id;
- direction;
- operation;
- status;
- attempt count;
- HTTP status;
- request summary;
- response summary;
- error category;
- error message;
- first attempted;
- last attempted;
- next retry;
- completed at.

Do NOT persist secrets. Avoid uncontrolled storage of sensitive payloads.

## 9.13 Integration_Error__c

Stores normalized errors requiring operational attention.

## 9.14 Partner_Deal__c

Fields:

- Partner Account.
- Customer Account / Prospect.
- Opportunity.
- Registration date.
- Expiration date.
- Estimated value.
- Product family.
- Status.
- Conflict status.
- Approved by.
- Attribution percent.

## 9.15 Competitor__c / Opportunity_Competitor__c

Provide structured competitor tracking.

## 9.16 Freight_Rule__c

Configuration for simulated freight calculation based on region, weight/value bands, or warehouse.

---

# 10. LEAD MANAGEMENT

## 10.1 Lead sources

Support:

- Website;
- Partner;
- Referral;
- Outbound;
- Event;
- Existing Customer;
- Imported List;
- API.

## 10.2 Lead scoring

Prototype score 0–100 based on configurable criteria such as:

- company size;
- requested product family;
- estimated purchase value;
- strategic region;
- customer type;
- engagement.

Score bands:

- 0–29 Low;
- 30–59 Medium;
- 60–79 High;
- 80–100 Priority.

## 10.3 Routing

Routing considers:

1. state/region;
2. segment;
3. product specialization where configured;
4. active territory assignment;
5. representative availability/capacity if implemented;
6. fallback queue.

Must provide deterministic fallback behavior.

## 10.4 SLA

Track:

- assignment datetime;
- first activity datetime;
- qualification datetime;
- conversion datetime.

High-priority leads should produce visible SLA alerts.

## 10.5 Conversion

On conversion:

- deduplicate against Account/Contact;
- create or reuse Account;
- create Contact;
- create Opportunity when qualified;
- preserve source and attribution fields.

---

# 11. CUSTOMER 360

Account pages should expose:

- account summary;
- hierarchy;
- contacts;
- open opportunities;
- won revenue;
- contracts;
- renewal opportunities;
- open cases;
- credit status;
- recent orders;
- partner relationship;
- activities;
- integration sync state.

Strategic accounts should be visually identifiable.

---

# 12. TERRITORY MANAGEMENT

The prototype does not require Salesforce Enterprise Territory Management if unavailable. A custom territory assignment engine is acceptable.

Rules MUST support:

- region/state;
- segment;
- optional product family;
- priority;
- effective dates;
- fallback.

When account territory changes, define whether owner changes automatically or requires review. The architecture decision MUST be documented.

Provide a reassignment batch/job for mass recalculation.

---

# 13. QUOTA MANAGEMENT

## 13.1 Dimensions

Quota can be assigned by:

- user;
- manager/team;
- territory;
- product family;
- month;
- quarter;
- year.

Minimum MVP implementation MUST support user + period. Additional dimensions should be included for the big-project prototype.

## 13.2 Quota lifecycle

Draft -> Active -> Closed.

Activated quota values should not silently change. Changes require versioning/auditable update.

## 13.3 Attainment

Primary attainment formula:

```text
Attainment % = Eligible Closed Won Revenue / Active Quota Amount * 100
```

Gap:

```text
Gap to Quota = Quota Amount - Eligible Closed Won Revenue
```

Coverage:

```text
Pipeline Coverage = Eligible Open Pipeline / Gap to Quota
```

Handle zero/negative denominators safely.

## 13.4 Eligibility

Revenue eligibility should consider:

- Close Date in quota period;
- Stage = Closed Won;
- owner/crediting user;
- optional territory/product dimension;
- cancellation/reversal handling.

## 13.5 Recalculation triggers

Recalculate when relevant opportunity values change, but avoid expensive synchronous aggregate work. Use async/materialized patterns if necessary.

Provide:

- incremental recalculation;
- scheduled full reconciliation;
- admin manual recalculation action.

## 13.6 Quota Cockpit

LWC should show:

- quota amount;
- won revenue;
- attainment %;
- remaining gap;
- open pipeline;
- commit;
- best case;
- coverage;
- trend;
- drill-down opportunities;
- optional product-family breakdown.

---

# 14. OPPORTUNITY MANAGEMENT

## 14.1 Proposed stages

1. Discovery — 10%.
2. Qualification — 20%.
3. Solution Fit — 35%.
4. Pricing — 50%.
5. Proposal — 65%.
6. Negotiation — 80%.
7. Verbal Commit — 90%.
8. Closed Won — 100%.
9. Closed Lost — 0%.

## 14.2 Required controls

Stage progression may require:

- amount;
- close date;
- primary contact;
- products before Pricing;
- next step;
- loss reason for Closed Lost;
- approved pricing before Closed Won;
- acceptable credit status before order creation.

## 14.3 Forecast categories

Map stages to:

- Pipeline;
- Best Case;
- Commit;
- Closed;
- Omitted where appropriate.

## 14.4 Stalled deals

Flag opportunities with:

- no activity for configurable days;
- overdue next step;
- close date repeatedly pushed;
- approval pending beyond SLA.

---

# 15. PRODUCT CATALOG

Products include:

- SKU/external product id;
- name;
- family;
- subfamily;
- active flag;
- unit of measure;
- standard cost (simulation);
- weight/volume optional;
- service/physical type;
- maintenance eligibility;
- ERP sync metadata.

Create realistic product families such as:

- Industrial Pumps;
- Motors;
- Compressors;
- Valves;
- Replacement Parts;
- Safety Equipment;
- Maintenance Plans.

Seed enough products to demonstrate search/filter/pricing.

---

# 16. PRICING ENGINE

## 16.1 Inputs

Pricing may use:

- product;
- price book;
- quantity;
- customer tier;
- segment;
- territory;
- product family;
- strategic account status;
- contract price;
- active promotions/rules;
- freight;
- standard cost.

## 16.2 Outputs

Per line:

- list unit price;
- base unit price;
- policy discount;
- requested discount;
- final unit price;
- extended amount;
- estimated cost;
- gross margin amount;
- gross margin percent;
- policy status.

## 16.3 Example tier policy

Seed example policies, e.g.:

- Bronze: up to 3% standard discount.
- Silver: up to 6%.
- Gold: up to 10%.
- Platinum: up to 15%.

These are prototype configuration, not hard-coded business truth.

## 16.4 Volume discount example

Example bands:

- 1–9: 0%.
- 10–49: 2%.
- 50–99: 4%.
- 100+: 6%.

## 16.5 Margin protection

A line/deal violating minimum margin MUST be visibly flagged and may require approval regardless of discount percentage.

## 16.6 Pricing service

Create a clearly defined pricing application service with deterministic inputs/outputs. Avoid embedding pricing logic directly inside LWC controllers/triggers.

---

# 17. DEAL DESK AND APPROVALS

## 17.1 Approval decision inputs

- requested discount;
- permitted discount;
- resulting margin;
- minimum margin;
- opportunity amount;
- strategic account status;
- rep/manager authority;
- exception reason.

## 17.2 Example approval matrix

Prototype example:

- within policy: no approval;
- <= 5 percentage points beyond standard policy and margin safe: Sales Manager;
- larger exception or margin near floor: Regional Director;
- margin below policy floor or strategic exception: Deal Desk;
- extreme exception: Deal Desk + Director.

Configuration should drive thresholds.

## 17.3 Approval behavior

Submission locks relevant commercial values or prevents silent modification.

If commercial terms change materially after approval, prior approval must become invalid/reapproval required.

## 17.4 Deal Desk Console LWC

Show:

- queue;
- age/SLA;
- customer;
- opportunity;
- value;
- list price;
- requested price;
- discount;
- gross margin;
- policy thresholds;
- approval history;
- reason;
- Approve / Reject / Request Changes actions.

---

# 18. QUOTE / COMMERCIAL PROPOSAL

Support:

- quote number;
- opportunity;
- account/contact;
- version;
- status;
- validity date;
- line items;
- commercial terms;
- approved discount;
- freight;
- total;
- approval reference;
- document generation strategy if practical.

Lifecycle:

Draft -> Pricing -> Approval Required -> Approved -> Presented -> Accepted / Rejected / Expired / Superseded.

Creating a new version must preserve prior versions.

Only approved/current commercial terms may be used for order conversion.

---

# 19. ORDER MANAGEMENT

When an eligible opportunity/quote is accepted:

1. validate pricing approval;
2. validate credit;
3. validate required stock behavior;
4. create Order;
5. create OrderItems;
6. assign correlation id;
7. enqueue ERP submission;
8. store integration state;
9. display order status.

Statuses may include:

- Draft;
- Pending Submission;
- Submitted;
- Accepted by ERP;
- Processing;
- Partially Fulfilled;
- Fulfilled;
- On Hold;
- Cancelled;
- Integration Error.

---

# 20. ERP INTEGRATION

## 20.1 Simulated operations

- customer synchronization;
- product synchronization;
- order creation;
- order status update.

## 20.2 Requirements

- typed DTOs;
- correlation ids;
- idempotency strategy;
- normalized error handling;
- timeout handling;
- retry eligibility;
- maximum retry count;
- operational logs;
- deterministic test mocks.

## 20.3 Order create sample conceptual payload

```json
{
  "correlationId": "uuid",
  "customerExternalId": "ERP-100023",
  "salesforceOrderId": "...",
  "currency": "BRL",
  "lines": [
    {
      "sku": "PUMP-100",
      "quantity": 10,
      "unitPrice": 1250.00
    }
  ]
}
```

Do not bind implementation to this exact payload if architecture documents a better contract.

---

# 21. INVENTORY INTEGRATION

Provide inventory lookup by SKU/product and optionally warehouse.

Response should support:

- available quantity;
- reserved quantity;
- availability status;
- replenishment date;
- source timestamp.

Opportunity Workspace must surface stock status.

Implement graceful behavior when inventory service is unavailable.

---

# 22. CREDIT INTEGRATION

Credit service returns:

- Approved / Review / Blocked;
- credit limit;
- exposure;
- available credit;
- reason code;
- timestamp.

Order submission MUST be blocked when policy says credit is blocked, unless an explicit approved override mechanism exists.

---

# 23. CONTRACTS AND RENEWALS

Support maintenance/service contracts.

Fields/concepts:

- account;
- start/end date;
- contract value;
- product/service family;
- renewal notice period;
- auto-renew flag;
- renewal owner;
- status.

Scheduled automation should create renewal opportunities N days before expiration, configurable (example: 90 days).

Avoid duplicate renewal opportunity creation.

---

# 24. PARTNER SALES

## 24.1 Deal registration

Partner can register a deal with:

- target customer;
- estimated amount;
- products/family;
- expected close date;
- description.

## 24.2 Conflict detection

Detect possible conflict with:

- existing open direct opportunity;
- another active partner registration;
- existing strategic-account restriction.

## 24.3 Attribution

Approved partner deals can link to opportunity and preserve partner-source attribution.

---

# 25. CUSTOMER PORTAL PROTOTYPE

If Experience Cloud is available, create a lightweight authenticated prototype. Otherwise document and implement the closest available demo alternative.

Portal capabilities:

- My Account;
- My Orders;
- Order detail/status;
- My Contracts;
- Request a Quote;
- My Cases;
- Open a Case.

Portal users MUST only access authorized account data.

---

# 26. CASE MANAGEMENT

Basic customer support scenario:

- case number;
- account/contact;
- origin;
- type;
- priority;
- status;
- product/order reference;
- subject/description;
- owner queue/user;
- SLA indicators.

Cases are not the project's primary domain but should make Customer 360 credible.

---

# 27. LWC APPLICATIONS

## 27.1 Sales Command Center

Audience: Sales Rep.

Widgets:

- current quota;
- attainment gauge/progress;
- gap to quota;
- open pipeline;
- pipeline coverage;
- upcoming closes;
- stalled opportunities;
- approvals waiting;
- overdue tasks;
- renewal opportunities.

## 27.2 Opportunity Workspace

Single guided workspace containing:

- account summary;
- opportunity stage;
- contact roles summary;
- products;
- product search;
- pricing calculation;
- stock availability;
- credit state;
- margin indicators;
- approval state;
- quote state;
- activity/next-step prompts.

## 27.3 Quota Cockpit

Audience: rep/manager.

Features:

- period selector;
- quota amount;
- actual;
- attainment;
- gap;
- pipeline coverage;
- forecast categories;
- trend;
- drill-down table;
- team view for managers.

## 27.4 Deal Desk Console

Defined in section 17.

## 27.5 Manager Forecast

Features:

- rep rollup;
- quota versus actual;
- pipeline;
- commit;
- best case;
- coverage;
- stalled deals;
- changes since prior snapshot where practical.

## 27.6 Integration Monitor

Features:

- filters by system/status/entity/date;
- failures first;
- attempt count;
- correlation id;
- error detail;
- eligible Retry action;
- link to Salesforce source record.

## 27.7 Shared LWC requirements

All substantial LWCs MUST implement:

- loading state;
- empty state;
- user-friendly error state;
- toast/feedback where appropriate;
- refresh behavior;
- permission-aware actions;
- reusable modules/helpers where justified;
- no hard-coded record IDs;
- basic accessibility labels.

---

# 28. AUTOMATION STRATEGY

Use the appropriate Salesforce mechanism:

- validation rules for simple synchronous field constraints;
- Flow for declarative orchestration when maintainable;
- Apex for complex transactional/business logic;
- Queueable for asynchronous callout/work;
- Batch for large recalculations;
- Scheduled Apex/Flow for periodic jobs;
- Platform Events only where they improve the prototype meaningfully.

Avoid implementing the same business rule independently in multiple layers.

---

# 29. APEX ARCHITECTURE

Recommended conceptual layers:

```text
Trigger
  -> Handler
     -> Domain/Application Service
        -> Selector/Repository
        -> Integration Service
        -> Utility/Policy services
```

Exact framework is architect-owned. Do not introduce excessive abstraction solely to imitate enterprise patterns.

## 29.1 Trigger rules

- one logical trigger entry point per object where possible;
- no SOQL in loops;
- no DML in loops;
- recursion/re-entry handled deliberately;
- bulk operations supported;
- trigger delegates business logic.

## 29.2 Service classes

Expected services may include:

- `LeadRoutingService`
- `TerritoryAssignmentService`
- `QuotaService`
- `QuotaRecalculationService`
- `OpportunityPolicyService`
- `PricingService`
- `MarginPolicyService`
- `DealDeskService`
- `QuoteService`
- `OrderService`
- `RenewalService`
- `PartnerDealService`
- `InventoryService`
- `CreditService`
- `ErpOrderService`
- `IntegrationRetryService`

Names may change, but responsibilities must remain clear.

## 29.3 Async jobs

Potential jobs:

- quota reconciliation batch;
- territory reassignment batch;
- renewal generation scheduler;
- ERP order submission queueable;
- integration retry queueable/scheduler;
- product/customer sync jobs.

---

# 30. SECURITY MODEL

## 30.1 Principles

- least privilege;
- deny by default for sensitive actions;
- separate business personas;
- sharing-aware code where appropriate;
- explicit CRUD/FLS consideration;
- no security through UI hiding alone.

## 30.2 Permission sets — PERSONAS WITH 2 LICENSES

The org has **2 Salesforce licenses** (section 1.5). Do NOT create one real user per persona; it is impossible.

The personas in section 4 are implemented as **permission sets**:

- `NDG_Sales_Rep`
- `NDG_Sales_Manager`
- `NDG_Regional_Director`
- `NDG_Deal_Desk`
- `NDG_RevOps`
- `NDG_Integration_Admin`
- `NDG_Executive_ReadOnly`
- `NDG_Salesforce_Admin_Extended`

`NDG_Portal_User` is deferred with the customer portal (section 2.2).

How each persona is exercised:

- **Permission tests:** `System.runAs()` with users created inside the test. Test users do not consume licenses.
- **Live demonstration:** assign and unassign permission sets on the same user to show each persona's view.

Permission tests are mandatory, not optional. A permission model that is never tested is a permission model that does not work.

## 30.3 Sharing

Proposed baseline:

- Accounts/Opportunities private or controlled to demonstrate real sharing.
- Managers access subordinate/team data.
- Territory/criteria sharing where appropriate.
- Deal Desk gets required opportunity/discount request visibility.
- Executives read aggregated/business data.
- Portal strictly account-scoped.

Helix must document final OWD and sharing rationale, with Schema implementing the approved metadata.

## 30.4 Sensitive fields

Credit and margin-related fields may need restricted edit access.

---

# 31. VALIDATION RULES / BUSINESS GUARDS

At minimum implement/test rules such as:

- Closed Lost requires Loss Reason.
- Closed Won requires approved/current pricing state.
- Close Date required.
- Quote cannot be accepted after expiration.
- Active quota must have valid period and positive amount.
- Discount Request requires reason when outside policy.
- Order cannot submit without external customer id or documented fallback.
- Contract end date must be after start date.
- Partner deal expiration must be after registration.

Some guards may be Apex instead of Validation Rules if cross-record logic requires it.

---

# 32. REPORTING AND DASHBOARDS

## 32.1 Sales Rep Dashboard

- personal quota attainment;
- won revenue;
- open pipeline;
- pipeline coverage;
- deals closing this month;
- stalled deals;
- overdue activities;
- renewals.

## 32.2 Sales Manager Dashboard

- team quota attainment;
- attainment by rep;
- pipeline by stage;
- forecast category;
- pipeline coverage;
- average deal size;
- win rate;
- stalled deals;
- discount exception rate.

## 32.3 RevOps Dashboard

- quota allocation coverage;
- pipeline hygiene;
- pricing exceptions;
- margin leakage;
- approval SLA;
- lead routing SLA;
- territory exceptions.

## 32.4 Executive Dashboard

- bookings/won revenue;
- quota attainment;
- pipeline;
- forecast;
- win rate;
- margin;
- revenue by region;
- revenue by product family;
- partner contribution;
- renewal pipeline.

## 32.5 Integration Dashboard

- calls by status;
- errors by system;
- retry backlog;
- average retry count;
- oldest unresolved error.

---

# 33. SEED DATA — BINDING BUDGET

Synthetic data only. **This budget is mandatory, not a suggestion.** The org has ~4.65 MB free, which fits roughly 2,380 records in total across all objects (section 1.5).

| Object | Records | Note |
|---|---|---|
| Account | 120 | covering enterprise, SMB, strategic and partner segments |
| Contact | 240 | ~2 per account |
| Lead | 120 | spread across qualification stages |
| Product2 | 150 | equipment, spare parts, consumables, services |
| PricebookEntry | 300 | across 2 price books |
| Opportunity | 180 | spread across the funnel |
| OpportunityLineItem | 350 | |
| Quote + QuoteLineItem | 80 | |
| Order + OrderItem | 80 | |
| **Approximate total** | **~1,620** | leaves ~750 records of headroom |

The headroom is deliberate: Apex tests create records, and `RunLocalTests` creates and deletes data on every deploy.

## 33.1 Rules

- The seed MUST be **repeatable and idempotent**. Running it twice must not duplicate anything.
- A cleanup script MUST exist that returns the org to an empty state.
- **Never use real personal data.** All names, emails, phones and documents are fictional and generated.
- Configuration data (pricing policies, discount tiers, approval rules) does **not** go into these objects. It goes into **Custom Metadata**, which does not consume data storage.
- Integration logs do **not** go into these objects. They go into **Big Objects**.
- Before any large load, Pulse checks available storage.

## 33.2 Storage monitoring

Probe checks storage usage before every release and records it in the release evidence package (section 68).

**If usage exceeds 70%, stop loading and report to Helix.**

---

# 34. TEST STRATEGY

## 34.1 Quality target

- Salesforce deployment minimum coverage is not the project quality target.
- Target project coverage: **>= 85%**, while emphasizing meaningful assertions.
- Critical business services should target stronger behavioral coverage.

## 34.2 Apex tests

Tests MUST cover:

- positive path;
- negative path;
- bulk path;
- missing configuration;
- boundary values;
- permission-sensitive behavior where testable;
- callout success/failure/timeouts through mocks;
- idempotency/retry behavior;
- quota recalculation;
- pricing thresholds;
- approval invalidation;
- renewal duplicate prevention.

## 34.3 Bulk tests

Important services must be exercised with record collections, not only one-record tests.

Examples:

- 200 leads routed;
- 200 opportunities updated;
- many opportunity line items priced;
- batch quota reconciliation;
- integration queue behavior.

## 34.4 LWC tests

Where Jest tooling is practical, test:

- rendering;
- loading;
- error states;
- key user actions;
- permission/action visibility;
- data transformation helpers.

If Jest is omitted due to environment constraints, document the reason and provide manual/functional validation evidence.

## 34.5 Acceptance regression

Probe maintains a regression matrix mapping FR IDs to test evidence and deployment evidence.

---

# 35. NON-FUNCTIONAL REQUIREMENTS

## 35.1 Performance

- No SOQL/DML in loops.
- Bulk-safe triggers.
- Avoid loading unbounded datasets into LWC.
- Pagination/lazy loading for large lists.
- Select only required fields.
- Async operations for expensive/non-transactional work.
- Avoid synchronous external dependency for unrelated saves.

## 35.2 Reliability

- Integration retries are bounded.
- Idempotent operations where duplication would be harmful.
- Errors are observable.
- User-facing errors are understandable.

## 35.3 Maintainability

- cohesive classes/components;
- documented public service contracts;
- configurable rules;
- no unexplained magic constants;
- consistent naming;
- ADRs for major decisions.

## 35.4 Auditability

Important commercial decisions should preserve:

- who requested;
- who approved/rejected;
- when;
- relevant values;
- status history where practical.

---

# 36. INTEGRATION ERROR AND RETRY MODEL

Error categories:

- Validation;
- Authentication;
- Authorization;
- Timeout;
- Rate Limit;
- External Server Error;
- Mapping;
- Duplicate/Idempotency;
- Unknown.

Retry rules example:

- timeout: retry;
- 429/rate limit: retry later;
- 5xx: retry;
- validation 4xx: no automatic retry;
- authentication: no blind retry; flag admin;
- duplicate/idempotent success: normalize appropriately.

Retry must have maximum attempts and avoid infinite loops.

---

# 37. OBSERVABILITY

Every external operation should have enough information to answer:

- what operation occurred?
- which Salesforce record caused it?
- what external system?
- correlation id?
- when?
- successful or failed?
- error category?
- how many attempts?
- can it be retried?
- what was the final external id/status?

---

# 38. DOCUMENTATION DELIVERABLES

The repository MUST contain:

1. `README.md` — project setup and overview.
2. Master scope (this document).
3. Architecture overview.
4. Data dictionary.
5. Security model.
6. Integration contracts.
7. ADRs.
8. Test strategy.
9. Deployment/runbook.
10. Seed-data instructions.
11. Demo script.
12. Known limitations.
13. Change log.

---

# 39. ARCHITECTURE DECISION RECORDS

At minimum create ADRs for:

- ADR-001: Source control/environment strategy.
- ADR-002: Trigger/application architecture.
- ADR-003: Quota attainment calculation strategy.
- ADR-004: Pricing configuration model.
- ADR-005: Approval implementation approach.
- ADR-006: Integration and retry architecture.
- ADR-007: Territory assignment strategy.
- ADR-008: Quote implementation (standard vs custom prototype).
- ADR-009: Portal approach.
- ADR-010: Security/sharing model.

---

# 40. EPIC BACKLOG

## EPIC 01 — Org Foundation & Source Control

Deliver:

- Salesforce DX project;
- Git conventions;
- README;
- environment config;
- base Lightning app;
- initial package/manifest strategy;
- CI-style validation scripts.

Acceptance:

- fresh authorized org can receive base deployment;
- tests command documented;
- no secrets in repository.

## EPIC 02 — Identity, Security & Sharing

Deliver personas, permission sets, OWD/sharing design, access tests.

## EPIC 03 — Customer 360

Deliver Account/Contact model, account UI, hierarchy, segmentation, dedupe strategy.

## EPIC 04 — Lead Management

Deliver scoring, routing, SLA tracking, conversion rules.

## EPIC 05 — Territory Management

Deliver assignment model, engine, recalculation and admin visibility.

## EPIC 06 — Quota Management

Deliver quota model, allocation, attainment calculation, reconciliation and cockpit.

## EPIC 07 — Opportunity & Forecasting

Deliver stages, controls, forecast fields/views, stalled-deal detection.

## EPIC 08 — Product & Catalog

Deliver product metadata, price books, seed data, external ids.

## EPIC 09 — Pricing Engine

Deliver pricing service, tier/volume policies, margin calculation, test suite.

## EPIC 10 — Deal Desk

Deliver exception model, approval logic, approval console, SLA tracking.

## EPIC 11 — Quotes & Orders

Deliver quote/version lifecycle, order conversion, order status model.

## EPIC 12 — ERP Integration

Deliver customer/product/order integration simulation and observability.

## EPIC 13 — Inventory & Credit

Deliver simulated services, UI visibility, business blocking behavior.

## EPIC 14 — Contracts & Renewals

Deliver contract fields, renewal scheduler and renewal opportunity generation.

## EPIC 15 — Partner Sales

Deliver partner deal registration, conflict checks and attribution.

## EPIC 16 — Customer Portal

Deliver authenticated self-service prototype where org capability permits.

## EPIC 17 — Analytics

Deliver report folders, reports and dashboards by persona.

## EPIC 18 — Observability

Deliver integration monitor, logs, error normalization, retries.

## EPIC 19 — Automated Test Program

Deliver regression matrix, bulk tests, integration mocks, coverage evidence.

## EPIC 20 — Release & Demo

Deliver integrated deployment, seed dataset, demo script, acceptance report.

---

# 41. REQUIREMENTS TRACEABILITY

Every story/task should reference:

- Epic ID;
- Functional Requirement ID where applicable;
- owner agent;
- impacted metadata/classes/components;
- test evidence;
- review status;
- deployment status.

Recommended task header:

```text
Task ID:
Epic:
Requirement:
Owner:
Dependencies:
Acceptance Criteria:
Files/Metadata:
Tests Required:
Security Impact:
Integration Impact:
Documentation Impact:
```

---

# 42. DEFINITION OF READY

A task is ready when:

- requirement is understandable;
- acceptance criteria exist;
- dependencies identified;
- architecture questions resolved or explicitly delegated;
- test expectations known;
- target metadata ownership is clear enough to avoid collisions.

---

# 43. DEFINITION OF DONE

A feature is DONE only when:

1. implementation is committed;
2. metadata compiles/deploys;
3. automated tests pass;
4. targeted acceptance tests pass;
5. bulk behavior is validated where relevant;
6. security reviewed;
7. Helix architecture review and Probe QA/release review passed or findings resolved;
8. documentation updated;
9. no known critical defect remains;
10. integration deployment succeeds;
11. requirement traceability updated.

Code generation alone is NOT completion.

---

# 44. CODE REVIEW GATE

The review gate is split between **Helix** (architecture/business correctness) and **Probe** (quality, regression and deployability). Together they MUST check:

- correctness;
- naming;
- class/component cohesion;
- unnecessary complexity;
- governor-limit safety;
- bulkification;
- SOQL selectivity;
- CRUD/FLS;
- sharing;
- injection risks;
- secrets;
- hard-coded IDs;
- error handling;
- test quality;
- negative tests;
- integration idempotency;
- documentation impact.

Review result:

- APPROVED;
- APPROVED WITH NON-BLOCKING NOTES;
- CHANGES REQUIRED.

---

# 45. SALESFORCE CLI DELIVERY COMMANDS

Exact flags may vary by CLI version, but Probe should provide working equivalents for:

```bash
sf org list
sf project deploy validate
sf project deploy start
sf project retrieve start
sf apex run test
sf data query
sf data import tree
```

Release scripts SHOULD wrap repetitive commands.

---

# 46. RELEASE GATES

Before integration deploy:

- working tree clean/expected;
- branch reviewed;
- validation deployment passes;
- required Apex tests pass;
- no unresolved blocking review finding;
- permission metadata included;
- configuration included;
- documentation updated.

Before final demo:

- full target test suite passes;
- seed data loaded;
- demo users/personas configured;
- integration mocks available;
- dashboards populated;
- demo script rehearsable;
- known limitations documented.

---

# 47. DEMO SCENARIO A — COMPLETE LEAD TO ORDER

1. New high-value lead arrives.
2. Lead scoring marks it Priority.
3. Routing assigns correct territory rep.
4. Rep converts lead.
5. Opportunity created.
6. Rep adds products.
7. Inventory is checked.
8. Credit is checked.
9. Pricing engine applies tier and volume discount.
10. Rep requests extra discount.
11. Deal Desk workflow starts.
12. Manager/Deal Desk approves.
13. Quote version becomes approved.
14. Customer accepts.
15. Opportunity becomes Closed Won.
16. Order is created.
17. ERP integration succeeds.
18. Quota attainment increases.
19. Manager dashboard updates.
20. Order appears in customer portal.

---

# 48. DEMO SCENARIO B — FAILED INTEGRATION AND SELF-RECOVERY

1. Order is submitted.
2. Mock ERP returns 500/timeout.
3. Integration log is created.
4. Order shows Integration Error/Pending Retry.
5. Retry policy schedules another attempt.
6. Integration Monitor displays error.
7. Mock ERP succeeds on retry.
8. Log changes to success.
9. External order id is persisted.
10. Order status updates.

This scenario is important for demonstrating agent-built operational maturity.

---

# 49. DEMO SCENARIO C — QUOTA AND FORECAST

1. Rep begins quarter at 62% attainment.
2. Open pipeline is visible by forecast category.
3. Manager sees team coverage.
4. A large deal closes.
5. Attainment recalculates.
6. Rep crosses target.
7. Dashboard/Quota Cockpit reflects result.

---

# 50. DEMO SCENARIO D — CHANGE REQUEST FOR AGENT TEAM

After baseline completion, issue this change request to demonstrate maintenance:

> Strategic Accounts may receive an additional 3% discretionary discount when annual account revenue exceeds R$5M, but the resulting gross margin may not fall below the configured strategic margin floor. If the extra discount exceeds 2%, manager approval is required even when total pricing remains within the normal tier threshold.

Expected agent behavior:

1. Helix analyzes requirement and edge cases.
2. Helix determines impacted architecture/configuration and assigns affected domains.
3. Helix decomposes work and establishes dependency/merge order.
4. Kernel changes pricing/approval logic.
5. Pixel exposes new policy explanation in Opportunity Workspace.
6. Probe adds regression/boundary tests.
7. Helix performs architecture/business review; Probe performs QA/release review.
8. Probe validates/deploys through Salesforce CLI and records evidence.
9. Existing functionality remains green.

This is the recommended live demonstration of multi-agent Salesforce maintenance.

---

# 51. FUNCTIONAL REQUIREMENT CATALOG

- **FR-001** Capture leads from manual/API sources.
- **FR-002** Score leads.
- **FR-003** Route leads by business rules.
- **FR-004** Track lead SLA.
- **FR-005** Convert leads with dedupe awareness.
- **FR-006** Maintain Customer 360.
- **FR-007** Assign territories.
- **FR-008** Recalculate territory assignments.
- **FR-009** Create/manage quotas.
- **FR-010** Calculate quota attainment.
- **FR-011** Calculate pipeline coverage.
- **FR-012** Manage opportunity stages.
- **FR-013** Forecast pipeline.
- **FR-014** Detect stalled opportunities.
- **FR-015** Manage product catalog.
- **FR-016** Manage price books.
- **FR-017** Calculate customer-tier discounts.
- **FR-018** Calculate volume discounts.
- **FR-019** Calculate gross margin.
- **FR-020** Enforce margin policy.
- **FR-021** Create discount requests.
- **FR-022** Route approval by threshold.
- **FR-023** Invalidate approval after material term change.
- **FR-024** Version quotes.
- **FR-025** Convert approved quote/deal to order.
- **FR-026** Submit order to ERP.
- **FR-027** Query inventory.
- **FR-028** Query credit.
- **FR-029** Block orders for credit policy violations.
- **FR-030** Retry eligible integrations.
- **FR-031** Monitor integration errors.
- **FR-032** Manage contracts.
- **FR-033** Generate renewal opportunities.
- **FR-034** Register partner deals.
- **FR-035** Detect partner conflicts.
- **FR-036** Attribute partner-sourced opportunities.
- **FR-037** Expose customer orders in portal.
- **FR-038** Allow portal case creation.
- **FR-039** Provide sales dashboard.
- **FR-040** Provide manager dashboard.
- **FR-041** Provide executive dashboard.
- **FR-042** Provide RevOps dashboard.
- **FR-043** Provide integration dashboard.
- **FR-044** Enforce persona permissions.
- **FR-045** Provide auditable approval history.
- **FR-046** Support realistic synthetic seed data.
- **FR-047** Support repeatable CLI deployment.
- **FR-048** Provide automated regression tests.
- **FR-049** Provide end-to-end demo scripts.
- **FR-050** Support post-MVP change requests without architectural rewrite.

---

# 52. TECHNICAL ACCEPTANCE CRITERIA

The final prototype is accepted when:

- source deploys to target org;
- core metadata is reproducible;
- no Production access is needed;
- lead-to-order scenario works;
- quota calculations work;
- pricing policies work;
- Deal Desk approval works;
- order integration mock works;
- failure/retry scenario works;
- renewal creation works;
- partner registration works;
- persona security works;
- six or more substantial LWC experiences/components are present across the solution;
- dashboards/reports have meaningful demo data;
- automated tests meet agreed quality target;
- major bulk scenarios pass;
- no blocker from Helix architecture review or Probe QA/release review remains;
- docs are complete enough for a new agent to continue development;
- final deployment/test evidence is preserved.

---

# 53. KNOWN PROTOTYPE LIMITATIONS

The team MUST maintain a living limitations document. Expected limitations may include:

- simulated rather than real ERP;
- simplified tax/freight calculation;
- limited portal branding;
- simplified quote PDF generation;
- no production-scale 25k-product load in Developer Org if org limits make it impractical;
- no paid CPQ dependency;
- licensing constraints around test users/features.

Limitations must be explicit, not hidden.

---

# 54. PROJECT SUCCESS METRICS

The prototype should demonstrate:

### Engineering

- parallel agent contributions;
- successful source integration;
- repeatable deployments;
- automated tests;
- review gates;
- low metadata collision rate;
- documented architecture.

### Salesforce

- credible enterprise data model;
- real Apex business logic;
- meaningful LWCs;
- configuration-driven policies;
- integrations;
- security;
- analytics;
- governor-limit awareness.

### Agentic delivery

- agents receive requirements rather than exact code instructions;
- coordinator delegates work;
- specialists produce artifacts;
- QA finds defects;
- developers repair defects;
- reviewer blocks weak code when appropriate;
- DevOps deploys only validated work;
- team can handle a later change request.

---

# 55. MILESTONE LADDER — THE BINDING PLAN

Work advances through this ladder, **in order**. Each milestone MUST leave the org working and the deploy passing before the next one starts. Do not stack broken work.

| # | Deliverable | Validation |
|---|---|---|
| **M0** | sfdx project structure, git on `main`, `.gitignore`, initial docs, empty deploy validated | `sf project deploy validate` passes |
| **M1** | Data model: objects, fields, relationships, permission sets | metadata in the repo and in the org |
| **M2** | Repeatable seed data within the section 33 budget | runs twice without duplicating; storage below 50% |
| **M3** | Lead: capture, scoring, routing, conversion | a lead becomes Account, Contact and Opportunity |
| **M4** | Opportunity pipeline with products and price book | a full opportunity can be assembled |
| **M5** | **Custom Metadata pricing engine** | changing a pricing rule requires no Apex change |
| **M6** | Discount and margin controls | over-limit discount is blocked with a clear message |
| **M7** | Deal Desk approvals | full request, approve and reject flow |
| **M8** | Quote and Order | a closed opportunity produces an order |
| **M9** | ERP, inventory and credit simulation with mocks | success, failure and retry all tested |
| **M10** | Big Object observability plus Integration Monitor LWC | an integration error is visible and reprocessable |
| **M11** | Reports and dashboards | three views: rep, manager, executive |
| **M12** | Test hardening and release evidence package | coverage above 85%, evidence per section 68 |
| **M13** | CR-DEMO-001 demonstration from section 69.2 | end-to-end policy change with every agent participating |

Go as far as you can. **Delivering through M8 flawlessly beats delivering all thirteen half-broken.**

## 55.1 Single progress metric

One number, defined once, always the same ruler:

```
milestones completed and validated
──────────────────────────────────
                13
```

This number **only goes up**. Never report two rulers in the same message. Never report progress inside a milestone as if it were progress on the project. If asked about a milestone, say explicitly that it is about that milestone.

Record each milestone closure in `docs/PROGRESSO.md`.

---

# 56. INITIAL TASK QUEUE FOR HELIX

Helix begins with M0 and works down the ladder in section 55. Within M0 and M1, this order:

1. Clone the repository and verify org access with `sf org display`.
2. Confirm org limits: storage, licenses, API calls. Record them in `docs/AMBIENTE.md`.
3. Initialize and validate the Salesforce DX project.
4. Save this specification into the repository and commit it on `main`.
5. Write ADR-001 with the high-level architecture before any parallel implementation.
6. Define the object model, including what lives in Custom Metadata versus custom objects versus Big Objects.
7. Define the OWD, persona and permission-set plan.
8. Assign Schema to build the foundation metadata from the approved architecture.
9. Have Probe establish the git and `sf` CLI validation and deploy commands early.
10. Build the deterministic, idempotent seed-data framework within the section 33 budget.

Helix converts the FR catalog into prioritized agent tasks with acceptance criteria as each milestone approaches, not all at once up front.

---

# 57. AGENT COMMUNICATION CONTRACT

Each agent completion report should contain:

```text
TASK:
STATUS:
SUMMARY:
FILES/METADATA CHANGED:
TESTS EXECUTED:
RESULTS:
DEPENDENCIES/ASSUMPTIONS:
SECURITY IMPACT:
KNOWN LIMITATIONS:
FOLLOW-UP TASKS:
READY FOR REVIEW: YES/NO
```

Agents should communicate blockers early rather than silently changing scope.

---

# 58. CHANGE MANAGEMENT

Any material scope change should produce:

- Change Request ID;
- business reason;
- impacted requirements;
- impacted architecture;
- data migration implications;
- security implications;
- test implications;
- estimated task decomposition;
- approval by Helix or the appropriate human controller.

Do not silently reinterpret major business requirements.

---

# 59. SAFETY / OPERATIONAL GUARDRAILS

Agents MUST NOT:

- authenticate to Production;
- execute destructive changes against unknown orgs;
- commit auth URLs/tokens/passwords/private keys;
- disable tests to force deployment;
- weaken sharing/security merely to make tests pass;
- mass-delete org data without explicit scoped task;
- overwrite `main` history;
- bypass Probe validation or Helix acceptance for critical changes;
- fabricate test/deployment success.

Any command capable of destructive metadata/data change should be scoped and reviewed.

---

# 60. FINAL PRESENTATION NARRATIVE

The finished demonstration should communicate:

> Northstar is a fictional enterprise Salesforce implementation delivered by a coordinated OpenClaw agent team. Rather than one model generating isolated code, specialized agents perform architecture/coordination, declarative metadata, Apex development, LWC development, integrations, data/performance engineering, QA, Git operations and Salesforce CLI deployment. Git is the source of truth and Salesforce CLI provides a deterministic feedback loop for deployment and testing. The system demonstrates a realistic lead-to-order operation with quotas, forecasting, pricing, approvals, orders, external integrations, renewals, partner sales, portal capabilities, analytics, security, and operational monitoring. A post-build change request is then assigned to the same team to prove that the agents can maintain and evolve an existing Salesforce implementation.

---

# 61. COMPLETION CHECKLIST

- [ ] Repository initialized and protected.
- [ ] Salesforce CLI authenticated to dedicated non-production org.
- [ ] Architecture documented.
- [ ] Data model deployed.
- [ ] Security model deployed.
- [ ] Customer 360 complete.
- [ ] Lead scoring/routing complete.
- [ ] Territory engine complete.
- [ ] Quota management complete.
- [ ] Quota Cockpit complete.
- [ ] Opportunity lifecycle complete.
- [ ] Forecasting complete.
- [ ] Product catalog complete.
- [ ] Pricing engine complete.
- [ ] Margin controls complete.
- [ ] Deal Desk complete.
- [ ] Quote lifecycle complete.
- [ ] Order lifecycle complete.
- [ ] ERP mock integration complete.
- [ ] Inventory integration complete.
- [ ] Credit integration complete.
- [ ] Retry/observability complete.
- [ ] Contracts complete.
- [ ] Renewals complete.
- [ ] Partner sales complete.
- [ ] Customer portal prototype complete or limitation documented.
- [ ] Case visibility complete.
- [ ] Sales Command Center complete.
- [ ] Opportunity Workspace complete.
- [ ] Manager Forecast complete.
- [ ] Integration Monitor complete.
- [ ] Reports complete.
- [ ] Dashboards complete.
- [ ] Synthetic seed data loaded.
- [ ] Automated test suite passes.
- [ ] Bulk tests pass.
- [ ] Security review passes.
- [ ] Code review passes.
- [ ] CLI validation deployment passes.
- [ ] Full integration deploy passes.
- [ ] Demo Scenario A passes.
- [ ] Demo Scenario B passes.
- [ ] Demo Scenario C passes.
- [ ] Change Request demo passes.
- [ ] Documentation complete.
- [ ] Known limitations documented.
- [ ] Final acceptance report generated.

---


# 62. CANONICAL AGENT OWNERSHIP MATRIX

This matrix is the default routing model Helix SHOULD use. It does not prevent collaboration, but each row has one primary owner.

| Capability / artifact | Primary owner | Required collaborators | Final gate |
|---|---|---|---|
| Epic/task decomposition | Helix | relevant specialists | Helix |
| Architecture / ADR | Helix | specialist affected by ADR; Fable only if escalated | Helix |
| Custom objects / fields | Schema | Helix, Pulse | Probe deploy + Helix acceptance |
| Record types / layouts / Lightning pages | Schema | Pixel, Helix | Probe |
| Validation rules / formulas | Schema | Kernel when rule overlaps server logic | Probe |
| Flows / subflows | Schema | Kernel, Helix | Probe |
| Permission sets / declarative security metadata | Schema | Helix | Probe + Helix |
| Custom Metadata model | Schema | Helix, Kernel | Probe |
| Apex triggers/services | Kernel | Schema, Pulse | Probe + Helix |
| Async Apex | Kernel | Bridge/Pulse as applicable | Probe |
| LWC | Pixel | Kernel, Schema | Probe + Helix acceptance for major UX |
| External integration contracts | Bridge | Helix, Kernel | Probe + Helix |
| Callout mocks | Bridge | Probe | Probe |
| Seed data | Pulse | Schema, Kernel | Probe |
| Performance/query analysis | Pulse | Kernel, Bridge | Helix |
| Regression suite | Probe | all implementers | Probe |
| Git operations | Probe | all agents | Probe |
| sf CLI deployment | Probe | Helix | Probe + Helix go/no-go |
| Escalated blocker | Fable | Helix + affected agents | Helix |

---

# 63. AGENT TASK PROTOCOL

Every implementation task created by Helix SHOULD use this structure:

```text
TASK ID:
EPIC:
TITLE:
OWNER:
COLLABORATORS:
BUSINESS PURPOSE:
IN SCOPE:
OUT OF SCOPE:
DEPENDENCIES:
METADATA / CODE LIKELY AFFECTED:
ACCEPTANCE CRITERIA:
REQUIRED TESTS:
SECURITY CONSIDERATIONS:
PERFORMANCE CONSIDERATIONS:
INTEGRATION CONSIDERATIONS:
DEMO IMPACT:
DOCUMENTATION REQUIRED:
MERGE / DEPLOY ORDER:
```

## 63.1 Task completion protocol

Every specialist completion must return:

```text
TASK ID:
STATUS: COMPLETE | BLOCKED | PARTIAL
SUMMARY:
FILES / METADATA CHANGED:
NEW PUBLIC CONTRACTS:
BREAKING CHANGES: YES/NO
TESTS EXECUTED:
TEST RESULTS:
COVERAGE IMPACT:
SECURITY IMPACT:
PERFORMANCE IMPACT:
DATA IMPACT:
KNOWN LIMITATIONS:
BLOCKERS:
FOLLOW-UP TASKS:
READY FOR PROBE: YES/NO
```

## 63.2 Blocker protocol

A specialist MUST mark the task BLOCKED rather than silently changing scope when:

- required org capability is unavailable;
- shared schema would need a breaking change;
- security requirements conflict with implementation assumptions;
- Salesforce limits invalidate the selected approach;
- external contract is undefined;
- another branch owns the same metadata and conflict cannot be safely resolved;
- test failure indicates ambiguous expected behavior.

Helix either resolves the issue or escalates it to Fable.

---

# 64. PARALLEL EXECUTION AND METADATA COLLISION RULES

Salesforce metadata can create high-conflict files. The squad MUST actively prevent concurrent edits to the same metadata.

## 64.1 High-collision metadata

Treat the following as coordination-sensitive:

- the same CustomObject metadata file;
- the same permission set;
- the same Flow;
- the same Lightning page;
- the same Experience bundle;
- the same Custom Metadata record;
- the same Apex class;
- the same LWC bundle;
- the same report/dashboard folder artifacts;
- shared labels/translations if used;
- `package.xml` / destructive manifests;
- `sfdx-project.json`.

## 64.2 Metadata lock convention

For large parallel work, Helix may maintain `docs/coordination/METADATA_LOCKS.md`:

```text
OWNER | TASK | METADATA | STARTED | EXPECTED RELEASE
Schema | NS-143 | Sales_Quota__c | ... | ...
Pixel | NS-151 | opportunityWorkspace | ... | ...
```

Locks are coordination signals, not permanent ownership.

## 64.3 Merge principle

- semantic correctness is more important than line-level conflict resolution;
- the agent owning the shared contract should resolve or approve semantic conflicts;
- Probe may perform mechanical Git conflict resolution only when intent is unambiguous;
- Helix decides disputed behavior;
- Fable may be invoked if the conflict reveals a deeper architectural issue.

---

# 65. WORK ON MAIN — LIFECYCLE AND COMMITS

**All work happens on `main`. No branches, no worktrees.** This supersedes any branch pattern described elsewhere.

## 65.1 Task lifecycle

1. Helix creates and assigns the task.
2. The assigned agent implements only its assigned scope.
3. The agent runs its own local validations.
4. The agent reports back to Helix with what it produced.
5. Helix resolves architecture and business questions.
6. Probe runs `sf project deploy validate` against the org.
7. Probe commits to `main` and pushes.
8. Probe deploys to the Developer Org.
9. Probe records release evidence per section 68.

**Probe is the only agent that commits, pushes and deploys.** Other agents produce files and report; Probe integrates. This exists because a deploy is the only destructive action in the flow, and a gate only works if there is exactly one.

If Probe is blocked, work does NOT pass to another agent to deploy in its place. Probe reports to Helix, who escalates. A failed deploy needs diagnosis, not a retry by whoever has less context.

## 65.2 Commit convention

```text
feat(NS-143): add quarterly pricing tier metadata
fix(NS-188): prevent duplicate ERP order submission
perf(NS-205): optimize price lookup query
test(NS-211): add discount approval boundary regression
```

## 65.3 Metadata collision

Since everyone works on `main`, the collision rules in section 64 matter more, not less. Helix sequences tasks so that two agents never edit the same high-collision metadata at the same time.

---

# 66. FEATURE-TO-AGENT DELIVERY MAP

## 66.1 Customer 360

**Schema**
- Account/Contact metadata;
- segmentation fields;
- record types;
- duplicate-rule supporting metadata where applicable;
- Lightning pages;
- validation/formula configuration.

**Kernel**
- non-trivial account hierarchy/assignment logic if declarative tools are insufficient.

**Pulse**
- seed account/contact volume;
- duplicate scenarios;
- high-volume query review.

**Pixel**
- custom customer summary UI only if standard pages are insufficient.

**Probe**
- permission/regression/deployment validation.

## 66.2 Lead Management

**Schema**: lead fields, status, assignment-support metadata, flows where appropriate.  
**Kernel**: complex scoring/routing logic if selected by Helix.  
**Pulse**: routing-volume/performance scenarios.  
**Probe**: conversion, ownership and negative tests.

## 66.3 Territory Management

**Helix**: territory ownership design and sharing implications.  
**Schema**: territory-related metadata/configuration.  
**Kernel**: assignment engine if custom logic is required.  
**Pulse**: bulk reassignment/load scenarios.  
**Probe**: visibility and ownership tests.

## 66.4 Quotas / Attainment

**Schema**
- `Sales_Quota__c` and related metadata;
- quota-period configuration;
- Custom Metadata for policy values;
- declarative administration screens where practical.

**Kernel**
- quota attainment service;
- scheduled/recalculation jobs;
- rollup logic that cannot be safely declarative;
- recalculation API used by admin tooling.

**Pulse**
- aggregate-query design;
- historical quota volume;
- performance analysis.

**Pixel**
- Quota Cockpit;
- rep/manager drill-down.

**Probe**
- attainment math;
- boundary dates;
- manager hierarchy;
- bulk Closed Won updates;
- deployment validation.

## 66.5 Opportunity / Forecasting

**Schema**: stages, fields, validation, Lightning page metadata, configurable thresholds.  
**Kernel**: complex forecast support calculations and at-risk rules.  
**Pixel**: Opportunity Workspace and Manager Forecast.  
**Pulse**: pipeline query efficiency and data realism.  
**Probe**: stage transitions, persona access and regression.

## 66.6 Product / Pricing / Deal Desk

**Helix** owns the policy architecture and separation of configuration from execution.

**Schema**
- product-support metadata;
- pricing rule Custom Metadata;
- margin-policy configuration;
- approval configuration;
- Deal Desk record metadata.

**Kernel**
- pricing engine;
- discount evaluation;
- margin evaluation;
- approval-routing support services;
- pricing tests.

**Pixel**
- pricing portion of Opportunity Workspace;
- Deal Desk Console;
- policy explanations and decision feedback.

**Pulse**
- 25k-SKU query strategy;
- pricing-data volume analysis.

**Probe**
- pricing matrix regression;
- boundary values;
- unauthorized override tests;
- deployment gate.

## 66.7 Quotes / Orders

**Schema**: quote/order metadata, statuses, declarative validations.  
**Kernel**: conversion/business services.  
**Bridge**: outbound ERP contract.  
**Pixel**: quote/order UI enhancements if needed.  
**Probe**: end-to-end close-to-order regression.

## 66.8 ERP / Inventory / Credit

**Bridge** is primary owner.  
**Kernel** owns async Apex mechanics shared with Bridge when necessary.  
**Pulse** reviews log/data volume.  
**Pixel** owns user-facing integration state.  
**Probe** owns deterministic success/failure/retry validation.

## 66.9 Contracts / Renewals

**Schema**: metadata, schedules/flows where appropriate.  
**Kernel**: renewal generation if complex/bulk logic requires Apex.  
**Pixel**: renewal visibility components if required.  
**Probe**: date-boundary/idempotency regression.

## 66.10 Partner Sales

**Helix**: partner sharing/security architecture.  
**Schema**: partner/deal registration metadata.  
**Kernel**: conflict-detection rules if complex.  
**Pixel**: registration/visibility UI if custom UX is required.  
**Probe**: cross-partner data isolation tests.

## 66.11 Customer Portal

**Helix**: external-user security architecture.  
**Schema**: Experience/declarative metadata supported by org.  
**Pixel**: custom portal components.  
**Kernel**: server controllers and secure query boundaries.  
**Probe**: external-user isolation and feature regression.

## 66.12 Analytics / Observability

**Schema**: reports/dashboards and metadata-driven monitoring assets.  
**Bridge**: integration statuses/error semantics.  
**Pulse**: data shape/volume.  
**Pixel**: Integration Monitor LWC.  
**Probe**: evidence that failures/retries are visible and reproducible.

---

# 67. HELIX ARCHITECTURE CHECKLIST BEFORE MAJOR EPICS

Before a major epic enters implementation, Helix SHOULD answer:

- What business outcome does this epic provide?
- What are the authoritative Salesforce records?
- What objects/fields are new or changed?
- Is the change declarative, Apex, LWC, integration, or mixed?
- Which agent owns each artifact?
- What records are expected at realistic scale?
- What is the transaction boundary?
- What is synchronous versus asynchronous?
- What sharing/security rules apply?
- Is CRUD/FLS handling required in Apex?
- What happens on retry?
- What makes the operation idempotent?
- What errors are user-facing versus admin-facing?
- What Custom Metadata should control behavior?
- What metrics/logs prove the feature works?
- What tests prove success, failure, bulk and permission behavior?
- What metadata is collision-sensitive?
- What is the merge/deploy order?
- Is an ADR required?
- Does Fable need to be consulted before implementation?

---

# 68. PROBE RELEASE EVIDENCE PACKAGE

For every milestone release, Probe SHOULD produce a folder such as:

```text
docs/releases/R01/
├── release-summary.md
├── manifest.md
├── test-results.md
├── coverage-summary.md
├── deployment-result.md
├── known-limitations.md
└── smoke-test.md
```

Minimum release evidence:

- source commit SHA;
- branch/tag;
- target org alias (non-secret);
- validation/deployment command used;
- deployment result;
- Apex tests executed;
- failed tests, if any;
- coverage summary where available;
- smoke-test result;
- known limitations;
- rollback/recovery notes when applicable;
- Helix go/no-go decision for milestone releases.

No agent may claim that a feature is deployed merely because local files were created.

---

# 69. DEMONSTRATION OF THE AGENT TEAM ITSELF

The final presentation SHOULD visibly prove the responsibilities of the new squad.

## 69.1 Suggested live demonstration sequence

1. Human gives Helix a change request.
2. Helix explains architecture impact and creates specialist tasks.
3. Schema changes declarative metadata/configuration.
4. Kernel implements server-side logic.
5. Pixel implements the UI change.
6. Bridge participates if the request touches ERP/inventory/credit.
7. Pulse reviews query/data/performance implications.
8. Probe runs tests, Git integration and Salesforce CLI validation/deployment.
9. If a purposely difficult conflict is introduced, Helix escalates to Fable and records the resulting decision.
10. Salesforce UI is opened to demonstrate the working business outcome.
11. Git history, test results and deployment evidence are shown alongside the org.

## 69.2 Recommended demonstration change request

**CR-DEMO-001 — Strategic Account Expansion Policy**

Business request:

> Strategic accounts with annual revenue above R$50M may receive up to 18% discount without director approval only when gross margin remains at or above 24%. Between 18% and 25% discount, Regional Director approval is mandatory. Below 24% projected gross margin, Deal Desk approval is mandatory regardless of discount. The Opportunity Workspace must explain which policy was triggered, and the policy must be configurable without changing Apex.

Expected routing:

- Helix: architecture/task breakdown;
- Schema: new Custom Metadata records/fields/approval configuration;
- Kernel: pricing-policy evaluation changes;
- Pixel: policy explanation UI;
- Pulse: query/config lookup review;
- Probe: regression/boundary/security tests + Git + `sf` deploy;
- Fable: only if Helix intentionally introduces an architectural ambiguity or blocker for demonstration.

This change request is valuable because it touches configuration, Apex, UI, testing and deployment while remaining understandable to a non-technical audience.

---

# 70. FINAL TEAM-SPECIFIC COMPLETION CHECKLIST

## Helix
- [ ] Every epic has an owner and dependencies.
- [ ] Architecture is documented.
- [ ] Security model is documented.
- [ ] Shared contracts are documented.
- [ ] Material decisions have ADRs.
- [ ] No unresolved high-impact blocker remains.
- [ ] Fable escalations, if any, are recorded.

## Schema
- [ ] Required objects/fields/relationships exist in source control.
- [ ] Declarative automation is documented and non-recursive.
- [ ] Validation/formulas are covered by regression scenarios.
- [ ] Permission/configuration metadata is source-controlled.
- [ ] Mutable policy is configurable where required.

## Kernel
- [ ] Apex is bulk-safe.
- [ ] No SOQL/DML-in-loop defects remain.
- [ ] Controllers are thin.
- [ ] Async jobs are idempotent where required.
- [ ] Core Apex has positive/negative/bulk tests.

## Pixel
- [ ] Major LWCs implement loading/error/empty states.
- [ ] UI respects permission/security assumptions.
- [ ] Components work against realistic seed data.
- [ ] Server-call patterns are efficient.

## Bridge
- [ ] Integration contracts are documented.
- [ ] No secrets are committed.
- [ ] Success/failure/retry paths exist.
- [ ] Idempotency/correlation behavior is implemented.
- [ ] Deterministic mocks are available.

## Pulse
- [ ] Seed data is repeatable.
- [ ] High-volume queries were reviewed.
- [ ] Performance risks are documented.
- [ ] Quota/pricing/integration-volume scenarios were evaluated.

## Probe
- [ ] Regression matrix is current.
- [ ] Permission and negative tests pass.
- [ ] Bulk tests pass.
- [ ] Salesforce CLI validation succeeds.
- [ ] Integration-org deploy succeeds.
- [ ] Smoke test succeeds.
- [ ] Git history is clean and traceable.
- [ ] Release evidence package exists.

## Fable
- [ ] Used only if escalation was necessary or intentionally demonstrated.
- [ ] Recommendation and trade-offs are documented.
- [ ] Helix recorded the final adopted decision.

---

# 71. START NOW

1. Clone the repository and save this file as `docs/MASTER_SCOPE.md`. Commit it on `main`.
2. Read it in full. Every agent reads it before producing anything.
3. Create `docs/DECISIONS.md`, `docs/PROGRESSO.md`, `docs/PENDENCIAS.md` and `docs/AMBIENTE.md`.
4. Helix: build the plan, distribute it across the squad, and start at M0.

Do not reply asking for confirmation. Start.

---

# END OF MASTER SPECIFICATION

**This is the only source of truth for this project.** There is no addendum, annex or companion document. If something is not in this file, it was not agreed.

Where an earlier version of this document conflicts with the sections corrected for Developer Edition (1.2, 1.5, 2, 7.2, 7.3, 30.2, 33, 55, 56, 65), the corrected sections win.

This specification still describes a project larger than a minimal Salesforce MVP, and deliberately so: its purpose is to exercise a reusable autonomous Salesforce engineering squad across enough domains to demonstrate coordination, specialization, platform feedback loops, enterprise architecture, quality controls and maintainability. Sections 2.2 and 55 define how much of it this execution actually delivers.
