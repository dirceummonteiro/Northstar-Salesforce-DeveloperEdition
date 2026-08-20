# R01 — Release Summary (M1, fatia 1: campos comerciais + Quote padrão)

**O M1 não fecha neste release.** Esta é a primeira fatia de um marco maior (§55: objetos,
campos, relacionamentos **e** permission sets). `PROGRESSO.md` continua em **1 / 13**.

## Identificação

| Campo | Valor |
|---|---|
| Marco | M1, fatia 1 de N — campos de Account/Opportunity + habilitação do Quote padrão |
| Commit (metadata) | `b29e8e0af7051155d85800a189d6a9ce1417c5c6` (`b29e8e0`) |
| Commit (base anterior) | `003f6b8` — docs(NS-M0): registra evidência de release R00 e fecha o marco M0 |
| Branch | `main` |
| Remoto | `origin` (`github-helix:dirceummonteiro/Northstar-Salesforce-DeveloperEdition.git`) |
| Org alvo | alias `helix-dev` (Developer Edition, não-produção) |
| Data | 2026-08-18 |
| Owner do release | Probe |
| Desvio registrado | D-010 — Kernel produziu esta metadata declarativa enquanto o agente `schema` não inicializa (P-15) |

## O que este release entrega

Primeira fatia do modelo de dados da §9: 11 campos novos em `Account` (§9.2) e 13 campos novos
em `Opportunity` (§9.3), mais a habilitação do objeto `Quote` padrão via `QuoteSettings`
(D-009/ADR-008), substituindo o modelo de proposta custom que seria necessário se o Quote
padrão continuasse desligado. `Available_Credit__c` é fórmula (`Credit_Limit__c -
Current_Exposure__c`), não campo gravável. `ERP_Customer_Id__c` é External ID único — chave de
idempotência que o M9 vai usar para upsert de conta via ERP.

Nenhum objeto custom, Custom Metadata Type, Big Object ou permission set foi criado nesta fatia
— ver `known-limitations.md`.

## Comandos executados

```
sf project deploy quick --job-id 0Affj00000NeKUECA3 --target-org helix-dev
sf apex run test --target-org helix-dev --result-format human --code-coverage --wait 20
sf data query --target-org helix-dev --query "SELECT Id, ERP_Customer_Id__c, Credit_Status__c, Available_Credit__c FROM Account LIMIT 1"
sf data query --target-org helix-dev --query "SELECT COUNT() FROM Quote"
```

Usado **`deploy quick`**, não uma validação nova: o job `0Affj00000NeKUECA3`, produzido e
validado pelo Kernel com `RunLocalTests` (27/27 componentes, 3/3 testes), ainda estava dentro da
janela de reaproveitamento do Salesforce. Isso economiza uma validação inteira do orçamento
diário de API (`AMBIENTE.md` §2.3) e não é bypass de teste — os testes rodaram e passaram nesse
mesmo job, antes do deploy real.

## Resultado

- Deploy real (quick): **Succeeded** (Deploy ID `0Affj00000Negp1CAB`), 27/27 componentes, 0
  erros.
- Smoke test Apex pós-deploy: **Passed**, 3/3, 100% cobertura, Test Run Id `707fj00000u2Ll6`.
- **`SELECT COUNT() FROM Quote` responde sem erro (0 registros)** — antes desta fatia essa
  mesma consulta retornava `sObject type 'Quote' is not supported`. Prova direta de que a D-009
  foi aplicada na org.
- A consulta aos novos campos de `Account` via SOQL **falhou** com `No such column
  'ERP_Customer_Id__c' on entity 'Account'` — não por falha de deploy (os 24 campos foram
  confirmados via Tooling API, ver `smoke-test.md`), mas por ausência de Field-Level Security:
  nenhum profile ou permission set tem `FieldPermissions` para os campos novos ainda, nem o
  usuário `Administrador do sistema` que executa estes comandos, mesmo com `View All Data` e
  `Modify All Data` = `true` (essas permissões são de registro, não de campo). Detalhe completo
  em `smoke-test.md` e `known-limitations.md`.

Detalhes completos em `manifest.md`, `test-results.md`, `coverage-summary.md`,
`deployment-result.md`, `smoke-test.md`.

## Impacto em dados/limites

`DataStorageMB`: 0 MB em uso antes e depois (Remaining 5 / Max 5) — esperado, campos sem
registro não consomem espaço.
`DailyApiRequests`: 239 em uso na medição de `AMBIENTE.md` §2 (2026-08-18, baseline do M0) →
357 em uso agora (Remaining 14.643 / Max 15.000) — variação de +118 chamadas, consumidas pela
validação do Kernel, pelo `deploy quick`, pelos relatórios de job, pelos testes Apex e pelas
consultas de verificação (SOQL, describe, Tooling API) desta e da tarefa anterior. 2,4% de uso
diário — bem abaixo do limiar de 70% de `AMBIENTE.md` §2. Detalhe em `deployment-result.md`.

## Segurança

Nenhuma mudança neste release toca permission set, profile, sharing rule, `without sharing`,
Named Credential ou lógica de exposição de dado. Não há ESCALONAMENTO DE SEGURANÇA a reportar —
a ausência de FLS observada é o estado **padrão e seguro** de um campo recém-criado via
Metadata API (nada fica visível até alguém conceder acesso explicitamente); ela não abre
exposição nenhuma, é o oposto disso.

## Limitações conhecidas

Ver `known-limitations.md`.

## Go/no-go do Helix

Pendente — este release não fecha o M1 e não pede aceitação de marco, apenas integra a primeira
fatia. Fica para o Helix decidir se aceita a fatia como está ou pede ajuste antes da próxima.
