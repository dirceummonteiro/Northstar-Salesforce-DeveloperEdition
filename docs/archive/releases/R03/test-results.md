# R03 — Test Results

## 1. Validação (job `0Affj00000NipBFCAZ`, `--test-level RunLocalTests`)

```
status: 0
success: true
id: 0Affj00000NipBFCAZ
checkOnly: true
numberComponentErrors: 0
numberComponentsDeployed: 65
numberComponentsTotal: 65
numberTestErrors: 0
numberTestsCompleted: 3
runTestsEnabled: true
componentFailures: []
```

## 2. Deploy real (job `0Affj00000NipPlCAJ`, `--test-level RunLocalTests`)

```
status: 0
success: true
id: 0Affj00000NipPlCAJ
checkOnly: false
runTestsEnabled: true
numberComponentErrors: 0
numberComponentsDeployed: 65
numberTestErrors: 0
numberTestsCompleted: 3
completedDate: 2026-08-19T13:00:12.000Z
```

Diferente de R02 (que usou `deploy quick` sobre a validação), esta fatia rodou um deploy
completo com `RunLocalTests` próprio — decisão do Probe de exercitar a esteira de teste duas
vezes de forma independente, dado que a fatia introduz dois objetos custom novos e altera sete
permission sets. Nenhuma diferença de resultado entre as duas execuções: 3/3 testes, 0 falhas,
em ambas.

## 3. Smoke test pós-deploy (`sf apex run test --code-coverage --wait 20`)

Comando:

```
sf apex run test --target-org helix-dev --result-format human --code-coverage --wait 20
```

Saída real (Org Id e Username redigidos — ver alias `helix-dev`):

```
=== Test Results
TEST NAME                                         OUTCOME  MESSAGE  RUNTIME (MS)
────────────────────────────────────────────────  ───────  ───────  ────────────
HttpCalloutServiceTest.testGet                    Pass              30
HttpCalloutServiceTest.testPostJson               Pass              10
HttpCalloutServiceTest.testSendSemHeadersNemBody  Pass              7

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
Test Run Id          707fj00000u9XjR
Test Setup Time      0 ms
Test Execution Time  47 ms
Test Total Time      47 ms
Org Wide Coverage    100%
```

## Falhas

Nenhuma falha de teste Apex. 0 falhas em 3/3 testes, em todas as três execuções (validação,
deploy real, smoke test pós-deploy).

Nenhum teste Apex novo foi escrito nesta fatia: Custom Metadata Types e `Discount_Request__c`
são metadata declarativa e um objeto sem automação própria ainda — não há classe Apex, trigger
ou lógica de serviço para testar unitariamente até os motores de precificação/margem/frete e o
fluxo de aprovação (M5-M7) consumirem esses dados. A validação real desta fatia é declarativa:
os objetos e registros existem na org, os `ObjectPermissions`/`FieldPermissions` de
`Discount_Request__c` batem com o desenho por persona (ver `smoke-test.md`). Fica confirmado
como pendência de qualidade em `known-limitations.md`, mesma limitação (c) já registrada em R02:
permission tests `System.runAs()` continuam sem lógica de negócio para exercitar.
