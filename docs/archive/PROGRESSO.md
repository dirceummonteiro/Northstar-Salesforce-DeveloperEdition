# PROGRESSO — Northstar Revenue Cloud Prototype

## Métrica única

A seção 55.1 do escopo define **uma régua só**, e ela nunca muda:

```
marcos concluídos e validados
─────────────────────────────
             13
```

**Progresso: 3 / 13**

Este número só sobe. Progresso *dentro* de um marco não é progresso do projeto e não entra
nesta conta. Quando este documento falar de um marco específico, ele diz explicitamente que é
sobre aquele marco.

---

## Escada de marcos

| # | Entregável | Validação | Status |
|---|---|---|---|
| **M0** | Estrutura sfdx, git na `main`, `.gitignore`, docs iniciais, deploy vazio validado | `sf project deploy validate` passa | ✅ concluído |
| **M1** | Modelo de dados: objetos, campos, relacionamentos, permission sets | metadata no repositório e na org | ✅ concluído |
| **M2** | Seed data repetível dentro do orçamento da §33 | roda duas vezes sem duplicar; storage abaixo de 50% | ✅ concluído |
| **M3** | Lead: captura, scoring, roteamento, conversão | um lead vira Account, Contact e Opportunity | 🔄 em andamento |
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

### M2 — Seed data ✅

**Aberto em:** 2026-08-19

A §33 exige, para este marco:

- [x] Chave técnica de idempotência (`Seed_Key__c`) em 11 dos 12 objetos do modelo de dados do
      M1 — ver fatia (a) abaixo
- [x] Volume do seed: **1.051 registros** distribuídos pelos 12 objetos do modelo de dados do M1.
      A meta de ~1.620 da §33 fica registrada como superada para esta org por **D-022**, que
      ratifica D-020 — os dois números não coexistem sob o critério de aceite "storage abaixo de
      50%" da §55, e os 53,5% restantes são orçamento de execução dos marcos M3 a M13
- [x] Script de carga repetível e idempotente (roda duas vezes sem duplicar) — provado na org: a
      2ª execução inseriu **0** e atualizou os mesmos 1.051 (`docs/releases/R08/`)
- [x] Script de limpeza correspondente — `scripts/apex/cleanup_seed.apex`, verificado: 1.051
      apagados, os 139 registros de amostra da Developer Edition intactos (D-016)
- [x] Dado 100% sintético — nenhum dado de pessoa real; conferido por query, 0 contatos e 0 leads
      fora de `@example.com`
- [x] Verificação de storage antes de carregar, contra o teto de `DataStorageMB` medido em
      `docs/AMBIENTE.md` §2.2 (0 MB de 5 MB em uso ao fechar o M1 — ver `docs/releases/R06/`).
      Cada etapa checa antes de gravar e aborta sem gravar nada acima de 70% (§33.2); medição
      final da carga: 46,5%

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

**Fatia (b) entregue — scripts de seed e de limpeza** (execução do Kernel):

- [x] Seed em Apex anônimo, em três etapas: `scripts/apex/seed_01_catalog.apex`,
      `seed_02_customers.apex`, `seed_03_pipeline.apex`. Três arquivos e não um só porque
      Apex anônimo tem teto de 32.000 caracteres por execução
- [x] Relatório de contagem somente-leitura `scripts/apex/seed_99_report.apex` e script de
      limpeza `scripts/apex/cleanup_seed.apex`
- [x] Invólucros `scripts/shell/seed.sh` e `scripts/shell/cleanup-seed.sh`, na convenção que já
      existia em `scripts/shell/`
- [x] Documentação de operação em `scripts/apex/README.md`; seção "Massa de demonstração" no
      `README.md` da raiz
- [x] **1.051 registros** nos 12 objetos: Account 80, Contact 150, Lead 80, Product2 100,
      Pricebook2 1, PricebookEntry 200, Opportunity 100, OpportunityLineItem 180, Quote 30,
      QuoteLineItem 50, Order 30, OrderItem 50
- [x] **Idempotência provada na org**: seed rodado duas vezes seguidas a partir de org limpa.
      1ª execução inseriu os 1.051; 2ª inseriu **0** e atualizou os mesmos 1.051. As contagens
      por objeto são idênticas (`diff` vazio entre os dois relatórios)
- [x] **Storage: 46,5%** (1.190 registros × 2 KB = ~2.380 KB de 5.120 KB), abaixo do portão de
      50% do M2 (D-017). Cada etapa checa storage antes de gravar e aborta sem gravar nada
      acima de 70% (§33.2)
- [x] Dado 100% sintético: e-mails só em `@example.com`, telefones no prefixo 5550, nomes de
      empresa e pessoa gerados por combinação indexada, nenhum documento (CPF/CNPJ) gerado —
      conferido por query, 0 contatos e 0 leads fora de `@example.com`
- [x] Limpeza apaga **somente** `Seed_Key__c LIKE 'NS-%'`, na ordem filho → pai, e esvazia a
      lixeira. Verificada: 1.051 apagados, 139 registros de amostra da Developer Edition
      intactos (D-016)
- [x] Cobertura de negócio para os marcos seguintes: 4 segmentos com 20 contas cada, 4 famílias
      de produto com 25 itens cada, os 10 estágios do funil ocupados, pipeline de R$ 132,8 mi

**Decisões tomadas nesta fatia:** **D-019** (onde a plataforma recusa `upsert`, o casamento é por
consulta a `Seed_Key__c` com insert e update separados), **D-020** (volume é 1.051 e não os
~1.620 da §33, porque os dois números não cabem sob o portão de 50% da §55), **D-021** (o seed
exige FLS de leitura em `Seed_Key__c`, que a fatia (a) não concedeu a nenhum perfil; contornado
com atribuição de permission set, correção definitiva pendente em P-17).

**Fatia (c) entregue — correção definitiva de P-17** (metadata versionada, validada e não
deployada):

- [x] Diagnóstico corrigido: as entradas de FLS **não estavam faltando**. A fatia (a) já havia
      concedido as 11 entradas de `Seed_Key__c` nos 8 permission sets `NDG_*`, todas com
      `readable=true`. O que faltava era **escrita para quem roda o seed** — nenhum dos 8 tinha
      `editable=true` — e a ausência de qualquer declaração de quem opera a massa
- [x] `NDG_Salesforce_Admin_Extended` passa a ter `editable=true` nas 11 entradas de
      `Seed_Key__c`. Os outros 7 permission sets `NDG_*` seguem com `editable=false`: leitura
      para auditar, escrita só no permission set que opera o seed
- [x] O contorno de D-021 era atribuição de permission set na org (`PermissionSetAssignment`),
      ação manual não versionada — **não havia artefato no repositório para remover**. O que
      existia era documentação descrevendo o contorno como vigente, em `scripts/apex/README.md`
      e em `docs/PENDENCIAS.md`, atualizada nesta fatia
- [x] Defeito pré-existente encontrado e corrigido no mesmo permission set: `Pricebook2` e
      `Product2` declaravam `viewAllRecords`/`modifyAllRecords` como `true`, que a licença do
      usuário não permite (`A licença do usuário não permite a autorização: Exibir todos os
      Pricebook2`). **Isso já reprovava a validação em HEAD, sem relação com P-17** — o
      permission set não era deployável. Os dois flags foram para `false`; CRUD integral
      (`create`/`read`/`edit`/`delete`) preservado nos dois objetos
- [x] `sf project deploy validate` — **Succeeded**, Deploy ID `0Affj00000Npk8QCAR`, 1/1
      componente, 3/3 testes, 0 falhas. Validação apenas; o deploy é do Probe (§65.1)

**Decisão desta fatia:** **D-022** ratifica D-020 — 1.051 é o volume oficial do seed, e a meta de
~1.620 da §33 fica registrada como superada para esta org.

**Ainda falta para o M2 fechar** (§33, §55):

- [x] Ratificação do Helix sobre **D-020** — ratificada por **D-022**. Entre o dimensionamento da
      §33 e o critério de aceite da §55, prevalece o critério de aceite; e os 53,5% de storage
      restantes são orçamento de execução dos marcos M3 a M13, não folga
- [x] Correção definitiva da FLS de `Seed_Key__c` (P-17 / D-021) — feita na fatia (c) acima, na
      metadata versionada, e validada contra a org
- [x] Commit e pacote de evidência da fatia (b) — feitos: `2262199` (scripts de seed e de
      limpeza) e `0b51c5f` (docs + evidência R08), ambos em `origin/main`
- [x] Deploy da fatia (c) e pacote de evidência correspondente — aplicado pelo Probe (§65.1):
      Deploy ID `0Affj00000NpcVqCAJ`, 3/3 testes, e pacote de evidência `docs/releases/R09/`

**Deploy real da fatia (c)** (evidência em `docs/releases/R09/`):

- [x] `sf project deploy start --source-dir force-app --test-level RunLocalTests` — Deploy ID
      `0Affj00000NpcVqCAJ`, **Succeeded**, 3/3 testes
- [x] Aplicação confirmada na org por SOQL/Tooling API direto contra `FieldPermissions` e
      `ObjectPermissions`, não só pelo status do comando: `Seed_Key__c` editável em
      `NDG_Salesforce_Admin_Extended`; `viewAllRecords`/`modifyAllRecords` de `Pricebook2` e
      `Product2` em `false`, CRUD íntegro
- [x] Reconciliação do volume do seed — 851 (11 objetos com `Seed_Key__c`) + 200
      (`PricebookEntry` por parentesco com `Product2.Seed_Key__c`) = **1.051**, confirmando
      D-022
- [x] **Critério de aceite §55 — idempotência**: segunda execução de `./scripts/shell/seed.sh`
      pós-deploy (quarta execução cumulativa) — **zero inserções em qualquer objeto**, todos os
      1.051 registros apenas atualizados
- [x] **Critério de aceite §55 — storage**: **46,5%** (1.190 registros × ~2 KB ≈ 2.380 KB de
      5.120 KB), abaixo do teto de 50% (D-017) e da parada de emergência de 70% (§33.2)
- [x] Defeito pré-existente em `main` encontrado e corrigido nesta fatia, sem relação com P-17:
      `NDG_Salesforce_Admin_Extended` declarava `viewAllRecords`/`modifyAllRecords` em
      `Pricebook2`/`Product2`, permissões que a licença Developer Edition não concede — isso já
      reprovava `sf project deploy validate` em `HEAD` antes de qualquer mudança desta fatia,
      confirmado de forma independente via `git stash`. Não estava em nenhuma pendência aberta;
      achado por acidente ao validar P-17. Os dois flags foram para `false`, CRUD íntegro
      preservado
- [x] **ESCALONAMENTO DE SEGURANÇA reportado ao Helix** — mudança em permission set
      (`NDG_Salesforce_Admin_Extended`): concede `editable=true` em `Seed_Key__c` e remove
      `viewAllRecords`/`modifyAllRecords` de `Pricebook2`/`Product2`
- [x] Pacote de evidência `docs/releases/R09/`

**Go/no-go do Helix: GO.** Os dois critérios de aceite da §55 — roda duas vezes sem duplicar (0
inserções na segunda execução) e storage abaixo do teto de 50% (medido em 46,5%) — estão
provados ao vivo na org, pós-deploy, e o volume oficial do seed (1.051 registros) está
ratificado em D-022.

**Fechamento:** 2026-08-20 · commit `f77534e` · evidência em `docs/releases/R07/` a
`docs/releases/R09/` · go/no-go do Helix: **GO**

### M3 — Lead: captura, scoring, roteamento, conversão 🔄

**Aberto em:** 2026-08-20

Escopo do marco, conforme §55: "Lead: capture, scoring, routing, conversion". Critério de
aceite: **um lead vira Account, Contact e Opportunity**.

**Decisão de modelo de dados: D-023** — o M3 usa o `Lead` **padrão** estendido, sem objeto custom
de lead; regras de scoring e de roteamento em Custom Metadata Type e não em Apex; deduplicação por
External Id único e case-insensitive; nenhum campo novo obrigatório, para não quebrar a captura
externa. **Padrão de trigger: D-024**, decidido agora e implementado na M3.2.

Decomposição do marco em fatias:

| Fatia | Entregável | Status |
|---|---|---|
| **M3.1** | Schema do Lead: 8 campos custom, `Lead_Scoring_Rule__mdt` e `Lead_Routing_Rule__mdt` com registros de exemplo, 3 filas, FLS nos permission sets `NDG_*` | ✅ deployada, evidência em `docs/releases/R10/` |
| **M3.2** | Framework de trigger (`TriggerHandler` base, `LeadTrigger`, `LeadTriggerHandler`) + motor de scoring lendo `Lead_Scoring_Rule__mdt` | ⬜ |
| **M3.3** | Roteamento por fila lendo `Lead_Routing_Rule__mdt`, com `Routed_At__c` e `Routing_Reason__c` preenchidos | ⬜ |
| **M3.4** | Conversão para Account, Contact e Opportunity, com `Conversion_Blocked_Reason__c` no caminho de recusa — **é esta fatia que prova o critério de aceite da §55** | ⬜ |
| **M3.5** | Captura via REST (`Capture_Channel__c` = API) com deduplicação por `Lead_Dedupe_Key__c`, mais as classes de teste do marco | ⬜ |

**Fatia M3.1 — schema do Lead** (metadata versionada e **deployada** em `helix-dev`):

- [x] 8 campos custom em `Lead`, todos opcionais por desenho (D-023): `Lead_Score__c` (Number 3,0),
      `Lead_Score_Band__c` (picklist Hot/Warm/Cold, sem padrão), `Capture_Channel__c` (picklist
      Web/API/Import/Event/Manual, padrão Manual), `Lead_Dedupe_Key__c` (Text 255, External Id,
      Unique, **case-insensitive**), `Scored_At__c`, `Routed_At__c` (DateTime),
      `Routing_Reason__c`, `Conversion_Blocked_Reason__c` (Text 255)
- [x] `Lead_Scoring_Rule__mdt` (7 campos) + 6 registros de exemplo, sem dado pessoal
- [x] `Lead_Routing_Rule__mdt` (7 campos) + 3 registros: 70–100 → `Lead_Enterprise`,
      40–69 → `Lead_SMB`, 0–39 → `Lead_Nurture`
- [x] 3 filas de `Lead` (`Lead_Enterprise`, `Lead_SMB`, `Lead_Nurture`), **sem membros**, para que
      o deploy não dependa de nenhum usuário existir na org
- [x] FLS dos 8 campos nos 8 permission sets `NDG_*` já existentes. Os 6 campos calculados por
      Apex ficam `readable=true`/`editable=false` em todos — usuário não edita resultado de
      cálculo. `Capture_Channel__c` e `Lead_Dedupe_Key__c` recebem `editable=true` **só** em
      `NDG_Integration_Admin` (integração) e `NDG_Salesforce_Admin_Extended` (opera o seed, por
      D-021); nos outros 6, somente leitura
- [x] Nenhum permission set novo criado; nenhum `View All` / `Modify All` reintroduzido (a
      correção de `eaf8baf` segue intacta)
- [x] Nenhum Apex nesta fatia — `TriggerHandler` e o motor de scoring são da M3.2 (D-024)
- [x] Commit, `sf project deploy validate` e deploy — do Probe (§65.1), evidência em
      `docs/releases/R10/`
- [x] **ESCALONAMENTO DE SEGURANÇA revisado pelo Fable** — veredito **"aprovado com ressalva"**.
      Duas ações imediatas aplicadas: `objectPermissions` de `Lead` adicionado a
      `NDG_Integration_Admin` (a FLS de campo estava inerte sem ele) e `readable` de
      `Lead_Dedupe_Key__c` removido de `NDG_Executive_ReadOnly` e `NDG_Deal_Desk` (dado pessoal
      sem uso funcional nesses dois personas). Três regras de Apex para a M3.2 registradas em
      D-025, emendando D-024. Correção documentada em `docs/releases/R10/`
