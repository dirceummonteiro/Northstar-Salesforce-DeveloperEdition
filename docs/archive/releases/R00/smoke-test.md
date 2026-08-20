# R00 — Smoke Test

## 1. Testes Apex pós-deploy

Comando:

```
sf apex run test --target-org helix-dev --result-format human --code-coverage --wait 20
```

Resultado real:

```
=== Test Results
TEST NAME                                         OUTCOME  MESSAGE  RUNTIME (MS)
────────────────────────────────────────────────  ───────  ───────  ────────────
HttpCalloutServiceTest.testGet                    Pass              37
HttpCalloutServiceTest.testPostJson               Pass              6
HttpCalloutServiceTest.testSendSemHeadersNemBody  Pass              10

=== Test Summary
NAME                 VALUE
───────────────────  ─────────────────────────────────────────────
Outcome              Passed
Tests Ran            3
Pass Rate            100%
Fail Rate            0%
Skip Rate            0%
Test Run Id          707fj00000u0Wb1
Org Wide Coverage    100%
```

## 2. Consulta de conectividade

Comando:

```
sf data query --query "SELECT Id, Name FROM Organization LIMIT 1" --target-org helix-dev --result-format human
```

Resultado real:

```
┌────────────────────────────────┬────────────┐
│ ID                             │ NAME       │
├────────────────────────────────┼────────────┤
│ [redigido — ver alias helix-dev] │ Salesforce │
└────────────────────────────────┴────────────┘

Total number of records retrieved: 1.
```

## Conclusão

Org sã e acessível após o deploy. Testes Apex passando 3/3 com 100% de cobertura. Consulta SOQL
simples confirma conectividade e resposta correta da API.
