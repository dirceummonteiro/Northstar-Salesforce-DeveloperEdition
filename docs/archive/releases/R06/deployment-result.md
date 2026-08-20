# R06 — Deployment Result (consolidado do M1)

Nenhum deploy nesta rodada. Tabela consolidando todos os Deploy IDs aplicados durante o M1,
lidos de `docs/releases/R0{1..5}/deployment-result.md` e `release-summary.md`.

| Fatia | Etapa | Deploy ID | Resultado | Componentes | Testes |
|---|---|---|---|---|---|
| 1 | Validação (Kernel) | `0Affj00000NeKUECA3` | Succeeded | 27/27 | 3/3 |
| 1 | Quick deploy | `0Affj00000Negp1CAB` | Succeeded | 27/27 | reaproveitados |
| (a) | Validação | `0Affj00000NhxUDCAZ` | Succeeded | 8/8 | 3/3 |
| (a) | Quick deploy | `0Affj00000NhwRiCAJ` | Succeeded | 8/8 | reaproveitados |
| (b)+(c) | Validação | `0Affj00000NipBFCAZ` | Succeeded | 65/65 | 3/3 |
| (b)+(c) | Deploy completo (`RunLocalTests` próprio) | `0Affj00000NipPlCAJ` | Succeeded | 65/65 | 3/3 |
| (d) | Validação — tentativa 1 | `0Affj00000NlcCiCAJ` | **Recusado** — índice de Big Object > 100 caracteres | — | — |
| (d) | Validação — tentativa 2 | `0Affj00000NmAhNCAV` | **Recusado** — mesma regra, soma exata de 100 (prova teto exclusivo) | — | — |
| (d) | Validação — tentativa 3 (aceita) | `0Affj00000NmAkbCAF` | Succeeded | 111/111 | 3/3 |
| (d) | Quick deploy | `0Affj00000NliQBCAZ` | Succeeded | 111/111 | reaproveitados |
| Reconciliação (a)-(d) | Validação | `0Affj00000NmN9yCAF` | Succeeded | 111/111 | 3/3 |
| Reconciliação (a)-(d) | Deploy completo (`RunLocalTests` próprio) | `0Affj00000NmNjRCAV` | Succeeded | 111/111 | 3/3 |

**0 erros de componente em todo o M1.** As duas únicas recusas (fatia (d), tentativas 1 e 2)
foram por limite de plataforma no índice do Big Object, não por erro de conteúdo — nenhuma
delas escreveu na org (`sf project deploy validate` não escreve). Detalhe completo do limite em
D-012, `docs/DECISIONS.md`.

O deploy mais recente sobre o conteúdo final do M1 é o da reconciliação, `0Affj00000NmNjRCAV`
(111/111 componentes, 0 erros, 3/3 testes, 0 falhas), aplicado no commit `5d7d4ec`, que é o
commit em `origin/main` no momento deste fechamento.
