# R00 — Manifest

## Fonte

`sf project deploy validate --source-dir force-app --test-level RunLocalTests --target-org helix-dev`
usa o diretório `force-app` como fonte; o `manifest/package.xml` versionado no repositório
descreve o pacote completo do projeto (não é o manifesto usado nesta chamada específica, que foi
gerada automaticamente pelo CLI a partir de `force-app`).

### `manifest/package.xml` (versionado)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<Package xmlns="http://soap.sforce.com/2006/04/metadata">
    <types>
        <members>*</members>
        <name>ApexClass</name>
    </types>
    <version>67.0</version>
</Package>
```

## Componentes validados e implantados

| Estado | Nome | Tipo | Caminho |
|---|---|---|---|
| Unchanged | HttpCalloutService | ApexClass | `force-app/main/default/classes/HttpCalloutService.cls` |
| Unchanged | HttpCalloutService | ApexClass | `force-app/main/default/classes/HttpCalloutService.cls-meta.xml` |
| Unchanged | HttpCalloutServiceTest | ApexClass | `force-app/main/default/classes/HttpCalloutServiceTest.cls` |
| Unchanged | HttpCalloutServiceTest | ApexClass | `force-app/main/default/classes/HttpCalloutServiceTest.cls-meta.xml` |

`numberComponentsTotal: 2` (2 classes Apex, cada uma com o par `.cls` + `.cls-meta.xml`,
totalizando `numberFiles: 6` incluindo o manifesto). `numberComponentErrors: 0` em ambas as
etapas (validate e start).

## sourceApiVersion

`sfdx-project.json`: `62.0` → `67.0` (D-003), alinhada à versão da org (`Api Version: 67.0`
confirmada via `sf org display --target-org helix-dev`).
