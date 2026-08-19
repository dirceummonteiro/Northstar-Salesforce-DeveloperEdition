# R01 — Test Results

## 1. Testes na validação reaproveitada (job `0Affj00000NeKUECA3`, produzido pelo Kernel)

Comando: `sf project deploy report --job-id 0Affj00000NeKUECA3 --target-org helix-dev`

```
0Affj00000NeKUECA3... Succeeded

Deploy Info
┌──────────────────────────┬──────────────────────────┐
│ Key                      │ Value                    │
├──────────────────────────┼──────────────────────────┤
│ checkOnly                │ true                     │
│ completedDate            │ 2026-08-19T00:49:04.000Z │
│ done                     │ true                     │
│ id                       │ 0Affj00000NeKUECA3       │
│ ignoreWarnings           │ false                    │
│ numberComponentErrors    │ 0                        │
│ numberComponentsDeployed │ 27                       │
│ numberComponentsTotal    │ 27                       │
│ numberFiles              │ 11                       │
│ numberTestErrors         │ 0                        │
│ numberTestsCompleted     │ 3                        │
│ numberTestsTotal         │ 3                        │
│ rollbackOnError          │ true                     │
│ runTestsEnabled          │ true                     │
│ status                   │ Succeeded                │
│ success                  │ true                     │
└──────────────────────────┴──────────────────────────┘

Test Results Summary
Passing: 3
Failing: 0
Total: 3
Time: 239
```

## 2. Deploy real aplicado por este release (job `0Affj00000Negp1CAB`)

`checkOnly: false`, `runTestsEnabled: false` — quick deploy reaproveitando os testes já
executados e aprovados no job acima (mesmo conteúdo de fonte, dentro da janela de reaproveitamento
do Salesforce). Não é bypass de teste (§59): os testes rodaram e passaram na validação do
Kernel, minutos antes.

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
HttpCalloutServiceTest.testGet                    Pass              29
HttpCalloutServiceTest.testPostJson               Pass              4
HttpCalloutServiceTest.testSendSemHeadersNemBody  Pass              4

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
Test Run Id          707fj00000u2Ll6
Test Setup Time      0 ms
Test Execution Time  37 ms
Test Total Time      37 ms
Org Wide Coverage    100%
```

`Org Id` e `Username` redigidos desta saída — ver alias `helix-dev`.

## Falhas

Nenhuma falha de teste Apex. 0 falhas em 3/3 testes, em ambas as etapas (validação reaproveitada
e smoke test pós-deploy).

Nenhum campo novo tem teste Apex dedicado nesta fatia porque nenhum é usado por lógica Apex
ainda — são campos declarativos puros (picklist, texto, fórmula, data, checkbox). O Kernel não
escreveu Apex nesta tarefa (D-010: ele cobriu apenas metadata declarativa). Cobertura de
regressão para estes campos entra quando alguma automação/serviço passar a usá-los.
