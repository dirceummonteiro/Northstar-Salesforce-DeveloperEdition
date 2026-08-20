# R06 — Coverage Summary (consolidado do M1)

## Cobertura em todas as fatias do M1

```
=== Apex Code Coverage by Class
CLASSES             PERCENT  UNCOVERED LINES
──────────────────  ───────  ───────────────
HttpCalloutService  100%

Org Wide Coverage    100%
```

Idêntico em R01, R02, R03, R04 e na reconciliação R05 — nenhuma fatia mudou este número.

## Leitura

`HttpCalloutService`/`HttpCalloutServiceTest` continuam a única classe e o único teste do
projeto (D-006, mantido até o M9). Nenhuma fatia do M1 adicionou Apex: objetos, campos,
relacionamentos, Custom Metadata Types, Big Object e permission sets são todos metadata
declarativa, que não entra no cálculo de cobertura de código. O critério mínimo de deploy do
Salesforce (75% org-wide) permanece superado com folga, em 100%, do início ao fim do marco.

**Nenhum Apex de negócio foi escrito no M1** — é esperado, não uma lacuna: a lógica de negócio
(scoring de lead, motor de precificação, controles de desconto/margem, aprovações) começa no
M3, sobre o modelo de dados que este marco entrega.
