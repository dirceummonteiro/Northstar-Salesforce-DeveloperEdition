# R00 — Deployment Result

## Comando

```
./scripts/shell/deploy.sh
```

Que executa, com `ORG_ALIAS=helix-dev` (default do script):

```
sf project deploy validate --source-dir force-app --test-level RunLocalTests --target-org helix-dev
sf project deploy start --source-dir force-app --target-org helix-dev
```

## Etapa 1 — Validate (Deploy ID `0Affj00000NeZZiCAN`)

Status: **Succeeded**. `checkOnly: true`, `runTestsEnabled: true`, `test-level: RunLocalTests`.
`numberComponentErrors: 0`, `numberTestErrors: 0`, 3/3 testes. Detalhe completo em
`test-results.md`.

## Etapa 2 — Deploy real (Deploy ID `0Affj00000NeaHFCAZ`)

Status: **Succeeded**. `checkOnly: false`, `runTestsEnabled: false` — o Salesforce aplicou
**quick deploy**: como a validação anterior (etapa 1) foi feita com o mesmo conteúdo de fonte
minutos antes, a plataforma reaproveita o resultado de teste já validado em vez de rodar os
testes de novo. Isso é comportamento padrão do `sf project deploy start` quando existe uma
validação recente compatível — não é bypass de teste (a §59 do escopo proíbe desabilitar teste
para forçar deploy; aqui os testes rodaram e passaram na etapa 1, minutos antes, sobre o mesmo
código).

```
Deployed Source
┌───────────┬────────────────────────┬───────────┬────────────────────────────────────────────────────────────────────┐
│ State     │ Name                   │ Type      │ Path                                                               │
├───────────┼────────────────────────┼───────────┼────────────────────────────────────────────────────────────────────┤
│ Unchanged │ HttpCalloutService     │ ApexClass │ force-app/main/default/classes/HttpCalloutService.cls              │
│ Unchanged │ HttpCalloutService     │ ApexClass │ force-app/main/default/classes/HttpCalloutService.cls-meta.xml     │
│ Unchanged │ HttpCalloutServiceTest │ ApexClass │ force-app/main/default/classes/HttpCalloutServiceTest.cls          │
│ Unchanged │ HttpCalloutServiceTest │ ApexClass │ force-app/main/default/classes/HttpCalloutServiceTest.cls-meta.xml │
└───────────┴────────────────────────┴───────────┴────────────────────────────────────────────────────────────────────┘
```

`numberComponentErrors: 0`, `numberComponentsDeployed: 2`, `numberComponentsTotal: 2`,
`status: Succeeded`, `success: true`.

## Medição de limites — antes vs. depois

Baseline registrado em `docs/AMBIENTE.md` §2 (medido em 2026-08-18, org recém-criada):

| Recurso | Antes (`AMBIENTE.md` §2) | Depois (pós-deploy, `sf org list limits --target-org helix-dev`) | Variação |
|---|---|---|---|
| `DataStorageMB` | 0 MB em uso / 5 MB máx (0%) | 0 MB em uso / 5 MB máx (Remaining 5 / Max 5) | Nenhuma |
| `DailyApiRequests` | 239 em uso / 15.000 máx | 265 em uso / 15.000 máx (Remaining 14.735 / Max 15.000) | +26 chamadas |

A variação de API (+26) é consumida pelas próprias chamadas desta integração (validate, deploy,
report x2, apex test, data query, org list limits) — nenhuma delas grava dado, por isso
`DataStorageMB` não se move. Ambos os valores estão muito abaixo do limiar de 70% definido em
`AMBIENTE.md` §2 (`DailyApiRequests` em 1,8% de uso). Nenhuma ação de contenção necessária.

## Rollback / recuperação

Não aplicável — deploy bem-sucedido, sem erro de componente, sem falha de teste. Nenhuma ação de
rollback foi necessária.
