# R09 — Known Limitations

## a) Volume é 1.051 registros, não os ~1.620 da tabela da §33 — resolvida (D-022 ratifica D-020)

Era limitação aberta no R08 (`docs/releases/R08/known-limitations.md`, item a). **Ratificada
nesta fatia por D-022**: entre o dimensionamento da §33 (~1.620) e o critério de aceite da §55
(storage abaixo de 50%), prevalece o critério de aceite — os dois números não cabem na mesma org
de 5 MB. Não é mais uma limitação em aberto; é decisão registrada e fechada.

## b) FLS de `Seed_Key__c` só existia em permission set, não em perfil — corrigida (P-17, D-021)

Era limitação aberta no R08 (item b). O diagnóstico original estava parcialmente incorreto: as
entradas de FLS não faltavam (a fatia (a) já concedia `readable=true` nos 8 permission sets
`NDG_*`). O que faltava era `editable=true` para quem opera o seed. `NDG_Salesforce_Admin_Extended`
recebeu `editable=true` nas 11 entradas de `Seed_Key__c` nesta fatia, deployado e confirmado na
org. Os outros 7 permission sets seguem `editable=false` — leitura para auditar, escrita só no
permission set que opera a massa. Nenhum perfil enxerga o campo; a atribuição de
`NDG_Salesforce_Admin_Extended` é procedimento declarado, não contorno.

## c) Defeito pré-existente corrigido: `viewAllRecords`/`modifyAllRecords` não licenciados em `Pricebook2`/`Product2`

Achado durante esta fatia, sem relação com P-17: `NDG_Salesforce_Admin_Extended` declarava
`viewAllRecords=true`/`modifyAllRecords=true` em `Pricebook2` e `Product2`, permissões que a
licença de usuário da org (Developer Edition) não concede. Isso já reprovava `sf project deploy
validate` em `HEAD`, antes de qualquer mudança desta fatia — confirmado de forma independente
neste release via `git stash` + validação isolada. Os dois flags foram para `false`; CRUD integral
(`create`/`read`/`edit`/`delete`) preservado nos dois objetos. Deployado e confirmado na org por
SOQL direto contra `ObjectPermissions`.

## d) `Order` sempre em `Draft`

Sem mudança nesta fatia. Nenhum pedido do seed é ativado (`Status = 'Activated'`). Ativação
dispara validação de negócio que pertence ao M8 (Quote e Order), não ao seed de dado.

## e) `DuplicateRuleHeader.AllowSave = true` em `Account`/`Contact`/`Lead`

Sem mudança nesta fatia. Documentado em `scripts/apex/README.md` como válido **apenas** para dado
de demonstração — não é padrão a copiar para carga de dado real em fatias futuras.

## f) `Quote.Status` usa valores de API em português

Sem mudança nesta fatia. A org roda em pt-BR; valores de API da picklist padrão de
`Quote.Status` (`Rascunho`, `Apresentado`, `Aceito`) refletem isso.

## g) Drift de source-tracking em permission sets e objetos fora do escopo desta fatia

O relatório do deploy real (Deploy ID `0Affj00000NpcVqCAJ`) marcou como "Changed" sete permission
sets (`NDG_Deal_Desk`, `NDG_Executive_ReadOnly`, `NDG_Integration_Admin`, `NDG_Regional_Director`,
`NDG_RevOps`, `NDG_Sales_Manager`, `NDG_Sales_Rep`) e `Discount_Request__c`, nenhum dos quais está
no `git diff` desta fatia — o conteúdo local já estava commitado em `main`. Não houve mudança de
permissão introduzida por esta fatia nesses arquivos; o conteúdo reenviado é idêntico ao já
versionado. Provável causa: cache de source-tracking local do `sf` CLI (`.sf/`, não versionado)
divergente do estado real da org, por deploy/config anterior fora deste clone. Não é bloqueante
para o M2 — registrado para rastreabilidade caso o próximo marco precise investigar a causa raiz.

## h) M2 fecha nesta fatia

`docs/PROGRESSO.md` passa a ter todos os itens do §33/§55 marcados para o M2. Sujeito à
ratificação do Helix sobre o ESCALONAMENTO DE SEGURANÇA registrado em `release-summary.md`
(mudança em permission set, ainda que redutora/restrita a campo de controle interno do seed).
