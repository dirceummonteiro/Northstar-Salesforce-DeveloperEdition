# R04 — Release Summary (M1, fatia (d): Big Object `Integration_Log__b`)

## Identificação

| Campo | Valor |
|---|---|
| Marco | M1, fatia (d) — Big Object de observabilidade de integração (§1.5/§9.11) |
| Commit | `feat(NS-M1): adiciona o Big Object Integration_Log__b de observabilidade de integracao` |
| Commit (base anterior) | `b4f6a85` — docs(NS-M1): marca confirmacao do Helix na fatia 3, sem fechar o M1 |
| Branch | `main` |
| Remoto | `origin` |
| Org alvo | alias `helix-dev` (Developer Edition, não-produção) |
| Data | 2026-08-19 |
| Owner do release | Probe |

## O que este release entrega

O objeto `Integration_Log__b` (Big Object, §1.5/§9.11, 17 campos): nome e operação da
integração, objeto e registro Salesforce afetados, payloads de request/response, status HTTP,
resultado, contagem e status de retry, correlação com a tentativa original e com a primeira
tentativa da cadeia. Um único índice composto, `Integration_Log_Index`:
`Integration_Name__c` (ASC) → `Event_Date__c` (DESC) → `Correlation_Id__c` (ASC). Rationale
completo da ordem do índice e do modelo de permissão em **D-012**, `docs/DECISIONS.md`.

**Esta é a segunda tentativa de integrar esta fatia.** A primeira parou corretamente na
validação, por um limite de plataforma não documentado em nenhum material de referência
disponível. Ver "Duas recusas antes da aceita" abaixo.

Chegou pronto no working tree. A correção de `Integration_Name__c` (80 → 64) foi aplicada pelo
`schema` diretamente — não pelo Kernel sob o desvio D-010, diferente das fatias (b) e (c). Ver
observação em `docs/PENDENCIAS.md`, P-15.

## Duas recusas antes da aceita

| # | `Integration_Name__c` | Soma com `Correlation_Id__c` (36) | Deploy ID | Resultado |
|---|---|---|---|---|
| 1 | Text(80) | 116 | `0Affj00000NlcCiCAJ` | Recusado — "The total length for all text fields in an index can't exceed 100 characters" |
| 2 | Text(64) | 100 | `0Affj00000NmAhNCAV` | Recusado — mesma mensagem. Prova que o teto é `< 100`, não `<= 100` |
| 3 | Text(60) | 96 | `0Affj00000NmAkbCAF` (validação) → `0Affj00000NliQBCAZ` (deploy) | **Aceito** |

Nada foi criado na org nas tentativas 1 e 2 — `sf project deploy validate` não escreve, só
valida. A correção da tentativa 2 → 3 (`Integration_Name__c` 64 → 60) foi feita sob autorização
de exceção do Helix, dada antecipadamente para este cenário específico: se a validação falhasse
de novo exatamente pelo teto de 100, reduzir para 60 e tentar mais uma vez sem perguntar. É o
que aconteceu. Detalhe completo em **D-012**.

## Comandos executados

```
git -C . status --porcelain -uall
sf project deploy validate --source-dir force-app --test-level RunLocalTests --target-org helix-dev --json
# (recusado, Deploy ID 0Affj00000NmAhNCAV — Integration_Name__c ainda em 64)
# edição: Integration_Name__c 64 -> 60 (Text), descrição do campo atualizada
sf project deploy validate --source-dir force-app --test-level RunLocalTests --target-org helix-dev --json
# (aceito, Deploy ID 0Affj00000NmAkbCAF)
sf project deploy quick --job-id 0Affj00000NmAkbCAF --target-org helix-dev --json
# (aceito, Deploy ID 0Affj00000NliQBCAZ)
sf sobject describe --sobject Integration_Log__b --target-org helix-dev --json
sf data query --use-tooling-api --target-org helix-dev --query "SELECT QualifiedApiName, DataType FROM FieldDefinition WHERE EntityDefinition.QualifiedApiName = 'Integration_Log__b' ORDER BY QualifiedApiName"
sf project retrieve start --metadata "CustomObject:Integration_Log__b" --target-org helix-dev --output-dir tmp/retrieve-check --json
sf data query --target-org helix-dev --query "SELECT Parent.Name, PermissionsRead, PermissionsCreate, PermissionsEdit, PermissionsDelete, PermissionsViewAllRecords, PermissionsModifyAllRecords FROM ObjectPermissions WHERE SobjectType = 'Integration_Log__b' AND Parent.Name IN ('NDG_Integration_Admin','NDG_RevOps','NDG_Salesforce_Admin_Extended') ORDER BY Parent.Name"
sf data query --target-org helix-dev --query "SELECT Correlation_Id__c FROM Integration_Log__b LIMIT 1"
sf org list limits --target-org helix-dev --json
git add -A -- force-app/main/default/objects/Integration_Log__b/ force-app/main/default/permissionsets/ docs/
git commit
git push origin main
git log origin/main --oneline -3
git status --porcelain -uall
```

Validação e deploy rodaram com timeout estendido dentro do turno (ambos concluíram em minutos,
não nas dezenas de minutos que `RunLocalTests` pode levar em suítes maiores) — mas a saída foi
sempre redirecionada para arquivo (`tmp/r04-validate-*.json`, `tmp/r04-deploy.json`) e lida
depois, conforme a prática do `AGENTS.md` para tarefa longa.

## Resultado

- Validação final (`0Affj00000NmAkbCAF`): **Succeeded**, 111/111 componentes, 0 erros, 3/3
  testes (`RunLocalTests`, mesma suíte `HttpCalloutServiceTest` das fatias anteriores — 100% de
  cobertura em `HttpCalloutService`, 15/15 linhas).
- Deploy real (`0Affj00000NliQBCAZ`, `checkOnly: false`, `deploy quick` sobre a validação):
  **Succeeded**, 111/111 componentes, 0 erros. `numberTestsCompleted: 0` — esperado, `quick
  deploy` reaproveita os testes já rodados na validação, não roda de novo.
- Confirmado na org via Tooling API (`FieldDefinition`): 21 campos totais em
  `Integration_Log__b` = 4 padrão (`Id`, `CreatedById`, `CreatedDate`, `SystemModstamp`) + 17
  custom, batendo com os 17 arquivos entregues. `Integration_Name__c` = Texto(60),
  `Correlation_Id__c` = Texto(36).
- Índice confirmado via `sf project retrieve start` isolado: `Integration_Log_Index` com
  `Integration_Name__c` (ASC) → `Event_Date__c` (DESC) → `Correlation_Id__c` (ASC), a mesma
  ordem do source.
- `ObjectPermissions` confirmados na org via SOQL (tabela completa na seção de segurança
  abaixo).
- `SELECT Correlation_Id__c FROM Integration_Log__b LIMIT 1` retornou 0 registros — objeto
  vazio, nenhum registro de teste criado.

Detalhes completos em `manifest.md` e `known-limitations.md`.

## Impacto em dados/limites

`DataStorageMB`: Remaining 5 / Max 5, sem alteração — Big Object não consome data storage
comum, por design da plataforma (é exatamente por isso que a §1.5 escolheu este mecanismo).
`DailyApiRequests`: Remaining 14.698 / Max 15.000 na leitura final deste release (medido após
todas as consultas de confirmação). Consumo desta fatia inclui 3 validações + 1 deploy + 1
describe + 1 retrieve + 3 queries SOQL/Tooling — mais do que uma fatia sem recusa de plataforma,
pelo custo das duas tentativas recusadas e da confirmação medida (não deduzida) na org.

## Segurança — ESCALONAMENTO DE SEGURANÇA (reporte obrigatório ao Helix)

Este release **toca 3 dos permission sets `NDG_*`** (`NDG_Integration_Admin`, `NDG_RevOps`,
`NDG_Salesforce_Admin_Extended`) — por definição do `AGENTS.md`, isso é marcado como
ESCALONAMENTO DE SEGURANÇA e reportado ao Helix, independentemente do resultado da revisão.

**Diferente de R03, esta fatia não amplia superfície de `viewAllRecords`/`modifyAllRecords`.**
É o oposto: o desenho é deliberadamente mais restrito do que qualquer permission set já tocado
neste projeto — nenhum dos 3 tem `Edit`, `Delete`, `ViewAllRecords` ou `ModifyAllRecords` sobre
`Integration_Log__b`.

| Permission Set | `Create` | `Read` | `Edit` | `Delete` | `ViewAllRecords` | `ModifyAllRecords` |
|---|---|---|---|---|---|---|
| `NDG_Integration_Admin` | `true` | `true` | `false` | `false` | `false` | `false` |
| `NDG_RevOps` | `false` | `true` | `false` | `false` | `false` | `false` |
| `NDG_Salesforce_Admin_Extended` | `true` | `true` | `false` | `false` | `false` | `false` |

Tabela acima medida por SOQL contra `ObjectPermissions` na org, não deduzida do XML fonte nem
do resultado do deploy.

**Revisão de conteúdo feita antes do deploy** (varredura sobre `git diff` e sobre os arquivos
novos, com `grep` para senha, `sfdx-auth-url`, token, `.sfdx`/`.sf`, ID de org e dado de pessoa
real — nenhuma ocorrência):

- Nenhum dos 21 arquivos novos/alterados (17 campos + objeto + índice + 3 permission sets)
  contém segredo, credencial ou ID de org em comentário.
- Nenhum permission set concede `View All Data` / `Modify All Data` (permissão de sistema) —
  confirmado ausência de `<userPermissions>` nos 3 arquivos.
- `NDG_RevOps` não tem `Create` — confirmado no XML fonte e via SOQL na org.
- Nenhum campo de `Integration_Log__b` tem `<fieldPermissions>` declarada em nenhum permission
  set (comportamento esperado para Big Object: FLS de Big Object segue o `ObjectPermissions`,
  não campo a campo).
- `.sfdx/` e `.sf/` continuam ignorados (`git status --porcelain -uall` confirmado antes do
  commit).
- Os arquivos de evidência bruta de comando (`tmp/r04-validate*.json`, `tmp/r04-deploy.json`,
  `tmp/r04-describe.json`, `tmp/r04-fields.json`, `tmp/r04-objperms.json`, `tmp/r04-count.json`,
  `tmp/r04-retrieve.json`, `tmp/retrieve-check/`) ficam em `tmp/`. **`tmp/` não está no
  `.gitignore`** — diferente do que uma versão anterior deste texto assumia. Por isso o commit
  desta fatia usa `git add` explícito só em `docs/` e `force-app/`, nunca `git add -A` nem
  `git add tmp/`, para que esses arquivos de saída de comando (que incluem Deploy IDs e nomes de
  usuário da org, não segredo, mas também não artefato de projeto) fiquem fora do histórico
  público. Ficou registrado aqui como um item para o Helix avaliar: adicionar `tmp/` ao
  `.gitignore` evitaria depender de recordar isso a cada release.

## Limitações conhecidas

Ver `known-limitations.md`. Destaque: (a) `PROGRESSO.md` segue medindo o M1 como não fechado;
(b) o teto de 100 caracteres do índice de Big Object é exclusivo (`< 100`), não documentado em
nenhuma fonte alcançada antes do deploy — conhecimento agora capturado em D-012 para reuso; (e)
`Integration_Name__c`/`Correlation_Id__c` não podem crescer depois sem recriar o objeto, por
causa do índice imutável.

## Go/no-go do Helix

Pendente. Com esta fatia, o M1 ganha o Big Object de observabilidade previsto na §1.5. Fica
para o Helix: (1) confirmar o modelo de permissão append-only de D-012 como desenhado; (2)
avaliar a observação sobre P-15 em `docs/PENDENCIAS.md` — o `schema` aplicou uma correção
diretamente nesta fatia, o que pode ser sinal de que o agente voltou a inicializar; (3) decidir
se o M1 fecha nesta rodada ou se aguarda os objetos custom restantes da §9 e os permission
tests da limitação (c), ainda abertos desde R02.
