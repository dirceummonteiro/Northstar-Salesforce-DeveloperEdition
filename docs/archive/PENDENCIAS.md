# PENDÊNCIAS — o que ficou de fora e por quê

Nada aqui foi cancelado. Tudo aqui foi **adiado**, com motivo registrado. A seção 2.2 do
`MASTER_SCOPE.md` exige este arquivo.

Regra da §2.2: se durante a execução um item adiado se mostrar necessário, o Helix registra a
justificativa em `DECISIONS.md` e **escala para o `sfable`** antes de trazer de volta. Nenhum
agente reabre escopo por conta própria.

---

## 1. Escopo adiado pela §2.2 do escopo

| # | Item | Motivo do adiamento | Reavaliar quando |
|---|---|---|---|
| P-01 | Portal de autoatendimento do cliente (Experience Cloud) | Modelo de segurança externo inteiro (perfis de comunidade, sharing sets, OWD externo). Não é necessário para demonstrar o squad. | Depois do M13, se houver tempo |
| P-02 | Vendas por parceiro e registro de deal | Depende do mesmo modelo de comunidade/portal do P-01 | Junto com P-01 |
| P-03 | Contratos e renovações | Ciclo de vida separado; não faz parte de lead-to-order | Depois do M13 |
| P-04 | Cases e atendimento ao cliente | Domínio separado do comercial | Depois do M13 |
| P-05 | Territory Management formal (Enterprise Territory Management) | Substituído por posse simples de conta + permission sets | Só se o roteamento de lead do M3 provar que precisa |
| P-06 | Gestão de cota e cálculo de atingimento | Substituído por um campo de meta no time, e só se algum relatório precisar | M11, se um dashboard exigir |
| P-07 | RevOps avançado e analytics executivo | Relatórios e dashboards básicos cobrem a demonstração | M11 |

### 1.1 Correção de motivo no P-01

A §2.2 do escopo cita "licenças limitadas no Developer Edition" como uma das razões para adiar o
portal. **A medição não confirma isso**: a org tem 5 Customer Community, 5 Customer Community
Plus, 5 Partner Community e mais licenças de portal livres (`AMBIENTE.md` §3).

O adiamento **continua válido**, mas por um motivo só: o custo do modelo de segurança externo.
Registrar o motivo correto importa porque, se alguém reabrir o P-01 no futuro, precisa saber que
o obstáculo é desenho de sharing, não compra de licença.

---

## 2. Pendências operacionais criadas pela execução

| # | Pendência | Bloqueia? | Dono |
|---|---|---|---|
| P-10 | **Trocar a branch padrão do GitHub de `master` para `main`** | Não | Dirceu (1 clique) |
| P-11 | Remover a branch `master` do remoto depois do P-10 | Não | Probe |
| P-12 | Remover ou absorver `HttpCalloutService` quando a camada real de integração existir | Não | Bridge, no M9 |
| P-13 | Runbook de reautenticação PKCE manual do Salesforce | Não | Probe, antes do M12 |
| P-14 | Definir licença do projeto (o `README` está com "TBD") | Não | Dirceu |
| P-15 | **Agente `schema` não inicializa** — `WorkspaceVanishedError` após o rename forge → schema. **Resolvida em 2026-08-19** (ver nota abaixo e D-018) | Não — resolvida | Helix |
| P-16 | `sf sobject describe` não reflete campos recém-deployados de forma confiável, mesmo fora de Big Object | Não (Tooling API resolve) | Probe |
| P-17 | **`Seed_Key__c` invisível para quem roda o seed** — contornado com atribuição de permission set (D-021). **Fechada em 2026-08-20** (ver nota abaixo): metadata versionada, validada e deployada na org (`0Affj00000NpcVqCAJ`) | Não — fechada | Probe |

### P-16 — `sf sobject describe` truncado depois de deploy

Na reconciliação de `docs/releases/R05/`, logo depois de um `sf project deploy start` bem
sucedido (111/111 componentes, 0 erros), `sf sobject describe -s Discount_Request__c` mostrou só
1 campo customizado (de 13) e `sf sobject describe -s Integration_Log__b` mostrou só 3 (de 17).
`docs/releases/R04/known-limitations.md` já registrava esse comportamento para Big Object; esta
fatia confirma que ele também aparece em `Discount_Request__c`, que é objeto comum. A Tooling API
(`SELECT QualifiedApiName FROM FieldDefinition WHERE EntityDefinition.QualifiedApiName = '...'`)
mostrou os campos completos nos dois casos, sem o mesmo atraso. **Regra prática para quem
verificar campo por campo depois de um deploy: usar `FieldDefinition` via Tooling API, nunca
`sf sobject describe` sozinho** — o describe local pode ler uma lacuna que não existe.

### P-17 — `Seed_Key__c` invisível para quem roda o seed

A fatia (a) do M2 concedeu FLS de `Seed_Key__c` **somente nos 8 permission sets `NDG_*`**
(`readable=true`, `editable=false`). Nenhum perfil recebeu o campo, inclusive o de administrador
do sistema. Campo deployado por Metadata API não ganha FLS de perfil sozinho — só ganha o que a
metadata declarar.

Efeito medido na fatia (b): `sf data query`, `sf sobject describe` e o Apex anônimo relatam todos
`No such column 'Seed_Key__c' on entity 'Account'`, e o script de seed **não compila**. A Tooling
API (`FieldDefinition`) mostra os 11 campos presentes o tempo todo. O campo existe; a FLS o
esconde.

**Contorno que estava em vigor:** o permission set `NDG_Salesforce_Admin_Extended` foi atribuído
ao usuário que roda o seed. Registrado em D-021. Era `PermissionSetAssignment` — ação na org, não
versionada; não deixou artefato no repositório.

**Correção definitiva (2026-08-20, fatia (c) do M2):** o diagnóstico acima está parcialmente
errado e fica registrado como estava para não reescrever a história. As entradas de FLS **não
faltavam**: a fatia (a) concedeu as 11 entradas de `Seed_Key__c` nos 8 permission sets `NDG_*`,
todas com `readable=true`. O que faltava era **escrita para quem opera o seed** — nenhum dos 8
tinha `editable=true` — e a declaração de qual permission set é o do seed.

`NDG_Salesforce_Admin_Extended` passou a ter `editable=true` nas 11 entradas de `Seed_Key__c`. Os
outros 7 seguem com `editable=false`: leitura para auditar, escrita só no permission set que
opera a massa. A atribuição desse permission set deixa de ser contorno e passa a ser parte
declarada do procedimento de seed — o ramo "se estiver errado" de D-021.

Validado com `sf project deploy validate` (Deploy ID `0Affj00000Npk8QCAR`, 1/1 componente, 3/3
testes).

**Fechamento (2026-08-20):** deploy aplicado pelo Probe (§65.1) — Deploy ID
`0Affj00000NpcVqCAJ`, 3/3 testes — e confirmado na org por SOQL/Tooling API direto contra
`FieldPermissions`. Commits desta fatia: `da7d337` (concede `editable=true` em `Seed_Key__c` ao
permission set do seed), `eaf8baf` (remove `viewAllRecords`/`modifyAllRecords` de `Pricebook2`/
`Product2`), `737b8e8` e `ec845ec` (docs e pacote de evidência `docs/releases/R09/`). **P-17
fechada.** Registro final do diagnóstico, para não reescrever a história: a causa original
apontada — "FLS invisível para quem roda o seed" — estava parcialmente errada. As entradas de
FLS de `Seed_Key__c` **existiam** nos 8 permission sets `NDG_*` desde a fatia (a) do M2, todas
com `readable=true`. O que faltava não era a entrada, era `editable=true` — nenhum dos 8 tinha
escrita concedida. A correção definitiva concede `editable=true` apenas em
`NDG_Salesforce_Admin_Extended`; os outros 7 permanecem `editable=false` (leitura para auditar,
escrita só no permission set que opera a massa).

**Achado colateral:** o mesmo permission set declarava `viewAllRecords`/`modifyAllRecords` em
`Pricebook2` e `Product2`, que a licença do usuário não permite. Isso já reprovava a validação em
HEAD, sem relação com P-17: o permission set não era deployável. Os flags foram para `false` e o
CRUD integral foi preservado nos dois objetos.

**Relação com P-16:** o mesmo mecanismo explicaria o que P-16 registrou como "describe truncado"
— campo deployado por Metadata API fica sem FLS, e tanto `describe` quanto SOQL passam pela FLS
do usuário, relatando como inexistente um campo que está lá. Para `Seed_Key__c` isso está
**provado** (atribuir o permission set fez o campo aparecer nos três canais). Para os campos de
`Discount_Request__c` e `Integration_Log__b` da R05 é só a leitura mais provável: ninguém
reverificou aqueles casos sob esta hipótese. Vale a pena o Probe reabrir P-16 com esse teste
antes de tratar o describe como não confiável.

### P-15 — observação da fatia (d) do M1

Na fatia (d) (`Integration_Log__b`, `docs/releases/R04/`), foi o próprio `schema` — não o Kernel
— quem aplicou a correção de `Integration_Name__c` no working tree, entre a primeira recusa de
validação (Deploy ID `0Affj00000NlcCiCAJ`) e a integração desta fatia. Isso é evidência de que o
agente voltou a produzir metadata, mas o Probe não tem visibilidade de infraestrutura para
confirmar se a inicialização foi corrigida de forma definitiva ou se foi uma execução pontual.
**Não fecha P-15 nem reverte D-010** por conta própria — fica registrado para o Helix decidir se
reavalia o desvio.

### P-15 — resolução (2026-08-19)

**Resolvida.** O Helix testou o agente `schema` diretamente nesta rodada, antes de atribuir a
fatia (a) do M2: leitura e escrita confirmadas em
`/home/shieldadmin/.openclaw/workspace-helix`, `sf` CLI 2.147.7 disponível e a org `helix-dev`
visível e conectada. O `schema` produziu esta própria fatia (campos `Seed_Key__c` e FLS
correspondente) como evidência. Decisão de encerrar o desvio registrada em D-018 —
`docs/DECISIONS.md`.

### P-10 — detalhe

Nenhum agente consegue fazer isso daqui. A deploy key SSH autentica operações `git`, mas não a
API REST do GitHub, que é o que altera configuração de repositório (`AMBIENTE.md` §4.1).

Caminho para o dono, em `Settings → General → Default branch → Switch to another branch → main`.
Alternativa: autenticar o `gh` CLI nesta máquina, e aí o Probe resolve sozinho.

Enquanto não for feito: `main` é a branch de trabalho e recebe todos os commits; `master`
continua no remoto como ponteiro obsoleto e **não pode ser apagada** enquanto for a padrão.
Quem clonar o repositório cai em `master` e vê o projeto congelado no M0. É cosmético para o
time e feio para a vitrine — por isso está registrado, não escondido.
