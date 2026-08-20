# AMBIENTE — Helix Salesforce

Fatos medidos da org `helix-dev` e da estação de trabalho. **Não são estimativas.**
Toda vez que este documento for atualizado, registre a data da medição.

Não há projeto fixo. O time Helix trabalha por tarefas diretas do Dirceu, e estes limites
valem para qualquer coisa que for construída aqui.

> Regra: a medição manda nos **fatos da org**. Quando uma tarefa pedir algo que a medição
> contradiz, a medição ganha — e a divergência fica registrada aqui, com data.

---

## 1. Org alvo

Medido em **2026-08-18**.

| Item | Valor |
|---|---|
| Alias no `sf` CLI | `helix-dev` |
| Tipo | **Developer Edition** |
| Sandbox | Não |
| Instância | USA1044 |
| Idioma padrão | `en_US` |
| Namespace | nenhum |
| API da org | 67.0 |
| Multimoeda | **desativada** (não existe `CurrencyIsoCode`) |
| Status da conexão | Connected |

O ID da org e o username **não** entram em documentação versionada (seção de segurança do
`AGENTS.md`). Estão disponíveis via `sf org display --target-org helix-dev`.

### 1.1 Consequência de multimoeda desativada

A seção 9.4 do escopo cita `CurrencyIsoCode` "se multimoeda estiver habilitada". Não está.
Todo valor monetário é BRL implícito, no campo `Currency` padrão do Salesforce.
Nenhum objeto recebe campo de moeda. Ver decisão **D-005**.

---

## 2. Limites medidos

Medido em **2026-08-18**, org recém-criada e praticamente vazia.

| Recurso | Máximo | Em uso | Livre |
|---|---|---|---|
| **Data Storage** | 5 MB | 0 MB (0%) | 5 MB |
| **File Storage** | 20 MB | 0 MB | 20 MB |
| Chamadas de API por dia | 15.000 | 239 | 14.761 |
| Execuções Apex assíncronas / dia | 250.000 | 0 | 250.000 |
| Lotes Bulk API / dia | 15.000 | 0 | 15.000 |
| Platform Events entregues / dia | 10.000 | 0 | 10.000 |
| Permission Sets | 1.500 | 2 | 1.498 |
| E-mails simples / dia | 15 | 0 | 15 |
| Mass e-mails / dia | 10 | 0 | 10 |
| Callouts OData / hora | 1.000 | 0 | 1.000 |

### 2.1 O que 5 MB significa

O Salesforce cobra **2 KB por registro** na maioria dos objetos, independente de quantos
campos estão preenchidos.

```
5 MB ÷ 2 KB ≈ 2.560 registros no TOTAL, somando todos os objetos
```

O orçamento vinculante de seed data (seção 33 do escopo) é de ~1.620 registros, o que deixa
cerca de 900 de folga para os registros que os testes Apex criam e destroem a cada
`RunLocalTests`.

### 2.2 As duas saídas que não consomem esses 5 MB

1. **Custom Metadata Types** não contam contra data storage. Toda política de preço, faixa de
   desconto, regra de aprovação e configuração de integração mora lá — nunca em objeto custom.
2. **Big Objects** têm alocação própria de 1.000.000 de registros. Logs de integração,
   histórico de retry e evidência operacional vão para lá — nunca para objeto custom.

Isso não é otimização. É o que torna o projeto possível nesta org.

### 2.3 Orçamento de chamadas de API

15.000 por dia é o teto, e cada `sf project deploy`, `sf apex run test` e `sf data query`
consome. Regras:

- Deploy sempre em lote (`--source-dir force-app`), nunca arquivo a arquivo.
- `sf project deploy validate` antes de `start`, mas não em loop.
- Nada de polling de status em intervalo curto.
- Se o consumo diário passar de 60%, o Probe reporta ao Helix antes de continuar.

---

## 3. Licenças

Medido em **2026-08-18**. Só as que têm alocação > 0.

| Licença | Total | Em uso | Livre |
|---|---|---|---|
| **Salesforce** | 4 | 2 | **2** |
| Salesforce Platform | 6 | 0 | 6 |
| Identity | 110 | 0 | 110 |
| Chatter Free | 5.000 | 1 | 4.999 |
| Customer Community | 5 | 0 | 5 |
| Customer Community Plus | 5 | 0 | 5 |
| Customer Community Login | 5 | 0 | 5 |
| Customer Community Plus Login | 5 | 0 | 5 |
| Partner Community | 5 | 0 | 5 |
| Customer Portal Manager Standard | 10 | 0 | 10 |
| Customer Portal Manager Custom | 10 | 0 | 10 |
| Gold Partner | 6 | 0 | 6 |
| Silver Partner | 4 | 0 | 4 |
| External Identity | 9 | 0 | 9 |
| External Apps Login | 40 | 0 | 40 |
| Work.com Only | 3 | 0 | 3 |
| Salesforce Integration | 1 | 0 | 1 |
| Cloud Integration User | 1 | 0 | 1 |
| Analytics Cloud Integration User | 2 | 2 | 0 |
| Force.com App Subscription | 2 | 0 | 2 |
| Partner App Subscription | 2 | 0 | 2 |

### 3.1 Divergência com o escopo

A seção 1.5 e a 30.2 do `MASTER_SCOPE.md` afirmam **2 licenças Salesforce**. A medição mostra
**4 no total, 2 livres**. A conclusão de arquitetura **não muda**: continua sendo impossível
criar um usuário real por persona (são 9 personas na seção 4), e continua valendo o modelo de
**personas como permission sets** com `System.runAs()` nos testes. Ver **D-004**.

### 3.2 Experience Cloud é tecnicamente licenciável

Existem licenças de comunidade livres (Customer Community, Plus, Partner). O portal continua
**adiado** pela seção 2.2 do escopo — a razão do adiamento é o modelo de segurança externo
inteiro, não a licença. Registrado em `PENDENCIAS.md` com essa correção de motivo.

---

## 4. Estação de trabalho

Medido em **2026-08-18**.

| Item | Valor |
|---|---|
| Salesforce CLI | `@salesforce/cli/2.147.7` |
| Node.js | v26.7.0 |
| SO | Linux x64 (kernel 6.8.0) |
| `sourceApiVersion` do projeto | ver `sfdx-project.json` |
| Autenticação | refresh token no `sf` CLI, fora do repositório |
| GitHub | acesso por deploy key SSH (`git@github-helix`) |

### 4.1 Limitação conhecida: sem `gh` autenticado

O `gh` CLI está instalado mas **não autenticado**. A deploy key SSH dá acesso de escrita ao
repositório via `git`, mas **não** à API REST do GitHub. Consequência prática: nenhum agente
consegue alterar configurações do repositório (branch padrão, proteções de branch, criação de
PR). Ver `PENDENCIAS.md`.

### 4.2 Sem navegador nesta máquina

O VPS não tem navegador. Reautenticação no Salesforce, se o refresh token expirar, exige um
fluxo PKCE manual. Runbook em `docs/runbooks/` quando for necessário.

---

## 5. Como reproduzir estas medições

```bash
sf org display --target-org helix-dev
sf org limits list --target-org helix-dev
sf data query --target-org helix-dev \
  --query "SELECT Name, TotalLicenses, UsedLicenses, Status FROM UserLicense WHERE TotalLicenses > 0"
sf data query --target-org helix-dev \
  --query "SELECT Name, OrganizationType, InstanceName, IsSandbox, LanguageLocaleKey FROM Organization"
sf version
```

O Probe registra `DataStorageMB` no pacote de evidências de cada release (seção 68 do escopo).
**Se o uso passar de 70%, para tudo e reporta ao Helix.**
