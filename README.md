# Northstar — Salesforce Developer Edition

Enterprise Salesforce prototype built by a multi-agent AI engineering team, featuring Sales Cloud, quotas, forecasting, pricing, Deal Desk, integrations, LWC, Apex, analytics, security, automated testing and Salesforce CLI deployment.

> **Status:** early scaffolding. The data model and features are added here as they are designed and built.

## Project structure

- `force-app/main/default/` — all org metadata (objects, fields, Apex classes, LWC, flows, validation rules, permission sets).
- `sfdx-project.json` — Salesforce DX project configuration (API 62.0).

## Getting started

Prerequisite: [Salesforce CLI](https://developer.salesforce.com/tools/salesforcecli) (`sf`).

```bash
# authenticate against a Developer Edition org
sf org login web --alias northstar --set-default

# preview what will be deployed
sf project deploy preview

# deploy metadata to the org
sf project deploy start

# run Apex tests with coverage
sf apex run test --result-format human --code-coverage
```

## Data model

_Under construction — documented here as objects and relationships are created._

## Roadmap

- [ ] Core data model (Sales Cloud: quotas, forecasting, pricing, Deal Desk)
- [ ] Apex domain & service layer with a trigger framework
- [ ] Lightning Web Components
- [ ] Integrations (REST/SOAP, named credentials, platform events)
- [ ] Analytics & reporting
- [ ] Security model (profiles, permission sets, sharing)
- [ ] Automated tests & CLI-based deployment

## How it's built

Developed by an AI engineering squad, each agent owning a layer — declarative metadata, Apex, LWC, integrations, data-model & performance review, and testing/deployment. Architecture and data-model decisions are made deliberately up front: schema mistakes in Salesforce are expensive to reverse once data exists.

## License

TBD.
