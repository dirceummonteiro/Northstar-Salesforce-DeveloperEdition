# R02 — Known Limitations

## a) O M1 ainda não está completo

`PROGRESSO.md` permanece em **1 / 13** — a §55.1 é explícita: o número só sobe quando o marco
inteiro está concluído e validado, e a §55 exige objetos, campos, relacionamentos **e**
permission sets. Esta fatia entrega o último item da lista (permission sets), mas os objetos
custom da §9 e as Custom Metadata Types de política ainda não existem. Ver
`docs/PROGRESSO.md` para o detalhe atualizado do que falta.

## b) `NDG_Portal_User` continua adiado

A §30.2 já prevê isso: `NDG_Portal_User` é adiado junto com o portal de cliente (§2.2). Não é
uma omissão desta fatia — é o escopo definido.

## c) Permission tests (`System.runAs()`) ainda não existem

A §30.2 é explícita: "permission tests are mandatory, not optional". Esta fatia entrega os 8
permission sets e confirma via SOQL/Tooling que a FLS está correta, mas não há ainda nenhuma
classe `@isTest` exercitando `System.runAs()` por persona, porque não há lógica de negócio
(triggers, Apex de serviço, automação) que dependa dessas permissões para testar — os objetos e
a automação do restante do M1/M3+ ainda não existem. Registrar aqui para não perder de vista:
o gate do M1 sobre "permission model que não é testado é um permission model que não funciona"
só pode ser satisfeito depois que houver lógica de negócio para exercitar via `runAs()`. Dono da
próxima ação: Helix decide se isso vira tarefa própria antes do M1 fechar ou se é coberto junto
com os testes que os objetos custom da próxima fatia vão precisar.

## d) Sharing / OWD (§30.3) fora do escopo desta fatia

Esta fatia entrega apenas `PermissionSet` (CRUD + FLS por objeto/campo). Sharing rules, OWD e
territory/criteria sharing (§30.3) não fazem parte do que foi pedido aqui e continuam
pendentes — não confundir "permission set criado" com "modelo de sharing completo". Nenhum dos
8 permission sets tenta compensar sharing ausente concedendo `View All Records` além do
estritamente descrito por persona (ver `manifest.md` e o XML fonte de cada arquivo).

## Pendências operacionais já registradas em `docs/PENDENCIAS.md`, relevantes para este release

- **P-10 / P-11** — branch padrão do GitHub ainda é `master`; sem mudança nesta fatia.
- **P-15** — agente `schema` não inicializa (D-010). Não se aplica aqui: esta fatia integra
  metadata que já estava pronta no working tree quando a tarefa começou, sem passar pelo Kernel
  nem pelo `schema` nesta rodada — o Probe não teve visibilidade de qual agente a produziu, só
  confirmou que estava correta e a integrou.

Nenhuma das limitações acima bloqueia a integração desta fatia — mas (a) continua bloqueando,
por desenho, o fechamento do M1 como marco, e (c) é uma pendência real de qualidade que deveria
ser fechada antes de declarar o M1 pronto.
