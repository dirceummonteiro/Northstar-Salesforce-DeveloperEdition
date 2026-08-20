# R10 — Known Limitations

## a) M3.1 é só a fundação declarativa — sem Apex, sem comportamento

Esta fatia não implementa scoring, roteamento, conversão nem captura via API. Os 8 campos novos
existem e têm FLS, mas nada os preenche ainda — `Scored_At__c`, `Routed_At__c`,
`Routing_Reason__c`, `Conversion_Blocked_Reason__c` ficam vazios até M3.2–M3.5. Os 6 registros de
`Lead_Scoring_Rule__mdt` e os 3 de `Lead_Routing_Rule__mdt` são dado de configuração, não são
lidos por código nenhum ainda.

## b) Filas sem membros

`Lead_Enterprise`, `Lead_SMB` e `Lead_Nurture` foram criadas deliberadamente sem membros (D-023,
escopo desta fatia), para que o deploy não dependesse de nenhum usuário existir na org. Atribuição
de membros é decisão de M3.3 (roteamento) ou de fatia futura de operação — não bloqueante para
M3.1.

## c) `TriggerHandler` ainda não existe

D-024 registra o padrão de trigger do projeto (uma trigger por objeto, handler dedicado, bypass
nomeado, controle de recursão, zero SOQL/DML em laço) mas não implementa nada — o repositório
segue com zero triggers até M3.2. Decisão tomada agora, antes da primeira trigger nascer, para
evitar reescrita em retrospecto.

## d) Drift de source-tracking em permission sets fora do escopo (herdado de R09)

Mesmo padrão registrado em `docs/releases/R09/known-limitations.md`, item g: o relatório de
deploy pode listar como "Changed" arquivos já commitados em `main` fora do `git diff` da fatia
corrente, por cache de source-tracking local do `sf` CLI (`.sf/`, não versionado) divergente do
estado real da org. Não observado como bloqueio nesta rodada — os 158 componentes deployados
bateram exatamente com o esperado (44 novos/alterados do Kernel + drift conhecido de fatias
anteriores).

## e) M3 não fecha nesta fatia

`docs/PROGRESSO.md` marca M3.1 como concluída e deployada; M3.2 a M3.5 seguem `⬜`. A métrica de
marcos do `README.md` permanece **3/13** — M3 só conta como marco fechado quando a fatia M3.4
(conversão) provar o critério de aceite do §55: "um lead vira Account, Contact e Opportunity".
