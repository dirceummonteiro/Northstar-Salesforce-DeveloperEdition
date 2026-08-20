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

---

## D-009 — Quote padrão em vez de modelo custom (ADR-008)

**Data:** 2026-08-18 · **Marco:** M1, com efeito no M8 · **Status:** aplicada

O objeto `Quote` padrão do Salesforce **não estava habilitado** nesta org — `SELECT COUNT() FROM
Quote` retornava "sObject type 'Quote' is not supported".

**Decisão:** habilitar o Quote padrão, via metadata:

```xml
<QuoteSettings>
    <enableQuote>true</enableQuote>
    <enableQuotesWithoutOppEnabled>false</enableQuotesWithoutOppEnabled>
</QuoteSettings>
```

**Por quê:** a §9.1 já preferia o padrão e só autorizava um modelo custom "se não estiver
habilitado/adequado". A investigação mostrou que não era indisponibilidade da Developer Edition —
era só uma configuração desligada, acessível por deploy. Habilitando, o M8 ganha de graça
`Quote`, `QuoteLineItem`, sincronização com a Opportunity, cálculo de totais e geração de PDF.
Construir tudo isso como objeto custom seria dias de trabalho, mais superfície de bug, e ainda
consumiria os 5 MB de storage que o objeto padrão não consome do mesmo jeito.

`enableQuotesWithoutOppEnabled` fica `false`: no fluxo da §18 toda proposta nasce de uma
oportunidade. Permitir proposta órfã abriria um caminho sem controle de preço nem aprovação.

**Se estiver errado:** habilitar Quote é reversível, mas propostas já criadas ficam. Como o
protótipo ainda não tem dado comercial, o custo de reverter hoje é zero.

---

## D-010 — Kernel assume metadata declarativa enquanto o agente Schema estiver quebrado

**Data:** 2026-08-18 · **Marco:** M1 · **Status:** aplicada, temporária

O agente `schema` **não inicializa**. Falha em ~100 ms com `WorkspaceVanishedError` apontando
para `/home/shieldadmin/.openclaw/workspace-schema`. Reproduzido três vezes.

Causa identificada: o agente foi renomeado de `forge` para `schema` (backup
`rename-forge-schema-20260818T202235Z`). O rename moveu o workspace antigo — com o arquivo de
estado dentro — para backup, e o novo ficou sem estado coerente. O runtime compara os hashes
atestados com o que está no disco, não bate, e se recusa a re-semear por cima. **A trava está
correta**: ela existe para não sobrescrever um workspace real com template em branco. O defeito
é o estado que o rename deixou, não a proteção.

**Decisão:** o **Kernel** assume a produção de metadata declarativa até o `schema` voltar. A §6.3
permite ao Helix atribuir trabalho cross-domain de forma explícita, e é o que está sendo feito.
Toda tarefa reatribuída diz no cabeçalho que é desvio, e o especialista confirma isso no relatório.

**Por quê:** o `kernel` sobe normalmente (verificado com ping de leitura), e o modelo de dados já
estava decidido e escrito por mim — o que faltava era digitar XML, não decidir arquitetura. Parar
a entrega para consertar um agente seria trocar dias de progresso por uma questão de ferramenta.

**O que NÃO muda:** o Probe continua sendo o único a commitar, empurrar e deployar (§65.1). O
portão não se mexe. Só quem produz o arquivo mudou.

**Quando reverter:** assim que o `schema` inicializar. O conserto provável é reiniciar o gateway,
o que faz a inicialização reavaliar o estado do workspace do zero. Registrado em `PENDENCIAS.md`
como P-15.

**Se estiver errado:** o risco é o Kernel produzir metadata com vícios de quem pensa em Apex —
por exemplo, resolver em código o que era para ser declarativo. Mitigação: as tarefas dele
especificam campo a campo, e eu confiro os pontos sensíveis antes do Probe.

---

## D-011 — Deal Desk enxerga todas as oportunidades

**Data:** 2026-08-19 · **Marco:** M1 (fatia 3) · **Status:** aplicada · **Corrige:** matriz de FLS da NS-M1-KERNEL-02

`Discount_Request__c` é master-detail de Opportunity, com `sharingModel = ControlledByParent`.
Ao deployar, a plataforma recusou:

```
A permissão Exibir todos os Discount_Request__c depende da(s) permissão(ões):
Exibir todos os Opportunity
```

Minha matriz original dava ao `NDG_Deal_Desk` apenas `Read` e `Edit` em Opportunity, sem
`ViewAllRecords`. O Kernel satisfez a dependência **concedendo `ViewAll` em Opportunity** ao Deal
Desk.

**Decisão: ratificar a concessão.**

**Por quê — e por que minha matriz estava errada, não a solução dele:** a §4.4 define o Deal Desk
como quem revisa exceções de preço de toda a operação, e a §17.4 exige um console com fila de
pedidos, cliente, oportunidade, valor, desconto pedido e margem. Com OWD privada e sem `ViewAll`,
o analista de Deal Desk enxergaria apenas as oportunidades das quais ele é dono — ou seja,
nenhuma. **O console nasceria vazio.** A dependência da plataforma não ampliou escopo: ela expôs
uma lacuna no meu desenho, onde eu tinha dado a permissão do pedido de desconto sem dar a do
registro que lhe dá sentido.

**O que a ratificação NÃO concede:** `ViewAll` é ler tudo, não `ModifyAll`. O Deal Desk continua
sem poder editar o negócio. A FLS da fatia 2 permanece: dos campos sensíveis, ele edita apenas
`Deal_Desk_Status__c`. Ele decide sobre o pedido; não reescreve a oportunidade. Preço, margem,
tier e desconto seguem fora do alcance dele para escrita.

**Quem tem `ViewAll` em Opportunity depois disto:** Deal Desk, Regional Director, RevOps,
Integration Admin, Executive ReadOnly e Admin Extended. **Rep e Sales Manager continuam sem** —
os dois enxergam pelo dono do registro e pela hierarquia, que é o comportamento correto para
quem vende.

**Se estiver errado:** o risco é vazamento lateral — um analista de Deal Desk lendo pipeline que
não precisaria ver. É um risco real e aceito conscientemente: a alternativa é um console de
aprovação que não mostra o que precisa aprovar. Se o modelo de sharing evoluir para regras por
critério (§30.3), esta concessão deve ser reavaliada e possivelmente substituída por uma sharing
rule que exponha só as oportunidades com pedido de desconto aberto.

---

## D-012 — Big Object `Integration_Log__b` (§1.5/§9.11), índice composto e o teto de 100 caracteres

**Data:** 2026-08-19 · **Marco:** M1 (fatia (d)) · **Status:** aplicada

Big Object é o mecanismo da §1.5 para observabilidade de integração de alto volume sem consumir
os 5 MB de `DataStorageMB` da org (`AMBIENTE.md` §3), que já estão no teto de storage de
registro comum. `Integration_Log__b` (17 campos) registra cada tentativa de chamada de
integração — nome da integração, operação, objeto e registro afetados, payloads de request e
response, status HTTP, resultado, contagem e status de retry, correlação com a tentativa
original.

**Decisão:** um único índice composto, `Integration_Log_Index`, na ordem
`Integration_Name__c` (ASC) → `Event_Date__c` (DESC) → `Correlation_Id__c` (ASC).

**Por quê esta ordem:** Big Object não tem índice secundário — só a chave primária declarada no
`<indexes>`, e toda consulta contra Big Object precisa filtrar pelo prefixo do índice para não
degradar para varredura completa. `Integration_Name__c` primeiro porque o caso de uso central do
M10 (Integration Monitor LWC) é "mostrar os eventos recentes de uma integração específica", não
"mostrar tudo". `Event_Date__c` em `DESC` como segundo campo ordena os eventos mais recentes
primeiro dentro de cada integração, sem exigir `ORDER BY` explícito em cada consulta.
`Correlation_Id__c` por último porque, como o índice de Big Object é a chave primária, ele
precisa terminar num campo que torne cada linha única — sem isso, duas tentativas com o mesmo
nome de integração e o mesmo instante (raro, mas possível em retry automático) se sobrescreveriam
silenciosamente.

**Limite de plataforma que só apareceu no deploy.** A soma do comprimento de todos os campos
Text de um índice de Big Object não pode passar de 100 caracteres, e esse teto se mostrou
**exclusivo na prática**, não inclusivo:

1. O desenho original tinha `Integration_Name__c` em 80 mais `Correlation_Id__c` em 36 = 116, e
   a validação foi recusada (Deploy ID `0Affj00000NlcCiCAJ`, nada chegou a ser criado na org).
2. `Integration_Name__c` caiu para 64: 64 + 36 = 100, o que parecia o teto exato. A validação foi
   recusada de novo, com a mesma mensagem (Deploy ID `0Affj00000NmAhNCAV`) — a soma exatamente
   igual a 100 não passa. O teto de plataforma é `< 100`, não `<= 100`.
3. `Integration_Name__c` caiu para 60: 60 + 36 = 96. Validação aceita (`0Affj00000NmAkbCAF`,
   111/111 componentes, 3/3 testes), deploy aplicado (`0Affj00000NliQBCAZ`).

Nem esta revisão nem o parecer do Pulse tinham esse limite: ele não aparece na documentação que
conseguimos alcançar e só se manifesta na validação. **`Integration_Name__c` fica em Text(60)** —
64 é seguro na teoria e não passa na prática desta org. Como o índice de Big Object é imutável,
o orçamento restante (96 de 100, com folga deliberada de 4 depois de duas recusas) não é
reaproveitável por um deploy futuro: aumentar qualquer um dos dois campos exige recriar o objeto.
Registrado em `docs/releases/R04/known-limitations.md`, item (e).

**Modelo de permissão — append-only, sem edição nem exclusão para ninguém:**
`NDG_Integration_Admin` e `NDG_Salesforce_Admin_Extended` têm `Create`+`Read`;
`NDG_RevOps` tem só `Read`. Nenhum dos três tem `Edit`, `Delete`, `ViewAllRecords` ou
`ModifyAllRecords` sobre `Integration_Log__b` — confirmado por SOQL contra `ObjectPermissions`
na org, não só no XML fonte.

**Por quê:** um log de auditoria de integração que pode ser editado ou apagado por quem quer que
o leia deixa de servir como evidência — a §1.5 pede rastreabilidade, e rastreabilidade exige
imutabilidade do lado de quem só consome. RevOps lê para monitorar volume e taxa de erro; não
precisa (e não deveria poder) alterar histórico. Só quem integra ou administra grava — e mesmo
esses só criam, nunca editam ou apagam um registro já gravado, o que é consistente com o próprio
Big Object: ele não tem operação de update nativa pela UI declarativa, então dar `Edit`/`Delete`
seria conceder uma permissão que a plataforma nem exerceria da forma esperada.

**Se estiver errado:** o índice imutável é o único risco real — se 60 caracteres se provarem
curtos demais para algum nome de integração futuro, a correção é recriar o objeto (perda do
histórico acumulado) ou introduzir um segundo campo de nome curto exclusivo para o índice. O
modelo de permissão é conservador por desenho; afrouxar depois é reversível, apertar depois de
já ter concedido `Edit` a alguém não é.

---

## D-013 — `manifest/package.xml` não é atualizado por esta fatia, por desenho da esteira

**Data:** 2026-08-19 · **Marco:** M1 (fatia (d)) · **Status:** aplicada, com pendência registrada

`manifest/package.xml` declara só `ApexClass: *`, versão 67.0 — nunca foi expandido para
declarar os objetos, campos, Custom Metadata ou permission sets das fatias 1, (a), (b) e (c).
`scripts/shell/validate.sh` e `scripts/shell/deploy.sh` (herdados do M0) usam
`sf project deploy validate/start --source-dir force-app`, nunca `-x manifest/package.xml`. O
Probe confirmou isso lendo os dois scripts nesta fatia: o manifesto não está no caminho real do
deploy desde o M0.

**Decisão:** não editar `manifest/package.xml` nesta fatia nem em nenhuma anterior. Registrar a
divergência entre o que o manifesto declara e o que o deploy de fato usa como
`docs/releases/R04/known-limitations.md`, item já presente desde R01/R02/R03 sob rótulos
diferentes, consolidado aqui.

**Por quê:** editar o manifesto para "ficar correto" sem ele nunca ser lido pelo deploy real
custaria trabalho de manutenção (17 campos, 1 índice, 1 objeto a mais a cada fatia) sem mudar
nenhum comportamento observável — é documentação que finge ser configuração. A alternativa mais
honesta é registrar que o manifesto está fora do caminho, não fingir que ele reflete o deploy.

**Se estiver errado:** se algum dia a esteira migrar de `--source-dir` para `-x
manifest/package.xml` (por exemplo, para deploy incremental por tipo de componente), o manifesto
precisa ser reconstruído do zero a partir do `force-app/` real, porque hoje ele não acompanha
nada além de `ApexClass`. Baixo custo agora, custo conhecido e adiado por decisão — não por
descuido.

---

## D-014 — Chave de idempotência do seed é `Seed_Key__c`, não a chave de negócio

**Data:** 2026-08-19 · **Marco:** M2 (fatia (a)) · **Status:** aplicada

O critério de aceite do M2 é "roda duas vezes sem duplicar". A opção óbvia seria reaproveitar uma
External Id já existente: `Account.ERP_Customer_Id__c` (External Id, unique) ou
`Opportunity.External_Order_Id__c` (External Id, mas `unique=false` de propósito, porque é chave
de integração, não de seed).

**Decisão:** o seed usa um campo técnico dedicado em vez disso — `Seed_Key__c` (Text 40, External
Id, Unique, case-sensitive), criado em `Account`, `Contact`, `Lead`, `Product2`, `Pricebook2`,
`Opportunity`, `OpportunityLineItem`, `Quote`, `QuoteLineItem`, `Order` e `OrderItem`. Todo
registro de seed carrega o prefixo `NS-` no valor.

**Por quê:** chave de integração e chave de seed têm ciclos de vida diferentes; misturar as duas
faria o script de limpeza do M2 apagar dado que um dia virá do ERP.

**Consequência:** `PricebookEntry` não aceita campo custom e fica de fora desta lista — a
idempotência dele é por chave natural (`Pricebook2Id` + `Product2Id`) no script Apex do Kernel.

**Se estiver errado:** o campo é aditivo e não conflita com nenhuma External Id existente;
ajustar `Seed_Key__c` depois é reversível enquanto não houver dado real gravado nele.

---

## D-015 — O seed é Apex anônimo com `upsert`, não `sf data import tree`

**Data:** 2026-08-19 · **Marco:** M2 (fatia (a)) · **Status:** registrada, execução do Kernel

**Decisão:** o script de seed do M2 é Apex anônimo usando `upsert` contra `Seed_Key__c` (e contra
chave natural para `PricebookEntry`), não `sf data import tree`.

**Por quê:** `sf data import tree` só faz `insert` — rodar duas vezes duplica, o que reprova o
critério de aceite do M2 direto. Bulk CSV com upsert resolveria os objetos com External Id, mas
não resolve os filhos sem campo custom, que precisam de consulta por chave natural antes de
inserir. Apex anônimo é o único mecanismo que cobre os dois casos no mesmo script. O volume da
§33 (~1.620 registros) cabe folgado nos limites de uma transação (10.000 linhas de DML, 50.000
linhas de SOQL).

**Se estiver errado:** trocar o mecanismo de carga é reescrever o script, não o modelo de dados —
`Seed_Key__c` continua válido independentemente de como a carga é feita.

---

## D-016 — Os 139 registros de sample data da Developer Edition ficam onde estão

**Data:** 2026-08-19 · **Marco:** M2 (fatia (a)) · **Status:** registrada, execução do Kernel/Probe

A org já tinha 139 registros de exemplo (`Account`, `Contact`, `Lead`, `Product2`,
`PricebookEntry`, `Opportunity`) antes do projeto.

**Decisão:** o seed não toca nesses registros. O script de limpeza apaga **somente** registros
com `Seed_Key__c` começando em `NS-`.

**Por quê:** limpeza que apaga por objeto inteiro é destrutiva e irreversível numa org
compartilhada; limpeza por marca (`NS-`) é reversível e auditável.

**Consequência:** o orçamento de registros sobe para 1.759 (1.620 do seed + 139 de amostra),
dentro dos ~2.380 da §1.5 — custo aceito.

**Se estiver errado:** apagar os 139 manualmente depois é uma operação pontual e não depende de
nenhuma decisão de schema.

---

## D-017 — O portão de storage do M2 é 50%, e 70% continua sendo parada obrigatória

**Data:** 2026-08-19 · **Marco:** M2 (fatia (a)) · **Status:** registrada

A §33.2 manda parar e reportar acima de 70% de storage. O critério de aceite do M2 na §55 exige
storage abaixo de 50%.

**Decisão:** não é contradição, são dois portões com finalidades diferentes. 50% é o portão para
o marco M2 fechar; 70% é a parada de emergência de qualquer carga, em qualquer marco. Vale o mais
restritivo dos dois no contexto de cada um.

**Se estiver errado:** ajustar qualquer um dos dois números é edição de processo, não de schema.

---

## D-018 — O agente `schema` volta a ser o dono da metadata declarativa; D-010 encerrada

**Data:** 2026-08-19 · **Marco:** M2 (fatia (a)) · **Status:** aplicada

D-010 desviou a metadata declarativa para o Kernel porque o `schema` não inicializava (P-15).

**Decisão:** em 2026-08-19 o `schema` foi testado pelo Helix e respondeu: lê e escreve em
`/home/shieldadmin/.openclaw/workspace-helix`, tem `sf` CLI 2.147.7 e enxerga a org `helix-dev`
conectada. O desvio está encerrado, e esta fatia — os campos `Seed_Key__c` e a FLS
correspondente — é a primeira metadata produzida por ele desde então.

**Por quê:** a causa raiz registrada em D-010 (estado inconsistente deixado por um rename mal
sucedido) some quando o gateway reinicializa e reavalia o workspace do zero — exatamente o
"conserto provável" que D-010 já previa.

**O que muda:** o `schema` volta a produzir toda metadata declarativa; o Kernel deixa de ser
responsável por isso. O Probe continua sendo o único a commitar, empurrar e deployar (§65.1) —
isso nunca mudou.

**Se estiver errado:** se o `schema` voltar a falhar, o desvio para o Kernel pode ser reaberto
como uma nova decisão. D-010 fica no histórico como registrada — decisão revogada não se apaga.

---

## D-019 — Onde a plataforma não aceita `upsert`, o seed casa por consulta e separa insert de update

**Data:** 2026-08-20 · **Marco:** M2 (fatia (b)) · **Status:** aplicada

D-015 definiu que o seed é Apex anônimo com `upsert` contra `Seed_Key__c`. Na implementação,
seis objetos recusam o mecanismo: `Opportunity`, `Quote`, `Order`, `OpportunityLineItem`,
`QuoteLineItem` e `OrderItem`. Neles, `Pricebook2Id`, `OpportunityId`, `QuoteId`, `OrderId`,
`PricebookEntryId` e `Product2Id` são `createable` mas **não** `updateable` — confirmado por
`sf sobject describe`, não suposto. Um `upsert` reenvia esses campos na segunda execução, o
registro já existe, a operação vira update e a plataforma recusa.

**Decisão:** manter `upsert ... Seed_Key__c` onde a plataforma aceita (`Account`, `Contact`,
`Lead`, `Product2`, `Pricebook2`) e, nos seis objetos acima, consultar as chaves existentes por
`Seed_Key__c` e separar a carga em dois DML: `insert` com o payload completo para o que é novo,
`update` só com os campos mutáveis para o que já existe.

**Por quê:** o critério de aceite do M2 é comportamental — "roda duas vezes sem duplicar" —, não
uma exigência de qual verbo de DML usar. O contrato de D-015 (a chave de casamento é
`Seed_Key__c`) continua intacto; o que muda é o mecanismo, e só onde a plataforma não deixa
escolha. Alternativas foram descartadas: `Database.upsert(..., allOrNone=false)` engoliria as
falhas em silêncio, e recriar as linhas a cada execução trocaria os Ids toda vez, o que quebra
qualquer referência externa à massa.

**Se estiver errado:** é reversível dentro do script, sem tocar em schema. `Seed_Key__c` continua
sendo a chave independentemente do verbo de DML.

---

## D-020 — O volume do seed é 1.051 registros, não os ~1.620 da §33

**Data:** 2026-08-20 · **Marco:** M2 (fatia (b)) · **Status:** aplicada, precisa de ratificação do Helix

A §33 fixa uma tabela de ~1.620 registros e diz que o orçamento é obrigatório. A §55 exige, para
o M2 fechar, **storage abaixo de 50%**. Os dois números não cabem na mesma org: 1.620 do seed +
139 de amostra da Developer Edition (D-016) dão 1.759 registros × 2 KB ≈ 3.518 KB, ou **68,7%**
de 5 MB. Cumprir a §33 à risca reprova o critério de aceite do próprio marco.

**Decisão:** carregar 1.051 registros, mantendo as proporções e a cobertura de negócio da tabela
da §33 (todos os 12 objetos, os 4 segmentos, as 4 famílias de produto, os 10 estágios do funil).
Resultado medido: 1.190 registros no total, ~2.380 KB, **46,5%** — abaixo do portão de 50%.

**Por quê:** D-017 já tinha estabelecido que 50% é o portão de fechamento do M2 e 70% é a parada
de emergência de qualquer carga. Entre um número de tabela e um critério de aceite, vale o
critério de aceite. Reduzir preservando proporção mantém o que a massa existe para demonstrar —
busca, filtro e preço nos marcos seguintes — enquanto cortar objetos inteiros não manteria.

**O que isto deixa de folga:** ~1.190 registros até o teto de ~2.380 da §1.5, que é a margem de
que `RunLocalTests` precisa para criar e apagar dado a cada deploy.

**Como mudar:** as constantes `N_*` no topo de cada etapa em `scripts/apex/`. Refaça a conta de
storage antes de subir qualquer número.

**Se estiver errado:** se o Helix decidir que a §33 vence a §55, é editar as constantes e rodar
de novo — nenhuma mudança de schema. Mas então o M2 fecha em ~68,7% e o critério "storage abaixo
de 50%" precisa ser explicitamente revogado, não ignorado.

---

## D-021 — O seed exige FLS de leitura em `Seed_Key__c`; a fatia (a) não a entregou

**Data:** 2026-08-20 · **Marco:** M2 (fatia (b)) · **Status:** contorno encerrado em 2026-08-20 pela fatia (c) — ver nota final

A fatia (a) criou `Seed_Key__c` nos 11 objetos e concedeu FLS **somente nos 8 permission sets
`NDG_*`**, com `readable=true, editable=false`. Nenhum *perfil* recebeu o campo — nem o de
administrador do sistema, que é quem roda o seed. Consequência medida: `sf data query`,
`sf sobject describe` e o Apex anônimo relatam todos `No such column 'Seed_Key__c' on entity
'Account'`, e o script **nem compila**. O campo existe na org o tempo todo; a Tooling API
(`FieldDefinition`) mostra os 11. É a FLS do usuário que o esconde.

Isto é fácil de ler errado como "o deploy da fatia (a) não chegou na org". Não é: chegou.

**Decisão:** destravar atribuindo o permission set `NDG_Salesforce_Admin_Extended` ao usuário que
roda o seed. É reversível (apagar o `PermissionSetAssignment`), não é deploy e não altera
metadata versionada.

**Por quê:** era o menor movimento capaz de destravar a fatia (b) sem invadir escopo alheio. FLS
em perfil é metadata declarativa, portanto do `schema` (D-018), e quem deploya é o Probe (§65.1).
Produzir essa metadata aqui seria reabrir o desvio que D-018 acabou de encerrar.

**Nota sobre `editable=false`:** DML em Apex roda em modo de sistema e ignora FLS de escrita, então
o seed grava normalmente. O que a FLS bloqueia é a *visibilidade* — e visibilidade é o que a
compilação do Apex anônimo exige. Ou seja: `readable` é o suficiente, e `editable=false` continua
sendo a escolha certa para um campo técnico.

**Pendência que isto cria:** enquanto a FLS não estiver no perfil, qualquer verificação do seed
por CLI ou por Setup depende de o usuário ter um permission set `NDG_*` atribuído. Registrado em
`docs/PENDENCIAS.md`.

**Se estiver errado:** se o Helix preferir que nenhum perfil enxergue o campo, a atribuição de
permission set vira parte documentada do procedimento de seed em vez de um contorno temporário —
e este registro passa de "pendente" a "definitiva".

**Encerramento (2026-08-20, fatia (c) do M2):** foi este o ramo escolhido. Nenhum perfil recebeu o
campo; a atribuição de `NDG_Salesforce_Admin_Extended` a quem roda o seed é agora procedimento
declarado, não contorno. Uma correção ao diagnóstico acima: as entradas de FLS não faltavam — a
fatia (a) concedeu as 11 nos 8 permission sets, todas com `readable=true`. O que faltava era
`editable=true` para quem opera a massa, agora concedido só em `NDG_Salesforce_Admin_Extended`.
A nota "`editable=false` continua sendo a escolha certa" vale para os 7 permission sets de
persona e segue em vigor neles; ela não vale para o permission set que opera o seed, porque
qualquer manutenção da massa por CLI ou Data Loader — diferente do Apex anônimo, que roda em modo
de sistema — passa pela FLS de escrita. P-17 fica corrigida na metadata versionada; falta o
deploy, do Probe (§65.1).

---

## D-022 — Volume definitivo do seed data: 1.051 registros (ratifica D-020)

**Data:** 2026-08-20 · **Marco:** M2 · **Status:** aplicada — decisão do Helix

A §33 previa cerca de 1.620 registros. A §55 define como critério de aceite do M2 "storage abaixo
de 50%". Os dois números não coexistem nesta org: Developer Edition, 5 MB, teto prático de
aproximadamente 2.500 registros. 1.051 registros ocupam 46,5%; 1.620 estouram o teto.

**Decisão:** entre o número da §33 e o critério de aceite da §55, prevalece o critério de aceite:
é ele que valida o marco. O número da §33 é dimensionamento, não contrato.

**Razão adicional, e mais importante:** o seed não é o fim. Os marcos M3 a M13 vão criar Leads,
Opportunities, Quotes, Orders e registros em `Integration_Log__b` em cima dessa massa. Um seed que
consome o orçamento inteiro de storage trava todos os marcos seguintes. Os 53,5% restantes são
orçamento de execução, não folga.

**Efeito:** 1.051 é o volume oficial do seed. A meta de aproximadamente 1.620 da §33 fica
registrada como superada para esta org. D-020 fica ratificada.

**Se estiver errado:** se a org ganhar storage no futuro, a decisão é revisitada.
