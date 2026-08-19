# R04 — Known Limitations

## a) O M1 ainda não está completo

`PROGRESSO.md` permanece abaixo de 2/13 — a §55.1 é explícita: o número só sobe quando o marco
inteiro está concluído e validado. Com esta fatia, o M1 ganha o Big Object de observabilidade
(§1.5), mas ainda faltam os demais objetos custom da §9 fora do escopo das fatias (b)/(c)/(d) e
a limitação (c) de R02 — permission tests (`System.runAs()`) por persona — continua aberta.

## b) Duas recusas de validação por limite de plataforma, não por erro de conteúdo

A validação desta fatia foi recusada duas vezes antes de passar, sempre pela mesma regra: "The
total length for all text fields in an index can't exceed 100 characters." Detalhe completo,
com os três Deploy IDs, em **D-012** (`docs/DECISIONS.md`) e em `release-summary.md`. O ponto
que vale destacar aqui: a segunda recusa aconteceu com a soma **exatamente igual a 100**
(`Integration_Name__c` 64 + `Correlation_Id__c` 36), provando que o teto de plataforma é
exclusivo (`< 100`), não inclusivo (`<= 100`) — um detalhe que não está documentado em nenhum
material de referência que o Kernel, o Pulse ou o Probe conseguiram alcançar antes do deploy.
Quem for desenhar outro índice de Big Object nesta org deve orçar para `<= 99`, não `100`.

## c) Permission tests (`System.runAs()`) ainda não existem

Mesma limitação (c) de R02/R03, ainda aberta. Esta fatia adiciona `Integration_Log__b`, mas
segue sem lógica de negócio (o serviço Apex que grava o log de integração é escopo do M9) para
exercitar via `runAs()`.

## d) Índices de Big Object não retornam pelo `sf sobject describe` padrão

`sf sobject describe --sobject Integration_Log__b` devolveu só 3 campos custom
(`Correlation_Id__c`, `Event_Date__c`, `Integration_Name__c` — os do índice) e nenhum bloco de
índice, mesmo com o deploy já `Succeeded`. Os 17 campos completos só ficaram visíveis via
Tooling API (`SELECT QualifiedApiName FROM FieldDefinition WHERE
EntityDefinition.QualifiedApiName = 'Integration_Log__b'`, 21 registros = 4 padrão + 17 custom),
e o índice só ficou visível retirando o `CustomObject` inteiro via `sf project retrieve start`
— o índice volta como arquivo separado, `objects/Integration_Log__b/indexes/
Integration_Log_Index.index-meta.xml`, não embutido no `.object-meta.xml` como no source
original. Registrado para que quem confirmar esta fatia depois não interprete o resultado curto
do `describe` como "faltou campo" — é o describe padrão que não reflete Big Object
imediatamente, não o deploy que ficou incompleto. `COUNT()` também não é suportado em Big
Object (`BIG_OBJECT_UNSUPPORTED_OPERATION`); a confirmação de "zero registros" usou `SELECT
Correlation_Id__c FROM Integration_Log__b LIMIT 1` e a ausência de linhas no resultado.

## e) Nome da integração limitado a 60 caracteres, correlation id a 36

`Integration_Name__c` é Text(60) e `Correlation_Id__c` é Text(36), por causa do teto de 100
caracteres do índice de Big Object (que na prática é `< 100`, ver item (b) acima). Como o
índice é imutável, esses tamanhos **não podem ser aumentados depois** sem recriar o objeto
inteiro — o que apaga o histórico acumulado. Nomes de integração muito longos precisam de uma
convenção de abreviação decidida antes do M9 (quando o serviço de integração de verdade começa
a gravar neste objeto), não depois.

## f) `manifest/package.xml` não reflete este nem os deploys anteriores

Mesma situação de R01/R02/R03: `manifest/package.xml` declara só `ApexClass: *`, versão 67.0.
`scripts/shell/validate.sh` e `scripts/shell/deploy.sh` usam `--source-dir force-app`, nunca
`-x manifest/package.xml` — confirmado lendo os dois scripts nesta fatia. O manifesto está fora
do caminho real do deploy desde o M0; decisão de não reescrevê-lo a cada fatia registrada em
**D-013** (`docs/DECISIONS.md`).

## Pendências operacionais já registradas em `docs/PENDENCIAS.md`, relevantes para este release

- **P-10 / P-11** — branch padrão do GitHub ainda é `master`; sem mudança nesta fatia.
- **P-15** — agente `schema` não inicializa (D-010). Nesta fatia, foi o `schema` — não o Kernel
  — quem aplicou a correção de `Integration_Name__c` no working tree; ver observação em
  `PENDENCIAS.md`. Não é uma confirmação de que P-15 está resolvida, é um dado novo para o
  Helix avaliar.

Nenhuma das limitações acima bloqueia a integração desta fatia — (a) continua bloqueando, por
desenho, o fechamento do M1 como marco; (b) já está resolvida (a validação passou na terceira
tentativa) e documentada aqui como conhecimento de plataforma reutilizável; (c) é a mesma
pendência de qualidade real de R02/R03, ainda não fechada.
