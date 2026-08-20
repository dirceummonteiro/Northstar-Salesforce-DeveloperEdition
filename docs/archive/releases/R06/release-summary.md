# R06 — Release Summary (fechamento do marco M1)

## Identificação

| Campo | Valor |
|---|---|
| Marco | M1 — Modelo de dados: objetos, campos, relacionamentos, permission sets (§55) |
| Natureza deste release | Não é evidência de uma fatia. É o pacote de **aceitação do marco inteiro**, consolidando R01–R05. Nenhum metadata novo, nenhum deploy nesta rodada. |
| Commit de fechamento | `5d7d4ec` (reconciliação R05, já em `origin/main` antes desta rodada) |
| Branch | `main` |
| Remoto | `origin` |
| Org alvo | alias `helix-dev` (Developer Edition, não-produção) |
| Data do fechamento | 2026-08-19 |
| Owner do release | Probe |
| Go/no-go do Helix | **GO — M1 aceito em 2026-08-19** |

## O que o M1 entregou, somando as quatro fatias

| Fatia | Conteúdo | Commit | Evidência |
|---|---|---|---|
| 1 | 11 campos em `Account` (§9.2), 13 campos em `Opportunity` (§9.3), objeto `Quote` padrão habilitado (D-009/ADR-008) | `b29e8e0` | `docs/releases/R01/` |
| (a) | 8 permission sets `NDG_*` (§30.2) com FLS explícita sobre os 24 campos comerciais da fatia 1 | `a4185b9` | `docs/releases/R02/` |
| (b) | 3 Custom Metadata Types de política — `Pricing_Rule__mdt` (11 campos, 8 registros), `Margin_Policy__mdt` (9 campos, 1 registro), `Freight_Rule__mdt` (9 campos, 2 registros) | `db3391d` | `docs/releases/R03/` |
| (c) | Objeto `Discount_Request__c` (13 campos, master-detail em `Opportunity`), `ObjectPermissions`/`FieldPermissions` nos 7 permission sets existentes | `897cfef` | `docs/releases/R03/` |
| (d) | Big Object `Integration_Log__b` (17 campos, índice composto de 3 partes), `ObjectPermissions` append-only em 3 permission sets | `79981cd` | `docs/releases/R04/` |
| Reconciliação | Redeploy completo + reconfirmação via Tooling API de (a)-(d) | `5d7d4ec` | `docs/releases/R05/` |

Escopo consolidado: **5 objetos/tipos custom** (`Discount_Request__c`, `Pricing_Rule__mdt`,
`Margin_Policy__mdt`, `Freight_Rule__mdt`, `Integration_Log__b`), **24 campos comerciais**
declarativos em objetos padrão (11 em `Account`, 13 em `Opportunity`), **8 permission sets**
`NDG_*`, e **11 registros de Custom Metadata** (8+1+2). Detalhe completo por fatia em
`manifest.md`.

## Deploys aplicados e seus IDs

Tabela completa em `deployment-result.md`. Todos os deploys do M1 tiveram **0 erros de
componente**. A única recusa de plataforma (fatia (d), índice de Big Object acima de 100
caracteres) foi resolvida sem perda de escopo — ver D-012 em `docs/DECISIONS.md`.

## Resultado de teste e cobertura mais recentes

Detalhe em `test-results.md` e `coverage-summary.md`. Consolidado: **100% de cobertura
org-wide**, `HttpCalloutService`/`HttpCalloutServiceTest` continuam a única classe/teste do
projeto (D-006) — nenhuma fatia do M1 adicionou Apex, porque M1 é modelo de dados declarativo.
Último deploy completo com `RunLocalTests` (R05, Deploy ID `0Affj00000NmNjRCAV`): 111/111
componentes, 0 erros, 3/3 testes, 0 falhas.

## Medição de storage antes e depois — a premissa da §2.2 confirmada como fato medido

| Momento | `DataStorageMB` | Fonte |
|---|---|---|
| Antes do M1 (M0, org recém-criada) | 0 MB em uso / 5 MB máx (0%) | `docs/AMBIENTE.md` §2, medido em 2026-08-18 |
| Depois de cada fatia do M1 (R01–R04) | 0 MB em uso / 5 MB máx (0%), sem variação em nenhuma rodada | `docs/releases/R0{1,2,3,4}/deployment-result.md` |
| Fechamento do M1 (agora, com 11 registros de Custom Metadata e o Big Object `Integration_Log__b` criados) | 0 MB em uso / 5 MB máx (0%) | Consulta direta desta rodada, `sf limits api display -o helix-dev`: `DataStorageMB max=5, remaining=5` |

**Conclusão registrada como fato medido, não como suposição:** a org criou 5 objetos/tipos
custom, 11 registros de Custom Metadata e um Big Object entre 2026-08-18 e 2026-08-19, e
`DataStorageMB` permaneceu em 0/5 MB do início ao fim. Isso confirma empiricamente a premissa da
§2.2 do `AMBIENTE.md`: Custom Metadata Types e Big Objects não contam contra o teto de 5 MB de
data storage desta org. É a premissa que sustenta o projeto inteiro — sem ela, o orçamento de
seed data da §33 (~1.620 registros) não caberia depois de somar política de preço, margem,
frete e log de integração como registros comuns. A verificação ao vivo desta rodada está em
`smoke-test.md`.

## Limitações que atravessam para o M2

Ver `known-limitations.md`. Resumo:

- **Agente `schema` quebrado (P-15)** — `WorkspaceVanishedError` documentado desde o M0.
  Cobertura pelo desvio D-010 (Kernel produz metadata declarativa). Não fechado por conta
  própria pelo Probe; segue para o Helix decidir.
- **FLS ainda não exercitada com dado real** — a FLS dos permission sets `NDG_*` foi confirmada
  por SOQL/Tooling API contra a definição de metadata, mas nenhum `System.runAs()` por persona
  rodou ainda contra registro real, porque não há lógica de negócio para exercitar (§30.2 torna
  isso obrigatório; ver limitação (c) de R02/R03/R04).
- **Nenhum Apex de negócio escrito ainda** — esperado; M1 é modelo de dados declarativo. Apex de
  negócio começa no M3.

## Go/no-go do Helix

**GO — M1 aceito em 2026-08-19.**

## Nota de verificação do Probe sobre a justificativa do Helix

O Probe verificou de forma independente cada item citado pelo Helix na decisão de GO (detalhe
em `smoke-test.md`) e encontrou duas imprecisões na redação da decisão, que **não alteram o
GO** — os entregáveis do M1 estão de fato completos e batem com o que R01–R05 já documentavam —
mas são registradas aqui porque a instrução do Helix foi explícita: não consertar em silêncio.

1. **"18 campos custom em Account, 18 em Opportunity"** — não bate com o escopo do projeto (11
   em `Account`, 13 em `Opportunity`, documentados desde `docs/releases/R01/` e confirmados ao
   vivo nesta rodada via Tooling API). A contagem de 18/18 bate exatamente se somados os campos
   de amostra que a própria Developer Edition cria por padrão (7 em `Account`:
   `CustomerPriority__c`, `SLA__c`, `Active__c`, `NumberofLocations__c`, `UpsellOpportunity__c`,
   `SLASerialNumber__c`, `SLAExpirationDate__c`; 5 em `Opportunity`:
   `DeliveryInstallationStatus__c`, `TrackingNumber__c`, `OrderNumber__c`,
   `CurrentGenerators__c`, `MainCompetitors__c` — nenhum desses pertence ao repositório ou ao
   escopo do M1). Provável causa: uma contagem bruta de todos os campos `%__c` do objeto na org,
   sem filtrar os campos de amostra pré-existentes da DE.
2. **"resolvidos por campo em vez de objeto (D-004 e a decisão de crédito na Account)"** — o
   fato está correto (`Credit_Status__c` existe como campo de `Account`, `Competitor_Primary__c`
   e `Inventory_Check_Status__c` existem como campos de `Opportunity`, cobrindo em substância
   `Credit_Status__c`, `Competitor__c` e `Inventory_Snapshot__c` da lista da §9), mas **D-004
   não trata deste assunto** — D-004 é sobre permission sets vs. licenças de perfil (M0). Não
   existe, em `docs/DECISIONS.md`, uma decisão numerada que registre explicitamente a escolha de
   resolver esses três itens por campo em vez de objeto; é um padrão implícito desde a fatia 1
   (R01), nunca formalizado como decisão própria.

Os demais itens da justificativa do Helix (8 permission sets, os 5 objetos/tipos nomeados, as 3
personas certas no Big Object, `DataStorageMB` em 0/5 MB, árvore limpa em `5d7d4ec`) foram
confirmados exatamente como descritos — ver `smoke-test.md` para o detalhe de cada consulta.
