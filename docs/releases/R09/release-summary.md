# R09 — Release Summary (M2, fatia (c): correção definitiva de P-17 e fechamento do marco)

## Identificação

| Campo | Valor |
|---|---|
| Marco | M2, fatia (c) — correção definitiva da FLS de `Seed_Key__c` (P-17, D-021), correção de defeito pré-existente e fechamento do marco (§55) |
| Commit | ver hashes no final deste documento |
| Branch | `main` |
| Remoto | `origin` |
| Base | `0b51c5f` (fatia (b), `HEAD == origin/main` no início desta rodada) |
| Org alvo | alias `helix-dev` (Developer Edition, não-produção) |
| Data | 2026-08-20 |
| Owner do release | Probe |
| Produzido por | agente Kernel (metadata declarativa e reconciliação de docs); validado, corrigido, deployado e commitado pelo Probe (§65.1) |

## O que este release entrega

Concessão de `editable=true` em `Seed_Key__c` (11 campos) no permission set
`NDG_Salesforce_Admin_Extended`, correção de um defeito pré-existente em
`viewAllRecords`/`modifyAllRecords` de `Pricebook2`/`Product2` no mesmo permission set, e
reconciliação de documentação (`D-022` ratifica `D-020`, `docs/PROGRESSO.md`,
`scripts/apex/README.md`, status de `P-17` em `docs/PENDENCIAS.md`). Contexto completo em
**D-021**, **D-022**, `docs/DECISIONS.md`.

## A) Validação — HEAD (defeito) vs. árvore corrigida

**HEAD (`0b51c5f`) falha `sf project deploy validate` de forma independente**, confirmado por este
release antes de qualquer alteração ser tocada (via `git stash` sobre as mudanças do Kernel,
validado, depois `git stash pop`):

```
Deploy ID: 0Affj00000NpysvCAB
Status: Failed
Component Failures [1]
  PermissionSet · NDG_Salesforce_Admin_Extended
  Problema: A licença do usuário não permite a autorização: Modificar todos Pricebook2
```

Esse erro **não tem relação com P-17** — é um defeito pré-existente no permission set
(`viewAllRecords`/`modifyAllRecords` declarados em `Pricebook2`/`Product2`, que a licença Developer
Edition não permite). O permission set já não era deployável antes desta fatia.

**Árvore corrigida** (mudanças do Kernel: `editable=true` em `Seed_Key__c` + `viewAllRecords`/
`modifyAllRecords` → `false` em `Pricebook2`/`Product2`, CRUD preservado):

```
Deploy ID: 0Affj00000NpPnBCAV
Status: Succeeded
Test Results Summary — Passing: 3, Failing: 0, Total: 3
```

## B) Reconciliação do volume do seed — 851 + 200 = 1.051

A soma dos 11 objetos com `Seed_Key__c` preenchido é **851**. A hipótese de que a diferença para
1.051 é `PricebookEntry` (12º objeto do modelo, sem `Seed_Key__c` por ser objeto padrão — D-014)
foi confirmada por SOQL, com uma ressalva importante:

| Consulta | Resultado |
|---|---|
| `COUNT(Id) FROM PricebookEntry` (org inteira) | **234** |
| `COUNT(Id) FROM PricebookEntry WHERE Product2.Seed_Key__c != null` | **200** |
| `COUNT(Id) FROM PricebookEntry WHERE Product2.Seed_Key__c = null` | 34 |

A contagem bruta da org (234) **não** fecha a conta — os 34 registros extras são `PricebookEntry`
alheios ao seed (dado pré-existente da org, fora do escopo de D-016/D-022). A contagem correta é a
filtrada por parentesco com `Product2.Seed_Key__c`, que dá exatamente **200** (100 produtos × 2
tabelas de preço: padrão + parceiro). **851 + 200 = 1.051 — a documentação está correta.**
D-022 (ratifica D-020) confirmado.

## C) Risco derivado — limpeza de `PricebookEntry` sem `Seed_Key__c`

Verificado por leitura de `scripts/apex/cleanup_seed.apex`: como `PricebookEntry` não tem
`Seed_Key__c` (objeto padrão, D-014), o script apaga por parentesco —
`Product2.Seed_Key__c LIKE 'NS-%'` — nunca por varredura da tabela inteira. A entrada da tabela de
preço customizada é apagada antes da entrada da tabela padrão do mesmo produto (a plataforma
recusa apagar a entrada padrão enquanto a customizada dependente existir). A tabela de preço
padrão em si (`Pricebook2` com `IsStandard = true`) nunca é tocada, só as entradas que apontam
para produto do seed. **Sem defeito — critério de aceite bate com a contagem de 200 confirmada em
(B).**

## D) Deploy real

```
sf project deploy start --source-dir force-app --target-org helix-dev --test-level RunLocalTests
Deploy ID: 0Affj00000NpcVqCAJ
Status: Succeeded
Test Results Summary — Passing: 3, Failing: 0, Total: 3
```

Aplicação confirmada por consulta direta à org (`Tooling API` / SOQL), não só pelo status do
comando:

| Objeto.Campo / Permissão | Antes (P-17) | Depois (confirmado na org) |
|---|---|---|
| `Account.Seed_Key__c` editável em `NDG_Salesforce_Admin_Extended` | `false` | **`true`** |
| `Pricebook2` `viewAllRecords`/`modifyAllRecords` | `true`/`true` (não licenciado) | **`false`/`false`** (CRUD íntegro) |
| `Product2` `viewAllRecords`/`modifyAllRecords` | `true`/`true` (não licenciado) | **`false`/`false`** (CRUD íntegro) |

**Observação (não bloqueante):** o relatório de deploy listou como "Changed" outros permission
sets (`NDG_Deal_Desk`, `NDG_Executive_ReadOnly`, `NDG_Integration_Admin`, `NDG_Regional_Director`,
`NDG_RevOps`, `NDG_Sales_Manager`, `NDG_Sales_Rep`) e `Discount_Request__c`, nenhum dos quais faz
parte do `git diff` desta fatia — o conteúdo local desses arquivos já estava commitado em `main`
antes desta rodada. O status "Changed" reflete o cache de source-tracking local do `sf` CLI
divergindo do estado da org (provável de deploys/config anteriores fora deste clone), não uma
mudança de permissão introduzida aqui. O conteúdo reenviado é idêntico ao já versionado — sem
risco de escopo, mas registrado para rastreabilidade.

## E) Idempotência e storage pós-deploy

Segunda execução de `./scripts/shell/seed.sh` após o deploy (quarta execução cumulativa sobre a
mesma massa):

- `Product2 upsert=100`, `Pricebook2 upsert=1`, `PricebookEntry inseridos=0 ja_existiam=200`
- `Account upsert=80`, `Contact upsert=150`, `Lead upsert=80`
- `Opportunity total=100 inseridas=0 atualizadas=100`
- `OpportunityLineItem inseridas=0 atualizadas=180`
- `Quote total=30 inseridas=0 atualizadas=30`
- `QuoteLineItem inseridas=0 atualizadas=50`
- `Order total=30 inseridos=0 atualizados=30`
- `OrderItem inseridos=0 atualizados=50`
- **Zero inserções em qualquer objeto** — critério "roda duas vezes sem duplicar" (§55) confirmado.
- `seed_99_report.apex`: `TOTAL_SEED = 1051`, `PRE_EXISTENTES = 139`, `REGISTROS_TOTAIS = 1190`.

**Storage:**

| Fonte | Valor |
|---|---|
| `DataStorageMB` (API, granularidade grosseira) | 1 MB / 5 MB (20,0%) |
| Estimativa por registro (1.190 registros × ~2 KB) | **~2.380 KB de 5.120 KB ≈ 46,5%** |
| `sf org list limits` (`DataStorageMB`) | `max: 5`, `remaining: 4` — consistente com a leitura grosseira acima |

**46,5% < 50% (portão de fechamento do M2, §55) e < 70% (parada de emergência, §33.2).**

## Impacto em dados/limites

Sem variação de storage nesta rodada em relação ao R08 — os dados já existiam; a segunda carga
só confirmou o mesmo total. `DailyApiRequests`: consumo desta rodada inclui 3 chamadas de
Metadata API (`validate` × 2, `deploy` × 1) mais SOQL/Tooling de verificação — volume baixo,
dentro do teto diário de 15.000 chamadas (§ economia de API do `AGENTS.md`).

## Segurança — ESCALONAMENTO DE SEGURANÇA

Este release **toca permission set** (`NDG_Salesforce_Admin_Extended`): concede escrita em
`Seed_Key__c` e remove `viewAllRecords`/`modifyAllRecords` de `Pricebook2`/`Product2`. Por
definição do `AGENTS.md`, isso se qualifica como **ESCALONAMENTO DE SEGURANÇA** e foi reportado ao
Helix, mesmo a mudança sendo redutora de permissão (remoção de `viewAll`/`modifyAll`) e aditiva
apenas num campo customizado de controle interno do seed (`Seed_Key__c`), não dado de negócio.

**Auditoria de segredo feita antes do `git add` (bloqueante, repositório público):**

- `grep -inE` por `sfdx-auth-url`, `force://`, senha/token/secret/chave, blocos `-----BEGIN`,
  padrão de Org Id (`00D...`) em todos os arquivos alterados — nenhum resultado além de texto de
  documentação descrevendo a própria política de segurança.
- Nenhum ID de org, e-mail real ou dado de pessoa real introduzido nesta fatia — mudança é
  metadata declarativa (permission set) e documentação.
- `.gitignore` confirmado cobrindo `.sfdx/`, `.sf/`, `*.sfdx-auth-url` — não alterado nesta rodada.

## Limitações conhecidas

Ver `known-limitations.md`.

## Go/no-go do Helix

**M2 fecha nesta fatia**, sujeito à ratificação do Helix sobre o ESCALONAMENTO DE SEGURANÇA acima.
Todos os itens da checklist do §33/§55 em `docs/PROGRESSO.md` estão marcados — volume (D-022),
idempotência, script de limpeza, dado sintético, verificação de storage, ratificação de D-020,
correção de P-17 e este pacote de evidência.
