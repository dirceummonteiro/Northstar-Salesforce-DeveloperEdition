# R03 — Known Limitations

## a) O M1 ainda não está completo

`PROGRESSO.md` permanece em **1 / 13** — a §55.1 é explícita: o número só sobe quando o marco
inteiro está concluído e validado. Com esta fatia, a §55 tem todos os componentes declarativos
do M1 (objetos, campos, relacionamentos, permission sets) no repositório e na org, mas a
limitação (c) de R02 — permission tests (`System.runAs()`) por persona — continua aberta.
`PROGRESSO.md` é atualizado para marcar (b) e (c) como concluídas, sem fechar o marco M1 inteiro.

## b) `viewAllRecords`/`modifyAllRecords` por objeto — mudança de superfície desde R02

R02 registrou que nenhum permission set concedia `View All Records` além do estritamente
descrito por persona. Esta fatia muda esse fato para 3 objetos (`Opportunity` em
`NDG_Deal_Desk`; `Discount_Request__c` em `NDG_Deal_Desk`, `NDG_Executive_ReadOnly`,
`NDG_Regional_Director`, `NDG_RevOps`, `NDG_Salesforce_Admin_Extended`). Marcado como
ESCALONAMENTO DE SEGURANÇA em `release-summary.md`, com tabela completa de justificativa por
persona. Não é permissão de sistema (`View All Data`/`Modify All Data`) e a revisão de conteúdo
não encontrou nada fora do desenho documentado — mas é uma mudança real de superfície de
sharing que o Helix deveria confirmar antes do M1 fechar, não só ler depois do fato.

**Atualização:** confirmado. O Helix ratificou a concessão de `ViewAll` em Opportunity ao Deal
Desk em `docs/DECISIONS.md`, **D-011**. Ver também item (f) abaixo — a concessão não foi uma
escolha de design isolada, foi resposta a uma recusa de deploy da plataforma.

## f) Duas recusas da plataforma durante esta fatia (não erros de conteúdo)

A validação/deploy desta fatia parou duas vezes por regra de plataforma, não por dado errado:

1. **`.md-meta.xml` sem `xmlns:xsd` quando algum `<value xsi:type="xsd:boolean">` está presente.**
   A API 67.0 rejeita o pacote inteiro na fase de parse — antes de tocar qualquer componente —
   com erro opaco, `numberComponentErrors: 0` e nenhuma pista de qual arquivo ou campo causou a
   falha. Os 11 registros de Custom Metadata desta fatia usam `xsi:type="xsd:boolean"` (campo
   `Active__c` em todos, `Stackable__c` em `Pricing_Rule__mdt`), então o namespace precisa estar
   declarado mesmo que só `xmlns:xsi` pareça necessário à primeira vista. Runbook completo,
   incluindo como bissetar esse erro, em `docs/runbooks/custom-metadata.md`.
2. **`ViewAll` em `Discount_Request__c` (filho master-detail) exige `ViewAll` no pai
   (`Opportunity`).** A plataforma recusou o deploy com a mensagem citada em D-011. Resolvido
   ratificando a concessão em Opportunity para o Deal Desk — ver D-011 em `docs/DECISIONS.md` e
   a atualização do item (b) acima.

Nenhuma das duas é uma falha de conteúdo do modelo de dados; são restrições de plataforma que só
aparecem no momento do deploy, não numa revisão estática do XML.

## c) Permission tests (`System.runAs()`) ainda não existem

Mesma limitação (c) de R02, ainda aberta. A §30.2 é explícita: "permission tests are mandatory,
not optional". Esta fatia adiciona `Discount_Request__c` e três Custom Metadata Types, mas
segue sem lógica de negócio (triggers, Apex de serviço, fluxo de aprovação) para exercitar via
`runAs()` — isso é escopo dos motores de precificação/margem/frete (M5) e do fluxo de aprovação
do Deal Desk (M6/M7). Dono da próxima ação: Helix decide se isso vira tarefa própria antes do
M1 fechar ou se é coberto junto com os testes que a lógica de negócio dos próximos marcos vai
precisar.

## d) `ObjectPermissions` de perfil de sistema em `Discount_Request__c` não vieram deste deploy

A query de `ObjectPermissions` sobre `Discount_Request__c` retornou 9 registros, não 7: os 2
extras (`Parent.Name` no formato `X00e1a...`/`X00ex...`) são concedidos automaticamente pela
plataforma a perfis quando um `CustomObject` é criado — comportamento padrão do Salesforce, não
uma linha presente em nenhum dos 7 arquivos de permission set entregues por esta fatia. Registrado
aqui para que a leitura de `smoke-test.md` não seja mal interpretada como "9 permission sets
tocados" quando são 7.

## e) `Discount_Request__c` sem seed e sem automação

Objeto vazio na org (`COUNT() = 0`), como esperado — seed data é escopo do M2 (§33) e a lógica
de aprovação (validação de `Status__c`, cálculo de `Approval_Level__c` pela matriz da §17.2,
notificação ao `Current_Approver__c`) é escopo de M6/M7. Este release entrega apenas o modelo de
dados e o acesso por persona, conforme pedido pela tarefa.

## Pendências operacionais já registradas em `docs/PENDENCIAS.md`, relevantes para este release

- **P-10 / P-11** — branch padrão do GitHub ainda é `master`; sem mudança nesta fatia.
- **P-15** — agente `schema` não inicializa (D-010). Aplica-se aqui: esta fatia é mais uma
  produzida pelo Kernel sob o desvio D-010, com o cabeçalho de desvio confirmado na tarefa.

Nenhuma das limitações acima bloqueia a integração desta fatia — (a) continua bloqueando, por
desenho, o fechamento do M1 como marco; (b) foi confirmada pelo Helix via D-011; (c) é a mesma
pendência de qualidade real de R02, ainda não fechada; (f) já está resolvida, documentada aqui
para não custar uma hora de bisseção a quem tocar Custom Metadata de novo.
