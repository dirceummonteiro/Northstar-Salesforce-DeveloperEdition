# R06 — Smoke Test (verificação de aceitação do M1)

Nenhum deploy nesta rodada. Todas as consultas abaixo rodaram diretamente contra `helix-dev`
nesta rodada de fechamento (2026-08-19), como verificação independente da decisão de GO do
Helix — a instrução recebida foi explícita: não aceitar a decisão sem conferir.

## Comandos executados

```
sf org list
sf data query -o helix-dev -q "SELECT Name FROM PermissionSet WHERE Name LIKE 'NDG_%' ORDER BY Name"
sf data query -o helix-dev --use-tooling-api -q "SELECT QualifiedApiName, Label FROM EntityDefinition WHERE QualifiedApiName IN ('Discount_Request__c','Pricing_Rule__mdt','Margin_Policy__mdt','Freight_Rule__mdt','Integration_Log__b')"
sf data query -o helix-dev --use-tooling-api -q "SELECT QualifiedApiName FROM FieldDefinition WHERE EntityDefinition.QualifiedApiName='Account' AND QualifiedApiName LIKE '%__c'"
sf data query -o helix-dev --use-tooling-api -q "SELECT QualifiedApiName FROM FieldDefinition WHERE EntityDefinition.QualifiedApiName='Opportunity' AND QualifiedApiName LIKE '%__c'"
sf data query -o helix-dev --use-tooling-api -q "SELECT QualifiedApiName FROM FieldDefinition WHERE EntityDefinition.QualifiedApiName='Discount_Request__c'"
sf data query -o helix-dev --use-tooling-api -q "SELECT QualifiedApiName FROM FieldDefinition WHERE EntityDefinition.QualifiedApiName='Integration_Log__b'"
sf data query -o helix-dev -q "SELECT COUNT() FROM Pricing_Rule__mdt"
sf data query -o helix-dev -q "SELECT COUNT() FROM Margin_Policy__mdt"
sf data query -o helix-dev -q "SELECT COUNT() FROM Freight_Rule__mdt"
sf data query -o helix-dev -q "SELECT ParentId, Parent.Name, PermissionsRead, PermissionsCreate, PermissionsEdit, PermissionsDelete, PermissionsViewAllRecords, PermissionsModifyAllRecords FROM ObjectPermissions WHERE SobjectType='Integration_Log__b'"
sf limits api display -o helix-dev
```

Consultas de contagem agregada (`SELECT COUNT() FROM FieldDefinition WHERE ... LIKE '%__c'`)
retornaram números visivelmente baixos e inconsistentes com o repositório (10 em vez de 11 para
`Account`, 5 em vez de 13 para `Opportunity`, 1 em vez de 13 para `Discount_Request__c`, 3 em
vez de 17 para `Integration_Log__b`). Reconhecido como o mesmo padrão de P-16 em
`docs/PENDENCIAS.md` — a diferença é que desta vez o problema não é o `sf sobject describe`, é a
própria consulta `COUNT()` agregada via Tooling API que não bate com a listagem completa do
mesmo endpoint. Trocado para `SELECT QualifiedApiName FROM FieldDefinition WHERE ...` sem
`COUNT()`, que devolveu a lista completa e bateu exatamente com o repositório em todos os quatro
casos. **Registrado como observação nova para o Helix avaliar** (não é P-16 em si, é uma
variante: contagem agregada via Tooling API pode truncar mesmo quando a listagem completa não
trunca).

## Resultado — cada item da justificativa do Helix, conferido

| Item | Afirmação do Helix | Confirmado nesta rodada |
|---|---|---|
| Permission sets | 8 `NDG_*` presentes | ✅ `NDG_Deal_Desk`, `NDG_Executive_ReadOnly`, `NDG_Integration_Admin`, `NDG_Regional_Director`, `NDG_RevOps`, `NDG_Sales_Manager`, `NDG_Sales_Rep`, `NDG_Salesforce_Admin_Extended` — 8/8 |
| Objetos/tipos | `Discount_Request__c`, `Pricing_Rule__mdt`, `Margin_Policy__mdt`, `Freight_Rule__mdt`, `Integration_Log__b` presentes | ✅ 5/5 confirmados via `EntityDefinition` |
| Campos comerciais | "18 campos custom em Account, 18 em Opportunity" | ⚠️ Não bate com o escopo do projeto. `Account`: 11 campos do projeto + 7 campos de amostra da Developer Edition = 18 no total do objeto. `Opportunity`: 13 campos do projeto + 5 campos de amostra da DE = 18 no total. Os números corretos para o escopo do M1 são **11 e 13**, os mesmos documentados desde `docs/releases/R01/`. Ver nota em `release-summary.md`. |
| Big Object — 3 personas certas | `NDG_Integration_Admin`, `NDG_RevOps`, `NDG_Salesforce_Admin_Extended` com `ObjectPermissions` em `Integration_Log__b`, append-only | ✅ Confirmado por SOQL: os 3 têm `Read=true`; `NDG_Integration_Admin` e `NDG_Salesforce_Admin_Extended` têm `Create=true`, `NDG_RevOps` não; nenhum dos 3 tem `Edit`/`Delete`/`ViewAllRecords`/`ModifyAllRecords` |
| `DataStorageMB` | 0 de 5 MB, com 11 registros de CMDT e o Big Object criados | ✅ `sf limits api display`: `DataStorageMB max=5, remaining=5` — 0 MB em uso |
| Registros de Custom Metadata | 11 (8+1+2) | ✅ `Pricing_Rule__mdt`=8, `Margin_Policy__mdt`=1, `Freight_Rule__mdt`=2, soma 11 |
| Árvore limpa, `origin/main` em `5d7d4ec`, nada por enviar | — | ✅ `git status` limpo, `git log origin/main -1` = `5d7d4ec`, `git log HEAD..origin/main` e `git log origin/main..HEAD` ambos vazios |

## Conclusão

7 dos 8 itens conferidos batem exatamente. O item de campos comerciais tem uma imprecisão de
redação (conta bruta do objeto em vez de contagem escopada ao projeto), mas o fato subjacente —
os 24 campos comerciais do M1 (11+13) existem no repositório e na org — está confirmado por três
fontes independentes: o repositório (`force-app/`), `docs/PROGRESSO.md` desde a fatia 1, e esta
consulta ao vivo. **A decisão de GO se sustenta pelos fatos, não pela redação da justificativa.**
Detalhe da imprecisão e de uma segunda (citação de D-004) em `release-summary.md`.
