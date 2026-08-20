# R06 — Test Results (consolidado do M1)

## Resultado mais recente (reconciliação R05, deploy `0Affj00000NmNjRCAV`)

```
Test Results
CLASSES                 OUTCOME  MESSAGE  RUNTIME (MS)
──────────────────────  ───────  ───────  ────────────
HttpCalloutServiceTest  Pass              (ver docs/releases/R05/ para runtime exato)

Total Test Time: —
Passing: 3
Failing: 0
Skipped: 0
Pass Rate: 100%
```

`RunLocalTests` executou a mesma suíte (`HttpCalloutServiceTest`, 3 métodos de teste) em todos
os deploys completos do M1 (fatia 1, (a), (b)+(c) — completo próprio —, (d) — validação, e a
reconciliação R05 — completo próprio). Nos `deploy quick` que reaproveitaram validação anterior
(fatia 1, (a), (d) etapa de deploy real), os testes aparecem como reaproveitados
(`numberTestsCompleted: 0` na etapa de quick deploy, pelo desenho do Salesforce — não é teste
pulado, é teste já executado minutos antes na validação imediatamente anterior, dentro da
janela de reaproveitamento).

**0 falhas em qualquer execução de teste durante o M1 inteiro.**

## Por que não há teste novo para o conteúdo do M1

`§30.2` exige `System.runAs()` por persona (permission tests), mas essa exigência só é
exercitável quando há registro real e lógica de negócio para testar contra os 8 permission
sets. M1 é modelo de dados — a lógica de negócio (Apex) começa no M3. Esta é a limitação (c),
aberta desde R02 e reafirmada em R03/R04, e atravessa para o M2/M3 sem se resolver neste marco
— ver `known-limitations.md`.
