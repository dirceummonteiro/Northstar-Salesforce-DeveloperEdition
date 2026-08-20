# R08 — Release Summary (M2, fatia (b): scripts de seed e limpeza)

## Identificação

| Campo | Valor |
|---|---|
| Marco | M2, fatia (b) — massa de demonstração idempotente e script de limpeza (§33, D-015, D-016) |
| Commit | (registrado após este pacote de evidência — ver hash final no relatório da tarefa) |
| Branch | `main` |
| Remoto | `origin` |
| Base | `2de46b7` (fatia (a), `HEAD == origin/main` no início desta rodada) |
| Org alvo | alias `helix-dev` (Developer Edition, não-produção) |
| Data | 2026-08-20 |
| Owner do release | Probe |
| Produzido por | agente Kernel (Apex anônimo e wrappers de shell); integrado, executado e commitado pelo Probe (§65.1) |

## O que este release entrega

Seed data sintético em Apex anônimo (três etapas: `seed_01_catalog.apex`, `seed_02_customers.apex`,
`seed_03_pipeline.apex` — separado porque Apex anônimo tem teto de 32.000 caracteres por
execução), relatório de contagem somente-leitura (`seed_99_report.apex`), limpeza seletiva por
marca (`cleanup_seed.apex`), invólucros de shell (`seed.sh`, `cleanup-seed.sh`) e documentação de
operação (`scripts/apex/README.md`, seção "Massa de demonstração" no `README.md` da raiz).
Contexto completo em **D-019**, **D-020**, **D-021**, `docs/DECISIONS.md`.

## Comandos executados

```
sf apex run --target-org helix-dev --file scripts/apex/seed_99_report.apex   # leitura, pré-execução
./scripts/shell/seed.sh                                                     # etapas 1-3 + relatório
```

`seed.sh` executa, em ordem: `seed_01_catalog.apex`, `seed_02_customers.apex`,
`seed_03_pipeline.apex`, `seed_99_report.apex`.

## Resultado

- **Estado da org antes desta rodada:** a massa do M2 já estava carregada de uma execução
  anterior do Kernel — 1.051 registros nos 12 objetos, confirmados por `seed_99_report.apex` antes
  de qualquer escrita desta rodada.
- **Execução desta rodada (`seed.sh`, terceira execução cumulativa sobre a mesma massa):**
  - `Product2 upsert=100`, `Pricebook2 upsert=1`, `PricebookEntry inseridos=0 ja_existiam=200`
  - `Account upsert=80`, `Contact upsert=150`, `Lead upsert=80`
  - `Opportunity total=100 inseridas=0 atualizadas=100`
  - `OpportunityLineItem inseridas=0 atualizadas=180`
  - `Quote total=30 inseridas=0 atualizadas=30`
  - `QuoteLineItem inseridas=0 atualizadas=50`
  - `Order total=30 inseridos=0 atualizados=30`
  - `OrderItem inseridos=0 atualizados=50`
  - Nenhum objeto abortou por storage (`STORAGE_ANTES` ficou em 20,0% durante toda a execução,
    bem abaixo do teto de 70% da §33.2).
- **Idempotência confirmada nesta rodada:** zero inserções em qualquer objeto da etapa 3 (a
  única etapa que não usa `upsert` direto — ver D-019); os seis objetos "insert/update
  separados" (`Opportunity`, `OpportunityLineItem`, `Quote`, `QuoteLineItem`, `Order`,
  `OrderItem`) reportaram `inseridas=0` e a contagem de `atualizadas`/`atualizados` bateu
  exatamente com o total esperado de cada objeto. `seed_99_report.apex` ao final reportou as
  mesmas contagens de antes da execução, registro por registro.
- **Relatório final (`seed_99_report.apex`):**

  | Objeto | Contagem |
  |---|---|
  | Account | 80 |
  | Contact | 150 |
  | Lead | 80 |
  | Product2 | 100 |
  | Pricebook2 | 1 |
  | PricebookEntry | 200 |
  | Opportunity | 100 |
  | OpportunityLineItem | 180 |
  | Quote | 30 |
  | QuoteLineItem | 50 |
  | Order | 30 |
  | OrderItem | 50 |
  | **TOTAL_SEED** | **1.051** |

## Impacto em dados/limites

- `DataStorageMB`: **1 MB / 5 MB pela API** (granularidade grosseira demais — ver
  `scripts/apex/README.md`, "Por que a estimativa por registro"); estimativa por registro:
  **1.190 registros totais (1.051 do seed + 139 de amostra da Developer Edition, D-016) ≈ 2.380
  KB de 5.120 KB = 46,5%**, abaixo do portão de fechamento do M2 (50%, D-017 e §55) e da parada
  de emergência (70%, §33.2). Sem variação desta rodada em relação à execução anterior — os
  dados já existiam e a carga só confirmou o mesmo total.
- `DailyApiRequests`: consumo desta rodada é de leitura de dados (SOQL) e Apex anônimo, não
  Metadata API; volume baixo, não medido individualmente por não haver deploy nesta fatia.

## Segurança

Este release **não** toca permission set, profile, sharing rule, `without sharing`, Named
Credential nem qualquer metadata declarativa — é execução de Apex anônimo (dado, não schema) mais
documentação e scripts de shell. Não se qualifica como ESCALONAMENTO DE SEGURANÇA por definição
do `AGENTS.md`.

**Auditoria de segredo feita antes do `git add` (bloqueante, repositório público):**

- `grep -inE` por `sfdx-auth-url`, `force://`, senha/token/secret/chave, blocos `-----BEGIN`,
  padrão de Org Id (`00D...`) em todos os arquivos não commitados — nenhum resultado além de
  texto de documentação descrevendo a própria política de segurança.
- `grep -inE` por CPF/CNPJ e domínios de e-mail pessoais (`@gmail`, `@hotmail`, `@outlook`,
  `@yahoo`) nos scripts de seed e documentação — nenhum resultado além de texto afirmando que
  nenhum documento é gerado.
- `.gitignore` confirmado cobrindo `.sfdx/`, `.sf/`, `*.sfdx-auth-url` (linhas 6, 7, 10, 11) —
  não alterado nesta rodada.
- Dado de seed é 100% sintético: e-mails só em `@example.com` (RFC 2606), telefones no prefixo
  `5550`, nomes de empresa/pessoa gerados por combinação indexada, nenhum CPF/CNPJ gerado —
  confirmado por leitura do código-fonte dos três scripts de carga, não só pela documentação.

## Limitações conhecidas

Ver `known-limitations.md`.

## Go/no-go do Helix

**Pendente.** Esta fatia entrega e comprova os scripts de seed e limpeza do M2, com idempotência
e storage reconfirmados na org. O M2 **ainda não fecha** — falta a ratificação do Helix sobre
**D-020** (volume de 1.051 em vez dos ~1.620 da §33) e a correção definitiva da FLS de
`Seed_Key__c` em perfil (**P-17** / **D-021**), que é metadata declarativa do agente `schema`,
deploy do Probe. `docs/PROGRESSO.md` permanece em **2 / 13**.
