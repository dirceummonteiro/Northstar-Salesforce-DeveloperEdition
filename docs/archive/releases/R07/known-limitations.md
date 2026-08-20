# R07 — Known Limitations

## a) `PricebookEntry` fica sem `Seed_Key__c`

A plataforma não aceita campo custom em `PricebookEntry` (limitação estrutural do objeto, não
uma recusa de validação desta rodada — não foi tentado o deploy de um campo nele, porque a
decisão de excluí-lo já estava registrada no working tree antes desta rodada, em **D-014**,
`docs/DECISIONS.md`).

**Consequência:** a idempotência de `PricebookEntry` não pode ser feita por External Id/upsert
como os outros 11 objetos. Ela será resolvida no Apex do script de seed (D-015) por **chave
natural** — a combinação `Pricebook2Id` + `Product2Id` já é única por natureza do objeto
(um `Product2` aparece no máximo uma vez por `Pricebook2`), então uma consulta por essas duas
colunas antes do `insert`/`update` cobre o mesmo requisito de "roda duas vezes sem duplicar" sem
precisar de campo próprio. Isso é trabalho do script de carga (fatia futura do M2, dono: Kernel),
não deste release.

## b) Nenhuma recusa de plataforma nos 11 objetos que foram tentados

A tarefa autorizava remover `Seed_Key__c` objeto a objeto caso a plataforma recusasse
`externalId`/`unique` — o risco identificado era justamente nos três line items
(`OpportunityLineItem`, `QuoteLineItem`, `OrderItem`). Isso **não aconteceu**: os 11 objetos
validaram e deployaram na primeira tentativa (Deploy ID `0Affj00000Nmmt9CAB` validação,
`0Affj00000NnBZmCAN` deploy real), 0 erros de componente. Registrado aqui para não haver dúvida:
o passo 3 da tarefa (remoção seletiva) existia como plano de contingência e não foi exercido.

## c) M2 ainda não fechou

`docs/PROGRESSO.md` permanece em **2 / 13** — esta fatia entrega só o campo de idempotência.
Faltam, para o M2 fechar (§33, §55): a carga dos ~1.620 registros de seed (D-015, dono: Kernel),
o script de limpeza correspondente por marca `NS-` (D-016), dado 100% sintético confirmado, e a
reconfirmação de storage abaixo do portão de 50% (D-017) depois da carga real — hoje, sem carga,
o número é 0%, o que confirma a folga do orçamento mas não substitui a medição pós-carga.

## d) `Seed_Key__c` ainda não tem nenhum valor gravado

Este release cria o campo, mas nenhum registro na org tem `Seed_Key__c` preenchido — a validação
de que o padrão `NS-` realmente é respeitado, e de que o `upsert` por essa chave realmente evita
duplicação, só acontece quando o script de carga (D-015) rodar. Não é uma limitação de schema, é
uma dependência de ordem entre fatias do mesmo marco.

## Pendências operacionais relevantes já registradas em `docs/PENDENCIAS.md`

- **P-15** — resolvida nesta rodada (ver nota em `docs/PENDENCIAS.md` e **D-018**). O `schema`
  voltou a produzir metadata declarativa; esta fatia é a primeira evidência disso.
- **P-16** — `sf sobject describe` não reflete campos recém-deployados de forma confiável; esta
  rodada usou Tooling API `FieldDefinition` para a confirmação na org, como o P-16 recomenda.

Nenhuma das limitações acima bloqueia a integração desta fatia. (a) é uma decisão de desenho já
tomada (D-014), não uma pendência aberta; (b) documenta que a contingência autorizada não foi
necessária; (c) e (d) são, por desenho, o que ainda falta para o M2 fechar — não um defeito desta
fatia.
