# Scripts de seed data — marco M2

Massa sintética de demonstração para a org `helix-dev`. Apex anônimo, idempotente
por construção (**D-015**).

## Arquivos

| Arquivo | O que faz |
|---|---|
| `seed_01_catalog.apex` | `Product2` (100), `Pricebook2` de parceiro (1), `PricebookEntry` (200) |
| `seed_02_customers.apex` | `Account` (80), `Contact` (150), `Lead` (80) |
| `seed_03_pipeline.apex` | `Opportunity` (100), `OpportunityLineItem` (180), `Quote` (30), `QuoteLineItem` (50), `Order` (30), `OrderItem` (50) |
| `seed_99_report.apex` | Somente leitura. Conta o seed por objeto e estima o storage |
| `cleanup_seed.apex` | **Destrutivo.** Apaga só o que tem `Seed_Key__c LIKE 'NS-%'` e esvazia a lixeira |

Total: **1.051 registros**.

As três etapas rodam **em ordem** — a etapa 3 lê contas e entradas de preço que
as etapas 1 e 2 criam. Estão separadas porque Apex anônimo tem teto de 32.000
caracteres por execução; um script único não cabe.

## Como rodar

```bash
./scripts/shell/seed.sh            # carrega (idempotente) e imprime as contagens
./scripts/shell/cleanup-seed.sh    # DESTRUTIVO: apaga a massa e reconta
```

Ou etapa a etapa:

```bash
sf apex run --target-org helix-dev --file scripts/apex/seed_01_catalog.apex
sf apex run --target-org helix-dev --file scripts/apex/seed_02_customers.apex
sf apex run --target-org helix-dev --file scripts/apex/seed_03_pipeline.apex
sf apex run --target-org helix-dev --file scripts/apex/seed_99_report.apex
```

O alias da org sai de `ORG_ALIAS` (default `helix-dev`).

## Pré-requisito de permissão

O usuário conectado precisa **enxergar `Seed_Key__c`**. A fatia (a) do M2
entregou o campo com FLS apenas nos 8 permission sets `NDG_*`, e nenhum *perfil*
o enxerga — nem o de administrador do sistema. Sem isso o Apex anônimo **não
compila**:

```
No such column 'Seed_Key__c' on entity 'Account'
```

O mesmo vale para `sf data query` e `sf sobject describe`: os dois passam pela
FLS do usuário e relatam o campo como inexistente, o que é fácil de confundir
com "o deploy não chegou na org". Para confirmar que o campo existe de fato,
consulte a Tooling API:

```bash
sf data query --target-org helix-dev --use-tooling-api \
  --query "SELECT QualifiedApiName FROM FieldDefinition \
           WHERE EntityDefinition.QualifiedApiName = 'Account' AND QualifiedApiName = 'Seed_Key__c'"
```

Destravar é atribuir um permission set `NDG_*` ao usuário que roda o seed. A
correção definitiva — FLS do campo no perfil — é metadata declarativa, portanto
do `schema`, e o deploy é do Probe (§65.1). Ver **D-019**.

## Idempotência

Rodar duas vezes não duplica nada. Todo registro carrega `Seed_Key__c` com o
prefixo `NS-` (**D-014**), e o casamento acontece assim:

- **`upsert ... Seed_Key__c` direto** em `Account`, `Contact`, `Lead`,
  `Product2` e `Pricebook2` — todos os campos usados são atualizáveis.
- **Insert/update separados** em `Opportunity`, `Quote`, `Order`,
  `OpportunityLineItem`, `QuoteLineItem` e `OrderItem`. Nesses objetos,
  `Pricebook2Id`, `OpportunityId`, `QuoteId`, `OrderId`, `PricebookEntryId` e
  `Product2Id` são `createable` mas **não** `updateable`; um upsert reenviaria
  esses campos na segunda execução e a plataforma recusaria a atualização. O
  script consulta as chaves existentes, manda o payload completo só no insert e
  no update apenas os campos mutáveis. O contrato continua sendo casar por
  `Seed_Key__c`; muda o mecanismo onde a plataforma não aceita upsert (**D-019**).
- **`PricebookEntry`** não aceita campo customizado (**D-014**), então a chave é
  a natural `Pricebook2Id + Product2Id`.

Os valores de campo são derivados do índice do registro — sem `Math.random()`.
Duas execuções produzem chave **e** conteúdo idênticos.

## Dados fictícios — o repositório é público

- Nomes de empresa e de pessoa: combinações sintéticas indexadas.
- E-mails: sempre em `@example.com` (RFC 2606, reservado para exemplo).
- Telefones: prefixo `5550`, equivalente brasileiro da convenção de número
  fictício.
- Documentos (CPF/CNPJ): **nenhum é gerado.** Não existe campo de documento no
  modelo de dados, e não se inventa um.
- Leads usam vocabulário próprio de nomes e empresas, separado do de contas e
  contatos. Isso não é enfeite: a regra padrão de duplicidade de `Lead` compara
  lead contra contato, e reutilizar o mesmo conjunto fazia a plataforma recusar
  12 de 80 leads com `DUPLICATES_DETECTED`.

## Storage

A org é Developer Edition: **5 MB**, ~2 KB por registro (§1.5).

| | Registros | ~KB | % de 5 MB |
|---|---|---|---|
| Pré-existentes (amostra da DE, **D-016**) | 139 | 278 | 5,4% |
| Seed do M2 | 1.051 | 2.102 | 41,1% |
| **Total** | **1.190** | **2.380** | **46,5%** |

Abaixo do portão de 50% do M2 (**D-017**) e bem abaixo da parada obrigatória de
70% da §33.2. Cada etapa checa o storage antes de gravar e **aborta sem gravar
nada** se já estiver em 70% ou mais.

O volume é menor que os ~1.620 registros da tabela da §33 porque os dois números
não cabem na mesma org: 1.620 + 139 dariam ~68,7%, reprovando o critério de
aceite do M2. Ver **D-019**.

Para mudar o volume, edite o bloco `PERFIL DE VOLUME` / as constantes `N_*` no
topo de cada etapa. Suba os números só depois de refazer a conta acima.

### Por que a estimativa por registro, e não a API de limites

`OrgLimits.getMap().get('DataStorageMB')` devolve **MB inteiro** — granularidade
grosseira demais para um portão de 50% numa org de 5 MB (a mesma carga aparece
como `0/5` ou `1/5` dependendo do arredondamento). A conta por registro é a
medida reportável; o número da API sai ao lado, para conferência.

## Limitações conhecidas

- Todos os `Order` ficam em `Draft`. `Activated` dispara a validação de ativação
  de pedido, que é comportamento de negócio do M8 e não pertence ao seed.
- `Quote.Status` usa os valores de API em português (`Rascunho`, `Apresentado`,
  `Aceito`) porque a org roda em pt-BR. Confirmado por `describe`, não suposto.
- O seed grava com `DuplicateRuleHeader.AllowSave = true` em `Account` e
  `Contact`: a massa sintética dispara as regras padrão de duplicidade de
  propósito. Isso vale para dado de demonstração; não é padrão a copiar para
  carga de dado real.
