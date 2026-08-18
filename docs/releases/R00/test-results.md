# R00 — Test Results

## 1. Testes na validação (`sf project deploy validate --test-level RunLocalTests`)

Comando: `sf project deploy report --job-id 0Affj00000NeZZiCAN --target-org helix-dev --coverage-formatters text`

```
0Affj00000NeZZiCAN... Succeeded

Deploy Info
┌──────────────────────────┬──────────────────────────┐
│ Key                      │ Value                    │
├──────────────────────────┼──────────────────────────┤
│ checkOnly                │ true                     │
│ completedDate            │ 2026-08-18T23:22:08.000Z │
│ createdBy                │ [redigido — dado pessoal]│
│ createdByName            │ [redigido — dado pessoal]│
│ createdDate               │ 2026-08-18T23:22:06.000Z │
│ done                     │ true                     │
│ id                       │ 0Affj00000NeZZiCAN       │
│ ignoreWarnings           │ false                    │
│ lastModifiedDate         │ 2026-08-18T23:22:08.000Z │
│ numberComponentErrors    │ 0                        │
│ numberComponentsDeployed │ 2                        │
│ numberComponentsTotal    │ 2                        │
│ numberFiles              │ 6                        │
│ numberTestErrors         │ 0                        │
│ numberTestsCompleted     │ 3                        │
│ numberTestsTotal         │ 3                        │
│ rollbackOnError          │ true                     │
│ runTestsEnabled          │ true                     │
│ startDate                │ 2026-08-18T23:22:07.000Z │
│ status                   │ Succeeded                │
│ success                  │ true                     │
│ zipSize                  │ 3651                     │
└──────────────────────────┴──────────────────────────┘

Test Results Summary
Passing: 3
Failing: 0
Total: 3
Time: 211
```

## 2. Smoke test pós-deploy (`sf apex run test --code-coverage --wait 20`)

Comando executado após o deploy real (`0Affj00000NeaHFCAZ`) ter sido aplicado à org:

```
sf apex run test --target-org helix-dev --result-format human --code-coverage --wait 20
```

Saída real:

```
=== Test Results
TEST NAME                                         OUTCOME  MESSAGE  RUNTIME (MS)
────────────────────────────────────────────────  ───────  ───────  ────────────
HttpCalloutServiceTest.testGet                    Pass              37
HttpCalloutServiceTest.testPostJson               Pass              6
HttpCalloutServiceTest.testSendSemHeadersNemBody  Pass              10

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
Test Run Id          707fj00000u0Wb1
Test Setup Time      0 ms
Test Execution Time  53 ms
Test Total Time      53 ms
Org Id               [redigido — ver alias helix-dev]
Username             [redigido — dado pessoal, ver alias helix-dev]
Org Wide Coverage    100%
```

## Falhas

Nenhuma. 0 falhas em ambas as execuções (validação e smoke test pós-deploy), 3/3 testes em cada
uma.
