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
| P-15 | **Agente `schema` não inicializa** — `WorkspaceVanishedError` após o rename forge → schema | Não (Kernel cobre, D-010) | Helix |

### P-15 — observação da fatia (d) do M1

Na fatia (d) (`Integration_Log__b`, `docs/releases/R04/`), foi o próprio `schema` — não o Kernel
— quem aplicou a correção de `Integration_Name__c` no working tree, entre a primeira recusa de
validação (Deploy ID `0Affj00000NlcCiCAJ`) e a integração desta fatia. Isso é evidência de que o
agente voltou a produzir metadata, mas o Probe não tem visibilidade de infraestrutura para
confirmar se a inicialização foi corrigida de forma definitiva ou se foi uma execução pontual.
**Não fecha P-15 nem reverte D-010** por conta própria — fica registrado para o Helix decidir se
reavalia o desvio.

### P-10 — detalhe

Nenhum agente consegue fazer isso daqui. A deploy key SSH autentica operações `git`, mas não a
API REST do GitHub, que é o que altera configuração de repositório (`AMBIENTE.md` §4.1).

Caminho para o dono, em `Settings → General → Default branch → Switch to another branch → main`.
Alternativa: autenticar o `gh` CLI nesta máquina, e aí o Probe resolve sozinho.

Enquanto não for feito: `main` é a branch de trabalho e recebe todos os commits; `master`
continua no remoto como ponteiro obsoleto e **não pode ser apagada** enquanto for a padrão.
Quem clonar o repositório cai em `master` e vê o projeto congelado no M0. É cosmético para o
time e feio para a vitrine — por isso está registrado, não escondido.
