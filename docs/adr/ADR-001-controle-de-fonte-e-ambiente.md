# ADR-001 — Estratégia de controle de fonte e ambiente

- **Status:** Aceito
- **Data:** 2026-08-18
- **Marco:** M0
- **Decisor:** Helix
- **Consultados:** Probe (esteira `sf` CLI e git)
- **Referências do escopo:** §7 (controle de fonte e ambiente), §39 (ADR-001), §45, §46, §55, §59, §65, §68

---

## 1. Contexto

O Northstar é um protótipo Salesforce construído por um time de agentes autônomos, num
repositório **público** que serve de vitrine. Antes de qualquer objeto ou linha de Apex existir,
três perguntas precisam de resposta fixa, porque toda decisão posterior depende delas:

1. Onde mora a verdade — o repositório ou a org?
2. Quantos ambientes existem e como o código chega neles?
3. Quem tem autoridade para alterar a org?

O ambiente medido (`AMBIENTE.md`) impõe as restrições:

- **Uma única org**, Developer Edition. Sem sandbox, sem scratch org, sem Change Sets.
- **5 MB de data storage.** Aproximadamente 2.560 registros somando todos os objetos.
- **15.000 chamadas de API por dia**, e todo comando `sf` consome desse mesmo balde.
- **Sem `gh` autenticado.** A deploy key SSH dá `git push`, mas não dá API do GitHub.

A restrição que mais dói é a primeira: **não existe ambiente descartável**. Um deploy ruim não
é revertido criando uma org nova. É revertido consertando a org que também é o ambiente de demo.

---

## 2. Decisão

### 2.1 Git é a fonte de verdade. A org é um alvo de deploy.

Nenhum agente configura nada direto na UI do Salesforce e deixa lá. Toda mudança nasce como
arquivo no repositório e chega na org por `sf project deploy`. O caminho contrário —
`sf project retrieve` — existe só para capturar o que o Salesforce gera sozinho (por exemplo, o
XML completo de um dashboard), e o resultado é revisado e commitado imediatamente.

**Consequência que vale escrever:** se a org for perdida amanhã, o projeto se reconstrói do
repositório. Se o repositório for perdido, o projeto acabou. É essa a assimetria que define
qual dos dois é a verdade.

### 2.2 Uma branch: `main`. Sem branches, sem worktrees.

Todo trabalho acontece na `main` (§7.2 e §65 do escopo, decisão D-001).

O motivo não é preguiça de fazer branch — é que o benefício de branch é isolamento, e aqui não
há isolamento real a proteger: existe **uma org só**. Duas branches deployando na mesma org não
estão isoladas, estão se sobrescrevendo em silêncio, com o agravante de o git achar que está
tudo bem. Trocar merge conflict por sobrescrita silenciosa na org é um péssimo negócio.

O que substitui o isolamento:

- **Sequenciamento pelo Helix.** Duas tarefas que tocam o mesmo metadata de alta colisão (§64.1)
  não rodam ao mesmo tempo. Se a fila apertar, `docs/coordination/METADATA_LOCKS.md`.
- **Nunca commitar projeto quebrado.** Se está quebrado, conserta antes de commitar.
- **Validar antes de integrar.** Sempre `deploy validate` antes de `deploy start`.
- **Nunca `--force`.** Histórico da `main` não se reescreve (§59).

### 2.3 Um ambiente: `helix-dev`. Validar antes de deployar, sempre.

Comando de validação, que é o gate:

```bash
sf project deploy validate --source-dir force-app --test-level RunLocalTests --target-org helix-dev
```

Só depois que ele passa:

```bash
sf project deploy start --source-dir force-app --target-org helix-dev
```

`deploy validate` roda o deploy inteiro e os testes no servidor, e **descarta o resultado**. É a
coisa mais próxima de um ambiente descartável que esta org oferece: dá o veredito sem deixar a
org num estado meio-aplicado. Como não há sandbox, esse passo não é opcional.

`--test-level RunLocalTests` desde o M0, e não só perto da entrega. Cobertura descoberta no M12 é
cobertura que vira dívida em doze marcos.

**Deploy em lote, nunca arquivo a arquivo.** Cada chamada consome do orçamento diário de 15.000.

### 2.4 O Probe é o único agente que commita, faz push e deploya.

Os outros produzem arquivos e reportam. O Probe integra (§65.1).

Isso concentra a única ação destrutiva do fluxo — o deploy — atrás de um portão só. Portão que
tem duas entradas não é portão. Se o Probe travar, o trabalho **não** passa para outro agente
deployar no lugar dele: o Probe reporta ao Helix, que diagnostica ou escala. Deploy que falhou
precisa de diagnóstico, não de nova tentativa por quem tem menos contexto.

### 2.5 Nenhum segredo no repositório, garantido por `.gitignore` desde o primeiro commit.

Bloqueados sempre: `.sfdx/`, `.sf/`, qualquer `*.sfdx-auth-url`, saída de
`sf org display --verbose`, chaves e certificados, `.env`, senha ou token dentro de Named
Credential, dados de pessoa real, e IDs da org em documentação.

Autenticação vive no `sf` CLI, fora da árvore do repositório. Named Credentials referenciam
credenciais por nome; o segredo é configurado na org, nunca no metadata versionado.

**Histórico público não se apaga.** Um segredo que entrar continua acessível depois de removido,
via reflog, forks e caches de terceiros. Por isso a defesa é o `.gitignore` no primeiro commit,
e não uma limpeza depois.

### 2.6 Evidência de release por marco

Cada marco fechado gera `docs/releases/RNN/` conforme a §68: commit SHA, org alvo (alias, nunca
o ID), comando usado, resultado do deploy, testes executados, falhas, cobertura, smoke test,
limitações conhecidas e o go/no-go do Helix.

Regra da §68 que vale repetir: **nenhum agente diz que uma feature está deployada porque criou
arquivos locais.** Arquivo criado é arquivo criado. Deploy é o que o `sf` responde.

---

## 3. Alternativas consideradas

### 3.1 GitFlow ou branch por feature

**Rejeitada.** Branch protege contra interferência entre linhas de trabalho paralelas que têm
ambientes distintos. Com uma org só, duas branches compartilham o mesmo alvo: o isolamento é
ilusório, e ainda custa merge de metadata XML — que resolve mal, porque conflito em
`CustomObject` ou em permission set é semântico, não textual.

### 3.2 Scratch orgs por feature

**Impossível aqui, e seria a escolha certa em outro lugar.** Developer Edition não é Dev Hub e
não cria scratch org. Se este projeto tivesse Dev Hub, esta ADR seria outra: scratch org por
feature, `main` protegida, PR com validação automática. Vale registrar porque a decisão é
imposta pelo ambiente, não preferida em abstrato — e se a org mudar, a ADR deve ser revisitada.

### 3.3 Configurar na UI e fazer retrieve depois ("org como fonte de verdade")

**Rejeitada.** É o caminho mais rápido para o primeiro resultado e o mais caro do segundo em
diante. Com seis agentes mexendo, o retrieve traz junto tudo o que outro agente fez na mesma
janela, o diff fica ilegível, e a revisão vira arqueologia. Além disso quebra a §52
("core metadata is reproducible"), que é critério de aceitação do projeto.

### 3.4 Deploy sem validate, confiando no rollback do Salesforce

**Rejeitada.** O deploy do Salesforce é transacional para o metadata, mas o efeito colateral não
é: teste que rodou criou e apagou dado, job assíncrono que disparou não volta, e o consumo de
API já foi. Como esta org é simultaneamente ambiente de desenvolvimento e de demonstração,
deixá-la num estado imprevisto custa mais do que os minutos do validate.

---

## 4. Consequências

### 4.1 Positivas

- Projeto reconstruível do zero a partir do repositório.
- Uma linha do tempo só, legível de fora — o dono acompanha o progresso pelo histórico da `main`.
- Um único ponto de mudança na org, o que torna qualquer regressão rastreável.
- Sem segredo vazado, por construção e não por vigilância.
- Feedback real desde o M0: se a esteira não funciona, isso aparece com o projeto vazio, e não
  com o modelo de dados inteiro dentro.

### 4.2 Negativas, assumidas conscientemente

- **O Probe é gargalo.** Todo commit e todo deploy passam por um agente. É o preço de ter um
  portão só, e é intencional.
- **Sem isolamento de verdade.** Uma tarefa mal sequenciada pelo Helix sobrescreve outra. Mitigado
  por sequenciamento explícito e pelas regras da §64, não por ferramenta.
- **`deploy validate` é lento** e consome API. Aceito: é mais barato que uma org inconsistente.
- **A branch padrão do GitHub ainda é `master`** e não dá para trocar daqui (P-10 em
  `PENDENCIAS.md`). Quem clonar cai numa branch congelada até o dono trocar. Cosmético, mas real,
  e por isso está registrado.

### 4.3 O que reabre esta ADR

- A org ganhar Dev Hub, ou o projeto ganhar uma segunda org.
- O `gh` CLI ser autenticado nesta máquina (aí PR e proteção de branch passam a ser possíveis, e
  o gate do Probe pode virar CI de verdade).
- O time crescer a ponto de o sequenciamento manual do Helix não dar conta.

---

## 5. Conformidade

| Regra do escopo | Onde é cumprida |
|---|---|
| §7.1 estrutura do repositório | Árvore criada inteira no M0 (D-007) |
| §7.2 só `main` | 2.2 desta ADR; D-001 |
| §7.3 uma org, validate antes de deploy | 2.3 desta ADR |
| §7.4 autenticação fora do repositório | 2.5 desta ADR |
| §59 guardrails | 2.4 e 2.5 desta ADR |
| §65.1 só o Probe integra | 2.4 desta ADR |
| §65.2 convenção de commit | `README.md`, seção de contribuição |
| §68 evidência de release | 2.6 desta ADR |
