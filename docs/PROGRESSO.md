# PROGRESSO — Northstar Revenue Cloud Prototype

## Métrica única

A seção 55.1 do escopo define **uma régua só**, e ela nunca muda:

```
marcos concluídos e validados
─────────────────────────────
             13
```

**Progresso: 2 / 13**

Este número só sobe. Progresso *dentro* de um marco não é progresso do projeto e não entra
nesta conta. Quando este documento falar de um marco específico, ele diz explicitamente que é
sobre aquele marco.

---

## Escada de marcos

| # | Entregável | Validação | Status |
|---|---|---|---|
| **M0** | Estrutura sfdx, git na `main`, `.gitignore`, docs iniciais, deploy vazio validado | `sf project deploy validate` passa | ✅ concluído |
| **M1** | Modelo de dados: objetos, campos, relacionamentos, permission sets | metadata no repositório e na org | ✅ concluído |
| **M2** | Seed data repetível dentro do orçamento da §33 | roda duas vezes sem duplicar; storage abaixo de 50% | 🔄 em andamento |
| **M3** | Lead: captura, scoring, roteamento, conversão | um lead vira Account, Contact e Opportunity | ⬜ |
| **M4** | Pipeline de Opportunity com produtos e price book | uma oportunidade completa pode ser montada | ⬜ |
| **M5** | Motor de precificação em Custom Metadata | mudar regra de preço não exige mudar Apex | ⬜ |
| **M6** | Controles de desconto e margem | desconto acima do limite é bloqueado com mensagem clara | ⬜ |
| **M7** | Aprovações do Deal Desk | fluxo completo de pedido, aprovação e rejeição | ⬜ |
| **M8** | Quote e Order | uma oportunidade fechada gera um pedido | ⬜ |
| **M9** | Simulação de ERP, estoque e crédito com mocks | sucesso, falha e retry todos testados | ⬜ |
| **M10** | Observabilidade em Big Object + Integration Monitor LWC | um erro de integração é visível e reprocessável | ⬜ |
| **M11** | Relatórios e dashboards | três visões: rep, gerente, executivo | ⬜ |
| **M12** | Endurecimento de testes e pacote de evidências | cobertura acima de 85%, evidência conforme §68 | ⬜ |
| **M13** | Demonstração do CR-DEMO-001 (§69.2) | mudança de política ponta a ponta com todo agente participando | ⬜ |

Regra da §55: **entregar até o M8 impecável vale mais do que entregar os treze pela metade.**

---

## Registro de fechamento de marcos

Cada marco fechado ganha uma entrada aqui, com data, commit e evidência.

### M0 — Fundação ✅

**Aberto em:** 2026-08-18

Escopo do marco:

- [x] Estrutura de pastas da §7.1 criada
- [x] `docs/MASTER_SCOPE.md` salvo no repositório
- [x] `docs/AMBIENTE.md` com limites, licenças e edição medidos na org real
- [x] `docs/DECISIONS.md` aberto (D-001 a D-008)
- [x] `docs/PENDENCIAS.md` aberto
- [x] `docs/PROGRESSO.md` aberto
- [x] ADR-001 — estratégia de controle de fonte e ambiente
- [x] `.gitignore` auditado contra a seção de segurança do `AGENTS.md` — histórico limpo, nenhum
      arquivo sensível rastreado em nenhum commit anterior
- [x] `sourceApiVersion` alinhada à org: 62.0 → 67.0 (D-003 confirmada, não quebrou nada)
- [x] `README.md` reescrito como entregável de vitrine
- [x] Scripts `validate.sh`, `deploy.sh` e `test.sh` em `scripts/shell/`
- [x] `manifest/package.xml` inicial na versão 67.0
- [x] **`sf project deploy validate --test-level RunLocalTests` passa** — 3/3 testes, 100%,
      Deploy ID `0Affj00000NdJfCCAV`
- [x] Branch local renomeada para `main`
- [x] Commit e push na `main`
- [x] Deploy aplicado na org
- [x] Pacote de evidências `docs/releases/R00/`

**Fechamento:** 2026-08-18 · commit `d115424` · evidência em `docs/releases/R00/`

### M1 — Modelo de dados ✅

**Aberto em:** 2026-08-18

**Fatia 1 entregue** (commit `b29e8e0`, evidência em `docs/releases/R01/`):

- [x] 11 campos novos em `Account` (§9.2): segmento, tier, crédito, território, canal, sync ERP
- [x] 13 campos novos em `Opportunity` (§9.3): margem, desconto, status de pricing/deal desk/
      crédito/estoque, concorrente, motivo de perda
- [x] Objeto `Quote` padrão habilitado (D-009/ADR-008), confirmado na org via
      `SELECT COUNT() FROM Quote`
- [x] Deploy aplicado (`deploy quick` sobre validação do Kernel), 27/27 componentes, 0 erros
- [x] Pacote de evidência `docs/releases/R01/`

**Fatia (a) entregue — permission sets** (commit `a4185b9`, evidência em `docs/releases/R02/`):

- [x] Os 8 permission sets da §30.2 (`NDG_Sales_Rep`, `NDG_Sales_Manager`,
      `NDG_Regional_Director`, `NDG_Deal_Desk`, `NDG_RevOps`, `NDG_Integration_Admin`,
      `NDG_Executive_ReadOnly`, `NDG_Salesforce_Admin_Extended`), confirmados na org via SOQL
- [x] FLS explícita para os 24 campos comerciais de R01 — fecha a limitação (c) de
      `docs/releases/R01/known-limitations.md` (campos que antes não eram visíveis para ninguém,
      nem para o administrador)
- [x] Margem e desconto verificados somente-leitura em todos os 8 permission sets, na org
- [x] Nenhum permission set concede `View All Data` / `Modify All Data`
- [x] Deploy aplicado (`deploy quick` sobre validação própria do Probe), 8/8 componentes, 0 erros
- [x] Pacote de evidência `docs/releases/R02/`

**Fatia (b) entregue — Custom Metadata Types de política** (commit `db3391d`, evidência em
`docs/releases/R03/`):

- [x] `Pricing_Rule__mdt` (§9.7, 11 campos) + 8 registros (4 tiers, 4 faixas de volume)
- [x] `Margin_Policy__mdt` (§9.8, 9 campos) + 1 registro (`Default_Policy`)
- [x] `Freight_Rule__mdt` (§9.16, 9 campos) + 2 registros (Nordeste, Sudeste)
- [x] Confirmado na org via SOQL: 8 + 1 + 2 = 11 registros, batendo com os 11 arquivos entregues
- [x] Deploy aplicado (validate + deploy completo com `RunLocalTests`), 65/65 componentes
      (junto com a fatia (c)), 0 erros
- [x] Pacote de evidência `docs/releases/R03/`

**Fatia (c) entregue — `Discount_Request__c`** (commit `897cfef`, evidência em
`docs/releases/R03/`):

- [x] Objeto `Discount_Request__c` (§9.9, 13 campos), `sharingModel: ControlledByParent` via
      master-detail para `Opportunity`
- [x] `ObjectPermissions`/`FieldPermissions` adicionadas nos 7 permission sets `NDG_*`
      existentes — FLS somente-leitura mantida nos campos de negociação sensíveis
      (`Requested_Discount__c`, `Requested_Margin_Percent__c`, `Current_Margin_Percent__c`,
      `Policy_Discount__c`) em todos os 7, confirmado na org
- [x] **ESCALONAMENTO DE SEGURANÇA reportado ao Helix** — `viewAllRecords`/`modifyAllRecords`
      por objeto (não permissão de sistema) introduzidos em `Discount_Request__c` (5 personas)
      e em `Opportunity` (`NDG_Deal_Desk`); tabela de justificativa por persona em
      `docs/releases/R03/release-summary.md`
- [x] Deploy aplicado, confirmado na org (objeto existe, vazio — sem seed nesta fatia)
- [x] Pacote de evidência `docs/releases/R03/`

**Fatia (d) entregue — Big Object `Integration_Log__b`** (evidência em `docs/releases/R04/`):

- [x] Big Object `Integration_Log__b` (§1.5/§9.11, 17 campos), índice composto
      `Integration_Name__c` (ASC) → `Event_Date__c` (DESC) → `Correlation_Id__c` (ASC) —
      decisão completa e o teto de 100 caracteres do índice (exclusivo, não inclusivo) em
      **D-012**, `docs/DECISIONS.md`
- [x] `ObjectPermissions` nos 3 permission sets relevantes (`NDG_Integration_Admin`,
      `NDG_RevOps`, `NDG_Salesforce_Admin_Extended`) — append-only, sem `Edit`/`Delete`/
      `ViewAllRecords`/`ModifyAllRecords` para nenhum, `NDG_RevOps` sem `Create`; confirmado na
      org via SOQL
- [x] Duas recusas de validação por limite de plataforma antes da aceita (Deploy IDs
      `0Affj00000NlcCiCAJ` e `0Affj00000NmAhNCAV`), documentadas em D-012 e em
      `docs/releases/R04/known-limitations.md`, item (e)
- [x] Deploy aplicado (`deploy quick` sobre validação própria do Probe), 111/111 componentes,
      0 erros, 3/3 testes
- [x] Confirmado na org: objeto + 17 campos via Tooling API `FieldDefinition`, índice via
      retrieve de metadata, `COUNT()` não suportado em Big Object — confirmado vazio via
      `SELECT ... LIMIT 1` sem registros
- [x] Pacote de evidência `docs/releases/R04/`

**Ainda falta para o M1 fechar** (§55 exige objetos, campos, relacionamentos e permission sets):

- [ ] Demais objetos custom da §9 (`Sales_Quota__c`, `Quota_Attainment__c`,
      `Territory_Assignment__c`, `Inventory_Snapshot__c`, `ERP_Sync_Log__c`, `Partner_Deal__c`,
      etc. — fora do escopo das fatias (b)/(c)/(d))
- [ ] Permission tests (`System.runAs()`) por persona (§30.2 os torna obrigatórios) — ainda sem
      lógica de negócio para exercitar; ver `docs/releases/R02/known-limitations.md`, item (c),
      reafirmado em `docs/releases/R03/known-limitations.md`, item (c)
- [x] Confirmação explícita do Helix sobre a tabela de `viewAllRecords`/`modifyAllRecords`
      introduzida na fatia (c) — ratificada como **D-011** em `docs/DECISIONS.md`; ver
      `docs/releases/R03/known-limitations.md`, item (b)

**Reconciliação (b)-(d) confirmada** (evidência em `docs/releases/R05/`): rodada disparada
porque o dono viu apenas um objeto customizado na org. Reconhecimento mostrou que `main` e
`origin/main` já estavam idênticos (nada preso sem push) e que as quatro fatias (a)-(d) já
existiam completas em `force-app/`. Deploy completo reaplicado (`sf project deploy validate` +
`sf project deploy start`, 111/111 componentes, 0 erros, 3/3 testes) e conferido na org via
Tooling API `FieldDefinition` (não pelo `sf sobject describe`, que truncou os campos logo após o
deploy — ver P-16 em `docs/PENDENCIAS.md`): os 8 permission sets, os 11 registros de Custom
Metadata, os 13 campos de `Discount_Request__c` e os 17 campos de `Integration_Log__b` estão
todos presentes na org. Leitura mais provável da observação original: `Integration_Log__b` foi
criado numa janela de menos de uma hora antes desta rodada, e Custom Metadata Types não aparecem
no Object Manager padrão do Setup — quem olhou antes dessa criação via mesmo só
`Discount_Request__c`. Não é uma confirmação retroativa do que a tela mostrava, só a leitura mais
compatível com os timestamps.

**Desvio em vigor:** D-010 — Kernel produz a metadata declarativa desta fatia porque o agente
`schema` não inicializa (P-15). Aplica-se às fatias (b) e (c): ambas chegaram prontas no working
tree, produzidas pelo Kernel sob o mesmo desvio da fatia 1. Não se aplica à fatia (a): o Probe
não teve visibilidade de qual agente produziu os permission sets, só confirmou que estavam
corretos e os integrou. Na fatia (d), foi o `schema` — não o Kernel — quem aplicou a correção de
`Integration_Name__c` no working tree; ver observação em `docs/PENDENCIAS.md`, P-15. O Probe não
declara o desvio D-010 encerrado por conta própria.

**Fechamento:** 2026-08-19 · commit `5d7d4ec` · evidência em `docs/releases/R01/` a `R05/` · go/no-go do Helix: **GO**

### M2 — Seed data 🔄

**Aberto em:** 2026-08-19

A §33 exige, para este marco:

- [x] Chave técnica de idempotência (`Seed_Key__c`) em 11 dos 12 objetos do modelo de dados do
      M1 — ver fatia (a) abaixo
- [ ] ~1.620 registros no total, distribuídos pelos objetos do modelo de dados do M1
- [ ] Script de carga repetível e idempotente (roda duas vezes sem duplicar)
- [ ] Script de limpeza correspondente
- [ ] Dado 100% sintético — nenhum dado de pessoa real
- [ ] Verificação de storage antes de carregar, contra o teto de `DataStorageMB` medido em
      `docs/AMBIENTE.md` §2.2 (0 MB de 5 MB em uso ao fechar o M1 — ver `docs/releases/R06/`)

**Fatia (a) entregue — chave de idempotência `Seed_Key__c`** (evidência em
`docs/releases/R07/`):

- [x] Campo `Seed_Key__c` (Text 40, External Id, Unique, case-sensitive) em 11 objetos:
      `Account`, `Contact`, `Lead`, `Product2`, `Pricebook2`, `Opportunity`,
      `OpportunityLineItem`, `Quote`, `QuoteLineItem`, `Order`, `OrderItem` — decisão completa em
      **D-014**, `docs/DECISIONS.md`
- [x] FLS somente-leitura (`readable=true`, `editable=false`) do campo nos 8 permission sets
      `NDG_*` — 88 pares campo/permission set, nenhum com escrita concedida
- [x] Nenhuma recusa de plataforma nos 11 objetos, inclusive nos três de maior risco
      (`OpportunityLineItem`, `QuoteLineItem`, `OrderItem`) — `externalId`/`unique` aceitos sem
      exceção
- [x] `PricebookEntry` fica de fora por desenho (a plataforma não aceita campo custom nele);
      idempotência dele será por chave natural no Apex do seed — ver
      `docs/releases/R07/known-limitations.md`, item (a)
- [x] Deploy aplicado (`deploy quick` sobre validação própria do Probe, `0Affj00000Nmmt9CAB` →
      `0Affj00000NnBZmCAN`), 122/122 componentes, 0 erros, 3/3 testes na validação
- [x] Confirmado na org via Tooling API `FieldDefinition` (não `sf sobject describe`, P-16): os
      11 campos existem, `IsIndexed = true`, External Id + Unique Case Sensitive
- [x] Storage medido pós-deploy: 0 MB / 5 MB (0%) — folga total dos portões de 50% (D-017) e 70%
      (§33.2) preservada para a carga de dados da próxima fatia
- [x] P-15 resolvida nesta rodada — primeira metadata produzida pelo `schema` desde então
      (**D-018**)
- [x] Pacote de evidência `docs/releases/R07/`

**Ainda falta para o M2 fechar** (§33, §55): a carga dos ~1.620 registros de seed (D-015,
execução do Kernel), o script de limpeza correspondente (D-016), confirmação de dado 100%
sintético, e reconfirmação de storage abaixo de 50% depois da carga real.
