/**
 * SEED M2 — ETAPA 2 DE 3: CLIENTES
 *
 * Cria Account (80), Contact (150) e Lead (80). Os tres casam por
 * `upsert ... Seed_Key__c` (D-015): todos os campos usados sao atualizaveis,
 * entao o upsert direto funciona e nada duplica na segunda execucao.
 *
 * Dados 100% ficticios: nomes de empresa e de pessoa sao combinacoes sinteticas
 * indexadas, e-mails no dominio reservado @example.com (RFC 2606) e telefones
 * no prefixo 5550. Nenhum documento (CPF/CNPJ) e gerado — nao existe campo de
 * documento no modelo, e nao se inventa um. O repositorio e publico.
 *
 * Depende da etapa 1 apenas por ordem de execucao, nao por dado.
 * Ver scripts/apex/README.md.
 */

public class NsCust {
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
final NsCust NS = new NsCust();

// A org tem as regras padrao de duplicidade de Account/Contact/Lead ligadas, e
// a massa sintetica dispara alerta de propósito: sao dezenas de empresas com o
// mesmo padrao de nome e endereco. O seed grava assim mesmo. Isso vale para
// dado de demonstracao; nao e um padrao a copiar para carga de dado real.
final Database.DMLOptions DUP_OK = new Database.DMLOptions();
DUP_OK.DuplicateRuleHeader.AllowSave = true;

final Integer N_ACCOUNT = 80;
final Integer N_CONTACT = 150;
final Integer N_LEAD    = 80;
final String  PFX       = 'NS-';
final String  DOM       = '@example.com';
final Date    TODAY     = Date.today();

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

final List<String> HEADS = new List<String>{
    'Metalurgica', 'Industrias', 'Usinagem', 'Siderurgica', 'Fundicao', 'Mecanica',
    'Engenharia', 'Montagem', 'Fabrica', 'Manutencao'
};
final List<String> CORES = new List<String>{
    'Aurora', 'Bandeirante', 'Cristalina', 'Diamantina', 'Esperanca', 'Farroupilha',
    'Guanabara', 'Horizonte', 'Ipiranga', 'Juazeiro', 'Kubitschek', 'Laguna',
    'Mantiqueira', 'Navegantes', 'Oriente', 'Paranapanema'
};
final List<String> TAILS = new List<String>{ 'Ltda', 'S.A.', 'ME', 'EIRELI' };
final List<String> FIRST = new List<String>{
    'Adriana', 'Bruno', 'Camila', 'Diego', 'Eliane', 'Fabio', 'Gabriela', 'Heitor',
    'Isabela', 'Joao', 'Karina', 'Leandro', 'Marina', 'Nelson', 'Olivia', 'Paulo',
    'Renata', 'Sergio', 'Tatiana', 'Vinicius'
};
final List<String> LAST = new List<String>{
    'Almeida', 'Barbosa', 'Cardoso', 'Dias', 'Esteves', 'Ferreira', 'Gomes', 'Henriques',
    'Ibrahim', 'Justino', 'Klein', 'Lopes', 'Moreira', 'Nunes', 'Oliveira', 'Pacheco'
};
final List<String> TITLES = new List<String>{
    'Gerente de Manutencao', 'Diretor Industrial', 'Comprador Tecnico',
    'Supervisor de Producao', 'Coordenador de Suprimentos', 'Engenheiro de Processos',
    'Gerente de Planta', 'Analista de Compras'
};
final List<String> SEGMENTS = new List<String>{ 'SMB', 'Mid-Market', 'Enterprise', 'Strategic' };
final List<String> TIERS    = new List<String>{ 'Bronze', 'Silver', 'Gold', 'Platinum' };
final List<String> CHANNELS = new List<String>{ 'Direct', 'Partner', 'Hybrid' };
final List<String> TYPES    = new List<String>{
    'Customer - Direct', 'Customer - Channel', 'Prospect', 'Channel Partner / Reseller'
};
final List<String> INDUSTRIES = new List<String>{
    'Manufacturing', 'Construction', 'Energy', 'Transportation', 'Machinery',
    'Chemicals', 'Food & Beverage', 'Utilities', 'Shipping', 'Agriculture'
};
final List<String> CREDIT = new List<String>{ 'Approved', 'Approved', 'Review', 'Unknown', 'Blocked' };
final List<String> SOURCES = new List<String>{
    'Web', 'Phone Inquiry', 'Partner Referral', 'Purchased List', 'Other'
};
final List<String> LEAD_STATUS = new List<String>{
    'Open - Not Contacted', 'Working - Contacted', 'Closed - Converted', 'Closed - Not Converted'
};
final List<String> RATINGS = new List<String>{ 'Hot', 'Warm', 'Cold' };

// Vocabulario proprio dos leads. Nao e enfeite: a regra padrao de duplicidade
// de Lead compara lead contra contato, e reutilizar o mesmo conjunto de nomes
// e de empresas faz a plataforma recusar parte da carga com DUPLICATES_DETECTED.
// Separar tambem e mais fiel ao negocio: prospect nao e cliente existente.
final List<String> LEAD_FIRST = new List<String>{
    'Amanda', 'Bernardo', 'Clarice', 'Danilo', 'Evandro', 'Flavia', 'Gustavo', 'Helena',
    'Igor', 'Juliana', 'Kaique', 'Luciana', 'Murilo', 'Natalia', 'Otavio', 'Priscila',
    'Rodrigo', 'Simone', 'Thiago', 'Viviane'
};
final List<String> LEAD_LAST = new List<String>{
    'Antunes', 'Bittencourt', 'Camargo', 'Drummond', 'Escobar', 'Fontoura', 'Guimaraes',
    'Hoffmann', 'Ivanov', 'Jacome', 'Kowalski', 'Linhares', 'Machado', 'Negrao',
    'Orsini', 'Peixoto'
};
final List<String> LEAD_HEADS = new List<String>{
    'Agroindustria', 'Transportadora', 'Mineradora', 'Construtora', 'Logistica',
    'Refrigeracao', 'Automacao', 'Hidraulica', 'Termotecnica', 'Ferramentaria'
};
final List<String> LEAD_CORES = new List<String>{
    'Anhanguera', 'Botucatu', 'Caraiva', 'Delmiro', 'Emboaba', 'Formosa', 'Gravatai',
    'Itaimbe', 'Jaguaribe', 'Marajo', 'Nhambiquara', 'Piracema', 'Quilombo',
    'Registro', 'Sertaneja', 'Tocantins'
};

// Pracas do distribuidor, alinhadas as regioes usadas em Freight_Rule__mdt.
final List<String> TERR = new List<String>{
    'SP01', 'SP02', 'RJ01', 'MG01', 'PR01', 'RS01', 'SC01', 'PE01', 'BA01', 'GO01', 'AM01', 'CE01'
};
final List<String> CITIES = new List<String>{
    'Sao Paulo', 'Campinas', 'Rio de Janeiro', 'Belo Horizonte', 'Curitiba', 'Porto Alegre',
    'Joinville', 'Recife', 'Salvador', 'Goiania', 'Manaus', 'Fortaleza'
};
// A org tem picklist de estado/pais ligada, entao os campos gravados sao os
// de codigo (BillingStateCode/BillingCountryCode), nao os de texto livre.
final List<String> UFS = new List<String>{
    'SP', 'SP', 'RJ', 'MG', 'PR', 'RS', 'SC', 'PE', 'BA', 'GO', 'AM', 'CE'
};
final List<String> DDD = new List<String>{
    '11', '19', '21', '31', '41', '51', '47', '81', '71', '62', '92', '85'
};

// --- 1. CONTAS -------------------------------------------------------------
List<Account> accounts = new List<Account>();
for (Integer i = 0; i < N_ACCOUNT; i++) {
    String  seq = NS.pad(i + 1, 4);
    Integer geo = NS.spread(i, 11, TERR.size());
    String  seg = NS.pick(SEGMENTS, NS.spread(i, 5, 4));

    Decimal limitAmt = seg == 'Strategic'  ? 4000000
                     : seg == 'Enterprise' ? 1500000
                     : seg == 'Mid-Market' ? 400000
                                           : 90000;

    accounts.add(new Account(
        Seed_Key__c               = PFX + 'ACC-' + seq,
        Name                      = NS.pick(HEADS, NS.spread(i, 3, HEADS.size()))
                                  + ' ' + NS.pick(CORES, NS.spread(i, 13, CORES.size()))
                                  + ' ' + seq + ' ' + NS.pick(TAILS, i),
        Type                      = NS.pick(TYPES, NS.spread(i, 17, 4)),
        Industry                  = NS.pick(INDUSTRIES, NS.spread(i, 19, INDUSTRIES.size())),
        Phone                     = '+55 ' + DDD[geo] + ' 5550-' + seq,
        Website                   = 'https://www.example.com/ndg/conta/' + seq,
        BillingStreet             = 'Rodovia Industrial Ficticia, km ' + (i + 1),
        BillingCity               = CITIES[geo],
        BillingStateCode          = UFS[geo],
        BillingPostalCode         = NS.pad(10000 + i * 7, 5) + '-000',
        BillingCountryCode        = 'BR',
        AnnualRevenue             = limitAmt * 12,
        NumberOfEmployees         = 25 + NS.spread(i, 23, 40) * 45,
        Customer_Segment__c       = seg,
        Customer_Tier__c          = NS.pick(TIERS, NS.spread(i, 31, 4)),
        Channel_Type__c           = NS.pick(CHANNELS, NS.spread(i, 37, 3)),
        Primary_Territory_Code__c = TERR[geo],
        Strategic_Account__c      = (seg == 'Strategic'),
        Credit_Limit__c           = limitAmt,
        Current_Exposure__c       = (limitAmt * NS.spread(i, 29, 70) / 100).setScale(2),
        Credit_Status__c          = NS.pick(CREDIT, NS.spread(i, 41, CREDIT.size())),
        // Prefixo NS- proposital: o id de ERP do seed nunca pode colidir com um
        // id vindo do ERP de verdade. A chave do seed continua sendo Seed_Key__c
        // — a limpeza nunca filtra por ERP_Customer_Id__c (D-014).
        ERP_Customer_Id__c        = PFX + 'ERP-' + seq,
        Last_ERP_Sync__c          = DateTime.newInstance(
                                        TODAY.addDays(-NS.spread(i, 43, 30)),
                                        Time.newInstance(3, 0, 0, 0))
    ));
}
for (Account a : accounts) { a.setOptions(DUP_OK); }
upsert accounts Seed_Key__c;
System.debug(LoggingLevel.ERROR, 'Account upsert=' + accounts.size());

// --- 2. CONTATOS -----------------------------------------------------------
List<Contact> contacts = new List<Contact>();
for (Integer i = 0; i < N_CONTACT; i++) {
    String  seq = NS.pad(i + 1, 4);
    Integer geo = NS.spread(i, 11, TERR.size());
    contacts.add(new Contact(
        Seed_Key__c    = PFX + 'CON-' + seq,
        AccountId      = accounts[Math.mod(i, accounts.size())].Id,
        FirstName      = NS.pick(FIRST, NS.spread(i, 7, FIRST.size())),
        LastName       = NS.pick(LAST, NS.spread(i, 13, LAST.size())) + ' ' + seq,
        Title          = NS.pick(TITLES, NS.spread(i, 17, TITLES.size())),
        Email          = 'ns.contato.' + seq + DOM,
        Phone          = '+55 ' + DDD[geo] + ' 5550-' + seq,
        LeadSource     = NS.pick(SOURCES, NS.spread(i, 19, SOURCES.size())),
        MailingCity    = CITIES[geo],
        MailingStateCode   = UFS[geo],
        MailingCountryCode = 'BR'
    ));
}
for (Contact c : contacts) { c.setOptions(DUP_OK); }
upsert contacts Seed_Key__c;
System.debug(LoggingLevel.ERROR, 'Contact upsert=' + contacts.size());

// --- 3. LEADS --------------------------------------------------------------
List<Lead> leads = new List<Lead>();
for (Integer i = 0; i < N_LEAD; i++) {
    String  seq = NS.pad(i + 1, 4);
    Integer geo = NS.spread(i, 11, TERR.size());
    leads.add(new Lead(
        Seed_Key__c       = PFX + 'LED-' + seq,
        FirstName         = NS.pick(LEAD_FIRST, NS.spread(i, 23, LEAD_FIRST.size())),
        LastName          = NS.pick(LEAD_LAST, NS.spread(i, 29, LEAD_LAST.size())) + ' ' + seq,
        Company           = NS.pick(LEAD_HEADS, NS.spread(i, 5, LEAD_HEADS.size()))
                          + ' ' + NS.pick(LEAD_CORES, NS.spread(i, 31, LEAD_CORES.size()))
                          + ' ' + seq + ' ' + NS.pick(TAILS, i),
        Title             = NS.pick(TITLES, NS.spread(i, 37, TITLES.size())),
        Email             = 'ns.lead.' + seq + DOM,
        Phone             = '+55 ' + DDD[geo] + ' 5550-' + seq,
        Status            = NS.pick(LEAD_STATUS, NS.spread(i, 3, 4)),
        LeadSource        = NS.pick(SOURCES, NS.spread(i, 41, SOURCES.size())),
        Industry          = NS.pick(INDUSTRIES, NS.spread(i, 43, INDUSTRIES.size())),
        Rating            = NS.pick(RATINGS, NS.spread(i, 47, 3)),
        City              = CITIES[geo],
        StateCode         = UFS[geo],
        CountryCode       = 'BR',
        NumberOfEmployees = 20 + NS.spread(i, 53, 30) * 55,
        AnnualRevenue     = 500000 + NS.spread(i, 59, 40) * 750000
    ));
}
for (Lead l : leads) { l.setOptions(DUP_OK); }
upsert leads Seed_Key__c;
System.debug(LoggingLevel.ERROR, 'Lead upsert=' + leads.size());
System.debug(LoggingLevel.ERROR, 'ETAPA 2 (clientes) CONCLUIDA');
