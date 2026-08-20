/**
 * SEED M2 — ETAPA 3 DE 3: PIPELINE
 *
 * Cria Opportunity (100), OpportunityLineItem (180), Quote (30),
 * QuoteLineItem (50), Order (30) e OrderItem (50).
 *
 * Nenhum destes usa `upsert ... Seed_Key__c` direto, e o motivo e da
 * plataforma, nao de gosto: Pricebook2Id, OpportunityId, QuoteId, OrderId,
 * PricebookEntryId e Product2Id sao `createable` mas nao `updateable`. Um
 * upsert reenviaria esses campos na segunda execucao e a plataforma recusaria a
 * atualizacao. O script entao consulta as chaves ja existentes por Seed_Key__c
 * e separa a carga em dois DML: insert com o payload completo para o que e
 * novo, update so com os campos mutaveis para o que ja existe. O contrato
 * continua sendo casar por Seed_Key__c. Ver D-019.
 *
 * Depende das etapas 1 e 2: le contas e entradas de tabela de preco pela marca
 * NS-. Roda depois delas, sempre.
 *
 * Bulk-safe: nenhum SOQL e nenhum DML dentro de laco.
 * Ver scripts/apex/README.md.
 */

public class NsPipe {
    public String pad(Integer i, Integer w) {
        String s = String.valueOf(i);
        while (s.length() < w) { s = '0' + s; }
        return s;
    }
    public String pick(List<String> v, Integer i) { return v[Math.mod(i, v.size())]; }
    public Integer spread(Integer i, Integer mult, Integer mod) {
        return Math.mod((Long) i * (Long) mult + 7L, (Long) mod).intValue();
    }
}
final NsPipe NS = new NsPipe();

final Integer N_OPP   = 100;
final Integer N_OLI   = 180;
final Integer N_QUOTE = 30;
final Integer N_QLI   = 50;
final Integer N_ORDER = 30;
final Integer N_OI    = 50;
final String  PFX     = 'NS-';
final Date    TODAY   = Date.today();

System.OrgLimit st = OrgLimits.getMap().get('DataStorageMB');
Decimal usedPct = st.getLimit() == 0 ? 0
    : (Decimal.valueOf(st.getValue()) / Decimal.valueOf(st.getLimit()) * 100).setScale(1);
System.debug(LoggingLevel.ERROR, 'STORAGE_ANTES ' + st.getValue() + '/' + st.getLimit()
    + ' MB (' + usedPct + '%)');
if (usedPct >= 70) {
    throw new System.IllegalArgumentException(
        'ABORTADO: storage em ' + usedPct + '%, acima do teto de 70% da secao 33.2. '
        + 'Nada gravado. Reporte ao Helix.');
}

final List<String> STAGES = new List<String>{
    'Prospecting', 'Qualification', 'Needs Analysis', 'Value Proposition',
    'Id. Decision Makers', 'Perception Analysis', 'Proposal/Price Quote',
    'Negotiation/Review', 'Closed Won', 'Closed Lost'
};
final List<String> OPP_TYPES = new List<String>{
    'New Customer', 'Existing Customer - Upgrade', 'Existing Customer - Replacement',
    'Existing Customer - Downgrade'
};
final List<String> SOURCES = new List<String>{
    'Web', 'Phone Inquiry', 'Partner Referral', 'Purchased List', 'Other'
};
final List<String> COMPETITORS = new List<String>{
    'None', 'Regional Distributor', 'National Competitor', 'Direct Manufacturer', 'Import Channel'
};
final List<String> LOSS = new List<String>{
    'Price', 'Product Fit', 'Timing', 'Competitor', 'Budget', 'No Decision', 'Credit'
};
final List<String> PRICING = new List<String>{ 'Not Priced', 'Priced', 'Approval Required' };
final List<String> DEALDESK = new List<String>{
    'Not Required', 'Not Required', 'Pending', 'Approved', 'Rejected'
};
final List<String> CREDITCHK = new List<String>{
    'Not Checked', 'Approved', 'Approved', 'Review', 'Blocked'
};
final List<String> INVCHK = new List<String>{
    'Not Checked', 'Available', 'Available', 'Partial', 'Unavailable'
};
// Quote.Status: a org roda em pt-BR e os VALORES DE API desta picklist padrao
// estao em portugues. Confirmado por describe, nao suposto.
final List<String> QUOTE_STATUS = new List<String>{ 'Rascunho', 'Apresentado', 'Aceito' };

// --- Insumos das etapas anteriores ----------------------------------------
List<Account> accounts = [
    SELECT Id, Seed_Key__c, Customer_Segment__c, Channel_Type__c, Primary_Territory_Code__c
    FROM Account WHERE Seed_Key__c LIKE 'NS-ACC-%' ORDER BY Seed_Key__c
];
Pricebook2 stdPb = [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1];
List<PricebookEntry> pbes = [
    SELECT Id, UnitPrice FROM PricebookEntry
    WHERE Pricebook2Id = :stdPb.Id AND Product2.Seed_Key__c LIKE 'NS-PRD-%'
    ORDER BY Product2.Seed_Key__c
];
if (accounts.isEmpty() || pbes.isEmpty()) {
    throw new System.IllegalArgumentException(
        'ABORTADO: etapas 1 e 2 precisam rodar antes. Contas=' + accounts.size()
        + ' entradas de preco=' + pbes.size());
}

// --- 1. OPORTUNIDADES ------------------------------------------------------
Map<String, Id> oppExisting = new Map<String, Id>();
for (Opportunity o : [SELECT Id, Seed_Key__c FROM Opportunity WHERE Seed_Key__c LIKE 'NS-OPP-%']) {
    oppExisting.put(o.Seed_Key__c, o.Id);
}

List<Opportunity> oppIns = new List<Opportunity>();
List<Opportunity> oppUpd = new List<Opportunity>();
for (Integer i = 0; i < N_OPP; i++) {
    String  seq   = NS.pad(i + 1, 4);
    String  key   = PFX + 'OPP-' + seq;
    Account a     = accounts[Math.mod(i, accounts.size())];
    String  stage = NS.pick(STAGES, NS.spread(i, 3, STAGES.size()));
    Boolean won   = (stage == 'Closed Won');
    Boolean lost  = (stage == 'Closed Lost');
    Boolean done  = won || lost;

    Opportunity o = new Opportunity(
        Name                      = 'NDG ' + a.Customer_Segment__c + ' - Fornecimento ' + seq,
        StageName                 = stage,
        CloseDate                 = done ? TODAY.addDays(-NS.spread(i, 17, 90) - 1)
                                         : TODAY.addDays(NS.spread(i, 19, 120) + 5),
        Type                      = NS.pick(OPP_TYPES, NS.spread(i, 7, 4)),
        LeadSource                = NS.pick(SOURCES, NS.spread(i, 11, SOURCES.size())),
        Description               = 'Oportunidade sintetica de demonstracao para '
                                  + a.Customer_Segment__c + ' na praca ' + a.Primary_Territory_Code__c + '.',
        NextStep                  = done ? null : 'Revisar proposta tecnica com o cliente',
        Next_Step_Date__c         = done ? null : TODAY.addDays(NS.spread(i, 13, 21) + 1),
        Competitor_Primary__c     = NS.pick(COMPETITORS, NS.spread(i, 23, COMPETITORS.size())),
        Partner_Sourced__c        = (a.Channel_Type__c != 'Direct'),
        Pricing_Status__c         = done ? 'Approved' : NS.pick(PRICING, NS.spread(i, 29, 3)),
        Deal_Desk_Status__c       = NS.pick(DEALDESK, NS.spread(i, 31, 5)),
        Credit_Check_Status__c    = NS.pick(CREDITCHK, NS.spread(i, 37, 5)),
        Inventory_Check_Status__c = NS.pick(INVCHK, NS.spread(i, 41, 5)),
        Total_Discount_Percent__c = NS.spread(i, 43, 18),
        Gross_Margin_Percent__c   = 15 + NS.spread(i, 47, 22),
        Quote_Version__c          = 1 + NS.spread(i, 53, 3),
        External_Order_Id__c      = won ? PFX + 'ERPORD-' + seq : null,
        Loss_Reason__c            = lost ? NS.pick(LOSS, NS.spread(i, 59, LOSS.size())) : null
    );

    if (oppExisting.containsKey(key)) {
        o.Id = oppExisting.get(key);
        oppUpd.add(o);
    } else {
        // So no insert: chave e campos createable-mas-nao-updateable.
        o.Seed_Key__c  = key;
        o.AccountId    = a.Id;
        o.Pricebook2Id = stdPb.Id;
        oppIns.add(o);
    }
}
if (!oppIns.isEmpty()) { insert oppIns; }
if (!oppUpd.isEmpty()) { update oppUpd; }

Map<String, Id> oppByKey = new Map<String, Id>();
for (Opportunity o : [SELECT Id, Seed_Key__c FROM Opportunity WHERE Seed_Key__c LIKE 'NS-OPP-%']) {
    oppByKey.put(o.Seed_Key__c, o.Id);
}
System.debug(LoggingLevel.ERROR, 'Opportunity total=' + oppByKey.size()
    + ' inseridas=' + oppIns.size() + ' atualizadas=' + oppUpd.size());

// --- 2. LINHAS DE OPORTUNIDADE --------------------------------------------
Map<String, Id> oliExisting = new Map<String, Id>();
for (OpportunityLineItem x : [
        SELECT Id, Seed_Key__c FROM OpportunityLineItem WHERE Seed_Key__c LIKE 'NS-OLI-%']) {
    oliExisting.put(x.Seed_Key__c, x.Id);
}

List<OpportunityLineItem> oliIns = new List<OpportunityLineItem>();
List<OpportunityLineItem> oliUpd = new List<OpportunityLineItem>();
for (Integer i = 0; i < N_OLI; i++) {
    String seq = NS.pad(i + 1, 4);
    String key = PFX + 'OLI-' + seq;
    Id     opp = oppByKey.get(PFX + 'OPP-' + NS.pad(Math.mod(i, N_OPP) + 1, 4));
    if (opp == null) { continue; }

    PricebookEntry pbe = pbes[Math.mod(i * 7 + 3, pbes.size())];
    // Desconto de linha de 0% a 12%: da o que exercitar no motor de preco do M5.
    OpportunityLineItem x = new OpportunityLineItem(
        Quantity    = 1 + NS.spread(i, 13, 120),
        UnitPrice   = (pbe.UnitPrice * (100 - NS.spread(i, 17, 13)) / 100).setScale(2),
        Description = 'Linha sintetica ' + seq,
        ServiceDate = TODAY.addDays(NS.spread(i, 19, 60) + 7)
    );
    if (oliExisting.containsKey(key)) {
        x.Id = oliExisting.get(key);
        oliUpd.add(x);
    } else {
        x.Seed_Key__c      = key;
        x.OpportunityId    = opp;
        x.PricebookEntryId = pbe.Id;
        oliIns.add(x);
    }
}
if (!oliIns.isEmpty()) { insert oliIns; }
if (!oliUpd.isEmpty()) { update oliUpd; }
System.debug(LoggingLevel.ERROR, 'OpportunityLineItem inseridas=' + oliIns.size()
    + ' atualizadas=' + oliUpd.size());

// --- 3. COTACOES -----------------------------------------------------------
Map<String, Id> qExisting = new Map<String, Id>();
for (Quote q : [SELECT Id, Seed_Key__c FROM Quote WHERE Seed_Key__c LIKE 'NS-QTE-%']) {
    qExisting.put(q.Seed_Key__c, q.Id);
}

List<Quote> qIns = new List<Quote>();
List<Quote> qUpd = new List<Quote>();
for (Integer i = 0; i < N_QUOTE; i++) {
    String seq = NS.pad(i + 1, 4);
    String key = PFX + 'QTE-' + seq;
    Id     opp = oppByKey.get(PFX + 'OPP-' + NS.pad(Math.mod(i, N_OPP) + 1, 4));
    if (opp == null) { continue; }

    Quote q = new Quote(
        Name           = 'Proposta NDG ' + seq,
        Status         = NS.pick(QUOTE_STATUS, NS.spread(i, 7, 3)),
        ExpirationDate = TODAY.addDays(NS.spread(i, 11, 45) + 15),
        Description    = 'Proposta comercial sintetica de demonstracao ' + seq + '.'
    );
    if (qExisting.containsKey(key)) {
        q.Id = qExisting.get(key);
        qUpd.add(q);
    } else {
        q.Seed_Key__c   = key;
        q.OpportunityId = opp;
        q.Pricebook2Id  = stdPb.Id;
        qIns.add(q);
    }
}
if (!qIns.isEmpty()) { insert qIns; }
if (!qUpd.isEmpty()) { update qUpd; }

Map<String, Id> quoteByKey = new Map<String, Id>();
for (Quote q : [SELECT Id, Seed_Key__c FROM Quote WHERE Seed_Key__c LIKE 'NS-QTE-%']) {
    quoteByKey.put(q.Seed_Key__c, q.Id);
}
System.debug(LoggingLevel.ERROR, 'Quote total=' + quoteByKey.size()
    + ' inseridas=' + qIns.size() + ' atualizadas=' + qUpd.size());

// --- 4. LINHAS DE COTACAO --------------------------------------------------
Map<String, Id> qliExisting = new Map<String, Id>();
for (QuoteLineItem x : [
        SELECT Id, Seed_Key__c FROM QuoteLineItem WHERE Seed_Key__c LIKE 'NS-QLI-%']) {
    qliExisting.put(x.Seed_Key__c, x.Id);
}

List<QuoteLineItem> qliIns = new List<QuoteLineItem>();
List<QuoteLineItem> qliUpd = new List<QuoteLineItem>();
for (Integer i = 0; i < N_QLI; i++) {
    String seq = NS.pad(i + 1, 4);
    String key = PFX + 'QLI-' + seq;
    Id     qid = quoteByKey.get(PFX + 'QTE-' + NS.pad(Math.mod(i, N_QUOTE) + 1, 4));
    if (qid == null) { continue; }

    PricebookEntry pbe = pbes[Math.mod(i * 11 + 5, pbes.size())];
    QuoteLineItem x = new QuoteLineItem(
        Quantity    = 1 + NS.spread(i, 23, 60),
        UnitPrice   = (pbe.UnitPrice * (100 - NS.spread(i, 29, 11)) / 100).setScale(2),
        Description = 'Item de proposta sintetico ' + seq,
        ServiceDate = TODAY.addDays(NS.spread(i, 31, 50) + 10)
    );
    if (qliExisting.containsKey(key)) {
        x.Id = qliExisting.get(key);
        qliUpd.add(x);
    } else {
        x.Seed_Key__c      = key;
        x.QuoteId          = qid;
        x.PricebookEntryId = pbe.Id;
        qliIns.add(x);
    }
}
if (!qliIns.isEmpty()) { insert qliIns; }
if (!qliUpd.isEmpty()) { update qliUpd; }
System.debug(LoggingLevel.ERROR, 'QuoteLineItem inseridas=' + qliIns.size()
    + ' atualizadas=' + qliUpd.size());

// --- 5. PEDIDOS ------------------------------------------------------------
// Todos em Draft de proposito: Activated dispara a validacao de ativacao de
// pedido, que e comportamento de negocio do M8 e nao pertence ao seed.
Map<String, Id> oExisting = new Map<String, Id>();
for (Order o : [SELECT Id, Seed_Key__c FROM Order WHERE Seed_Key__c LIKE 'NS-ORD-%']) {
    oExisting.put(o.Seed_Key__c, o.Id);
}

List<Order> oIns = new List<Order>();
List<Order> oUpd = new List<Order>();
for (Integer i = 0; i < N_ORDER; i++) {
    String  seq = NS.pad(i + 1, 4);
    String  key = PFX + 'ORD-' + seq;
    Account a   = accounts[Math.mod(i, accounts.size())];

    Order o = new Order(
        Name          = 'Pedido NDG ' + seq,
        Status        = 'Draft',
        EffectiveDate = TODAY.addDays(-NS.spread(i, 7, 60)),
        EndDate       = TODAY.addDays(NS.spread(i, 11, 180) + 30),
        Description   = 'Pedido sintetico de demonstracao ' + seq + '.'
    );
    if (oExisting.containsKey(key)) {
        o.Id = oExisting.get(key);
        oUpd.add(o);
    } else {
        o.Seed_Key__c  = key;
        o.AccountId    = a.Id;
        o.Pricebook2Id = stdPb.Id;
        oIns.add(o);
    }
}
if (!oIns.isEmpty()) { insert oIns; }
if (!oUpd.isEmpty()) { update oUpd; }

Map<String, Id> orderByKey = new Map<String, Id>();
for (Order o : [SELECT Id, Seed_Key__c FROM Order WHERE Seed_Key__c LIKE 'NS-ORD-%']) {
    orderByKey.put(o.Seed_Key__c, o.Id);
}
System.debug(LoggingLevel.ERROR, 'Order total=' + orderByKey.size()
    + ' inseridos=' + oIns.size() + ' atualizados=' + oUpd.size());

// --- 6. ITENS DE PEDIDO ----------------------------------------------------
Map<String, Id> oiExisting = new Map<String, Id>();
for (OrderItem x : [SELECT Id, Seed_Key__c FROM OrderItem WHERE Seed_Key__c LIKE 'NS-OIT-%']) {
    oiExisting.put(x.Seed_Key__c, x.Id);
}

List<OrderItem> oiIns = new List<OrderItem>();
List<OrderItem> oiUpd = new List<OrderItem>();
for (Integer i = 0; i < N_OI; i++) {
    String seq = NS.pad(i + 1, 4);
    String key = PFX + 'OIT-' + seq;
    Id     oid = orderByKey.get(PFX + 'ORD-' + NS.pad(Math.mod(i, N_ORDER) + 1, 4));
    if (oid == null) { continue; }

    PricebookEntry pbe = pbes[Math.mod(i * 13 + 9, pbes.size())];
    OrderItem x = new OrderItem(
        Quantity    = 1 + NS.spread(i, 37, 80),
        UnitPrice   = (pbe.UnitPrice * (100 - NS.spread(i, 41, 9)) / 100).setScale(2),
        Description = 'Item de pedido sintetico ' + seq,
        ServiceDate = TODAY.addDays(NS.spread(i, 43, 40) + 5)
    );
    if (oiExisting.containsKey(key)) {
        x.Id = oiExisting.get(key);
        oiUpd.add(x);
    } else {
        x.Seed_Key__c      = key;
        x.OrderId          = oid;
        x.PricebookEntryId = pbe.Id;
        oiIns.add(x);
    }
}
if (!oiIns.isEmpty()) { insert oiIns; }
if (!oiUpd.isEmpty()) { update oiUpd; }
System.debug(LoggingLevel.ERROR, 'OrderItem inseridos=' + oiIns.size()
    + ' atualizados=' + oiUpd.size());
System.debug(LoggingLevel.ERROR, 'ETAPA 3 (pipeline) CONCLUIDA');
