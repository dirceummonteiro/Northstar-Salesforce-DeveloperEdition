# R08 — Known Limitations

## a) Volume é 1.051 registros, não os ~1.620 da tabela da §33 (D-020, pendente de ratificação)

Os dois números não cabem sob o portão de storage de 50% do M2 (§55) na mesma org de 5 MB. O
Kernel escolheu o critério de aceite do marco sobre a tabela de volume, preservando proporção e
cobertura de negócio (todos os 12 objetos, 4 segmentos, 4 famílias de produto, 10 estágios do
funil). **Não fecha o M2 por si só** — precisa de ratificação explícita do Helix (ver
`docs/PROGRESSO.md`, "Ainda falta para o M2 fechar").

## b) FLS de `Seed_Key__c` só existe em permission set, não em perfil (D-021 / P-17)

O usuário que roda o seed depende do permission set `NDG_Salesforce_Admin_Extended` estar
atribuído a ele. Sem isso, `sf data query`, `sf sobject describe` e o próprio Apex anônimo do seed
relatam `No such column 'Seed_Key__c'` e o script não compila — o campo existe na org, a FLS o
esconde. Contorno em vigor, correção definitiva é metadata declarativa (dono: `schema`, deploy:
Probe), fora do escopo desta fatia por decisão registrada (não reabrir o desvio que D-018 fechou).

## c) `Order` sempre em `Draft`

Nenhum pedido do seed é ativado (`Status = 'Activated'`). Ativação dispara validação de negócio
que pertence ao M8 (Quote e Order), não ao seed de dado. Não é limitação técnica — é escopo
deliberadamente fora desta fatia.

## d) `DuplicateRuleHeader.AllowSave = true` em `Account`/`Contact`/`Lead`

A massa sintética, por ter dezenas de registros com padrão de nome/endereço semelhante, dispara as
regras padrão de duplicidade da org. O seed grava assim mesmo, com o bypass explícito no `DMLOptions`.
Documentado em `scripts/apex/README.md` como válido **apenas** para dado de demonstração — não é
padrão a copiar para carga de dado real em fatias futuras.

## e) `Quote.Status` usa valores de API em português

A org roda em pt-BR e os valores de API da picklist padrão de `Quote.Status` (`Rascunho`,
`Apresentado`, `Aceito`) refletem isso — confirmado por `describe`, não suposto. Quem escrever
Apex ou Flow contra este campo em marcos futuros (M8) precisa usar esses valores, não os em
inglês da documentação padrão da Salesforce.

## f) M2 ainda não fecha

`docs/PROGRESSO.md` permanece em **2 / 13**. Faltam, para o M2 fechar: ratificação de D-020 e
correção definitiva de P-17/D-021 (ambas descritas acima). Nenhuma das duas é um defeito desta
fatia — são, por desenho, o que a fatia (b) deixou explicitamente para a próxima.
