/**
 * SEED M2 — RELATORIO DE CONTAGEM (somente leitura)
 *
 * Conta os registros marcados como seed, objeto por objeto, e estima o consumo
 * de storage. Nao grava nada. E a evidencia usada para provar a idempotencia:
 * roda-se o seed, roda-se este relatorio, roda-se o seed de novo, roda-se este
 * relatorio outra vez — as contagens tem de ser identicas.
 *
 * PricebookEntry nao tem Seed_Key__c (D-014), entao ele e contado pela marca do
 * produto pai.
 *
 *     sf apex run --target-org helix-dev --file scripts/apex/seed_99_report.apex
 */

Integer cProduct = [SELECT COUNT() FROM Product2            WHERE Seed_Key__c LIKE 'NS-%'];
Integer cPb2     = [SELECT COUNT() FROM Pricebook2          WHERE Seed_Key__c LIKE 'NS-%'];
Integer cPbe     = [SELECT COUNT() FROM PricebookEntry      WHERE Product2.Seed_Key__c LIKE 'NS-%'];
Integer cAccount = [SELECT COUNT() FROM Account             WHERE Seed_Key__c LIKE 'NS-%'];
Integer cContact = [SELECT COUNT() FROM Contact             WHERE Seed_Key__c LIKE 'NS-%'];
Integer cLead    = [SELECT COUNT() FROM Lead                WHERE Seed_Key__c LIKE 'NS-%'];
Integer cOpp     = [SELECT COUNT() FROM Opportunity         WHERE Seed_Key__c LIKE 'NS-%'];
Integer cOli     = [SELECT COUNT() FROM OpportunityLineItem WHERE Seed_Key__c LIKE 'NS-%'];
Integer cQuote   = [SELECT COUNT() FROM Quote               WHERE Seed_Key__c LIKE 'NS-%'];
Integer cQli     = [SELECT COUNT() FROM QuoteLineItem       WHERE Seed_Key__c LIKE 'NS-%'];
Integer cOrder   = [SELECT COUNT() FROM Order               WHERE Seed_Key__c LIKE 'NS-%'];
Integer cOi      = [SELECT COUNT() FROM OrderItem           WHERE Seed_Key__c LIKE 'NS-%'];

Integer seedTotal = cProduct + cPb2 + cPbe + cAccount + cContact + cLead
                  + cOpp + cOli + cQuote + cQli + cOrder + cOi;

System.debug(LoggingLevel.ERROR, 'Account             = ' + cAccount);
System.debug(LoggingLevel.ERROR, 'Contact             = ' + cContact);
System.debug(LoggingLevel.ERROR, 'Lead                = ' + cLead);
System.debug(LoggingLevel.ERROR, 'Product2            = ' + cProduct);
System.debug(LoggingLevel.ERROR, 'Pricebook2          = ' + cPb2);
System.debug(LoggingLevel.ERROR, 'PricebookEntry      = ' + cPbe);
System.debug(LoggingLevel.ERROR, 'Opportunity         = ' + cOpp);
System.debug(LoggingLevel.ERROR, 'OpportunityLineItem = ' + cOli);
System.debug(LoggingLevel.ERROR, 'Quote               = ' + cQuote);
System.debug(LoggingLevel.ERROR, 'QuoteLineItem       = ' + cQli);
System.debug(LoggingLevel.ERROR, 'Order               = ' + cOrder);
System.debug(LoggingLevel.ERROR, 'OrderItem           = ' + cOi);
System.debug(LoggingLevel.ERROR, 'TOTAL_SEED          = ' + seedTotal);

// Registros que NAO sao do seed: os 139 de amostra que ja vinham na Developer
// Edition (D-016). Entram na conta de storage, mas o seed nao os toca.
Integer preExisting =
      [SELECT COUNT() FROM Account        WHERE Seed_Key__c = null]
    + [SELECT COUNT() FROM Contact        WHERE Seed_Key__c = null]
    + [SELECT COUNT() FROM Lead           WHERE Seed_Key__c = null]
    + [SELECT COUNT() FROM Product2       WHERE Seed_Key__c = null]
    + [SELECT COUNT() FROM Opportunity    WHERE Seed_Key__c = null]
    + [SELECT COUNT() FROM Pricebook2     WHERE Seed_Key__c = null]
    + [SELECT COUNT() FROM PricebookEntry WHERE Product2.Seed_Key__c = null];
System.debug(LoggingLevel.ERROR, 'PRE_EXISTENTES      = ' + preExisting);

// A API de limites so devolve MB inteiro — grosso demais para o portao de 50%
// do M2. A conta por registro (~2 KB, valor da secao 1.5) e a medida
// reportavel; o numero da API fica ao lado para conferencia.
Integer allRecords = seedTotal + preExisting;
Decimal estKb  = allRecords * 2;
Decimal estPct = (estKb / (5 * 1024) * 100).setScale(1);
System.debug(LoggingLevel.ERROR, 'REGISTROS_TOTAIS    = ' + allRecords);
System.debug(LoggingLevel.ERROR, 'STORAGE_ESTIMADO    = ~' + estKb + ' KB de 5120 KB (~' + estPct + '%)');
System.OrgLimit st = OrgLimits.getMap().get('DataStorageMB');
System.debug(LoggingLevel.ERROR, 'STORAGE_API         = ' + st.getValue() + ' MB de ' + st.getLimit() + ' MB');
