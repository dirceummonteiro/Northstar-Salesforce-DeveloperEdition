/**
 * ############################################################################
 * #  DESTRUTIVO — APAGA DADOS. LEIA ANTES DE RODAR.                          #
 * ############################################################################
 *
 * SEED M2 — LIMPEZA
 *
 * Apaga APENAS registros marcados como seed, isto e, com
 * `Seed_Key__c LIKE 'NS-%'`. Nao existe neste script nenhum `delete` por objeto
 * inteiro, e isso e proposital (D-016): a org e compartilhada e ja tinha 139
 * registros de amostra da Developer Edition antes do projeto. Limpeza por marca
 * e auditavel; limpeza por objeto e irreversivel.
 *
 * PricebookEntry nao tem Seed_Key__c (D-014), entao e apagado pela marca do
 * produto pai — `Product2.Seed_Key__c LIKE 'NS-%'` — e nunca por varredura da
 * tabela toda. A tabela de preco padrao (IsStandard) nunca e tocada: ela nao
 * carrega Seed_Key__c porque nao foi criada pelo seed.
 *
 * O filtro e sempre `Seed_Key__c`, nunca `ERP_Customer_Id__c`: a chave de
 * integracao e a chave de seed tem ciclos de vida diferentes, e confundir as
 * duas faria esta limpeza apagar, um dia, dado vindo do ERP (D-014).
 *
 * Ordem de exclusao: filho antes de pai. Nao e estetica — a plataforma recusa
 * apagar um Product2 que ainda esteja em linha de oportunidade, e apagar a
 * conta antes dos filhos deixaria a cascata decidir o que morre.
 *
 * A lixeira e esvaziada ao final: registro apagado continua ocupando storage
 * enquanto estiver nela, e numa org de 5 MB isso importa.
 *
 * COMO RODAR
 *     sf apex run --target-org helix-dev --file scripts/apex/cleanup_seed.apex
 */

final String MARK = 'NS-%';
List<Id> recycled = new List<Id>();

// --- Filhos primeiro -------------------------------------------------------
List<OrderItem> orderItems = [SELECT Id FROM OrderItem WHERE Seed_Key__c LIKE :MARK];
delete orderItems;
System.debug(LoggingLevel.ERROR, 'OrderItem apagados           = ' + orderItems.size());
for (OrderItem x : orderItems) { recycled.add(x.Id); }

List<Order> orders = [SELECT Id FROM Order WHERE Seed_Key__c LIKE :MARK];
delete orders;
System.debug(LoggingLevel.ERROR, 'Order apagados               = ' + orders.size());
for (Order x : orders) { recycled.add(x.Id); }

List<QuoteLineItem> quoteLines = [SELECT Id FROM QuoteLineItem WHERE Seed_Key__c LIKE :MARK];
delete quoteLines;
System.debug(LoggingLevel.ERROR, 'QuoteLineItem apagados       = ' + quoteLines.size());
for (QuoteLineItem x : quoteLines) { recycled.add(x.Id); }

List<Quote> quotes = [SELECT Id FROM Quote WHERE Seed_Key__c LIKE :MARK];
delete quotes;
System.debug(LoggingLevel.ERROR, 'Quote apagadas               = ' + quotes.size());
for (Quote x : quotes) { recycled.add(x.Id); }

List<OpportunityLineItem> oppLines = [
    SELECT Id FROM OpportunityLineItem WHERE Seed_Key__c LIKE :MARK];
delete oppLines;
System.debug(LoggingLevel.ERROR, 'OpportunityLineItem apagadas = ' + oppLines.size());
for (OpportunityLineItem x : oppLines) { recycled.add(x.Id); }

List<Opportunity> opps = [SELECT Id FROM Opportunity WHERE Seed_Key__c LIKE :MARK];
delete opps;
System.debug(LoggingLevel.ERROR, 'Opportunity apagadas         = ' + opps.size());
for (Opportunity x : opps) { recycled.add(x.Id); }

// --- Catalogo --------------------------------------------------------------
// PricebookEntry sai pela marca do produto pai; a tabela de preco padrao em si
// nunca e tocada, so as entradas dela que apontam para produto do seed.
//
// A entrada da tabela customizada tem de morrer antes da entrada da tabela
// padrao do mesmo produto: a plataforma recusa apagar a entrada padrao enquanto
// existir entrada customizada dependendo dela (UNKNOWN_EXCEPTION no delete).
List<PricebookEntry> customPbes = [
    SELECT Id FROM PricebookEntry
    WHERE Product2.Seed_Key__c LIKE :MARK AND Pricebook2.IsStandard = false];
delete customPbes;
for (PricebookEntry x : customPbes) { recycled.add(x.Id); }

List<PricebookEntry> stdPbes = [
    SELECT Id FROM PricebookEntry
    WHERE Product2.Seed_Key__c LIKE :MARK AND Pricebook2.IsStandard = true];
delete stdPbes;
for (PricebookEntry x : stdPbes) { recycled.add(x.Id); }
System.debug(LoggingLevel.ERROR, 'PricebookEntry apagadas      = '
    + (customPbes.size() + stdPbes.size())
    + ' (customizadas ' + customPbes.size() + ', padrao ' + stdPbes.size() + ')');

List<Pricebook2> pricebooks = [SELECT Id FROM Pricebook2 WHERE Seed_Key__c LIKE :MARK];
delete pricebooks;
System.debug(LoggingLevel.ERROR, 'Pricebook2 apagadas          = ' + pricebooks.size());
for (Pricebook2 x : pricebooks) { recycled.add(x.Id); }

List<Product2> products = [SELECT Id FROM Product2 WHERE Seed_Key__c LIKE :MARK];
delete products;
System.debug(LoggingLevel.ERROR, 'Product2 apagados            = ' + products.size());
for (Product2 x : products) { recycled.add(x.Id); }

// --- Clientes --------------------------------------------------------------
List<Lead> leads = [SELECT Id FROM Lead WHERE Seed_Key__c LIKE :MARK];
delete leads;
System.debug(LoggingLevel.ERROR, 'Lead apagados                = ' + leads.size());
for (Lead x : leads) { recycled.add(x.Id); }

List<Contact> contacts = [SELECT Id FROM Contact WHERE Seed_Key__c LIKE :MARK];
delete contacts;
System.debug(LoggingLevel.ERROR, 'Contact apagados             = ' + contacts.size());
for (Contact x : contacts) { recycled.add(x.Id); }

List<Account> accounts = [SELECT Id FROM Account WHERE Seed_Key__c LIKE :MARK];
delete accounts;
System.debug(LoggingLevel.ERROR, 'Account apagadas             = ' + accounts.size());
for (Account x : accounts) { recycled.add(x.Id); }

System.debug(LoggingLevel.ERROR, 'TOTAL_APAGADO                = ' + recycled.size());

// --- Lixeira ---------------------------------------------------------------
// emptyRecycleBin aceita no maximo 200 ids por chamada. Sem isso o storage nao
// volta e o portao de 50% do M2 continua consumido por dado ja apagado.
Integer purged = 0;
List<Id> batch = new List<Id>();
for (Id recordId : recycled) {
    batch.add(recordId);
    if (batch.size() == 200) {
        Database.emptyRecycleBin(batch);
        purged += batch.size();
        batch = new List<Id>();
    }
}
if (!batch.isEmpty()) {
    Database.emptyRecycleBin(batch);
    purged += batch.size();
}
System.debug(LoggingLevel.ERROR, 'LIXEIRA_ESVAZIADA            = ' + purged);
System.debug(LoggingLevel.ERROR, 'LIMPEZA CONCLUIDA');
