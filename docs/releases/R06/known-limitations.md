# R06 — Known Limitations (o que atravessa do M1 para o M2)

## a) Agente `schema` quebrado (P-15)

`WorkspaceVanishedError` documentado desde o M0, coberto pelo desvio D-010 (Kernel produz
metadata declarativa em nome do `schema` enquanto o agente não inicializa). Na fatia (d)
(`docs/releases/R04/`), foi o próprio `schema` — não o Kernel — quem aplicou uma correção no
working tree, o que pode ser sinal de que o agente voltou a inicializar, mas o Probe não tem
visibilidade de infraestrutura para confirmar isso de forma definitiva. **P-15 não é fechada
nem D-010 é revertida por esta rodada** — fica para o Helix decidir se reavalia o desvio antes
do M2 começar a depender do `schema`.

## b) FLS ainda não exercitada com dado real

A FLS dos 8 permission sets `NDG_*` foi confirmada por SOQL/Tooling API contra a definição de
metadata (`FieldPermissions`, `ObjectPermissions`) em todas as fatias do M1, mas nenhum teste
`System.runAs()` por persona rodou ainda contra um registro real, porque não há lógica de
negócio para exercitar essa FLS em contexto de execução. A §30.2 torna esses testes
obrigatórios ("permission tests are mandatory, not optional"). Esta é a limitação (c), aberta
desde `docs/releases/R02/known-limitations.md` e reafirmada em R03 e R04 — continua aberta ao
fechar o M1, e só pode fechar quando houver Apex de negócio para testar contra ela (M3 em
diante).

## c) Nenhum Apex de negócio escrito ainda

Esperado, não uma lacuna: M1 é modelo de dados declarativo (objetos, campos, relacionamentos,
permission sets). `HttpCalloutService`/`HttpCalloutServiceTest` (D-006) continuam a única
classe e o único teste do projeto, com 100% de cobertura. Apex de negócio — scoring de lead,
motor de precificação, controles de desconto/margem, aprovações, integrações — começa no M3,
sobre o modelo de dados que este marco entrega.

## d) `Discount_Request__c` e `Integration_Log__b` estão vazios

Nenhuma das fatias do M1 fez seed de dado nesses objetos — carga de dado é escopo do M2 (§33),
não do M1. `docs/PROGRESSO.md` já abre o bloco do M2 com o orçamento de ~1.620 registros e a
exigência de verificação de storage antes de carregar.

## e) Contagem agregada via Tooling API pode truncar (observação nova desta rodada)

`SELECT COUNT() FROM FieldDefinition WHERE ... LIKE '%__c'` devolveu números abaixo do real em
4 de 4 tentativas nesta rodada, mesmo horas depois do último deploy (fora da janela de atraso
que P-16 já documentava para `sf sobject describe` logo após deploy). A listagem completa sem
`COUNT()` no mesmo endpoint devolveu os números corretos nas 4 vezes. Não é uma reabertura de
P-16 — é uma variante nova, registrada aqui para o Helix avaliar se adiciona ao `PENDENCIAS.md`:
**contagem agregada (`COUNT()`) via Tooling API não é confiável, mesmo quando a listagem
completa do mesmo objeto é.**

## f) Imprecisões na justificativa de GO do Helix, corrigidas nesta rodada sem alterar a decisão

Ver `release-summary.md`, seção "Nota de verificação do Probe". Resumo: a contagem "18 campos
em Account, 18 em Opportunity" citada na decisão de GO soma campos de amostra da Developer
Edition não relacionados ao projeto; os números corretos (11 e 13) são os que o repositório e
`docs/PROGRESSO.md` já documentavam desde R01. A citação de D-004 como a decisão que resolveu
alguns objetos da §9 por campo em vez de objeto não corresponde ao conteúdo real de D-004 (que é
sobre permission sets vs. licenças). O fato em si — `Credit_Status__c`, `Competitor_Primary__c`
e `Inventory_Check_Status__c` existem como campos e cobrem em substância `Credit_Status__c`,
`Competitor__c` e `Inventory_Snapshot__c` da §9 — está correto, só não está registrado como
decisão formal e numerada em `docs/DECISIONS.md`.

Nenhuma das duas imprecisões altera o GO: os entregáveis reais do M1 (objetos, os 24 campos
comerciais corretos, permission sets, Custom Metadata, Big Object) estão confirmados presentes
tanto no repositório quanto na org, por múltiplas fontes independentes.

## Pendências operacionais que seguem sem mudança

- **P-10/P-11** — branch padrão do GitHub ainda é `master`; sem ação disponível ao Probe até o
  dono trocar em `Settings → General → Default branch`.
- **P-16** — `sf sobject describe` não confiável logo após deploy; usar `FieldDefinition` via
  Tooling API (mas ver item (e) acima: `COUNT()` sozinho também não é confiável).
