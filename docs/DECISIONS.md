# DECISIONS — registro de decisões do Helix

Toda decisão que o `MASTER_SCOPE.md` não especificou, ou que a realidade da org obrigou a
ajustar, entra aqui. O projeto roda com autonomia total (seção 5.0.2 do escopo): nenhum agente
para para perguntar. Em compensação, nada é decidido em silêncio.

**Decisões grandes de arquitetura viram ADR** em `docs/adr/`. Este arquivo é o log corrido:
decisões menores ficam completas aqui, decisões grandes ficam resumidas aqui com link para o ADR.

Formato: `D-NNN | data | decisão | por quê | o que muda se estiver errado`.

---

## D-001 — A linha principal do repositório chama-se `main`

**Data:** 2026-08-18 · **Marco:** M0 · **Status:** aplicada, com pendência

O repositório foi criado com a branch `master`. As seções 7.2 e 65 do escopo dizem `main` em
todos os lugares, e o pedido do dono foi explícito: "commite na main".

**Decisão:** renomear `master` → `main` localmente, publicar `main` no remoto e passar a
trabalhar só nela. Nenhum agente cria branch ou worktree.

**Por quê:** o escopo é a fonte de verdade e é literal quanto ao nome. Manter `master` obrigaria
a reinterpretar sete seções do documento.

**Pendência que isto cria:** a branch padrão do GitHub continua sendo `master` até alguém
trocar. Não dá para trocar daqui — a deploy key SSH autentica `git`, não a API REST do GitHub
(ver `AMBIENTE.md` §4.1). Enquanto não for trocada, `master` fica no remoto como ponteiro
obsoleto e não pode ser apagada. Registrado em `PENDENCIAS.md` como ação de um clique do dono.

**Se estiver errado:** custo baixo. Renomear de volta é um comando.

---

## D-002 — Idioma: processo em português, plataforma em inglês

**Data:** 2026-08-18 · **Marco:** M0 · **Status:** aplicada

| Artefato | Idioma |
|---|---|
| `DECISIONS.md`, `PROGRESSO.md`, `PENDENCIAS.md`, `AMBIENTE.md`, ADRs, runbooks | **Português** |
| `README.md` | **Português**, com resumo em inglês no fim |
| Mensagens de commit | **Português**, imperativo (regra do `AGENTS.md`) |
| `docs/MASTER_SCOPE.md` | **Inglês** — cópia literal, não se traduz fonte de verdade |
| Nomes de objetos, campos, classes Apex, LWC, permission sets | **Inglês** |
| Labels e descriptions de metadata, comentários de Apex | **Inglês** |

**Por quê:** o dono lê português e é ele quem acompanha o projeto — documento de processo em
inglês é fricção sem retorno. Já o metadata é diferente: a org roda em `en_US`, os objetos
padrão do Salesforce são em inglês, e `Customer_Segment__c` ao lado de `Segmento_Cliente__c`
seria inconsistência permanente e visível no schema. Além disso o repositório é público e
vitrine: convenção internacional de nomenclatura Salesforce pesa mais no código do que na
documentação de processo.

**Se estiver errado:** trocar a documentação de idioma é reescrita, chata mas reversível.
Trocar nome de campo depois que existe dado é caro — por isso o metadata é o lado que segue a
convenção mais conservadora.

---

## D-003 — `sourceApiVersion` alinhada à API da org

**Data:** 2026-08-18 · **Marco:** M0 · **Status:** aplicada

O `sfdx-project.json` nasceu com `sourceApiVersion: 62.0`. A org está em **67.0**.

**Decisão:** subir o projeto para `67.0`.

**Por quê:** com versões diferentes, o retrieve traz metadata numa forma e o deploy espera
outra. Isso produz diffs fantasmas em arquivos que ninguém editou, e num repositório público
isso lê como descuido. Alinhar é gratuito agora, e caro depois que houver dezenas de arquivos
de metadata versionados na forma antiga.

**Se estiver errado:** se o CLI 2.147.7 tiver algum tipo de metadata que não conhece em 67.0, o
`deploy validate` acusa na hora e voltamos para 62.0. O M0 existe exatamente para descobrir isso
com um projeto vazio, e não com o modelo de dados inteiro dentro.

---

## D-004 — Personas continuam sendo permission sets, mesmo com 2 licenças livres

**Data:** 2026-08-18 · **Marco:** M0 · **Status:** aplicada

O escopo (§1.5, §30.2) afirma que a org tem 2 licenças Salesforce. A medição real:
**4 no total, 2 em uso, 2 livres** (`AMBIENTE.md` §3).

**Decisão:** manter integralmente o desenho da §30.2. As 9 personas da §4 são implementadas
como **permission sets**, os testes de permissão usam `System.runAs()` com usuários criados
dentro do teste, e a demonstração ao vivo troca permission sets no mesmo usuário.

**Por quê:** 2 licenças livres não resolvem 9 personas. E mesmo que resolvessem, permission set
é o desenho correto: usuário de teste criado em `@isTest` não consome licença, o modelo fica
versionado como metadata, e a §30.1 pede menor privilégio — que se expressa em permission set,
não em profile.

**O que a folga de licença compra:** um segundo usuário real para demonstrar sharing de verdade
(um registro que o usuário A vê e o B não). Isso é útil no M11 e vai ser usado lá se fizer falta.

**Se estiver errado:** nada quebra. É a opção conservadora.

---

## D-005 — Sem multimoeda: BRL implícito

**Data:** 2026-08-18 · **Marco:** M0 · **Status:** aplicada

A org **não tem multimoeda habilitada** — o campo `CurrencyIsoCode` não existe (`AMBIENTE.md` §1.1).

**Decisão:** todo valor monetário usa o tipo `Currency` padrão, em BRL implícito. Nenhum objeto
custom recebe campo de moeda. A §9.4 do escopo, que cita `CurrencyIsoCode` "se multimoeda estiver
habilitada", fica atendida pela condicional dela mesma.

**Por quê:** habilitar multimoeda numa org Salesforce é **irreversível**. A Northstar é uma
distribuidora brasileira vendendo em BRL; não há requisito de segunda moeda em nenhuma das 71
seções do escopo. Ligar um recurso irreversível para atender um "se" é o tipo de erro de schema
que o `AGENTS.md` manda evitar.

**Se estiver errado:** habilitar multimoeda depois é possível, mas irreversível e mexe em todo
campo de valor já criado. Por isso a decisão é não ligar até haver requisito real.

---

## D-006 — `HttpCalloutService` fica até o M9

**Data:** 2026-08-18 · **Marco:** M0 · **Status:** aplicada

O repositório já tinha uma classe de exemplo de callout HTTP com teste de 100% de cobertura,
de antes deste escopo existir.

**Decisão:** manter no M0, remover ou absorver no M9, quando o Bridge entregar a camada real de
integração ERP/estoque/crédito.

**Por quê:** o critério de validação do M0 é "`sf project deploy validate` passa". Validar com
uma classe Apex e um teste real prova bem mais da esteira do que validar um projeto vazio —
prova que compila, que o teste roda e que `RunLocalTests` funciona. Depois que a camada de
verdade existir, código de exemplo em repositório vitrine vira ruído e sai.

**Se estiver errado:** custo zero. É um `git rm` de dois arquivos.

---

## D-007 — Estrutura de pastas conforme §7.1, criada inteira no M0

**Data:** 2026-08-18 · **Marco:** M0 · **Status:** aplicada

**Decisão:** criar já no M0 toda a árvore recomendada pela §7.1 (`config/`, `data/`, `docs/` com
`architecture/`, `adr/`, `integrations/`, `testing/`, `runbooks/`, `releases/`, `coordination/`;
`scripts/` com `apex/`, `data/`, `shell/`; `manifest/`), mesmo com pastas ainda vazias.

**Por quê:** cada agente especialista precisa saber onde escrever antes de começar a escrever.
Estrutura criada sob demanda por seis agentes em paralelo vira seis convenções diferentes.

**Se estiver errado:** pasta vazia não custa nada. O `.gitkeep` sai quando o conteúdo entra.

---

## D-008 — Ordem de leitura obrigatória para todo especialista

**Data:** 2026-08-18 · **Marco:** M0 · **Status:** aplicada

**Decisão:** todo agente especialista, ao receber uma tarefa, lê nesta ordem antes de produzir
qualquer coisa: (1) a tarefa; (2) as seções do `docs/MASTER_SCOPE.md` citadas na tarefa;
(3) `docs/AMBIENTE.md`; (4) este arquivo; (5) o ADR relevante, se a tarefa citar um.

**Por quê:** a §71.2 do escopo manda todo agente ler o escopo inteiro antes de produzir. São
3.374 linhas. Ler tudo a cada tarefa gasta contexto que faz falta para o trabalho em si. A
decomposição em tarefas do Helix já cita as seções que importam — o especialista lê o recorte
mais os quatro arquivos de estado, que juntos são curtos.

**Se estiver errado:** um especialista implementa contra uma seção que não leu. Mitigação: as
tarefas do Helix citam seções explicitamente, e o gate do Probe + a aceitação do Helix pegam
divergência de escopo antes do deploy.
