# R00 — Known Limitations

## Deste release (M0)

- M0 é fundação: nenhum objeto, campo, permission set, classe Apex de negócio ou LWC foi criado.
  A única metadata deployada é a classe de exemplo `HttpCalloutService`/`HttpCalloutServiceTest`,
  que já existia no repositório antes deste escopo (D-006 em `DECISIONS.md`) e será removida ou
  absorvida no M9, quando o Bridge entregar a camada real de integração.
- O deploy real (etapa 2) rodou como *quick deploy* e não reexecutou os testes — eles rodaram e
  passaram minutos antes, na validação (etapa 1), sobre o mesmo conteúdo. Detalhe em
  `deployment-result.md`.

## Pendências operacionais já registradas em `docs/PENDENCIAS.md`, relevantes para este release

- **P-10** — a branch padrão do GitHub continua sendo `master`; `main` é a branch de trabalho e
  recebe todos os commits deste release, mas quem clona o repositório sem selecionar `main` cai
  em `master`, que ficou parado no commit anterior a este M0. Ação de um clique do dono
  (Dirceu), fora do alcance de qualquer agente porque a chave SSH usada só autentica `git`, não a
  API REST do GitHub.
- **P-11** — remover a branch `master` do remoto só pode acontecer depois do P-10, e é tarefa do
  Probe quando chegar a vez.
- **P-12** — `HttpCalloutService`/`HttpCalloutServiceTest` saem ou são absorvidos no M9.
- **P-13** — falta o runbook de reautenticação PKCE manual do Salesforce, antes do M12.
- **P-14** — licença do projeto ainda não definida (`README.md` está com "TBD").

Nenhuma dessas pendências bloqueia a aceitação do M0.
