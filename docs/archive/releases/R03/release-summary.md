# R03 — Release Summary (M1, fatias (b) e (c): metadata de política e Discount_Request__c)

## Identificação

| Campo | Valor |
|---|---|
| Marco | M1, fatias (b) e (c) — Custom Metadata Types de política (§9.7/§9.8/§9.16) e o objeto `Discount_Request__c` (§9.9) |
| Commit (fatia b) | `db3391d` — feat(NS-M1): adiciona os custom metadata types de precificacao, margem e frete |
| Commit (fatia c) | `897cfef` — feat(NS-M1): adiciona o objeto Discount_Request__c |
| Commit (base anterior) | `42c3032` — docs(NS-M1): registra evidência de release R02 |
| Branch | `main` |
| Remoto | `origin` (push confirmado: `42c3032..897cfef main -> main`) |
| Org alvo | alias `helix-dev` (Developer Edition, não-produção) |
| Data | 2026-08-19 |
| Owner do release | Probe |

## O que este release entrega

**Fatia (b)** — três Custom Metadata Types de política, decisão de arquitetura já registrada na
própria §9.7 do escopo ("prefer Custom Metadata if rules are deployment-time configuration"):

- `Pricing_Rule__mdt` (11 campos) + 8 registros: 4 de tier (`Bronze`/`Silver`/`Gold`/`Platinum`)
  e 4 de volume (`1-9`, `10-49`, `50-99`, `100+`).
- `Margin_Policy__mdt` (9 campos) + 1 registro (`Default_Policy`).
- `Freight_Rule__mdt` (9 campos) + 2 registros (`Nordeste_Heavy_PE01`, `Sudeste_Light_SP01`).

**Fatia (c)** — o objeto custom `Discount_Request__c` (13 campos, conforme §9.9 literalmente),
`sharingModel: ControlledByParent` sobre `Opportunity` via `Opportunity__c` (master-detail) — a
descrição do próprio objeto documenta a razão: "sharing inherited from the opportunity means
whoever sees the deal sees the request." Consequência direta desta fatia: os 7 permission sets
`NDG_*` existentes ganharam `ObjectPermissions`/`FieldPermissions` para `Discount_Request__c`
(FLS explícita nos 12 campos que aceitam FLS; `Opportunity__c` é master-detail e não recebe
`FieldPermissions` — comportamento padrão da plataforma, não omissão).

Chegou pronto no working tree, sem commit, produzido pelo Kernel sob o desvio D-010 (agente
`schema` segue não inicializando, P-15) — o mesmo padrão da fatia (a) de R02, mas desta vez com
visibilidade de origem: cabeçalho de desvio confirmado pelo Helix na tarefa.

## Comandos executados

```
git -C . log origin/main --oneline -5
git -C . status --porcelain -uall
git add -A -- force-app/main/default/customMetadata/ force-app/main/default/objects/Pricing_Rule__mdt/ \
  force-app/main/default/objects/Margin_Policy__mdt/ force-app/main/default/objects/Freight_Rule__mdt/ \
  force-app/main/default/objects/Discount_Request__c/ force-app/main/default/permissionsets/
git diff --cached   # varredura de segurança, ver smoke-test.md
sf project deploy validate --source-dir <6 diretórios envolvidos> --test-level RunLocalTests --target-org helix-dev
sf project deploy start --source-dir <6 diretórios envolvidos> --test-level RunLocalTests --target-org helix-dev
sf data query --target-org helix-dev --query "SELECT COUNT() FROM Pricing_Rule__mdt"
sf data query --target-org helix-dev --query "SELECT COUNT() FROM Margin_Policy__mdt"
sf data query --target-org helix-dev --query "SELECT COUNT() FROM Freight_Rule__mdt"
sf data query --target-org helix-dev --query "SELECT COUNT() FROM Discount_Request__c"
sf data query --target-org helix-dev --query "SELECT Parent.Name, PermissionsRead, PermissionsEdit, PermissionsCreate, PermissionsDelete, PermissionsViewAllRecords, PermissionsModifyAllRecords FROM ObjectPermissions WHERE SobjectType='Discount_Request__c' ORDER BY Parent.Name"
sf data query --target-org helix-dev --query "SELECT Parent.Name, Field, PermissionsRead, PermissionsEdit FROM FieldPermissions WHERE SobjectType='Discount_Request__c' ORDER BY Field, Parent.Name"
sf apex run test --target-org helix-dev --result-format human --code-coverage --wait 20
sf org list limits --target-org helix-dev
git commit (dois commits, um por fatia)
git push origin main
```

Deploy validate e deploy real rodaram **fora do turno interativo**, em background com saída
redirecionada para arquivo (`nohup ... --json > deploy.json`), e o arquivo foi lido depois —
conforme a regra do `AGENTS.md` sobre tarefa longa nunca ser esperada dentro do turno.

## Resultado

- Validação (`0Affj00000NipBFCAZ`): **Succeeded**, 65/65 componentes, 0 erros, 3/3 testes
  (`RunLocalTests`).
- Deploy real (`0Affj00000NipPlCAJ`, `checkOnly: false`): **Succeeded**, 66/66 componentes
  entregues (65 de metadata + `package.xml`), 0 erros, 3/3 testes.
- Confirmado na org via SOQL: `Pricing_Rule__mdt` = 8 registros, `Margin_Policy__mdt` = 1,
  `Freight_Rule__mdt` = 2, `Discount_Request__c` = 0 (objeto vazio — correto, é operacional, não
  vem com seed nesta fatia; seed é escopo do M2).
- `ObjectPermissions`/`FieldPermissions` de `Discount_Request__c` confirmados na org por
  persona — ver `smoke-test.md` e a seção de segurança abaixo.

Detalhes completos em `manifest.md`, `test-results.md`, `coverage-summary.md`,
`deployment-result.md`, `smoke-test.md`.

## Impacto em dados/limites

`DataStorageMB`: Remaining 5 / Max 5, sem alteração — Custom Metadata Types não consomem data
storage (por design da plataforma, D-010 e §1.5) e `Discount_Request__c` está vazio nesta fatia.
`DailyApiRequests`: Remaining 14.826 / Max 15.000 na leitura final (1,2% em uso no dia, mesma
janela diária de R02 — sem reset de contador entre os dois releases). Detalhe em
`deployment-result.md`.

## Segurança — ESCALONAMENTO DE SEGURANÇA (reporte obrigatório ao Helix)

Este release **toca os 7 permission sets `NDG_*`** — por definição do `AGENTS.md`, isso é
marcado como ESCALONAMENTO DE SEGURANÇA e reportado ao Helix, independentemente do resultado da
revisão. Não é um bloqueio automático: é o protocolo de visibilidade que o `AGENTS.md` exige
sempre que permission set é tocado, mesmo quando o conteúdo parece pequeno ou correto.

**O que é novo em relação a R02** — R02 registrou explicitamente que nenhum dos 8 permission
sets concedia `View All Records` além do estritamente descrito por persona. **Este release muda
esse fato**: ao integrar `Discount_Request__c`, 3 dos 7 permission sets tocados ganharam
`viewAllRecords: true` sobre objetos de negócio:

| Permission Set | Objeto | `viewAllRecords` | `modifyAllRecords` | Consistente com a persona? |
|---|---|---|---|---|
| `NDG_Deal_Desk` | `Opportunity` | `false` → `true` | `false` | Sim — Deal Desk aprova desconto em qualquer negociação da empresa, não só na própria carteira; sem isso a fila de aprovação fica cega para deals fora da própria hierarquia. |
| `NDG_Deal_Desk` | `Discount_Request__c` (novo) | `true` | `false` | Mesma razão — a fila de aprovação central precisa ver todo pedido, mas não pode editar campos além dos liberados (ver FLS abaixo). |
| `NDG_Executive_ReadOnly` | `Discount_Request__c` (novo) | `true` | `false` (edit também `false`) | Sim — a persona já é `ReadOnly` por desenho; visão executiva exige ver todo pedido de desconto da empresa, sem poder editar nada. |
| `NDG_Regional_Director` | `Discount_Request__c` (novo) | `true` | `false` (edit também `false`) | Sim — diretor regional é um dos aprovadores da matriz (§17.2); precisa ver pedidos além da própria região para escalonamento, mas não edita. |
| `NDG_RevOps` | `Discount_Request__c` (novo) | `true` | `false` | Sim — RevOps administra o processo (`allowCreate`/`allowEdit`/`allowDelete` = `true`), mas segue sem a permissão de sistema `Modify All Data`. |
| `NDG_Salesforce_Admin_Extended` | `Discount_Request__c` (novo) | `true` | `true` | Sim — é a persona administrativa mais ampla das 8, já documentada em R02 como tendo `viewAllRecords`/`modifyAllRecords` por objeto (não a permissão de sistema) sobre os objetos de negócio do projeto; `Discount_Request__c` entra nesse padrão já estabelecido. |

Nenhum desses é a permissão de sistema `View All Data` / `Modify All Data` (confirmado: nenhuma
tag `<userPermissions>` em nenhum dos 7 arquivos) — é `viewAllRecords`/`modifyAllRecords` por
`ObjectPermissions`, escopado ao objeto, exatamente como `NDG_Salesforce_Admin_Extended` já fazia
sobre outros objetos desde R02. A diferença real é que R02 podia dizer "nenhum permission set
concede View All Records além do estrito" e essa frase deixa de ser verdadeira a partir deste
release — por isso a tabela acima existe, para que o Helix veja exatamente onde e por quê.

**Revisão de conteúdo feita antes do deploy** (detalhe em `smoke-test.md`):

- Nenhum dos 64 arquivos novos/alterados contém segredo, `sfdx-auth-url`, token, senha, ID de
  org ou dado de pessoa real (varredura com `grep` sobre `git diff --cached` antes do deploy e
  antes do commit).
- Nenhum registro de Custom Metadata (`Pricing_Rule`, `Margin_Policy`, `Freight_Rule`) contém
  dado de cliente real — são parâmetros de regra (percentuais, faixas, códigos de depósito),
  não registros de negócio.
- Nenhum permission set concede `View All Data` / `Modify All Data` (permissão de sistema).
- `Discount_Request__c` tem `sharingModel: ControlledByParent` — herda o sharing da
  `Opportunity` via master-detail; os `viewAllRecords` acima são a exceção deliberada por
  persona, documentada na tabela acima, não um enfraquecimento do modelo base.
- Campos de negociação sensíveis (`Requested_Discount__c`, `Requested_Margin_Percent__c`,
  `Current_Margin_Percent__c`, `Policy_Discount__c`) permanecem **somente leitura** (FLS
  `PermissionsEdit = false`) em todos os 7 permission sets, inclusive nos que têm `allowEdit`
  no objeto — confirmado por `FieldPermissions` na org, não só no XML fonte. Só `Status__c`,
  `Reason__c`, `Decision_Notes__c`, `Decision_At__c`, `Current_Approver__c`,
  `Approval_Level__c`, `Requested_By__c` são editáveis, e variam por persona conforme a etapa do
  fluxo de aprovação que cada uma opera.
- `Opportunity__c` (o master-detail) não aparece em `FieldPermissions` em nenhum permission
  set — comportamento padrão da plataforma para campos master-detail, não uma omissão da fatia.
- `.sfdx/` e `.sf/` continuam ignorados (`git status --porcelain -uall` confirmado antes do
  commit, nenhum arquivo dessas pastas listado).

## Limitações conhecidas

Ver `known-limitations.md`. Destaque: (a) `PROGRESSO.md` segue medindo o M1 como não fechado
até os permission tests (`System.runAs()`) existirem — limitação (c) de R02, ainda aberta; (b) a
tabela de `viewAllRecords` acima é nova neste release e deveria entrar na revisão de segurança
do Helix antes do M1 fechar, mesmo não bloqueando esta integração.

## Go/no-go do Helix

Pendente — com esta fatia, a §55 (objetos, campos, relacionamentos, permission sets) tem todos
os componentes declarativos do M1 no repositório e na org: `Account`/`Opportunity` (R01),
permission sets (R02), Custom Metadata de política e `Discount_Request__c` (este release).
`PROGRESSO.md` é atualizado para refletir (b) e (c) concluídas, mas **o M1 como marco inteiro
segue não fechado** — a limitação (c) de R02 (permission tests `System.runAs()`) continua aberta
e a §55.1 exige o marco completo e validado antes do número subir. Fica para o Helix: (1) decidir
se aceita a tabela de `viewAllRecords` acima como desenhada; (2) decidir se os permission tests
entram como tarefa própria antes de declarar o M1 fechado.
