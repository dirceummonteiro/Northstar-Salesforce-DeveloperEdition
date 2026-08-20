# Northstar Revenue Cloud Prototype

Implementação Salesforce de ponta a ponta — do lead ao pedido — construída por um time de
agentes de IA especializados, cada um responsável por uma camada da plataforma.

O objetivo não é gerar exemplos soltos de Apex. É construir um sistema coerente, com modelo de
dados de verdade, regras de negócio configuráveis, integrações com falha e recuperação,
segurança por persona, testes automatizados e deploy reproduzível — e provar que um time
autônomo consegue projetar, implementar, revisar, testar, entregar e **manter** isso.

> **Projeto encerrado em 2026-08-20.** O escopo, o log de decisões e o histórico de entregas
> estão em [`docs/archive/`](docs/archive/). O que já foi entregue continua no repositório e na
> org; nada novo será construído.

---

## O negócio

**Northstar Distribution Group** é uma distribuidora B2B brasileira fictícia de equipamentos
industriais, peças de reposição, consumíveis e contratos de manutenção. Vende por venda direta,
times regionais, contas estratégicas, canal de parceiros e inside sales.

Os problemas que a implementação resolve são os de sempre numa operação comercial que cresceu
sem plataforma: cliente fragmentado em várias planilhas, lead distribuído por e-mail, cálculo de
preço manual, desconto sem controle, margem vazando, Deal Desk lento, pedido digitado à mão e
nenhuma visibilidade de estoque ou crédito na hora da venda.

Escopo completo em [`docs/archive/MASTER_SCOPE.md`](docs/archive/MASTER_SCOPE.md) — 71 seções,
fonte de verdade única do projeto enquanto ele existiu.

---

## O que está sendo construído

| Capacidade | O que demonstra |
|---|---|
| Customer 360 | Account, Contact, hierarquia, segmentação, dedupe |
| Lead lifecycle | Captura, scoring 0–100, roteamento por território, SLA, conversão |
| Pipeline de oportunidade | Estágios, controles de progressão, forecast, detecção de deal parado |
| **Motor de precificação** | Faixa por tier, desconto por volume, margem — **tudo em Custom Metadata** |
| Controles de desconto e margem | Política de margem mínima, bloqueio com mensagem clara |
| Deal Desk | Matriz de aprovação por limiar, invalidação de aprovação, console de análise |
| Quote e Order | Versionamento de proposta, conversão para pedido |
| Integrações simuladas | ERP, estoque e crédito com mocks determinísticos, retry e idempotência |
| Observabilidade | Log de integração em **Big Object**, monitor com reprocessamento |
| Segurança | 8 permission sets, OWD, sharing, testes de permissão com `System.runAs()` |
| Analytics | Dashboards de rep, gerente e executivo |

### A decisão de arquitetura que define o projeto

A org alvo é uma **Salesforce Developer Edition com 5 MB de data storage** — cerca de 2.500
registros somando todos os objetos. Isso não é um detalhe de infraestrutura, é o que molda o
desenho:

- **Toda política de negócio mora em Custom Metadata Types**, que não consomem data storage.
  Faixa de desconto, regra de preço, limiar de aprovação, configuração de integração. Efeito
  colateral feliz: mudar uma regra comercial deixa de exigir mudança de Apex — que é justamente
  o que a §35.3 do escopo pede.
- **Todo log de integração vai para Big Objects**, que têm alocação própria de 1 milhão de
  registros. Observabilidade completa sem gastar os 5 MB.

Limites medidos, licenças e o que cada restrição implica: [`docs/AMBIENTE.md`](docs/AMBIENTE.md).

---

## Como rodar

Pré-requisito: [Salesforce CLI](https://developer.salesforce.com/tools/salesforcecli) (`sf`).

```bash
# 1. autenticar numa org Developer Edition
sf org login web --alias helix-dev --set-default

# 2. validar sem aplicar nada (roda o deploy e os testes no servidor, descarta o resultado)
./scripts/shell/validate.sh

# 3. aplicar na org
./scripts/shell/deploy.sh

# 4. rodar os testes Apex com cobertura
./scripts/shell/test.sh
```

`validate.sh` roda antes de todo deploy, sempre. Não existe sandbox nem scratch org neste
projeto: o validate é o que separa um erro descoberto de uma org meio-aplicada.

### Massa de demonstração

Depois do deploy, para carregar os dados de demonstração:

```bash
# carregar (idempotente: rodar duas vezes não duplica nada)
./scripts/shell/seed.sh

# apagar a massa — DESTRUTIVO
./scripts/shell/cleanup-seed.sh
```

Os dois aceitam `ORG_ALIAS` (default `helix-dev`).

São **1.051 registros sintéticos** em 12 objetos — contas, contatos, leads, catálogo de produtos,
tabelas de preço, oportunidades com linhas, propostas e pedidos. Todo registro carrega
`Seed_Key__c` com o prefixo `NS-`, e é essa marca que torna a carga repetível e a limpeza segura:
`cleanup-seed.sh` apaga **somente** o que tem a marca, nunca um objeto inteiro.

Nenhum dado de pessoa real. E-mails só em `@example.com`, telefones no prefixo `5550`, nomes
gerados por combinação indexada, nenhum documento gerado.

Detalhes de operação, pré-requisito de permissão e orçamento de storage em
[`scripts/apex/README.md`](scripts/apex/README.md).

---

## Estrutura

```
force-app/main/default/   metadata da org: objetos, campos, Apex, LWC, flows, permission sets
config/                   configuração de projeto
data/                     vazio — o seed é Apex, não arquivo de dados (D-015)
docs/
  AMBIENTE.md             limites, licenças e edição medidos na org real
  adr/                    architecture decision records
  architecture/           visão de arquitetura e dicionário de dados
  integrations/           contratos de integração
  testing/                estratégia de teste e matriz de regressão
  runbooks/               procedimentos operacionais
  archive/                projeto encerrado: escopo, decisões, progresso e evidências
    MASTER_SCOPE.md       fonte de verdade do escopo
    MVP_LADDER_V4.md      plano de entrega V4
    DECISIONS.md          log de decisões do coordenador
    PROGRESSO.md          marcos concluídos
    PENDENCIAS.md         o que foi adiado, e por quê
    releases/             pacote de evidências por marco
scripts/
  apex/                   seed data e limpeza (Apex anônimo) + README de operação
  shell/                  validate, deploy, test, seed, cleanup-seed
manifest/                 manifestos de deploy
```

---

## O time

Sete agentes, cada um com um domínio e um limite claro. Ninguém edita o domínio do outro sem
atribuição explícita.

| Agente | Domínio |
|---|---|
| **Helix** | Coordenação, arquitetura e modelo de dados. Decide o schema e não delega isso. |
| **Schema** | Metadata declarativa: objetos, campos, record types, flows, validation rules, permission sets, Custom Metadata |
| **Kernel** | Apex: triggers, handlers, services, batch, queueable, controllers |
| **Pixel** | Lightning Web Components e experiência do usuário |
| **Bridge** | Integrações: callouts, DTOs, mocks, retry, idempotência, correlation IDs |
| **Pulse** | Modelo de dados sob volume, SOQL, governor limits, seed data |
| **Probe** | QA, git e `sf` CLI. **Único agente que commita, faz push e deploya.** |
| **Fable** | Escalonamento. Acionado só pelo Helix, e só em decisão difícil ou bloqueio persistente. |

O portão único do Probe é deliberado: o deploy é a única ação destrutiva do fluxo, e portão com
duas entradas não é portão. Racional completo em
[`docs/adr/ADR-001-controle-de-fonte-e-ambiente.md`](docs/adr/ADR-001-controle-de-fonte-e-ambiente.md).

---

## Como o trabalho flui

Git é a fonte de verdade; a org é alvo de deploy. Todo trabalho acontece na `main`, sem branches
— porque com uma org só, duas branches não estão isoladas, estão se sobrescrevendo em silêncio.

```
requisito → Helix decompõe e decide arquitetura
          → especialista implementa só o escopo dele
          → Probe valida com sf project deploy validate
          → Probe commita, faz push e deploya
          → Probe registra evidência em docs/archive/releases/
          → Helix aceita ou devolve
```

Nenhum agente diz que algo está entregue porque criou arquivos locais. Entregue é o que o `sf`
respondeu.

Convenção de commit: `tipo(NS-ID): descrição no imperativo, em português`.

```
feat(NS-143): adiciona faixa de preço trimestral em Custom Metadata
fix(NS-188): impede submissão duplicada de pedido ao ERP
test(NS-211): cobre limites de aprovação de desconto
```

---

## Segurança

Este repositório é público. Nunca entram aqui, em nenhuma circunstância:

- `.sfdx/`, `.sf/`, qualquer arquivo com `sfdx-auth-url` ou saída de `sf org display --verbose`;
- senha, chave ou token dentro de Named Credential ou de qualquer metadata;
- dados de exemplo com nome, e-mail, telefone ou documento de pessoa real — **todo dado de seed
  é sintético e gerado**;
- IDs da org em comentário ou documentação.

O `.gitignore` cobre isso desde o primeiro commit, e não por limpeza posterior: **histórico
público não se apaga.** Um segredo que entra continua acessível depois de removido, via reflog,
forks e caches de terceiros.

---

## Limitações conhecidas

O ERP, o serviço de estoque e o de crédito são **simulados** com mocks determinísticos — o
objetivo é demonstrar o contrato, o tratamento de falha e o retry, não integrar com um sistema
real. O portal do cliente, vendas por parceiro, contratos e renovações estão **adiados**, com
motivo registrado em [`docs/archive/PENDENCIAS.md`](docs/archive/PENDENCIAS.md).

---

## Licença

A definir.

---

<details>
<summary><b>English summary</b></summary>

**Northstar Revenue Cloud Prototype** is an end-to-end Salesforce lead-to-order implementation
built by a squad of specialized AI agents — one owning declarative metadata, one Apex, one LWC,
one integrations, one data/performance, one QA and deployment, plus a coordinator that owns
architecture and the data model.

It covers Customer 360, lead scoring and routing, opportunity pipeline, a **Custom
Metadata-driven pricing engine**, discount and margin controls, Deal Desk approvals, quote and
order lifecycle, simulated ERP/inventory/credit integrations with deterministic mocks and retry,
Big Object observability, persona-based security, dashboards and an automated test suite.

The target org is a Salesforce Developer Edition with 5 MB of data storage (~2,500 records
total). That constraint drives the architecture: **all business policy lives in Custom Metadata
Types** (which don't consume data storage, and therefore make commercial rules configurable
without Apex changes) and **all integration logs live in Big Objects** (a separate 1M-record
allocation).

Git is the source of truth, the org is a deploy target, all work happens on `main`, and a single
agent owns commits and deployments. Full scope in [`docs/archive/MASTER_SCOPE.md`](docs/archive/MASTER_SCOPE.md);
measured org limits in [`docs/AMBIENTE.md`](docs/AMBIENTE.md); architecture decisions in
[`docs/adr/`](docs/adr/).

</details>
