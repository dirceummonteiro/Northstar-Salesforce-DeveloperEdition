# R01 — Known Limitations

## a) Agente `schema` quebrado — Kernel cobrindo (D-010)

O agente `schema` não inicializa (`WorkspaceVanishedError`, causa raiz identificada em D-010:
rename `forge` → `schema` deixou o workspace sem estado coerente). Toda a metadata declarativa
desta fatia — os 24 campos e o `QuoteSettings` — foi produzida pelo **Kernel**, por atribuição
explícita do Helix (§6.3), enquanto o `schema` não volta. Registrado como P-15 em
`PENDENCIAS.md`, dono Helix. O portão de commit/push/deploy não mudou: continua sendo só o
Probe (§65.1) — só quem produz o arquivo mudou.

## b) O M1 não está completo

Esta é a fatia 1 de N do M1. `PROGRESSO.md` permanece em **1 / 13** — a §55.1 é explícita: o
número só sobe quando o marco inteiro está concluído e validado, e a §55 exige objetos, campos,
relacionamentos **e** permission sets. Entregue nesta fatia: campos de Account/Opportunity e a
habilitação do Quote. Ainda falta, para o M1 fechar:

- objetos custom da §9 (`Sales_Quota__c`, `Quota_Attainment__c`, `Territory_Assignment__c`,
  `Discount_Request__c`, `Inventory_Snapshot__c`, `ERP_Sync_Log__c`, `Partner_Deal__c`, etc.);
- Custom Metadata Types de política de preço/desconto/margem (§1.5, obrigatório não consumir
  storage de dados);
- Big Object para observabilidade de integração (§1.5, mesma razão);
- permission sets das 9 personas (§30.2) — sem eles, ninguém enxerga os campos desta fatia nem
  os objetos que ainda vêm (ver item c).

## c) Campos sem Field-Level Security — mais restritivo do que o esperado

Nenhum dos 24 campos novos tem `FieldPermissions` concedida a nenhum perfil ou permission set.
Isso é esperado: os permission sets das personas (§30.2) são a próxima fatia do M1, não esta.

**Correção em relação à expectativa inicial:** a suposição de que "hoje só quem tem 'View
All / Modify All' enxerga" não se confirmou. `View All Data` e `Modify All Data` são permissões
de **registro** (contornam sharing), não de **campo** (FLS). A investigação em `smoke-test.md`
mostra que nem o usuário `Administrador do sistema` — que tem as duas ativas — consegue
consultar os campos novos via SOQL hoje. `FieldPermissions` para esses campos tem zero
registros na org. Na prática, isso significa: **ninguém** vê os campos desta fatia em list
view, page layout, relatório ou API até a próxima fatia (permission sets) conceder FLS
explicitamente. Isso é o comportamento padrão e seguro do Salesforce para campo criado via
Metadata API sem `<fieldPermissions>` associada — não é uma falha de deploy, e não é uma
exposição de dado (é o oposto: fail-closed).

## Pendências operacionais já registradas em `docs/PENDENCIAS.md`, relevantes para este release

- **P-10 / P-11** — branch padrão do GitHub ainda é `master`; sem mudança nesta fatia.
- **P-15** — agente `schema` não inicializa; ver item (a) acima. Dono Helix.

Nenhuma dessas pendências, nem as limitações (a)-(c) acima, bloqueia a integração desta fatia —
mas (b) e (c) bloqueiam, por desenho, o fechamento do M1 como marco.
