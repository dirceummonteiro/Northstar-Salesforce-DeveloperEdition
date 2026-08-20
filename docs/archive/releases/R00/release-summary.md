# R00 — Release Summary (M0: Fundação)

## Identificação

| Campo | Valor |
|---|---|
| Marco | M0 — Estrutura sfdx, git na `main`, `.gitignore`, docs iniciais, deploy vazio validado |
| Commit (fundação) | `d115424c53f965401064def352f9851965497bb1` (`d115424`) |
| Commit (base anterior) | `857694e` — Adiciona classe modelo de callout HTTP com teste de 100% de cobertura |
| Branch | `main` |
| Remoto | `origin` (`github-helix:dirceummonteiro/Northstar-Salesforce-DeveloperEdition.git`) |
| Org alvo | alias `helix-dev` (Developer Edition, não-produção) |
| Data | 2026-08-18 |
| Owner do release | Probe |

## O que este release entrega

Fundação do projeto Northstar: estrutura de pastas da §7.1, documentação de estado
(`MASTER_SCOPE.md`, `AMBIENTE.md`, `DECISIONS.md`, `PROGRESSO.md`, `PENDENCIAS.md`, ADR-001),
scripts de `sf` CLI parametrizados por org, manifesto inicial e `sourceApiVersion` alinhada à
org (62.0 → 67.0). Nenhum objeto, campo, classe Apex ou LWC novo foi criado neste marco — a
única metadata existente (`HttpCalloutService` / `HttpCalloutServiceTest`) já estava no
repositório antes deste escopo (D-006) e serviu para provar que a esteira de validação/deploy
funciona de ponta a ponta.

## Comandos executados

```
git push -u origin main
./scripts/shell/deploy.sh
sf apex run test --target-org helix-dev --result-format human --code-coverage --wait 20
```

`deploy.sh` executa, nesta ordem:

```
sf project deploy validate --source-dir force-app --test-level RunLocalTests --target-org helix-dev
sf project deploy start --source-dir force-app --target-org helix-dev
```

## Resultado

- Validação: **Succeeded** (Deploy ID `0Affj00000NeZZiCAN`), 3/3 testes, 100% cobertura.
- Deploy real: **Succeeded** (Deploy ID `0Affj00000NeaHFCAZ`), quick-deploy sobre a validação
  anterior (mesmo hash, dentro da janela de reaproveitamento do Salesforce — por isso a etapa de
  deploy real mostra testes "Skipped": eles já rodaram na validação imediatamente anterior).
- Smoke test pós-deploy: **Passed**, 3/3, 100% cobertura, Test Run Id `707fj00000u0Wb1`.
- Consulta de conectividade: `SELECT Id, Name FROM Organization` retornou 1 registro.

Detalhes completos em `manifest.md`, `test-results.md`, `coverage-summary.md`,
`deployment-result.md`, `smoke-test.md`.

## Impacto em dados/limites

`DataStorageMB`: 0 MB em uso antes e depois (0%) — esperado, M0 não cria dados.
`DailyApiRequests`: 239 → 265 em uso (de 15.000) — variação de 26 chamadas, consumidas pela
validação, pelo deploy, pelos testes e pelas consultas de verificação desta integração. Bem
abaixo do limiar de 70% definido em `AMBIENTE.md` §2. Detalhe em `deployment-result.md`.

## Segurança

Nenhuma mudança neste release toca permission set, profile, sharing rule, `without sharing`,
Named Credential ou exposição de dado. Não há ESCALONAMENTO DE SEGURANÇA a reportar.

## Limitações conhecidas

Ver `known-limitations.md`.

## Go/no-go do Helix

**Go/no-go do Helix: GO — M0 aceito**
