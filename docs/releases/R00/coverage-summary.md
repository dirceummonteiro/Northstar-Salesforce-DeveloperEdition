# R00 — Coverage Summary

## Cobertura por classe (formato `text`, gerado em `coverage/coverage/text.txt` pela validação)

```
--------------------|---------|----------|---------|---------|-------------------
File                | % Stmts | % Branch | % Funcs | % Lines | Uncovered Line #s
--------------------|---------|----------|---------|---------|-------------------
All files           |     100 |      100 |     100 |     100 |
 HttpCalloutService |     100 |      100 |     100 |     100 |
--------------------|---------|----------|---------|---------|-------------------
```

## Cobertura confirmada no smoke test pós-deploy

```
=== Apex Code Coverage by Class
CLASSES             PERCENT  UNCOVERED LINES
──────────────────  ───────  ───────────────
HttpCalloutService  100%

Org Wide Coverage    100%
```

## Leitura

100% de cobertura org-wide, uma única classe testável (`HttpCalloutService`, coberta por
`HttpCalloutServiceTest`, D-006). O critério mínimo de deploy do Salesforce (75% org-wide) é
superado com folga. Não há classe sem teste associado neste marco.
