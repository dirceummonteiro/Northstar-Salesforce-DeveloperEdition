/**
 * SEED M2 — ETAPA 1 DE 3: CATALOGO
 *
 * Cria Product2 (100), Pricebook2 de parceiro (1) e PricebookEntry (200: 100 na
 * tabela padrao + 100 na de parceiro). Idempotente: rodar de novo nao duplica.
 *
 * Product2 e Pricebook2 casam por `upsert ... Seed_Key__c`. PricebookEntry nao
 * aceita campo customizado (D-014), entao a chave dele e a natural
 * Pricebook2Id + Product2Id e o script so insere o que falta.
 *
 * Dados 100% ficticios. Ver scripts/apex/README.md para pre-requisitos,
 * orcamento de storage e o comando de execucao.
 */

public class NsCat {
    public String pad(Integer i, Integer w) {
        String s = String.valueOf(i);
        while (s.length() < w) { s = '0' + s; }
        return s;
    }
    public String pick(List<String> v, Integer i) { return v[Math.mod(i, v.size())]; }
    // Espalhamento deterministico no lugar de Math.random(): duas execucoes
    // produzem exatamente os mesmos valores, nao so as mesmas chaves.
    public Integer spread(Integer i, Integer mult, Integer mod) {
        return Math.mod((Long) i * (Long) mult + 7L, (Long) mod).intValue();
    }
    // Preco de tabela derivado do indice e da familia. Vive num metodo porque
    // PricebookEntry e as linhas de negocio precisam do mesmo numero.
    public Decimal listPrice(Integer i, String family) {
        if (family == 'Industrial Equipment') { return 18000 + spread(i, 137, 60) * 750; }
        if (family == 'Spare Parts')          { return 180 + spread(i, 89, 80) * 35; }
        if (family == 'Consumables')          { return 45 + spread(i, 53, 40) * 12; }
        return 3200 + spread(i, 71, 30) * 420;
    }
}
final NsCat NS = new NsCat();

final Integer N_PRODUCT = 100;
final String  PFX       = 'NS-';

// Portao de storage da secao 33.2: acima de 70% e parada obrigatoria.
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

// Vocabulario do distribuidor B2B de equipamento industrial da secao 1.
final List<String> FAMILIES = new List<String>{
    'Industrial Equipment', 'Spare Parts', 'Consumables', 'Services'
};
final List<String> EQUIP = new List<String>{
    'Compressor de Ar', 'Bomba Centrifuga', 'Motor Eletrico', 'Redutor de Velocidade',
    'Valvula de Controle', 'Painel de Comando', 'Empilhadeira Eletrica', 'Talha Eletrica',
    'Gerador Diesel', 'Torno CNC'
};
final List<String> PARTS = new List<String>{
    'Rolamento Rigido', 'Correia Sincronizadora', 'Retentor de Vedacao', 'Engrenagem Helicoidal',
    'Mangueira Hidraulica', 'Filtro de Linha', 'Acoplamento Elastico', 'Sensor de Pressao',
    'Contator Tripolar', 'Eixo de Transmissao'
};
final List<String> CONS = new List<String>{
    'Oleo Lubrificante', 'Graxa Industrial', 'Fluido de Corte', 'Eletrodo de Solda',
    'Disco Abrasivo', 'Estopa Industrial', 'Selante Anaerobico', 'Desengraxante Alcalino'
};
final List<String> SERV = new List<String>{
    'Contrato de Manutencao Preventiva', 'Contrato de Manutencao Corretiva',
    'Instalacao e Comissionamento', 'Treinamento Operacional',
    'Inspecao Preditiva por Vibracao', 'Calibracao Certificada'
};

// --- 1. PRODUTOS -----------------------------------------------------------
List<Product2> products = new List<Product2>();
for (Integer i = 0; i < N_PRODUCT; i++) {
    String seq    = NS.pad(i + 1, 4);
    String family = NS.pick(FAMILIES, NS.spread(i, 7, 4));
    String noun;
    String code;
    if (family == 'Industrial Equipment')  { noun = NS.pick(EQUIP, i); code = 'EQ'; }
    else if (family == 'Spare Parts')      { noun = NS.pick(PARTS, i); code = 'PC'; }
    else if (family == 'Consumables')      { noun = NS.pick(CONS,  i); code = 'CS'; }
    else                                   { noun = NS.pick(SERV,  i); code = 'SV'; }

    products.add(new Product2(
        Seed_Key__c = PFX + 'PRD-' + seq,
        Name        = noun + ' ' + code + '-' + seq,
        ProductCode = PFX + code + '-' + seq,
        Family      = family,
        Description = 'Item de catalogo ficticio da Northstar Distribution Group. Familia: '
                    + family + '. Registro de demonstracao, nao comercializado.',
        IsActive    = true
    ));
}
upsert products Seed_Key__c;
System.debug(LoggingLevel.ERROR, 'Product2 upsert=' + products.size());

// Preco por produto, na mesma ordem de indice usada acima.
Map<Id, Decimal> priceByProduct = new Map<Id, Decimal>();
for (Integer i = 0; i < products.size(); i++) {
    priceByProduct.put(products[i].Id, NS.listPrice(i, products[i].Family));
}

// --- 2. TABELAS DE PRECO ---------------------------------------------------
Pricebook2 stdPb = [SELECT Id, IsActive FROM Pricebook2 WHERE IsStandard = true LIMIT 1];
if (!stdPb.IsActive) {
    // Pre-requisito tecnico de PricebookEntry, nao dado de seed: por isso a
    // tabela padrao nao recebe Seed_Key__c e a limpeza nao a remove.
    stdPb.IsActive = true;
    update stdPb;
    System.debug(LoggingLevel.ERROR, 'Standard Price Book ativado (pre-requisito de PricebookEntry).');
}

Pricebook2 partnerPb = new Pricebook2(
    Seed_Key__c = PFX + 'PB2-0001',
    Name        = 'NDG Tabela Parceiro 2026',
    Description = 'Tabela de preco de canal para revendedores homologados. Massa de demonstracao.',
    IsActive    = true
);
upsert partnerPb Seed_Key__c;
System.debug(LoggingLevel.ERROR, 'Pricebook2 upsert=1');

// --- 3. PRICEBOOK ENTRY ----------------------------------------------------
Set<Id> productIds = priceByProduct.keySet();
Set<String> existing = new Set<String>();
for (PricebookEntry pbe : [
        SELECT Pricebook2Id, Product2Id FROM PricebookEntry WHERE Product2Id IN :productIds]) {
    existing.add(pbe.Pricebook2Id + ':' + pbe.Product2Id);
}

// A entrada na tabela padrao precisa existir antes de qualquer entrada em
// tabela customizada — regra da plataforma, nao escolha de modelagem.
List<PricebookEntry> toInsert = new List<PricebookEntry>();
for (Product2 p : products) {
    if (!existing.contains(stdPb.Id + ':' + p.Id)) {
        toInsert.add(new PricebookEntry(
            Pricebook2Id = stdPb.Id,
            Product2Id   = p.Id,
            UnitPrice    = priceByProduct.get(p.Id),
            IsActive     = true
        ));
    }
}
if (!toInsert.isEmpty()) { insert toInsert; }
Integer stdInserted = toInsert.size();

toInsert = new List<PricebookEntry>();
for (Product2 p : products) {
    if (!existing.contains(partnerPb.Id + ':' + p.Id)) {
        // Tabela de parceiro sai 8% abaixo da padrao — margem de canal.
        toInsert.add(new PricebookEntry(
            Pricebook2Id     = partnerPb.Id,
            Product2Id       = p.Id,
            UnitPrice        = (priceByProduct.get(p.Id) * 0.92).setScale(2),
            UseStandardPrice = false,
            IsActive         = true
        ));
    }
}
if (!toInsert.isEmpty()) { insert toInsert; }

System.debug(LoggingLevel.ERROR, 'PricebookEntry inseridos=' + (stdInserted + toInsert.size())
    + ' ja_existiam=' + existing.size());
System.debug(LoggingLevel.ERROR, 'ETAPA 1 (catalogo) CONCLUIDA');
