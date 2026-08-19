# R02 — Release Summary (M1, fatia (a): permission sets das 9 personas)

## Identificação

| Campo | Valor |
|---|---|
| Marco | M1, fatia (a) — os 8 permission sets de perfil funcional (§30.2) |
| Commit (permission sets) | `a4185b9` — feat(NS-M1): adiciona os 8 permission sets de perfil funcional |
| Commit (`.gitignore`, independente) | `56032b9` — chore: ignora DREAMS.md e memory/ do agente Helix no versionamento |
| Commit (base anterior) | `e7544c9` — docs(NS-M1): registra evidência de release R01 |
| Branch | `main` |
| Remoto | `origin` (push confirmado: `e7544c9..a4185b9 main -> main`) |
| Org alvo | alias `helix-dev` (Developer Edition, não-produção) |
| Data | 2026-08-19 |
| Owner do release | Probe |

## O que este release entrega

Os 8 permission sets da §30.2: `NDG_Sales_Rep`, `NDG_Sales_Manager`, `NDG_Regional_Director`,
`NDG_Deal_Desk`, `NDG_RevOps`, `NDG_Integration_Admin`, `NDG_Executive_ReadOnly`,
`NDG_Salesforce_Admin_Extended`. Cada um concede `ObjectPermissions` e `FieldPermissions`
compatíveis com a descrição da persona, incluindo FLS explícita para os 24 campos comerciais
entregues em R01 — que, sem isso, permaneciam invisíveis para todo mundo (limitação (c) de R01).
`NDG_Portal_User` continua adiado com o portal (§2.2), conforme a própria §30.2 instrui.

## Comandos executados

```
sf project deploy validate --source-dir force-app/main/default/permissionsets --test-level RunLocalTests --target-org helix-dev
sf project deploy quick --job-id 0Affj00000NhxUDCAZ --target-org helix-dev
sf project deploy report --job-id 0Affj00000NhwRiCAJ --target-org helix-dev
sf apex run test --target-org helix-dev --result-format human --code-coverage --wait 20
sf data query --target-org helix-dev --query "SELECT Id, Name, Label FROM PermissionSet WHERE Name LIKE 'NDG_%' ORDER BY Name"
sf data query --target-org helix-dev --query "SELECT Parent.Name, Field, PermissionsRead, PermissionsEdit FROM FieldPermissions WHERE ParentId IN (...)"
sf org list limits --target-org helix-dev
```

## Resultado

- Validação (`0Affj00000NhxUDCAZ`): **Succeeded**, 8/8 componentes, 0 erros, 3/3 testes
  (`RunLocalTests`).
- Deploy real (quick, `0Affj00000NhwRiCAJ`): **Succeeded**, 8/8 componentes, 0 erros.
- Smoke test Apex pós-deploy: **Passed**, 3/3, 100% cobertura, Test Run Id `707fj00000u7Vti`.
- Os 8 permission sets confirmados na org via SOQL, `Name` batendo com o `fullName` de cada
  arquivo.
- Os 24 campos de R01 têm FLS concedida por ao menos um permission set — confirmado via
  `FieldPermissions` (183 registros, campos distintos = exatamente os 24 esperados, nenhum a
  mais nem a menos).
- Margem e desconto (`Gross_Margin_Amount__c`, `Gross_Margin_Percent__c`,
  `Total_Discount_Percent__c`) permanecem `PermissionsEdit = false` em **todos** os 8 permission
  sets — verificado na org, não só no XML fonte.

Detalhes completos em `manifest.md`, `test-results.md`, `coverage-summary.md`,
`deployment-result.md`, `smoke-test.md`.

## Impacto em dados/limites

`DataStorageMB`: Remaining 5 / Max 5, sem alteração — permission set não consome storage de
dados. `DailyApiRequests`: Remaining 14.954 / Max 15.000 na leitura final (0,3% em uso no dia).
Sem baseline própria medida antes do primeiro comando desta tarefa; o número de R01
(Remaining 14.643) não é comparável porque o contador diário resetou entre os dois releases.
Detalhe em `deployment-result.md`.

## Segurança — ESCALONAMENTO DE SEGURANÇA (reporte obrigatório ao Helix)

Este release **toca permission set diretamente** — por definição do `AGENTS.md`, isso é marcado
como ESCALONAMENTO DE SEGURANÇA e reportado ao Helix, independentemente do resultado da revisão.
Este não é um bloqueio: é o protocolo de visibilidade que o `AGENTS.md` exige sempre que
permission set, profile, sharing rule, `without sharing`, Named Credential ou exposição de dado
são tocados, mesmo quando o conteúdo parece pequeno ou correto.

**Revisão de conteúdo feita antes do deploy** (detalhe em `smoke-test.md`, itens 3-4):

- Nenhum dos 8 arquivos contém segredo, `sfdx-auth-url`, token, senha, ID de org ou dado de
  pessoa real (varredura com `grep -riE` antes de qualquer `git add`).
- Nenhum permission set concede `View All Data` ou `Modify All Data` (nenhuma tag
  `<userPermissions>` em nenhum arquivo).
- `NDG_Salesforce_Admin_Extended` concede `modifyAllRecords`/`viewAllRecords` por objeto (não é
  a permissão de sistema `Modify/View All Data`) sobre os 8 objetos de negócio do projeto — a
  própria descrição do permission set declara essa exclusão de forma explícita. É a persona mais
  ampla das 8, mas dentro dos objetos do escopo, não sobre a org inteira.
- Campos sensíveis de margem e desconto permanecem somente leitura em todas as 8 personas,
  inclusive nas duas com maior superfície de escrita (`NDG_RevOps`,
  `NDG_Salesforce_Admin_Extended`) — verificado ao vivo na org, não só no arquivo fonte.
- Todos os 24 campos referenciados nos `fieldPermissions` já existiam na org antes deste release
  (entregues em R01); nenhuma referência a campo inexistente, nenhum typo de API name.
- `.sfdx/` e `.sf/` continuam ignorados (`git check-ignore -v` confirmado antes do commit).

Nenhuma exposição de dado foi introduzida — pelo contrário: este release é o que torna os 24
campos de R01 finalmente visíveis para quem a persona deveria enxergar, e só para essa persona.

## Limitações conhecidas

Ver `known-limitations.md`. Destaque: (c) permission tests (`System.runAs()`) por persona ainda
não existem — a §30.2 os torna obrigatórios, mas não há lógica de negócio para exercitar via
`runAs()` até os objetos custom do M1 chegarem. Fica registrado como pendência de qualidade, não
como bloqueio deste release.

## Go/no-go do Helix

Pendente — este release entrega a última peça declarativa do M1 (§55: objetos, campos,
relacionamentos e permission sets), mas os objetos custom e as Custom Metadata Types de política
ainda não existem, então o M1 **não fecha** com este release. `PROGRESSO.md` permanece em
**1 / 13**. Fica para o Helix: (1) decidir se aceita esta fatia como está; (2) decidir o dono e o
momento dos permission tests da limitação (c).
