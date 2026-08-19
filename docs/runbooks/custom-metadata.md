# Runbook — Custom Metadata (registros `.md-meta.xml`)

Origem: `docs/releases/R03/known-limitations.md`, item (f-1). Escrito para custar um minuto de
leitura em vez de uma hora de bisseção da próxima vez.

## O cabeçalho correto

Todo registro de Custom Metadata (`force-app/.../customMetadata/*.md-meta.xml`) precisa dos três
namespaces, mesmo que o registro não use `xsi:type="xsd:boolean"` em nenhum campo — porque o
próximo commit pode adicionar um:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata"
                 xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                 xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
```

`xmlns:xsi` sozinho parece suficiente — é o que qualifica `xsi:type` e `xsi:nil` — mas **quando
algum `<value>` usa `xsi:type="xsd:boolean"` (ou qualquer outro `xsd:*`), o parser da API também
exige `xmlns:xsd` declarado**, mesmo esse namespace nunca aparecendo sozinho fora de um valor de
atributo.

## O sintoma

- A API 67.0 rejeita **o pacote inteiro** na fase de parse, antes de validar qualquer componente.
- O erro é opaco: não aponta arquivo, linha ou campo.
- `numberComponentErrors` fica em `0` — não é um erro de componente, é o pacote inteiro que não
  chegou a ser parseado. Ler só esse contador engana: parece que nada deu errado.
- Nenhum dos componentes do pacote é deployado, mesmo os que não têm relação com Custom Metadata.

## Como bissetar

1. Isole o `--source-dir` para só `customMetadata` (e o objeto `.mdt` correspondente) e rode
   `sf project deploy validate` de novo. Se falhar isolado, o problema está ali, não em outro
   componente do pacote.
2. `grep -L 'xmlns:xsd' force-app/main/default/customMetadata/*.md-meta.xml` — lista os arquivos
   sem o namespace. Qualquer um que tenha `xsi:type="xsd:` em algum `<value>` é suspeito.
3. Corrija o cabeçalho (bloco acima) e revalide só o arquivo corrigido antes de reaplicar ao
   pacote inteiro.

## Por que isso não aparece numa revisão estática do XML

O XML é bem formado e o schema de `CustomMetadata` não obriga `xmlns:xsd` a olho nu — o erro só
se manifesta no parser da API de metadata durante validate/deploy, não em um linter de XML local.
