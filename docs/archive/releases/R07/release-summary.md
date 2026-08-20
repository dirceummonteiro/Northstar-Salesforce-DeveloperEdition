# R07 — Release Summary (M2, fatia (a): campo de idempotência `Seed_Key__c`)

## Identificação

| Campo | Valor |
|---|---|
| Marco | M2, fatia (a) — a chave técnica de idempotência do seed data (§33, D-014) |
| Commit | (registrado após este pacote de evidência — ver hash final no relatório da tarefa) |
| Branch | `main` |
| Remoto | `origin` |
| Base | `4297ab3` (fechamento do M1, `HEAD == origin/main` no início desta rodada) |
| Org alvo | alias `helix-dev` (Developer Edition, não-produção) |
| Data | 2026-08-19 |
| Owner do release | Probe |
| Produzido por | agente `schema` (primeira metadata dele desde a resolução de P-15 — ver D-018) |

## O que este release entrega

O campo `Seed_Key__c` (Text 40, `externalId=true`, `unique=true`, `caseSensitive=true`) em 11
objetos: `Account`, `Contact`, `Lead`, `Product2`, `Pricebook2`, `Opportunity`,
`OpportunityLineItem`, `Quote`, `QuoteLineItem`, `Order`, `OrderItem`. FLS somente-leitura
(`readable=true`, `editable=false`) desse campo nos 8 permission sets `NDG_*`. Contexto completo
da decisão em **D-014**, `docs/DECISIONS.md`. `PricebookEntry` fica de fora por desenho — ver
`known-limitations.md`, item (a).

## Comandos executados

```
sf project deploy validate --source-dir force-app --test-level RunLocalTests --target-org helix-dev
sf project deploy quick --job-id 0Affj00000Nmmt9CAB --target-org helix-dev
sf data query --use-tooling-api --target-org helix-dev \
  --query "SELECT QualifiedApiName, EntityDefinition.QualifiedApiName, IsIndexed, DataType \
           FROM FieldDefinition \
           WHERE EntityDefinition.QualifiedApiName IN (11 objetos) AND QualifiedApiName='Seed_Key__c'"
sf limits api display --target-org helix-dev
```

## Resultado

- **Validação** (`0Affj00000Nmmt9CAB`): **Succeeded**, 122/122 componentes, 0 erros de
  componente, 3/3 testes (`RunLocalTests`), 0 falhas. Única classe de teste do projeto
  (`HttpCalloutServiceTest`, D-006) — 100% de cobertura em `HttpCalloutService` (15/15 linhas).
  Nenhum objeto foi recusado pela plataforma, inclusive os três de maior risco
  (`OpportunityLineItem`, `QuoteLineItem`, `OrderItem`) — `externalId`/`unique` foram aceitos
  nos 11 objetos sem exceção. O passo 3 autorizado pela tarefa (remoção seletiva por recusa de
  plataforma) não precisou ser exercido.
- **Deploy real** (`deploy quick` sobre a validação acima, `0Affj00000NnBZmCAN`): **Succeeded**,
  122/122 componentes, 0 erros. `deploy quick` não reexecuta testes (`numberTestsCompleted: 0`
  no resultado) porque reaproveita o resultado já verde do `deploy validate`.
- **Confirmação na org via Tooling API `FieldDefinition`** (não `sf sobject describe` — P-16):
  os 11 registros esperados voltaram, um por objeto, todos com `IsIndexed = true` e `DataType`
  contendo `(ID externo)` + `(Diferenciação exclusiva de maiúsculas e minúsculas)` — a tradução
  pt-BR de `External Id` + `Unique Case Sensitive`. Nenhum objeto faltando, nenhum a mais:

  | Objeto | `IsIndexed` | `DataType` |
  |---|---|---|
  | Account | true | Texto(40) (ID externo) (Diferenciação exclusiva de maiúsculas e minúsculas) |
  | Contact | true | Texto(40) (ID externo) (Diferenciação exclusiva de maiúsculas e minúsculas) |
  | Lead | true | Texto(40) (ID externo) (Diferenciação exclusiva de maiúsculas e minúsculas) |
  | Opportunity | true | Texto(40) (ID externo) (Diferenciação exclusiva de maiúsculas e minúsculas) |
  | OpportunityLineItem | true | Texto(40) (ID externo) (Diferenciação exclusiva de maiúsculas e minúsculas) |
  | Order | true | Texto(40) (ID externo) (Diferenciação exclusiva de maiúsculas e minúsculas) |
  | OrderItem | true | Texto(40) (ID externo) (Diferenciação exclusiva de maiúsculas e minúsculas) |
  | Pricebook2 | true | Texto(40) (ID externo) (Diferenciação exclusiva de maiúsculas e minúsculas) |
  | Product2 | true | Texto(40) (ID externo) (Diferenciação exclusiva de maiúsculas e minúsculas) |
  | Quote | true | Texto(40) (ID externo) (Diferenciação exclusiva de maiúsculas e minúsculas) |
  | QuoteLineItem | true | Texto(40) (ID externo) (Diferenciação exclusiva de maiúsculas e minúsculas) |

## Impacto em dados/limites

- `DataStorageMB`: **0 MB em uso / 5 MB máx (0%)** — inalterado, esta fatia é só metadata
  declarativa, nenhum registro carregado ainda. Medido via `sf limits api display -o helix-dev`
  logo após o deploy: `DataStorageMB max=5, remaining=5`. A §33.2 manda parar acima de 70%; o
  portão do M2 (§55, D-017) é 50%. **O número hoje está a 0 pontos percentuais de ambos os
  portões** — a folga inteira do orçamento da §33 ainda está disponível para as próximas fatias
  do M2 (carga de ~1.620 registros).
- `DailyApiRequests`: remaining 14.043 / 15.000 ao final desta rodada (≈6,4% do dia consumido,
  a maior parte pela consulta de metadata da validação e pela leitura de `FieldDefinition`).

## Segurança — ESCALONAMENTO DE SEGURANÇA (reporte obrigatório ao Helix)

Este release **toca permission set diretamente** (FLS nos 8 `NDG_*`) — por definição do
`AGENTS.md`, isso é marcado como ESCALONAMENTO DE SEGURANÇA e reportado ao Helix,
independentemente do resultado da revisão. Não é um bloqueio: é o protocolo de visibilidade.

**Revisão de conteúdo feita antes do deploy:**

- `git status --porcelain -uall` conferido contra a lista exata que a tarefa descreveu — bateu
  campo por campo, nenhum arquivo extra, nenhum faltando.
- Nenhum arquivo do working tree contém `.sfdx/`, `.sf/`, `sfdx-auth-url`, segredo, token, senha,
  dado de pessoa real ou Id de org em comentário — varredura `grep -riE` antes de qualquer
  `git add` (feita nesta rodada, não reaproveitada de rodada anterior).
- A FLS adicionada é **somente-leitura** (`editable=false`) nos 11×8 = 88 pares
  campo/permission set — nenhum dos 8 `NDG_*` ganhou permissão de escrita em `Seed_Key__c`,
  confirmado no diff antes do commit.
- `Seed_Key__c` não carrega dado de negócio nem de pessoa real — é um campo técnico vazio até a
  próxima fatia do M2 popular o seed.
- Nenhuma alteração em `ObjectPermissions`, `userPermissions`, sharing rule ou Named Credential
  nesta rodada — o escopo do diff é estritamente `fieldPermissions` novas mais os 11 arquivos de
  campo.

Nenhuma exposição de dado nova: o campo é técnico, somente-leitura para todas as personas, e
ainda não tem valor gravado em nenhum registro.

## Limitações conhecidas

Ver `known-limitations.md`.

## Go/no-go do Helix

Pendente. Esta fatia entrega a base de idempotência do M2, mas o M2 **não fecha** com este
release — falta a carga dos ~1.620 registros de seed (D-015, execução do Kernel), o script de
limpeza correspondente, e a reconfirmação de storage abaixo de 50% depois da carga.
`docs/PROGRESSO.md` permanece em **2 / 13**.
