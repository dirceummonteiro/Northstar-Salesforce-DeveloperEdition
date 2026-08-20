# R02 — Test Results

## 1. Validação (job `0Affj00000NhxUDCAZ`, `--test-level RunLocalTests`)

```
sf project deploy validate --source-dir force-app/main/default/permissionsets --test-level RunLocalTests --target-org helix-dev --json
```

```
status: 0
success: true
id: 0Affj00000NhxUDCAZ
checkOnly: true
numberComponentErrors: 0
numberComponentsDeployed: 8
numberComponentsTotal: 8
numberTestErrors: 0
numberTestsCompleted: 3
numberTestsTotal: 3
runTestsEnabled: true
componentFailures: []
```

## 2. Deploy real aplicado por este release (job `0Affj00000NhwRiCAJ`)

`checkOnly: false`, `runTestsEnabled: false` — quick deploy reaproveitando os testes já
executados e aprovados na validação acima (mesmo conteúdo de fonte, dentro da janela de
reaproveitamento do Salesforce). Não é bypass de teste (§59): os testes rodaram e passaram na
validação, segundos antes.

## 3. Smoke test pós-deploy (`sf apex run test --code-coverage --wait 20`)

Comando:

```
sf apex run test --target-org helix-dev --result-format human --code-coverage --wait 20
```

Saída real:

```
=== Test Results
TEST NAME                                         OUTCOME  MESSAGE  RUNTIME (MS)
────────────────────────────────────────────────  ───────  ───────  ────────────
HttpCalloutServiceTest.testGet                    Pass              178
HttpCalloutServiceTest.testPostJson               Pass              10
HttpCalloutServiceTest.testSendSemHeadersNemBody  Pass              8

=== Apex Code Coverage by Class
CLASSES             PERCENT  UNCOVERED LINES
──────────────────  ───────  ───────────────
HttpCalloutService  100%

=== Test Summary
NAME                 VALUE
───────────────────  ─────────────────────────────────────────────
Outcome              Passed
Tests Ran            3
Pass Rate            100%
Fail Rate            0%
Skip Rate            0%
Test Run Id          707fj00000u7Vti
Test Setup Time      0 ms
Test Execution Time  196 ms
Test Total Time      196 ms
Org Wide Coverage    100%
```

`Org Id` e `Username` redigidos desta saída — ver alias `helix-dev`.

## Falhas

Nenhuma falha de teste Apex. 0 falhas em 3/3 testes, em ambas as etapas (validação e smoke test
pós-deploy).

Nenhum teste Apex novo foi escrito nesta fatia porque permission set é metadata puramente
declarativa — não há classe Apex para testar unitariamente. A validação real deste release é
declarativa: os 8 permission sets existem na org e os 24 campos comerciais de R01 têm FLS
concedida por ao menos um deles (ver `smoke-test.md`), o que os testes `System.runAs()` por
persona (§30.2) vão exercitar quando a lógica de negócio que depende dessas permissões existir —
isso é escopo de marcos futuros, não desta fatia puramente de segurança declarativa.
