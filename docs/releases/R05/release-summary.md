# R05 — Release Summary (reconciliação do M1, fatias (a)-(d))

## Identificação

| Campo | Valor |
|---|---|
| Marco | M1, reconciliação das fatias (a) permission sets, (b) Custom Metadata Types, (c) `Discount_Request__c`, (d) `Integration_Log__b` |
| Motivo | O dono entrou na org e viu apenas um objeto customizado e nenhum item do escopo do M1 além dele. Rodada disparada para fechar essa lacuna com fatos, sem suposição. |
| Branch | `main` |
| Remoto | `origin` |
| Org alvo | alias `helix-dev` (Developer Edition, não-produção) |
| Data | 2026-08-19 |
| Owner do release | Probe |

## Reconhecimento

- `git log origin/main --oneline -5` e `git log main --oneline -5` são idênticos; `git rev-list
  --left-right --count origin/main...main` retornou `0 0`. **Não havia commit não enviado.**
- `git status --porcelain -uall` limpo antes desta rodada.
- `docs/PROGRESSO.md` já declarava as quatro fatias como entregues, com commit e evidência
  (`R02`, `R03`, `R04`), e listava outros objetos do §9 (`Sales_Quota__c` etc.) como pendentes —
  isso continua verdadeiro, essas fatias nunca fizeram parte do escopo (a)-(d) desta rodada.
- No `force-app/` local, os quatro itens existem por completo: 8 permission sets em
  `permissionsets/`, os três objetos `*__mdt` com todos os campos e os 11 registros de
  `customMetadata/`, `Discount_Request__c` com 13 campos, `Integration_Log__b` com 17 campos.

## Estado da org — antes desta rodada

| Item | No repo? | Confirmado na org (metadata) antes | Observação |
|---|---|---|---|
| (a) 8 permission sets `NDG_*` | Sim | Sim — os 8 apareceram em `sf org list metadata -m PermissionSet` | `lastModifiedDate` recente, compatível com deploy anterior ao início desta rodada |
| (b) `Pricing_Rule__mdt`/`Margin_Policy__mdt`/`Freight_Rule__mdt` | Sim | Sim — `sf org list metadata -m CustomMetadata` retornou os 11 registros (8+1+2), batendo com `SELECT COUNT()` por tipo | — |
| (c) `Discount_Request__c` | Sim | Objeto presente em `sf org list metadata -m CustomObject`; **`sf sobject describe` mostrou só 1 campo customizado (`Opportunity__c`)** | Ver "Alerta de verificação" abaixo — o describe local não é confiável para checagem imediata |
| (d) `Integration_Log__b` | Sim | Objeto presente; **`sf sobject describe` mostrou só 3 campos customizados** (os 3 do índice) | Mesmo alerta — já documentado em `docs/releases/R04/known-limitations.md` para Big Object, mas aqui apareceu também em objeto comum |

A tabela acima é o motivo de eu não confiar cegamente em `sf sobject describe` para decidir se
havia lacuna real: o mesmo comando, rodado de novo depois do deploy desta rodada (abaixo),
retornou exatamente os mesmos números truncados — 1 e 3 campos — mesmo com o deploy reportando
111/111 componentes sem erro. Troquei para a Tooling API (`FieldDefinition`), que não usa o
mesmo cache e é a fonte usada para a tabela "depois desta rodada".

## Deploy executado nesta rodada

```
sf project deploy validate --source-dir force-app --test-level RunLocalTests --json
# sucesso: 111/111 componentes, 0 erros, 3/3 testes — validate ID 0Affj00000NmN9yCAF

sf project deploy start --source-dir force-app --test-level RunLocalTests --json
# sucesso: 111/111 componentes, 0 erros, 3/3 testes — deploy ID 0Affj00000NmNjRCAV
```

Nenhum arquivo em `force-app/` foi alterado para isso — é reaplicação do que já estava no
working tree, sobre a org, sem mudança de metadata.

## Estado da org — depois do deploy, confirmado por Tooling API (fonte confiável)

```
sf data query --use-tooling-api --query "SELECT QualifiedApiName FROM FieldDefinition WHERE EntityDefinition.QualifiedApiName = 'Discount_Request__c'"
sf data query --use-tooling-api --query "SELECT QualifiedApiName FROM FieldDefinition WHERE EntityDefinition.QualifiedApiName = 'Integration_Log__b'"
```

| Item | No repo? | Na org depois (Tooling API `FieldDefinition`) |
|---|---|---|
| (a) 8 permission sets `NDG_*` | Sim | Sim — 8/8 confirmados via `sf org list metadata -m PermissionSet` |
| (b) 3 Custom Metadata Types de política | Sim | Sim — 11/11 registros confirmados via `SELECT COUNT()` (8 `Pricing_Rule__mdt` + 1 `Margin_Policy__mdt` + 2 `Freight_Rule__mdt`) |
| (c) `Discount_Request__c` | Sim (13 campos) | Sim — **13/13 campos customizados presentes** via `FieldDefinition` |
| (d) `Integration_Log__b` | Sim (17 campos) | Sim — **17/17 campos customizados presentes** via `FieldDefinition` |

## Alerta de verificação — `sf sobject describe` não é confiável logo após deploy

`docs/releases/R04/known-limitations.md` já registrava que o `describe` padrão não reflete Big
Object imediatamente. Esta rodada confirma que o mesmo comportamento apareceu também em
`Discount_Request__c`, que é objeto comum — o describe local truncou para 1 campo enquanto a
Tooling API já mostrava os 13. Registrado como **P-16** em `docs/PENDENCIAS.md`: quem for
verificar campo por campo depois de um deploy deve usar `FieldDefinition` via Tooling API, não
`sf sobject describe`, ou vai ler uma lacuna que não existe.

## Leitura honesta

As quatro fatias (a)-(d) estão, neste momento, confirmadas tanto no repositório quanto na org,
com evidência de fonte confiável (Tooling API, não o describe padrão). Não houve necessidade de
contornar nenhum erro de deploy nesta rodada — o deploy completo passou de primeira, validação e
aplicação, sem erro de plataforma.

Isso **não fecha o M1**. `docs/PROGRESSO.md` já lista o que falta e continua valendo sem
mudança: os demais objetos do §9 fora de (b)/(c)/(d), e os testes de permissão via
`System.runAs()` por persona, que dependem de lógica de negócio que ainda não existe.

A observação original do dono — só um objeto customizado visível, nenhum item do M1 — é
compatível com o fato de `Integration_Log__b` ter sido criado nesta mesma janela de tempo (log
de criação do objeto no Tooling API é anterior a esta rodada em menos de uma hora) e de Custom
Metadata Types não aparecerem no Object Manager padrão do Setup — só em "Custom Metadata Types",
uma página separada. Quem olhou o Object Manager antes dessa criação via, de fato, só
`Discount_Request__c`. Isso é uma leitura plausível do timing, não uma confirmação — não há como
provar retroativamente o que a tela do dono mostrava no momento em que ele olhou.
