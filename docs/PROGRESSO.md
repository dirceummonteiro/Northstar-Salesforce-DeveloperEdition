# PROGRESSO — Northstar Revenue Cloud Prototype

## Métrica única

A seção 55.1 do escopo define **uma régua só**, e ela nunca muda:

```
marcos concluídos e validados
─────────────────────────────
             13
```

**Progresso: 1 / 13**

Este número só sobe. Progresso *dentro* de um marco não é progresso do projeto e não entra
nesta conta. Quando este documento falar de um marco específico, ele diz explicitamente que é
sobre aquele marco.

---

## Escada de marcos

| # | Entregável | Validação | Status |
|---|---|---|---|
| **M0** | Estrutura sfdx, git na `main`, `.gitignore`, docs iniciais, deploy vazio validado | `sf project deploy validate` passa | ✅ concluído |
| **M1** | Modelo de dados: objetos, campos, relacionamentos, permission sets | metadata no repositório e na org | ⬜ |
| **M2** | Seed data repetível dentro do orçamento da §33 | roda duas vezes sem duplicar; storage abaixo de 50% | ⬜ |
| **M3** | Lead: captura, scoring, roteamento, conversão | um lead vira Account, Contact e Opportunity | ⬜ |
| **M4** | Pipeline de Opportunity com produtos e price book | uma oportunidade completa pode ser montada | ⬜ |
| **M5** | Motor de precificação em Custom Metadata | mudar regra de preço não exige mudar Apex | ⬜ |
| **M6** | Controles de desconto e margem | desconto acima do limite é bloqueado com mensagem clara | ⬜ |
| **M7** | Aprovações do Deal Desk | fluxo completo de pedido, aprovação e rejeição | ⬜ |
| **M8** | Quote e Order | uma oportunidade fechada gera um pedido | ⬜ |
| **M9** | Simulação de ERP, estoque e crédito com mocks | sucesso, falha e retry todos testados | ⬜ |
| **M10** | Observabilidade em Big Object + Integration Monitor LWC | um erro de integração é visível e reprocessável | ⬜ |
| **M11** | Relatórios e dashboards | três visões: rep, gerente, executivo | ⬜ |
| **M12** | Endurecimento de testes e pacote de evidências | cobertura acima de 85%, evidência conforme §68 | ⬜ |
| **M13** | Demonstração do CR-DEMO-001 (§69.2) | mudança de política ponta a ponta com todo agente participando | ⬜ |

Regra da §55: **entregar até o M8 impecável vale mais do que entregar os treze pela metade.**

---

## Registro de fechamento de marcos

Cada marco fechado ganha uma entrada aqui, com data, commit e evidência.

### M0 — Fundação ✅

**Aberto em:** 2026-08-18

Escopo do marco:

- [x] Estrutura de pastas da §7.1 criada
- [x] `docs/MASTER_SCOPE.md` salvo no repositório
- [x] `docs/AMBIENTE.md` com limites, licenças e edição medidos na org real
- [x] `docs/DECISIONS.md` aberto (D-001 a D-008)
- [x] `docs/PENDENCIAS.md` aberto
- [x] `docs/PROGRESSO.md` aberto
- [x] ADR-001 — estratégia de controle de fonte e ambiente
- [x] `.gitignore` auditado contra a seção de segurança do `AGENTS.md` — histórico limpo, nenhum
      arquivo sensível rastreado em nenhum commit anterior
- [x] `sourceApiVersion` alinhada à org: 62.0 → 67.0 (D-003 confirmada, não quebrou nada)
- [x] `README.md` reescrito como entregável de vitrine
- [x] Scripts `validate.sh`, `deploy.sh` e `test.sh` em `scripts/shell/`
- [x] `manifest/package.xml` inicial na versão 67.0
- [x] **`sf project deploy validate --test-level RunLocalTests` passa** — 3/3 testes, 100%,
      Deploy ID `0Affj00000NdJfCCAV`
- [x] Branch local renomeada para `main`
- [x] Commit e push na `main`
- [x] Deploy aplicado na org
- [x] Pacote de evidências `docs/releases/R00/`

**Fechamento:** 2026-08-18 · commit `d115424` · evidência em `docs/releases/R00/`
