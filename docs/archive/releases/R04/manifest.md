# R04 — Manifest

## Fonte

Metadata declarativa chegou pronta no working tree. A correção de `Integration_Name__c` (80 →
64) foi aplicada pelo `schema` diretamente — não pelo Kernel sob o desvio D-010; ver observação
em `docs/PENDENCIAS.md`, P-15. O Probe validou, corrigiu uma segunda vez sob autorização de
exceção do Helix (64 → 60, ver D-012) e integrou:

```
sf project deploy validate --source-dir force-app --test-level RunLocalTests --target-org helix-dev --json
```

Três validações rodaram nesta fatia:

1. Job `0Affj00000NlcCiCAJ` (tentativa anterior, `Integration_Name__c` = 80) — **recusado**,
   "The total length for all text fields in an index can't exceed 100 characters."
2. Job `0Affj00000NmAhNCAV` (`Integration_Name__c` = 64, 64+36=100) — **recusado** com a mesma
   mensagem. Confirma que o teto de 100 é exclusivo, não inclusivo.
3. Job `0Affj00000NmAkbCAF` (`Integration_Name__c` = 60, 60+36=96) — **aceito**, 111/111
   componentes, 3/3 testes, 0 erros.

Seguido de quick deploy sobre a validação aceita (nenhum teste re-executado, reaproveita o
`RunLocalTests` já validado):

```
sf project deploy quick --job-id 0Affj00000NmAkbCAF --target-org helix-dev --json
```

Job de deploy `0Affj00000NliQBCAZ`.

## Componentes implantados (111/111, 0 erros)

### `Integration_Log__b` — objeto + 17 campos + 1 índice

| Estado | Nome | Tipo |
|---|---|---|
| Created | `Integration_Log__b` | CustomObject (Big Object) |
| Created | `Correlation_Id__c` (Text 36), `Duration_Ms__c` (Number 9,0), `Error_Code__c` (Text 40), `Error_Message__c` (LongTextArea 32768), `Event_Date__c` (DateTime), `Http_Status_Code__c` (Number 3,0), `Integration_Name__c` (Text 60), `Object_Name__c` (Text 40), `Operation__c` (Text 40), `Parent_Correlation_Id__c` (Text 36), `Record_Id__c` (Text 18), `Request_Payload__c` (LongTextArea 32768), `Response_Payload__c` (LongTextArea 32768), `Retry_Count__c` (Number 2,0), `Retry_Status__c` (Text 20), `Running_User_Id__c` (Text 18), `Status__c` (Text 20) | CustomField (17) |
| Created | `Integration_Log_Index` — `Integration_Name__c` (ASC) → `Event_Date__c` (DESC) → `Correlation_Id__c` (ASC) | Index |

### Permission sets (3 alterados)

| Estado | Nome | Tipo |
|---|---|---|
| Changed | `NDG_Integration_Admin`, `NDG_RevOps`, `NDG_Salesforce_Admin_Extended` | PermissionSet (3) |

Os 111 componentes deployados são o total do `force-app/` inteiro (`--source-dir force-app`,
não incremental — os scripts da esteira sempre reenviam a árvore inteira; ver D-013). O que é
**novo** nesta fatia é o objeto, os 17 campos, o índice e os 3 permission sets acima; o resto do
pacote é reimplantação sem diff de conteúdo dos objetos/campos/permission sets das fatias 1,
(a), (b) e (c).

## `manifest/package.xml` não reflete este deploy

Ver D-013 em `docs/DECISIONS.md` e item (f) de `known-limitations.md` — o manifesto declara só
`ApexClass: *` e não foi tocado nesta fatia nem em nenhuma anterior, por desenho: os scripts da
esteira nunca o usam.
