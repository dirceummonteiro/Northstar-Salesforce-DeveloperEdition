# R10 — Release Summary (M3, fatia M3.1: schema do Lead)

## Identificação

| Campo | Valor |
|---|---|
| Marco | M3, fatia M3.1 — schema do Lead: 8 campos custom, `Lead_Scoring_Rule__mdt`, `Lead_Routing_Rule__mdt`, 3 filas, FLS nos permission sets `NDG_*` (D-023, D-024) |
| Commit | ver hash no final deste documento |
| Branch | `main` |
| Remoto | `origin` |
| Base | `0508c03` (fecha M2 / abre M3, `HEAD == origin/main` no início desta rodada) |
| Org alvo | alias `helix-dev` (Developer Edition, não-produção) |
| Data | 2026-08-20 |
| Owner do release | Probe |
| Produzido por | agente Kernel (metadata declarativa e reconciliação de docs); validado, corrigido, deployado e commitado pelo Probe (§65.1) |

## O que este release entrega

Primeira fatia do M3 (Lead: captura, scoring, roteamento, conversão). Fundação declarativa,
sem Apex: 8 campos custom em `Lead`, os Custom Metadata Types `Lead_Scoring_Rule__mdt` (6
registros de exemplo) e `Lead_Routing_Rule__mdt` (3 registros), 3 filas de `Lead` sem membros, e
FLS dos 8 campos novos nos 8 permission sets `NDG_*` já existentes. Contexto completo em
**D-023** (modelo de dados do Lead) e **D-024** (padrão de trigger, registrado agora, implementado
na M3.2), `docs/DECISIONS.md`.

## A) Auditoria de segredo — antes do `git add` (bloqueante, repositório público)

`git diff` completo revisado arquivo a arquivo antes de qualquer stage. Busca por
`sfdx-auth-url`, `force://`, senha/token/secret/chave, blocos `-----BEGIN`, padrão de Org Id
(`00D...`) e e-mail/CPF/telefone real nos arquivos novos e alterados — nenhum resultado. Nenhum
ID de org, token, auth url ou dado de pessoa real no diff.

## B) `README.md` — diff investigado

`README.md` apareceu modificado sem que o Kernel tivesse alegado tê-lo tocado (árvore limpa em
`0508c03`). `git diff README.md` mostra só a atualização do badge de progresso — `0 / 13` →
`3 / 13` marcos — e uma frase substituindo "projeto no M0" por um resumo do estado atual (fundação,
modelo de dados e massa concluídos; M3 em andamento). **3/13 é factualmente correto**: M0, M1 e M2
estão fechados (`docs/PROGRESSO.md`). Sem conteúdo estranho ao badge. Incluído no commit desta
fatia.

## C) Dry-run e deploy real

```
sf project deploy start --source-dir force-app --dry-run --target-org helix-dev --test-level RunLocalTests
Status: Succeeded (dry-run)
Componentes: 158/158, 0 erros
Testes: 3/3, 0 falhas
```

Dry-run limpo na primeira tentativa — sem erro de `required=true` em campo de Custom Metadata
Type nem qualquer outro erro. Nenhum ajuste necessário na metadata do Kernel.

```
sf project deploy start --source-dir force-app --target-org helix-dev --test-level RunLocalTests
Status: Succeeded
Componentes: 158/158 deployados, 0 erros
Testes: 3/3, 0 falhas
```

## D) Verificação na org — direta, não só o status do deploy

**8 campos em `Lead`** (`sf sobject describe --sobject Lead`), todos presentes:
`Lead_Score__c`, `Lead_Score_Band__c`, `Capture_Channel__c`, `Lead_Dedupe_Key__c`,
`Scored_At__c`, `Routed_At__c`, `Routing_Reason__c`, `Conversion_Blocked_Reason__c` — **8 de 8**.

**Custom Metadata Types** (SOQL direto):

| Consulta | Esperado | Confirmado |
|---|---|---|
| `SELECT DeveloperName FROM Lead_Scoring_Rule__mdt` | 6 | **6** — `Annual_Revenue_Above_1M`, `Country_Brazil`, `Email_Present`, `Industry_Technology`, `Lead_Source_Web`, `Phone_Present` |
| `SELECT DeveloperName FROM Lead_Routing_Rule__mdt` | 3 | **3** — `Score_0_39_Nurture`, `Score_40_69_SMB`, `Score_70_100_Enterprise` |

**Filas** (`SELECT DeveloperName FROM Group WHERE Type='Queue' AND DeveloperName IN
('Lead_Enterprise','Lead_SMB','Lead_Nurture')`): **3 de 3** — `Lead_Enterprise`, `Lead_Nurture`,
`Lead_SMB` confirmadas.

## E) FLS revisada no diff

FLS dos 8 campos novos aplicada nos 8 permission sets `NDG_*`. Os 6 campos calculados
(`Lead_Score__c`, `Lead_Score_Band__c`, `Scored_At__c`, `Routed_At__c`, `Routing_Reason__c`,
`Conversion_Blocked_Reason__c`) ficam `readable=true`/`editable=false` em todos os 8. Os 2 campos
de entrada externa (`Capture_Channel__c`, `Lead_Dedupe_Key__c`) recebem `editable=true` só em
`NDG_Integration_Admin` e `NDG_Salesforce_Admin_Extended`; `readable=true`/`editable=false` nos
outros 6. Nenhum permission set novo criado; nenhum `viewAllRecords`/`modifyAllRecords`
reintroduzido.

## Impacto em dados/limites

Sem carga de dado nesta fatia — só metadata (campos, CMDT, filas, FLS). Consumo de API desta
rodada: 2 chamadas de Metadata API (dry-run + deploy) mais describe/SOQL de verificação — volume
baixo, dentro do teto diário de 15.000 chamadas (§ economia de API do `AGENTS.md`).

## Segurança — ESCALONAMENTO DE SEGURANÇA

Este release **toca FLS em 8 permission sets** `NDG_*`. Por definição do `AGENTS.md`, isso se
qualifica como **ESCALONAMENTO DE SEGURANÇA** e é reportado ao Helix, mesmo sendo concessão
aditiva de campos novos (nenhum campo pré-existente teve permissão alterada) e com o padrão mais
restritivo possível: escrita só nos dois permission sets operacionais que precisam popular os
campos de captura/dedupe (`Integration_Admin`, `Salesforce_Admin_Extended`); os demais só leitura,
inclusive para os 6 campos calculados por Apex futuro (M3.2+), que nenhum humano deve editar
manualmente.

## Limitações conhecidas

Ver `known-limitations.md`.

## Go/no-go do Helix

**M3 não fecha nesta fatia** — só a M3.1 (schema) está concluída e deployada; M3.2 a M3.5 seguem
em aberto (`docs/PROGRESSO.md`). Métrica de marcos do README permanece **3/13**. Sujeito à
ratificação do Helix sobre o ESCALONAMENTO DE SEGURANÇA acima.
