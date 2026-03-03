-- ex 4
--===========================================================================


-- secvente
create sequence seq_angajati start with 100 increment by 1 nocache;
create sequence seq_sedii start with 1 increment by 1 nocache;
create sequence seq_custi start with 1 increment by 1 nocache;
create sequence seq_animale start with 200 increment by 1 nocache;
create sequence seq_proceduri start with 1 increment by 1 nocache;
create sequence seq_diagnostice start with 1 increment by 1 nocache;
create sequence seq_medicamente start with 1 increment by 1 nocache;
create sequence seq_reviste start with 1 increment by 1 nocache;
create sequence seq_clienti start with 100 increment by 1 nocache;
create sequence seq_orase start with 1 increment by 1 nocache;


-- 1. orase
create table orase (
    cod_oras number(4,0) primary key,
    nume_oras varchar2(50) not null
);


-- 2. sedii
create table sedii (
    numar_sediu number(4,0) primary key,
    cod_oras number(4,0) references orase(cod_oras) not null
);


-- 3. angajati
create table angajati( 
    cod_angajat number(6,0) primary key,
    nume varchar2(50) not null check (regexp_like(nume, '^[A-Z][a-z]+$')),
    prenume varchar2(50) not null check (regexp_like(prenume, '^[A-Z][a-z]+$')),
    data_nastere date not null,
    data_angajare date not null,
    salariu number(7,2) not null check (salariu > 0),
    numar_telefon varchar2(10) check (regexp_like(numar_telefon, '^07[0-9]{8}$')),
    adresa varchar2(100),
    numar_sediu number(4,0) references sedii(numar_sediu) not null,
    tip varchar2(20) not null check (tip in ('medic veterinar', 'notar', 'ingrijitor'))
);


-- 4. subentitati angajati
create table ingrijitori (
    cod_angajat number(6,0) primary key references angajati(cod_angajat),
    nivel_experienta varchar2(15) not null check (nivel_experienta in ('incepator', 'mediu', 'avansat'))
);


create table medici_veterinari (
    cod_angajat number(6,0) primary key references angajati(cod_angajat),
    cod_parafa_medicala varchar2(20) not null unique
);


create table notari (
    cod_angajat number(6,0) primary key references angajati(cod_angajat),
    cod_parafa_notariala varchar2(20) not null unique
);


-- 5. custi
create table custi( 
    numar_cusca number(6,0) primary key, 
    marime char(1) not null check (marime in ('S', 'M', 'L')),
    numar_sediu number(4,0) not null references sedii(numar_sediu)
);


-- 6. animale
create table animale (
    cod_cip number(6,0) primary key, 
    nume varchar2(50), 
    data_nastere date not null,
    tip varchar2(50) not null, 
    grad_risc varchar2(10) not null check (grad_risc in ('mic', 'mediu', 'mare'))
); 


-- 7. proceduri
create table proceduri(cod_procedura number(6,0) primary key, nume_procedura varchar2(100) not null);


-- 8. diagnostice
create table diagnostice(cod_diagnostic number(6,0) primary key, denumire varchar2(100) not null);


-- 9. medicamente
create table medicamente(cod_medicament number(6,0) primary key, denumire varchar2(50) not null);


-- 10. clienti
create table clienti(
    cod_client number(6,0) primary key, 
    nume varchar2(50) not null check (regexp_like(nume, '^[A-Z][a-z]+$')),
    prenume varchar2(50) not null check (regexp_like(prenume, '^[A-Z][a-z]+$')), 
    numar_telefon varchar2(10) check (regexp_like(numar_telefon, '07[0-9]{8}$')),
    adresa varchar2(100) not null, 
    abonare_revista char(2) not null check (abonare_revista in ('DA', 'NU'))
);


-- 11. reviste
create table reviste(numar number(4,0) primary key, data_aparitie date not null);


-- 12. istoric custi (asociativa)
create table istoric_custi(
    cod_cip number(6,0), 
    numar_cusca number(6,0), 
    cod_angajat number(6,0), 
    data_incepere date not null,
    data_finalizare date,
    primary key (cod_cip, numar_cusca, cod_angajat, data_incepere),
    foreign key (cod_cip) references animale(cod_cip),
    foreign key (numar_cusca) references custi(numar_cusca),
    foreign key (cod_angajat) references ingrijitori(cod_angajat)
);


-- 13. istoric adoptii (asociativa)
create table istoric_adoptii(
    cod_client number(6,0), 
    cod_cip number(6,0), 
    cod_angajat number(6,0), 
    data_efectuare date not null,
    primary key (cod_client, cod_cip, cod_angajat),
    foreign key (cod_client) references clienti(cod_client),
    foreign key (cod_cip) references animale(cod_cip),
    foreign key (cod_angajat) references notari(cod_angajat)
);


-- 14. istoric aparitii (asociativa)
create table istoric_aparitii (
    numar number(4,0), 
    cod_cip number(6,0),
    primary key (numar, cod_cip),
    foreign key (numar) references reviste(numar),
    foreign key (cod_cip) references animale(cod_cip)
);


-- 15. istoric reviste (asociativa)
create table istoric_reviste(
    numar number(4,0), 
    cod_client number(6,0),
    primary key (numar, cod_client),
    foreign key (numar) references reviste(numar),
    foreign key (cod_client) references clienti(cod_client)
);


-- 16. istoric medical (asociativa)
create table istoric_medical (
    cod_cip number(6,0), 
    cod_angajat number(6,0), 
    cod_procedura number(6,0),
    data_ef date not null,
    primary key (cod_cip, cod_angajat, cod_procedura, data_ef),
    foreign key (cod_cip) references animale(cod_cip),
    foreign key (cod_angajat) references medici_veterinari(cod_angajat),
    foreign key (cod_procedura) references proceduri(cod_procedura)
);


-- 17. istoric diagnostice (asociativa)
create table istoric_diagnostice (
    cod_cip number(6,0), 
    cod_angajat number(6,0), 
    cod_procedura number(6,0),
    data_ef date, 
    cod_diagnostic number(6,0),
    primary key (cod_cip, cod_angajat, cod_procedura, data_ef, cod_diagnostic),
    foreign key (cod_cip, cod_angajat, cod_procedura, data_ef) references istoric_medical(cod_cip, cod_angajat, cod_procedura, data_ef),
    foreign key (cod_diagnostic) references diagnostice(cod_diagnostic)
);


-- 18. retete (asociativa)
create table retete (
    cod_cip number(6,0), 
    cod_angajat number(6,0), 
    cod_procedura number(6,0),
    data_ef date, 
    cod_medicament number(6,0),
    primary key (cod_cip, cod_angajat, cod_procedura, data_ef, cod_medicament),
    foreign key (cod_cip, cod_angajat, cod_procedura, data_ef) references istoric_medical(cod_cip, cod_angajat, cod_procedura, data_ef),
    foreign key (cod_medicament) references medicamente(cod_medicament)
);
-- ex 4
--===========================================================================




-- ex 5
--===========================================================================


-- tabela orase
insert into orase values (seq_orase.nextval, 'Bucuresti');
insert into orase values (seq_orase.nextval, 'Iasi');
insert into orase values (seq_orase.nextval, 'Cluj');
insert into orase values (seq_orase.nextval, 'Timisoara');
insert into orase values (seq_orase.nextval, 'Brasov');


-- tabela sedii
insert into sedii values (seq_sedii.nextval, 1);
insert into sedii values (seq_sedii.nextval, 1);
insert into sedii values (seq_sedii.nextval, 2);
insert into sedii values (seq_sedii.nextval, 3);
insert into sedii values (seq_sedii.nextval, 4);
insert into sedii values (seq_sedii.nextval, 5);
insert into sedii values (seq_sedii.nextval, 2);


-- tabela angajati
-- sediul 1
insert into angajati values (seq_angajati.nextval, 'Ionescu', 'Maria', to_date('20/06/1980', 'dd/mm/yyyy'), to_date('15/05/2015', 'dd/mm/yyyy'), 5500, '0768254145', 'Str. independentei 12', 1, 'notar');
insert into angajati values (seq_angajati.nextval, 'Popescu', 'Andrei', to_date('01/09/1985', 'dd/mm/yyyy'), to_date('01/09/2018', 'dd/mm/yyyy'), 6200, '0734712800', 'Bd. unirii 45', 1, 'medic veterinar');
insert into angajati values (seq_angajati.nextval, 'Georgescu', 'Ana', to_date('25/11/1990', 'dd/mm/yyyy'), to_date('22/03/2021', 'dd/mm/yyyy'), 4000, '0744254245', 'Calea timisorii 8', 1, 'ingrijitor');
insert into angajati values (seq_angajati.nextval, 'Dumitru', 'Ionel', to_date('15/01/1998', 'dd/mm/yyyy'), to_date('10/04/2023', 'dd/mm/yyyy'), 3000, '0722119817', 'Str. lalelelor 10', 1, 'ingrijitor');


-- sediul 2
insert into angajati values (seq_angajati.nextval, 'Marin', 'Raluca', to_date('30/09/1993', 'dd/mm/yyyy'), to_date('20/01/2020', 'dd/mm/yyyy'), 3500, '0733112728', 'Bd. revolutiei 22', 2, 'ingrijitor');
insert into angajati values (seq_angajati.nextval, 'Radu', 'Cristian', to_date('10/05/1982', 'dd/mm/yyyy'), to_date('18/06/2010', 'dd/mm/yyyy'), 6500, '0724556182', 'Str. cerbului 5', 2, 'medic veterinar');


-- sediul 3
insert into angajati values (seq_angajati.nextval, 'Neagu', 'Simona', to_date('21/07/1991', 'dd/mm/yyyy'), to_date('03/10/2019', 'dd/mm/yyyy'), 5300, '0774294174', 'Calea moldovei 88', 3, 'notar');
insert into angajati values (seq_angajati.nextval, 'Stan', 'Mihai', to_date('12/12/1988', 'dd/mm/yyyy'), to_date('01/02/2022', 'dd/mm/yyyy'), 4100, '0755123456', 'Str. pacurari 15', 3, 'ingrijitor');
insert into angajati values (seq_angajati.nextval, 'Vlaicu', 'Elena', to_date('05/05/1985', 'dd/mm/yyyy'), to_date('10/10/2016', 'dd/mm/yyyy'), 6100, '0744998877', 'Bd. carol 10', 3, 'medic veterinar');


-- sediul 4
insert into angajati values (seq_angajati.nextval, 'Mocanu', 'Vlad', to_date('14/02/1990', 'dd/mm/yyyy'), to_date('15/03/2018', 'dd/mm/yyyy'), 5400, '0722334455', 'Str. motilor 20', 4, 'notar');
insert into angajati values (seq_angajati.nextval, 'Albu', 'Diana', to_date('20/10/1995', 'dd/mm/yyyy'), to_date('01/06/2021', 'dd/mm/yyyy'), 3200, '0733445566', 'Calea turzii 55', 4, 'ingrijitor');
insert into angajati values (seq_angajati.nextval, 'Popa', 'Victor', to_date('30/01/1980', 'dd/mm/yyyy'), to_date('20/05/2012', 'dd/mm/yyyy'), 6800, '0766778899', 'Str. horea 3', 4, 'medic veterinar');


-- sediul 5
insert into angajati values (seq_angajati.nextval, 'Costea', 'Sorin', to_date('11/11/1983', 'dd/mm/yyyy'), to_date('12/12/2014', 'dd/mm/yyyy'), 5600, '0788990011', 'Bd. eroilor 9', 5, 'notar');
insert into angajati values (seq_angajati.nextval, 'Dima', 'Alina', to_date('08/03/1992', 'dd/mm/yyyy'), to_date('15/08/2019', 'dd/mm/yyyy'), 3600, '0799001122', 'Str. lipovei 40', 5, 'ingrijitor');
insert into angajati values (seq_angajati.nextval, 'Enache', 'Paul', to_date('01/01/1987', 'dd/mm/yyyy'), to_date('01/04/2017', 'dd/mm/yyyy'), 6300, '0722112233', 'Calea aradului 12', 5, 'medic veterinar');


-- sediul 6
insert into angajati values (seq_angajati.nextval, 'Toma', 'George', to_date('15/06/1994', 'dd/mm/yyyy'), to_date('01/09/2022', 'dd/mm/yyyy'), 5200, '0755667788', 'Str. lunga 100', 6, 'notar');
insert into angajati values (seq_angajati.nextval, 'Lupu', 'Carmen', to_date('23/09/1999', 'dd/mm/yyyy'), to_date('10/10/2023', 'dd/mm/yyyy'), 3100, '0744556677', 'Str. republicii 5', 6, 'ingrijitor');






-- tabela ingrijitori
insert into ingrijitori values (102, 'avansat');
insert into ingrijitori values (103, 'incepator');
insert into ingrijitori values (104, 'mediu');
insert into ingrijitori values (107, 'avansat');
insert into ingrijitori values (110, 'incepator');
insert into ingrijitori values (113, 'mediu');
insert into ingrijitori values (116, 'avansat');


-- tabela medici_veterinari
insert into medici_veterinari values (101, 'mv-b-101');
insert into medici_veterinari values (105, 'mv-b-205');
insert into medici_veterinari values (108, 'mv-is-308');
insert into medici_veterinari values (111, 'mv-cj-411');
insert into medici_veterinari values (114, 'mv-tm-514');


-- tabela notari
insert into notari values (100, 'nt-b-100');
insert into notari values (106, 'nt-is-106');
insert into notari values (109, 'nt-cj-409');
insert into notari values (112, 'nt-tm-512');
insert into notari values (115, 'nt-bv-615');


-- tabela custi
insert into custi values (seq_custi.nextval, 'L', 1);
insert into custi values (seq_custi.nextval, 'S', 1);
insert into custi values (seq_custi.nextval, 'M', 1);
insert into custi values (seq_custi.nextval, 'L', 2);
insert into custi values (seq_custi.nextval, 'M', 2);
insert into custi values (seq_custi.nextval, 'S', 3);
insert into custi values (seq_custi.nextval, 'M', 4);
insert into custi values (seq_custi.nextval, 'L', 5);
insert into custi values (seq_custi.nextval, 'S', 6);
insert into custi values (seq_custi.nextval, 'M', 6);




-- tabela animale
insert into animale values (seq_animale.nextval, 'Max', to_date('20/02/2020', 'dd/mm/yyyy'), 'caine', 'mare');
insert into animale values (seq_animale.nextval, 'Miti', to_date('03/08/2021', 'dd/mm/yyyy'), 'pisica', 'mic');
insert into animale values (seq_animale.nextval, 'Rex', to_date('12/05/2022', 'dd/mm/yyyy'), 'caine', 'mediu');
insert into animale values (seq_animale.nextval, 'Azor', to_date('01/01/2019', 'dd/mm/yyyy'), 'caine', 'mare');
insert into animale values (seq_animale.nextval, 'Luna', to_date('10/10/2023', 'dd/mm/yyyy'), 'pisica', 'mic');
insert into animale values (seq_animale.nextval, 'Bruno', to_date('05/05/2021', 'dd/mm/yyyy'), 'caine', 'mic');
insert into animale values (seq_animale.nextval, 'Sasha', to_date('15/09/2022', 'dd/mm/yyyy'), 'caine', 'mediu');
insert into animale values (seq_animale.nextval, 'Pufi', to_date('20/12/2023', 'dd/mm/yyyy'), 'pisica', 'mic');
insert into animale values (seq_animale.nextval, 'Thor', to_date('01/04/2018', 'dd/mm/yyyy'), 'caine', 'mare');
insert into animale values (seq_animale.nextval, 'Bella', to_date('14/02/2020', 'dd/mm/yyyy'), 'caine', 'mediu');


-- tabela proceduri
insert into proceduri values (seq_proceduri.nextval, 'control general');
insert into proceduri values (seq_proceduri.nextval, 'vaccinare');
insert into proceduri values (seq_proceduri.nextval, 'deparazitare');
insert into proceduri values (seq_proceduri.nextval, 'interventie chirurgicala');
insert into proceduri values (seq_proceduri.nextval, 'tratament otita');
insert into proceduri values (seq_proceduri.nextval, 'toaletare');


-- tabela diagnostice
insert into diagnostice values (seq_diagnostice.nextval, 'sanatos');
insert into diagnostice values (seq_diagnostice.nextval, 'paraziti intestinali');
insert into diagnostice values (seq_diagnostice.nextval, 'dermatita');
insert into diagnostice values (seq_diagnostice.nextval, 'otita');
insert into diagnostice values (seq_diagnostice.nextval, 'fractura');
insert into diagnostice values (seq_diagnostice.nextval, 'infectie');


-- tabela medicamente
insert into medicamente values (seq_medicamente.nextval, 'albendazol');
insert into medicamente values (seq_medicamente.nextval, 'otipax');
insert into medicamente values (seq_medicamente.nextval, 'antibiotic');
insert into medicamente values (seq_medicamente.nextval, 'vitamine');
insert into medicamente values (seq_medicamente.nextval, 'vaccin antirabic');
insert into medicamente values (seq_medicamente.nextval, 'antiinflamator');


-- tabela clienti
insert into clienti values (seq_clienti.nextval, 'Vasile', 'Dan', '0747385517', 'Bucuresti, Calea Victoriei 14', 'DA');
insert into clienti values (seq_clienti.nextval, 'Ionescu', 'Mihai', '0742345352', 'Iasi, Bd. Independentei 33', 'NU');
insert into clienti values (seq_clienti.nextval, 'Popa', 'Elena', '0722000111', 'Bucuresti, str. Izvor 2', 'DA');
insert into clienti values (seq_clienti.nextval, 'Stan', 'Alexandru', '0733000222', 'Cluj, str. Horea 5', 'NU');
insert into clienti values (seq_clienti.nextval, 'Dobre', 'Ioana', '0744000333', 'Timisoara, Pta. Victoriei 1', 'DA');
insert into clienti values (seq_clienti.nextval, 'Barbu', 'Cristina', '0755998800', 'Brasov, Str. Lunga 15', 'DA');


-- tabela reviste
insert into reviste values (seq_reviste.nextval, to_date('01/01/2024', 'dd/mm/yyyy'));
insert into reviste values (seq_reviste.nextval, to_date('01/02/2024', 'dd/mm/yyyy'));
insert into reviste values (seq_reviste.nextval, to_date('01/03/2024', 'dd/mm/yyyy'));
insert into reviste values (seq_reviste.nextval, to_date('01/04/2024', 'dd/mm/yyyy'));
insert into reviste values (seq_reviste.nextval, to_date('01/05/2024', 'dd/mm/yyyy'));
insert into reviste values (seq_reviste.nextval, to_date('01/06/2024', 'dd/mm/yyyy'));




-- tabela istoric_custi
insert into istoric_custi values (200, 1, 102, to_date('01/03/2023', 'dd/mm/yyyy'), to_date('01/06/2023', 'dd/mm/yyyy'));
insert into istoric_custi values (201, 2, 103, to_date('05/03/2023', 'dd/mm/yyyy'), null);
insert into istoric_custi values (202, 4, 104, to_date('10/06/2023', 'dd/mm/yyyy'), null);
insert into istoric_custi values (204, 3, 102, to_date('01/11/2023', 'dd/mm/yyyy'), to_date('01/12/2023', 'dd/mm/yyyy'));
insert into istoric_custi values (203, 1, 102, to_date('02/01/2023', 'dd/mm/yyyy'), to_date('28/02/2023', 'dd/mm/yyyy'));
insert into istoric_custi values (205, 9, 116, to_date('01/06/2023', 'dd/mm/yyyy'), null);
insert into istoric_custi values (206, 6, 107, to_date('20/09/2022', 'dd/mm/yyyy'), null);
insert into istoric_custi values (207, 7, 110, to_date('22/12/2023', 'dd/mm/yyyy'), null);
insert into istoric_custi values (208, 10, 116, to_date('01/01/2019', 'dd/mm/yyyy'), to_date('01/04/2019', 'dd/mm/yyyy'));
insert into istoric_custi values (209, 5, 104, to_date('15/02/2020', 'dd/mm/yyyy'), null);




-- tabela istoric_adoptii
insert into istoric_adoptii values (100, 204, 100, to_date('02/12/2023', 'dd/mm/yyyy'));
insert into istoric_adoptii values (101, 200, 100, to_date('10/06/2023', 'dd/mm/yyyy'));
insert into istoric_adoptii values (102, 203, 106, to_date('01/03/2023', 'dd/mm/yyyy'));
insert into istoric_adoptii values (103, 208, 112, to_date('10/04/2019', 'dd/mm/yyyy'));
insert into istoric_adoptii values (104, 201, 100, to_date('01/01/2025', 'dd/mm/yyyy'));
insert into istoric_adoptii values (105, 205, 115, to_date('01/08/2023', 'dd/mm/yyyy'));
insert into istoric_adoptii values (100, 206, 106, to_date('01/01/2024', 'dd/mm/yyyy'));
insert into istoric_adoptii values (101, 207, 109, to_date('15/01/2024', 'dd/mm/yyyy'));
insert into istoric_adoptii values (102, 209, 100, to_date('10/03/2024', 'dd/mm/yyyy'));
insert into istoric_adoptii values (103, 202, 100, to_date('15/07/2023', 'dd/mm/yyyy'));




-- tabela istoric_medical
insert into istoric_medical values (201, 101, 3, to_date('10/03/2023', 'dd/mm/yyyy'));
insert into istoric_medical values (202, 105, 5, to_date('15/06/2023', 'dd/mm/yyyy'));
insert into istoric_medical values (202, 105, 1, to_date('15/06/2023', 'dd/mm/yyyy'));
insert into istoric_medical values (204, 101, 2, to_date('15/11/2023', 'dd/mm/yyyy'));
insert into istoric_medical values (200, 101, 2, to_date('21/02/2023', 'dd/mm/yyyy'));
insert into istoric_medical values (200, 101, 3, to_date('20/03/2023', 'dd/mm/yyyy'));
insert into istoric_medical values (203, 101, 1, to_date('02/01/2023', 'dd/mm/yyyy'));
insert into istoric_medical values (203, 105, 4, to_date('05/01/2023', 'dd/mm/yyyy'));
insert into istoric_medical values (205, 108, 1, to_date('15/05/2023', 'dd/mm/yyyy'));
insert into istoric_medical values (202, 105, 2, to_date('16/06/2023', 'dd/mm/yyyy'));
insert into istoric_medical values (209, 105, 6, to_date('15/02/2020', 'dd/mm/yyyy'));




-- tabela istoric_diagnostice
insert into istoric_diagnostice values (201, 101, 3, to_date('10/03/2023', 'dd/mm/yyyy'), 2);
insert into istoric_diagnostice values (202, 105, 5, to_date('15/06/2023', 'dd/mm/yyyy'), 4);
insert into istoric_diagnostice values (204, 101, 2, to_date('15/11/2023', 'dd/mm/yyyy'), 1);
insert into istoric_diagnostice values (200, 101, 2, to_date('21/02/2023', 'dd/mm/yyyy'), 1);
insert into istoric_diagnostice values (200, 101, 3, to_date('20/03/2023', 'dd/mm/yyyy'), 2);
insert into istoric_diagnostice values (200, 101, 3, to_date('20/03/2023', 'dd/mm/yyyy'), 4);
insert into istoric_diagnostice values (203, 101, 1, to_date('02/01/2023', 'dd/mm/yyyy'), 5);
insert into istoric_diagnostice values (203, 105, 4, to_date('05/01/2023', 'dd/mm/yyyy'), 5);
insert into istoric_diagnostice values (205, 108, 1, to_date('15/05/2023', 'dd/mm/yyyy'), 1);
insert into istoric_diagnostice values (202, 105, 2, to_date('16/06/2023', 'dd/mm/yyyy'), 1);
insert into istoric_diagnostice values (209, 105, 6, to_date('15/02/2020', 'dd/mm/yyyy'), 1);


-- tabela retete
insert into retete values (201, 101, 3, to_date('10/03/2023', 'dd/mm/yyyy'), 1);
insert into retete values (202, 105, 5, to_date('15/06/2023', 'dd/mm/yyyy'), 2);
insert into retete values (204, 101, 2, to_date('15/11/2023', 'dd/mm/yyyy'), 5);
insert into retete values (200, 101, 2, to_date('21/02/2023', 'dd/mm/yyyy'), 5);
insert into retete values (200, 101, 3, to_date('20/03/2023', 'dd/mm/yyyy'), 1);
insert into retete values (203, 101, 1, to_date('02/01/2023', 'dd/mm/yyyy'), 3);
insert into retete values (203, 105, 4, to_date('05/01/2023', 'dd/mm/yyyy'), 3);
insert into retete values (203, 105, 4, to_date('05/01/2023', 'dd/mm/yyyy'), 6);
insert into retete values (205, 108, 1, to_date('15/05/2023', 'dd/mm/yyyy'), 4);
insert into retete values (202, 105, 2, to_date('16/06/2023', 'dd/mm/yyyy'), 5);


-- tabela istoric_aparitii
insert into istoric_aparitii values (1, 201);
insert into istoric_aparitii values (1, 204);
insert into istoric_aparitii values (2, 200);
insert into istoric_aparitii values (2, 205);
insert into istoric_aparitii values (3, 207);
insert into istoric_aparitii values (3, 209);
insert into istoric_aparitii values (4, 201);
insert into istoric_aparitii values (5, 206);
insert into istoric_aparitii values (6, 202);
insert into istoric_aparitii values (6, 205);


-- tabela istoric_reviste
insert into istoric_reviste values (1, 100);
insert into istoric_reviste values (1, 102);
insert into istoric_reviste values (1, 104);
insert into istoric_reviste values (1, 105);
insert into istoric_reviste values (2, 100);
insert into istoric_reviste values (2, 102);
insert into istoric_reviste values (3, 100);
insert into istoric_reviste values (4, 102);
insert into istoric_reviste values (5, 105);
insert into istoric_reviste values (6, 100);


-- ex 5
--===========================================================================




-- ex 6
--===========================================================================
create or replace procedure analiza_activitate_sediu(p_numar_sediu number)
is
    -- record pentru informatiile de care avem nevoie despre fiecare ingrijitor
    type r_info_angajat is record( cod_angajat number,
                                   nume_complet varchar2(101),
                                   nivel varchar2(15));
                                   
    -- tablou imbricat in care vom retine lista de ingrijitori
    type t_lista_ingrijitori is table of r_info_angajat;
    v_ingrijitori t_lista_ingrijitori := t_lista_ingrijitori();
    
    -- vector pentru numerele ultimelor 3 custi de care s-a ocupat cate un ingrijitor 
    type t_istoric_custi is varray(3) of number;
    v_custi t_istoric_custi := t_istoric_custi();
    
    -- tablou indexat de statistica
    type t_statistica is table of number index by varchar2(15);
    v_statistica t_statistica;
    v_index varchar2(15);
    
    v_sediu number;
    v_nume_sediu varchar2(50);
    
    e_nr_sediu exception;
    e_nr_ingrijitori exception;


begin
    -- verificam daca exista un sediu cu numarul dat ca parametru
    select count(*)
    into v_sediu
    from sedii
    where numar_sediu = p_numar_sediu;
    
    if v_sediu = 0 then
        raise e_nr_sediu;
    end if;
    
    -- preluam numarul sediului si numele orasului pentru raport
    select 'Sediu ' || s.numar_sediu || ' - ' || o.nume_oras
    into v_nume_sediu
    from sedii s
    inner join orase o on s.cod_oras = o.cod_oras
    where s.numar_sediu = p_numar_sediu;
    
    dbms_output.put_line('Raport activitate: ' || v_nume_sediu);
    dbms_output.new_line;
    
    -- populam tabloul cu ingrijitorii din sediul cu numarul dat ca parametru
    select a.cod_angajat, a.nume || ' ' || a.prenume, i.nivel_experienta
    bulk collect into v_ingrijitori
    from angajati a
    inner join ingrijitori i on a.cod_angajat = i.cod_angajat
    where a.tip = 'ingrijitor' and a.numar_sediu = p_numar_sediu;
    
    -- exceptie pentru cand sediul nu are niciun ingrijitor
    if v_ingrijitori.count = 0 then
        raise e_nr_ingrijitori;
    end if;
    
    dbms_output.put_line('Lista angajati:');
    
    for i in v_ingrijitori.first..v_ingrijitori.last loop
        dbms_output.put_line( i || '. ' || v_ingrijitori(i).nume_complet || ' [Nivel: ' || v_ingrijitori(i).nivel || ']');
        
        -- adaugam date pentru statistica din tabloul indexat
        if v_statistica.exists(v_ingrijitori(i).nivel) then
            v_statistica(v_ingrijitori(i).nivel) := v_statistica(v_ingrijitori(i).nivel) + 1;
        else
            v_statistica(v_ingrijitori(i).nivel) := 1;
        end if;
        
        -- populam vectorul cu ultimele 3 custi de care s-a ocupat ingrijitorul i
        v_custi := t_istoric_custi();
        for r_cusca in ( select numar_cusca
                         from istoric_custi
                         where cod_angajat = v_ingrijitori(i).cod_angajat
                         order by data_incepere desc
                         fetch first 3 rows only) loop
            v_custi.extend;
            v_custi(v_custi.last) := r_cusca.numar_cusca;
        end loop;
        
        -- afisare vector istoric custi
        if v_custi.count > 0 then
            dbms_output.put('-> Ultimele custi alocate: ');
            for j in 1..v_custi.count loop
                dbms_output.put(v_custi(j) || ' ');
            end loop;
            dbms_output.new_line;
        else
            dbms_output.put_line('-> Fara istoric custi.');
        end if;
            dbms_output.put_line('----------------------------------------');
    end loop;
    
    dbms_output.new_line;
    
    dbms_output.put_line('Statistica nivel experienta:');
    v_index := v_statistica.first;
    while v_index is not null loop
        dbms_output.put_line(' * ' || v_index || ': ' || v_statistica(v_index) || ' angajati');
        v_index := v_statistica.next(v_index);
    end loop;
        
exception
    when e_nr_sediu then
        dbms_output.put_line('Eroare: Nu exista niciun sediu cu numarul ' || p_numar_sediu);
    when e_nr_ingrijitori then
        dbms_output.put_line('Eroare: Nu exista niciun ingrijitor in sediul ' || p_numar_sediu);
    when others then
        dbms_output.put_line('Eroare neprevazuta: ' || sqlcode || ' - ' || sqlerrm);
end;
/


-- apelare
begin
    -- test fara nicio eroare
    dbms_output.put_line('Test 1: nicio eroare');
    analiza_activitate_sediu(1);
    
    dbms_output.new_line;
    
    -- test cu parametru gresit
    dbms_output.put_line('Test 2: parametru gresit');
    analiza_activitate_sediu(10);
    
    dbms_output.new_line;
    
    -- test cu un sediu fara ingrijitori
    dbms_output.put_line('Test 3: sediu fara ingrijitori');
    analiza_activitate_sediu(7);
    
    dbms_output.new_line;
    
    -- test cu ingrijitori fara istoric custi
    dbms_output.put_line('Test 4: ingrijitori fara istoric custi');
    analiza_activitate_sediu(5);
end;
/
-- ex 6
--===========================================================================




-- ex 7
--===========================================================================
create or replace procedure raport_medical(p_tip_raport varchar2)
is
    -- cursor dinamic pentru selectarea animalelor in functie de parametrul procedurii
    type t_animale is ref cursor;
    v_animale t_animale;
    
    v_cip animale.cod_cip%type;
    v_nume animale.nume%type;
    v_tip animale.tip%type;
    
    -- cursor parametrizat pentru extragerea detaliilor medicale in functie de codul cip al unui animal
    cursor c_istoric (p_cod_cip number) is
        select p.nume_procedura, im.data_ef, a.nume || ' ' || a.prenume as medic 
        from istoric_medical im
        inner join proceduri p on im.cod_procedura = p.cod_procedura
        inner join angajati a on im.cod_angajat = a.cod_angajat
        where im.cod_cip = p_cod_cip
        order by im.data_ef desc;
    
    v_nume_procedura proceduri.nume_procedura%type;
    v_data date;
    v_medic varchar2(101);
    
    e_parametru exception;
    
begin
    dbms_output.put_line('Generare raport tip: ' || upper(p_tip_raport));
    dbms_output.new_line;
    
    -- definire cursor dinamic -> pentru fiecare tip de raport
    if upper(p_tip_raport) = 'URGENTE' then
        open v_animale for
            select cod_cip, nume, tip
            from animale
            where grad_risc = 'mare';
            
    elsif upper(p_tip_raport) = 'JUNIORI' then
        open v_animale for
            select cod_cip, nume, tip
            from animale
            where extract(year from data_nastere) >= 2022;
    
    elsif upper(p_tip_raport) = 'EXTINS' then
        open v_animale for
            select cod_cip, nume, tip
            from animale;
    else
        raise e_parametru;
    end if;
    
    -- parcugere cursor dinamic
    loop
        fetch v_animale into v_cip, v_nume, v_tip;
        exit when v_animale%notfound;
        
        dbms_output.put_line('PACIENT: ' || v_nume || ' (CIP: ' || v_cip || ') -> ' || v_tip);
        
        -- parcurgere cursor parametrizat
        open c_istoric(v_cip);
        loop
            fetch c_istoric into v_nume_procedura, v_data, v_medic;
            exit when c_istoric%notfound;
            
            dbms_output.put_line('    -> ' || to_char(v_data, 'DD.MM.YY') || ': ' || 
                                 v_nume_procedura || ' (Dr. ' || v_medic || ')');
        end loop;
        
        -- daca animalul respectiv nu are nicio aparitie in istoric medical afisam un mesaj
        if c_istoric%rowcount = 0 then
            dbms_output.put_line('    -> Nu exista istoric medical.');
        end if;
        
        close c_istoric;
        dbms_output.put_line('---------------------------------------------');
    end loop;
    close v_animale;
    
exception
    when e_parametru then
        if v_animale%isopen then
            close v_animale;
        end if;
        dbms_output.put_line('Parametrul ' || p_tip_raport || ' este invalid.'); 
        dbms_output.put_line('Introduceti una din variantele "URGENTE", "JUNIORI", "EXTINS".');
    when others then
        if v_animale%isopen then
            close v_animale;
        end if;
        
        if c_istoric%isopen then
            close c_istoric;
        end if;
        
        dbms_output.put_line('Eroare neprevazuta: ' || sqlcode || ' - ' || sqlerrm);
end;
/


-- apelare
begin
    -- test URGENTE
    dbms_output.put_line('Test 1:');
    raport_medical('URGENTE');
    
    dbms_output.new_line;
    
    -- test JUNIORI
    dbms_output.put_line('Test 2:');
    raport_medical('JUNIORI');
    
    dbms_output.new_line;
    
    -- test EXTINS
    dbms_output.put_line('Test 3:');
    raport_medical('EXTINS');
    
    dbms_output.new_line;
    
    -- test eroare parametru
    dbms_output.put_line('Test 4:');
    raport_medical('altceva');
end;
/
-- ex 7
--===========================================================================






-- ex 8
--===========================================================================


-- definim tipul de date pe care il vom folosi pentru a returna datele din functie
create or replace type t_raport_medical as object 
    ( nume_animal varchar2(50),
      tip_animal varchar2(50),
      nume_medic varchar2(50),
      prenume_medic varchar2(50),
      numar_sediu number,
      nume_oras varchar2(50),
      nume_procedura varchar2(100));
      


create or replace function detalii_interventie(p_nume_animal varchar2, p_data_interventie date)
    return t_raport_medical
is
    v_rezultat t_raport_medical;
    v_animal number;
    
    e_nume_animal exception;
begin
    -- verificam daca exista un animal cu numele dat ca parametru
    select count(*)
    into v_animal
    from animale
    where lower(nume) = lower(p_nume_animal);
    
    if v_animal = 0 then
        raise e_nume_animal;
    end if;
    
    -- extragem datele
    select t_raport_medical(a.nume, a.tip, ang.nume, ang.prenume, s.numar_sediu, o.nume_oras, p.nume_procedura)
    into v_rezultat 
    from istoric_medical im
    inner join animale a on im.cod_cip = a.cod_cip
    inner join angajati ang on im.cod_angajat = ang.cod_angajat
    inner join sedii s on ang.numar_sediu = s.numar_sediu
    inner join orase o on s.cod_oras = o.cod_oras
    inner join proceduri p on im.cod_procedura = p.cod_procedura
    where lower(a.nume) = lower(p_nume_animal)
        and trunc(im.data_ef) = trunc(p_data_interventie);
        
    return v_rezultat;


exception
    when e_nume_animal then
        dbms_output.put_line('Eroare: Animalul ' || p_nume_animal || ' nu exista in baza de date.');
        return null;
    
    when no_data_found then
        dbms_output.put_line('Nu exista interventii inregistrate pentru ' || p_nume_animal || ' la data ' || to_char(p_data_interventie, 'dd.mm.yyyy') || '.');
        return null;
    
    when too_many_rows then
        dbms_output.put_line(p_nume_animal || ' are multiple proceduri efectuate la data ' || to_char(p_data_interventie, 'dd.mm.yyyy') || '.');
        return null;
        
    when others then
        dbms_output.put_line('Eroare neprevazuta: ' || sqlcode || ' - ' || sqlerrm);
        return null;
end;
/


-- apelare
declare
    v_rez t_raport_medical;
begin
    dbms_output.put_line('Test 1: nicio exceptie');
    v_rez := detalii_interventie('Rex', to_date('16/06/2023', 'dd.mm.yyyy'));
    
    if v_rez is not null then
        dbms_output.put_line('Pacient: ' || v_rez.nume_animal || ' - ' || v_rez.tip_animal);
        dbms_output.put_line('Medic: ' || v_rez.nume_medic || ' ' || v_rez.prenume_medic);
        dbms_output.put_line('Sediu: ' || v_rez.numar_sediu || ' - ' || v_rez.nume_oras);
        dbms_output.put_line('Pacient: ' || v_rez.nume_procedura);
    end if;
    dbms_output.new_line;


    
    dbms_output.put_line('Test 2: animal inexistent'); 
    v_rez := detalii_interventie('Stefan', to_date('16/06/2023', 'dd.mm.yyyy'));
    dbms_output.new_line;
    
    dbms_output.put_line('Test 4: fara interventii medicale');
    v_rez := detalii_interventie('Bella', to_date('16/06/2023', 'dd.mm.yyyy'));
    dbms_output.new_line;
    
    dbms_output.put_line('Test 5: mai multe proceduri'); 
    v_rez := detalii_interventie('Rex', to_date('15/06/2023', 'dd/mm/yyyy'));
end;
/
-- ex 8
--===========================================================================




-- ex 9
--===========================================================================
create or replace procedure bonus_ingrijitori(p_oras in varchar2 := 'Bucuresti', p_procent in number, p_nr_modificari out number)
is
    v_oras number;
    v_ang number;
    v_sal_max constant number := 5000;
    
    e_oras exception;
    e_procent exception;
    e_ingrijitori exception;
    e_salariu exception;
    
begin
    -- initializare parametru de iesire in caz ca apare o exceptie pe parcurs
    p_nr_modificari := 0;


    -- verificam daca exista orasul dat prin parametru
    select count(*)
    into v_oras
    from orase
    where lower(nume_oras) = lower(p_oras);
    
    if v_oras = 0 then
        raise e_oras;
    end if;
    
    -- verificam daca procentul este pozitiv
    if p_procent <= 0 then
        raise e_procent;
    end if;
    
    -- verificam daca sunt angajati cu salariu mai mare de v_sal_max
    select count(*)
    into v_ang
    from angajati a
    inner join sedii s on a.numar_sediu = s.numar_sediu
    inner join orase o on s.cod_oras = o.cod_oras
    where lower(o.nume_oras) = lower(p_oras)
        and a.tip = 'ingrijitor'
        and a.salariu > v_sal_max;
        
    if v_ang > 0 then
        raise e_salariu;
    end if;
        
    
    -- actualizam salariile ingrijitorilor ce s-au ocupat de animale cu grad mare de risc
    update angajati
    set salariu = salariu * (100 + p_procent) / 100
    where cod_angajat in
        ( select i.cod_angajat
          from ingrijitori i
          inner join angajati a on i.cod_angajat = a.cod_angajat
          inner join sedii s on a.numar_sediu = s.numar_sediu
          inner join orase o on s.cod_oras = o.cod_oras
          inner join istoric_custi ic on i.cod_angajat = ic.cod_angajat
          inner join animale an on ic.cod_cip = an.cod_cip
          where lower(o.nume_oras) = lower(p_oras)
            and an.grad_risc = 'mare');
    
    p_nr_modificari := sql%rowcount;
    
    -- daca nu a fost modificat niciun rand inseamna ca nu avem niciun ingrijitor ce respecta conditiile
    if p_nr_modificari = 0 then
        raise e_ingrijitori;
    end if;
    
exception
    when e_oras then
        dbms_output.put_line('Eroare: Nu exista niciun sediu in orasul ' || p_oras);
    
    when e_procent then
        dbms_output.put_line('Eroare: Procentul trebuie sa fie > 0');
        
    when e_ingrijitori then
        dbms_output.put_line('Niciun ingrijitor din ' || p_oras || ' nu s-a ocupat de animale cu grad mare de risc.');
    
    when e_salariu then
        dbms_output.put_line('In ' || p_oras || ' exista angajati cu salarii foarte mari. Marirea a fost anulata pentru a nu depasi bugetul.');
    
    when others then 
        dbms_output.put_line('Eroare neprevazuta: ' || sqlcode || ' - ' || sqlerrm);
end;
/
        
    
-- apelare
declare
    v_rez number;
begin
    -- test 1: nicio exceptie
    dbms_output.put_line('Test 1: nicio exceptie');
    bonus_ingrijitori('Bucuresti', 10, v_rez);
    dbms_output.put_line('Au fost actualizate ' || v_rez || ' salarii');
    dbms_output.new_line;
    
    -- test 2: exceptie oras
    dbms_output.put_line('Test 2: exceptie oras');
    bonus_ingrijitori('Vaslui', 12, v_rez);
    dbms_output.put_line('Au fost actualizate ' || v_rez || ' salarii');
    dbms_output.new_line;
    
    -- test 3: exceptie procent
    dbms_output.put_line('Test 3: exceptie procent');
    bonus_ingrijitori('Brasov', -2, v_rez);
    dbms_output.put_line('Au fost actualizate ' || v_rez || ' salarii');
    dbms_output.new_line;
    
    -- test 4: niciun update
    dbms_output.put_line('Test 4: niciun ingrijitor nu s-a ocupat de animale cu grad mare de risc');
    bonus_ingrijitori('Iasi', 15, v_rez);
    dbms_output.put_line('Au fost actualizate ' || v_rez || ' salarii');
    dbms_output.new_line;
    
    -- test 5: salarii deja mari
    dbms_output.put_line('Test 5: salariile angajatilor din orasul respectiv sunt deja mari');
    -- modificam salariile ca sa evidentiam exceptia
    update angajati set salariu = 6000
    where numar_sediu = 1;
    bonus_ingrijitori(p_procent => 10, p_nr_modificari => v_rez);
    dbms_output.put_line('Au fost actualizate ' || v_rez || ' salarii');
    
    rollback;
end;
/
-- ex 9
--===========================================================================






-- ex 10
--===========================================================================
-- secventa pentru pk ul datelor din tabela de alerte manageriale
create sequence seq_alerte start with 1 increment by 1 nocache;
-- tabela cu alertele manageriale
create table alerte_manageriale (
    cod_alerta number primary key,
    data_alerta date,
    mesaj varchar2(300),
    user_emitent varchar2(50));
-- procedura ce insereaza datele in mod autonom in tabela de alerte    
create or replace procedure log_alerta_manageriala(p_mesaj varchar2)
is 
    pragma autonomous_transaction;
begin
    insert into alerte_manageriale values (seq_alerte.nextval, sysdate, p_mesaj, user);
    
    commit;
exception
    when others then
        rollback;
end;
/


-- functia care verifica procentul de custi ocupate
create or replace function calculare_procent_ocupare_custi
    return number
is
    v_total_custi number;
    v_custi_ocupate number;
    v_procent number;
begin
    -- calculam numarul total de custi  
    select count(c.numar_cusca)
    into v_total_custi
    from custi c;
    
    -- evitarea impartirii cu 0
    if v_total_custi = 0 then
        return 100;
    end if;
    
    -- calculam numarul de custi ocupate
    select count(*)
    into v_custi_ocupate
    from istoric_custi
    where data_finalizare is null;
    
    v_procent := (v_custi_ocupate / v_total_custi) * 100;
    
    return v_procent;
exception
    when others then
        return -1;
end;
/


create or replace trigger trg_capacitate_custi
    before insert on istoric_custi
declare
    v_procent_actual number;
    v_prag constant number := 10;
begin
    -- apelam functia ce calculeaza procentul de custi ocupate
    v_procent_actual := calculare_procent_ocupare_custi();
    
    -- verificam daca am depasit procentul
    if v_procent_actual > v_prag then 
        log_alerta_manageriala('Blocaj sistem: capacitatea custilor adapostului este depasita.');
        raise_application_error(-20001, 'Capacitatea custilor maxima a fost atinsa.');
    end if;
end;
/
        
-- declansare trigger
insert into istoric_custi
    (cod_cip, numar_cusca, cod_angajat, data_incepere) 
values (200, 1, 102, sysdate);
    
-- verificare tabel alerte
select * from alerte_manageriale;


-- ex 10
--===========================================================================




-- ex 11
--===========================================================================
-- trigger initial -> table mutating
create or replace trigger trg_medici_suprasolicitati
    before insert on istoric_medical
    for each row
declare 
    v_nr_proceduri number;
begin
    select count(*)
    into v_nr_proceduri
    from istoric_medical
    where cod_angajat = :new.cod_angajat
        and trunc(data_ef) = trunc(:new.data_ef);
        
    if v_nr_proceduri > 2 then
        raise_application_error(-20000, 'Eroare: Limita de proceduri depasita.');
    end if;
end;
/


-- declansare trigger
insert into istoric_medical (cod_cip, cod_angajat, cod_procedura, data_ef)
select 202,105, 2, to_date('15/06/2023', 'dd/mm/yyyy') from dual;




-- functia autonoma de numarare a interventiilor efectuate de un medic intr-o anumita zi
create or replace function nr_interventii_azi(p_medic number, p_data date)
    return number
is
    pragma autonomous_transaction;
    v_total number;
begin
    select count(*)
    into v_total
    from istoric_medical
    where cod_angajat = p_medic 
        and trunc(data_ef) = trunc(p_data);
        
    commit;
    return v_total;
exception
    when others then
        return 0;
end;
/


create or replace trigger trg_medici_suprasolicitati
    before insert on istoric_medical
    for each row
declare
    v_existente number;
    v_limita constant number := 2;
begin
    v_existente := nr_interventii_azi(:new.cod_angajat, :new.data_ef);
    
    if v_existente >= v_limita then
        log_alerta_manageriala('Blocaj sistem: Limita de proceduri ale acestui medic a fost depasita pentru data precizata.');
        raise_application_error(-20002, 'Eroare: Limita de proceduri ale acestui medic a fost depasita pentru data precizata.');
    end if;
end;
/
    
    
-- declansare trigger
insert into istoric_medical(cod_cip, cod_angajat, cod_procedura, data_ef)
    values (202,105,1,sysdate);
insert into istoric_medical(cod_cip, cod_angajat, cod_procedura, data_ef)
    values (202,105,2,sysdate);
commit;
insert into istoric_medical(cod_cip, cod_angajat, cod_procedura, data_ef)
    values (202,105,3,sysdate);


-- verificare tabel alerte
select * from alerte_manageriale;


-- ex 11
--===========================================================================




-- ex 12
--===========================================================================
-- secventa pentru pk ul datelor din tabela de audit
create sequence seq_modificari_schema start with 1 increment by 1 nocache;


-- tabela de audit care stocheaza istoricul tuturor modificarilor de structura 
create table modificari_schema
    ( cod_eveniment number primary key,
      user_db varchar2(50),
      eveniment_sistem varchar2(50),
      nume_obiect_afectat varchar2(50),
      data_executie timestamp);
      
create or replace trigger trg_protectie_schema
    before ddl on schema
declare
    v_eveniment varchar2(50);
    v_obiect varchar2(50);
    v_user varchar2(50);
begin
    -- extragem informatiile despre contextul executiei
    v_eveniment := sysevent;
    v_obiect := dictionary_obj_name;
    v_user := login_user;
    
    if v_eveniment = 'DROP' and upper(v_obiect) like 'ISTORIC_%' then
        log_alerta_manageriala('Alerta securitate: Utilizatorul ' || v_user || 
                               ' a incercat sa stearga o tabela de tip istoric ('
                               || v_obiect || ').');
        raise_application_error(-20003, 'Incercare stergere tabela de tip istoric -> interzis');
    end if;
    
    insert into modificari_schema values (seq_modificari_schema.nextval, v_user, v_eveniment, v_obiect, systimestamp);
end;
/
        
-- declansare trigger
drop table istoric_medical;




-- verificare tabel audit
create table test(id number)
select * from modificari_schema;


-- verificare tabel alerte
select * from alerte_manageriale;


-- ex 12
--===========================================================================








-- ex 13
--===========================================================================
create or replace package pachet_management as


    --------------- tipuri de date
    
    -- record pentru a retine o interventie
    type r_interventie is record
        (data_interventie date,
         procedura varchar2(100),
         lista_diagnostice varchar2(500),
         lista_medicamente varchar2(500));
    
    -- colectie pentru a retine toate interventiile
    type t_fisa_medicala is table of r_interventie;
    
    -- record cu datele unui animal si fisa sa medicala
    type r_animal is record
        (cod_cip animale.cod_cip%type,
         nume_animal animale.nume%type,
         numar_sediu sedii.numar_sediu%type,
         scor_adoptie number,
         fisa_medicala t_fisa_medicala);
         
    -- tabel indexat dupa codurile animalelor cu detaliile fiecaruia
    type t_evidenta_animale is table of r_animal index by binary_integer;
    
    -- cursor dinamic
    type t_cursor_dinamic is ref cursor;
    
    
    --------------- subprograme
    
    -- functia ce calculeaza scorul de adoptie
    function f_calcul_scor_adoptie(p_cod_cip number)
        return number;
    
    -- functia ce verifica daca sunt notari in sediul dat
    function f_verificare_notari_sediu(p_numar_sediu number)
        return number;
        
    -- functia ce verifica daca sunt notari in orasul dat
    function f_verificare_notari_oras(p_cod_oras number) 
        return number;
        
    -- functia care calculeaza procentul de ocupare al unui sediu
    function f_ocupare_sediu(p_numar_sediu number)
        return number;
        
    -- functia care obtine lista de diagnostice respectiv de medicamente
    function f_obtine_lista(p_tabela varchar2, p_cod_cip number, p_cod_angajat number, p_cod_procedura number, p_data date)
        return varchar2;
        
    -- functia care obtine codul unui oras dat
    function f_cod_oras(p_nume_oras varchar2)
        return number;
        
    -- functia care verifica daca animalul poate fi adaugat intr-o revista pentru promovare
    -- iar daca da -> il adauga 
    function f_verificare_locuri_revista(p_cod_cip number)
        return number;
        
    -- procedura care populeaza tabelele din pachet 
    procedure p_populare(p_cod_oras number, p_evidenta out t_evidenta_animale);
        
    -- procedura care afiseaza toate interventiile unui animal
    procedure p_afisare_fisa_medicala(p_fisa t_fisa_medicala);
        
    -- procedura care leaga toate subprogramele
    procedure p_executie_flux(p_nume_oras varchar2);
    
end pachet_management;
/


create or replace package body pachet_management 
as


    function f_calcul_scor_adoptie(p_cod_cip number)
        return number
    is
        v_scor_final number := 0;
        v_scor_medical number;
        v_scor_promovare number := 0;
        v_scor_risc number;
    begin
        -- extragem diagnosticele primite de un animal
        -- daca e altul decat 'sanatos' -> scorul medical ii scade cu 15 de puncte
        select nvl(sum(case when lower(d.denumire) = 'sanatos' then 0
                            else 15 end),0)
        into v_scor_medical
        from istoric_diagnostice id
        inner join diagnostice d on id.cod_diagnostic = d.cod_diagnostic
        where id.cod_cip = p_cod_cip;
        
        v_scor_medical := greatest((100 - v_scor_medical),0);
        
        -- extragem numarul de aparitii in reviste
        -- fiecare aparitie ii creste scorul de promovare cu 25 de puncte
        select count(*) 
        into v_scor_promovare
        from istoric_aparitii
        where cod_cip = p_cod_cip;
        
        v_scor_promovare := least(v_scor_promovare * 25, 100);
        
        -- calculam scorul de risc in functie de gradul de risc
        select decode(grad_risc, 
                        'mic', 100,
                        'mediu', 60,
                        'mare', 10)
        into v_scor_risc
        from animale
        where cod_cip = p_cod_cip;
        
        -- formula finala de calculare a scorului de adoptie
        -- 40% medical 30% promovare 30% risc
        v_scor_final := round((v_scor_medical * 0.4) + (v_scor_promovare * 0.3) + (v_scor_risc * 0.3),2);
        
        return v_scor_final;
    exception
        -- exceptie pentru cand codul animalului nu este in baza de date
        when no_data_found then
            return 0;
    end f_calcul_scor_adoptie;
      
    function f_verificare_notari_sediu(p_numar_sediu number)
        return number
    is
        v_cnt number;
    begin
        -- selectam numarul de notari din sediul dat
        select count(*)
        into v_cnt
        from angajati a
        inner join sedii s on a.numar_sediu = s.numar_sediu
        where s.numar_sediu = p_numar_sediu
            and lower(a.tip) = 'notar';
            
        if v_cnt > 0 then
            return 1;
        else 
            return 0;
        end if;
    end f_verificare_notari_sediu;


    function f_verificare_notari_oras(p_cod_oras number)
        return number 
    is
        v_cnt number;
    begin
        -- selectam numarul de notari din orasul dat
        select count(*)
        into v_cnt
        from angajati a
        inner join sedii s on a.numar_sediu = s.numar_sediu
        where s.cod_oras = p_cod_oras
            and a.tip = 'notar';
            
        if v_cnt > 0 then
            return 1;
        else 
            return 0;
        end if;
    end f_verificare_notari_oras;
    
    function f_ocupare_sediu(p_numar_sediu number)
        return number
    is
        v_total_custi number;
        v_custi_ocupate number;
        v_procent number;
    begin
        -- selectam numarul total de custi dintr-un sediu
        select count(*)
        into v_total_custi
        from custi
        where numar_sediu = p_numar_sediu;
        
        -- selectam numarul de custi in care inca se afla animale
        select count(*)
        into v_custi_ocupate
        from istoric_custi ic
        inner join custi c on ic.numar_cusca = c.numar_cusca
        where c.numar_sediu = p_numar_sediu
            and ic.data_finalizare is null;
            
        if v_total_custi = 0 then
            v_procent := 100;
        else
            v_procent := round((v_custi_ocupate/v_total_custi)*100,2);
        end if;
        
        return v_procent;
        
    end f_ocupare_sediu;
    
    function f_obtine_lista(p_tabela varchar2, p_cod_cip number, p_cod_angajat number, p_cod_procedura number, p_data date)
        return varchar2
    is
        v_cursor t_cursor_dinamic;
        v_sql varchar2(1000);
        v_element varchar2(100);
        v_lista varchar2(2000) := '';
        v_nume_tabela varchar2(50);
        v_nume_coloana varchar2(50);
    
    begin
        -- setam variabilele pentru sql-ul dinamic in functie de parametrul primit
        if lower(p_tabela) = 'istoric_diagnostice' then
            v_nume_tabela := 'diagnostice';
            v_nume_coloana := 'cod_diagnostic';
        elsif (lower(p_tabela)) = 'retete' then
            v_nume_tabela := 'medicamente';
            v_nume_coloana := 'cod_medicament';
        end if;
        
        -- definim sql-ul dinamic
        v_sql := 'select t.denumire ' ||
                 ' from ' || v_nume_tabela || ' t ' ||
                 ' inner join ' || p_tabela || ' p on t.' || v_nume_coloana || ' = p.' || v_nume_coloana ||
                 ' where p.cod_cip = :1 ' ||
                        'and p.cod_angajat = :2 ' ||
                        'and p.cod_procedura = :3 ' ||
                        'and trunc(p.data_ef) = trunc(:4)';
                        
        open v_cursor 
            for v_sql 
                using p_cod_cip, p_cod_angajat, p_cod_procedura, p_data;
                loop
                    -- punem toate elementele (diagnostice sau medicamente) gasite intr-un sir
                    fetch v_cursor into v_element;
                    exit when v_cursor%notfound;
                    
                    -- adaugam elementul in sir si punem virgula daca nu e primul
                    if v_lista is null then
                        v_lista := v_element;
                    else
                        v_lista := v_lista || ', ' || v_element;
                    end if;
                end loop;
        close v_cursor;
        
        if v_lista is null then
            v_lista := 'fara inregistrari';
        end if;
        
        return v_lista;


    end f_obtine_lista;
              
    procedure p_populare(p_cod_oras number, p_evidenta out t_evidenta_animale)
    is
        -- cursor imbricat cu toate animalele din orasul dat si datele sale medicale 
        cursor c_animale_oras is
            select a.cod_cip, a.nume, c.numar_sediu,
                   cursor(select im.data_ef, im.cod_procedura, p.nume_procedura, im.cod_angajat
                          from istoric_medical im
                          inner join proceduri p on im.cod_procedura = p.cod_procedura
                          where im.cod_cip = a.cod_cip) as cursor_fisa
            from animale a
            inner join istoric_custi ic on a.cod_cip = ic.cod_cip
            inner join custi c on ic.numar_cusca = c.numar_cusca
            inner join sedii s on c.numar_sediu = s.numar_sediu
            where s.cod_oras = p_cod_oras 
                and ic.data_finalizare is null;
                
        -- variabile pentru a extrage datele din primul cursor
        v_crs_cod_cip number;
        v_crs_nume animale.nume%type;
        v_crs_numar_sediu number;
        v_crs_fisa t_cursor_dinamic;
        
        -- variabile pentru a extrage datele din al doilea cursor
        v_intv_data date;
        v_intv_cod_p number;
        v_intv_nume_p varchar2(100);
        v_intv_cod_ang number;
        
        v_index number := 0;
        
    begin
        open c_animale_oras;
        loop
            fetch c_animale_oras into v_crs_cod_cip, v_crs_nume, v_crs_numar_sediu, v_crs_fisa;
            exit when c_animale_oras%notfound;
            
            
            -- populam tabelul indexat 
            p_evidenta(v_crs_cod_cip).cod_cip := v_crs_cod_cip;
            p_evidenta(v_crs_cod_cip).nume_animal := v_crs_nume;
            p_evidenta(v_crs_cod_cip).numar_sediu := v_crs_numar_sediu;
            p_evidenta(v_crs_cod_cip).scor_adoptie := f_calcul_scor_adoptie(v_crs_cod_cip);
            
            -- initializam colectia de interventii
            p_evidenta(v_crs_cod_cip).fisa_medicala := t_fisa_medicala();
            
            v_index := 0;
            loop
                fetch v_crs_fisa into v_intv_data, v_intv_cod_p, v_intv_nume_p, v_intv_cod_ang;
                exit when v_crs_fisa%notfound;
                
                v_index := v_index + 1;
                p_evidenta(v_crs_cod_cip).fisa_medicala.extend;
                
                p_evidenta(v_crs_cod_cip).fisa_medicala(v_index).data_interventie := v_intv_data;
                p_evidenta(v_crs_cod_cip).fisa_medicala(v_index).procedura := v_intv_nume_p;
                p_evidenta(v_crs_cod_cip).fisa_medicala(v_index).lista_diagnostice := 
                        f_obtine_lista('istoric_diagnostice', v_crs_cod_cip, v_intv_cod_ang, v_intv_cod_p, v_intv_data);
                p_evidenta(v_crs_cod_cip).fisa_medicala(v_index).lista_medicamente := 
                        f_obtine_lista('retete', v_crs_cod_cip, v_intv_cod_ang, v_intv_cod_p, v_intv_data);
            end loop;
            close v_crs_fisa;
        end loop;
        close c_animale_oras;
    end p_populare;
      
    function f_cod_oras(p_nume_oras varchar2)
        return number
    is
        v_cod_oras number;
    begin        
        -- selectam codul orasului dat 
        select cod_oras
        into v_cod_oras
        from orase
        where lower(nume_oras) = lower(p_nume_oras);
        
        return v_cod_oras;
    exception
        when no_data_found then
            return 0;
        
    end f_cod_oras;
    
    function f_verificare_locuri_revista(p_cod_cip number)
        return number
    is
        v_cnt number;
        v_numar_revista number;
        v_data_revista date;
    begin
        -- numaram cate reviste exista deja
        select count(*)
        into v_cnt
        from reviste;
        
        -- daca nu exista vreo revista cream una -> actualizand tabelele
        if v_cnt = 0 then
            v_numar_revista := seq_reviste.nextval;
            insert into reviste values(v_numar_revista, sysdate);
            insert into istoric_aparitii values(v_numar_revista, p_cod_cip);
        else
            -- selectam ultima revista
            select data_aparitie, numar
            into v_data_revista, v_numar_revista
            from reviste
            order by numar desc
            fetch first 1 rows only;
            
            -- verificam daca ultima revista a fost publicata in saptamana curenta
            if (to_char(sysdate, 'iyyy-iw') = to_char(v_data_revista,'iyyy-iw')) then
                select count(*)
                into v_cnt
                from istoric_aparitii 
                where numar = v_numar_revista;
                
                -- verificam daca in revista apar mai putin de 2 animale
                if v_cnt < 2 then
                    insert into istoric_aparitii values(v_numar_revista, p_cod_cip);
                else
                -- daca da -> animalul nu poate fi promovat
                    return -1;
                end if;
            else
            -- daca nu -> publicam o noua revista cu animalul dat pentru promovare
                v_numar_revista := seq_reviste.nextval;
                insert into reviste values (v_numar_revista,sysdate);
                insert into istoric_aparitii values(v_numar_revista, p_cod_cip);
            end if;
        end if;
        
        return v_numar_revista;
        
    end f_verificare_locuri_revista;
            
    procedure p_afisare_fisa_medicala(p_fisa t_fisa_medicala)
    is
    begin
        -- parcurgem fisa medicala -> toate interventiile si afisam datele
        for i in 1..p_fisa.count loop
            dbms_output.put_line('  1.' || p_fisa(i).data_interventie || ' | ' || p_fisa(i).procedura );
            dbms_output.put_line('    ' || ' - diagnostice: ' || p_fisa(i).lista_diagnostice);
            dbms_output.put_line('    ' || ' - medicamente: ' || p_fisa(i).lista_medicamente);
        end loop;
    end p_afisare_fisa_medicala;
    
    
    procedure p_executie_flux(p_nume_oras varchar2)
    is
        v_cod_oras number;
        v_date_animale t_evidenta_animale;
        v_index number;
        v_numar_revista number;
        v_grad_ocupare number;
        
        e_oras exception;
    begin
        dbms_output.put_line('--- Analiza orasulului: ' || p_nume_oras || ' ---');
        -- extragem codul orasului dat ca parametru
        v_cod_oras := f_cod_oras(p_nume_oras);
        
        if v_cod_oras = 0 then
            raise e_oras;
        end if;
        
        -- afisam sediile oraselor si gradul lor de ocupare
        dbms_output.put_line('Sediile orasului:');
        for s in
            ( select numar_sediu 
            from sedii
            where cod_oras = v_cod_oras) loop
            v_grad_ocupare := f_ocupare_sediu(s.numar_sediu);
            dbms_output.put_line('  sediul ' || s.numar_sediu || ' -> grad ocupare ' || v_grad_ocupare || '%');
            if v_grad_ocupare > 80 then
                dbms_output.put_Line('      -> sediu aproape plin. considerati transferul animalelor.');
            end if;
        end loop;
              


        -- populam tablourile create
        p_populare(v_cod_oras, v_date_animale);
        
        
        -- analiza pentru fiecare animal din oras
        dbms_output.put_line('Analiza animale:');
        v_index := v_date_animale.first;
        while v_index is not null loop
            dbms_output.put_line(v_date_animale(v_index).nume_animal || ' | scor adoptie: ' ||  v_date_animale(v_index).scor_adoptie);
            
            if v_date_animale(v_index).scor_adoptie > 75 then
                if f_verificare_notari_sediu(v_date_animale(v_index).numar_sediu) = 1 then
                    dbms_output.put_line('  -> gata sa fie adoptat (scor mare + notar disponibil in sediul sau)');
                elsif f_verificare_notari_oras(v_cod_oras) = 1 then
                    dbms_output.put_line('  -> scor mare, dar nu este niciun notar disponibil in SEDIUL sau');
                    dbms_output.put_line('      -> notar disponibil in oras, dar in alt sediu');
                else
                    dbms_output.put_line('  -> scor mare, dar nu este niciun notar disponibil in ORASUL sau');
                end if;
            else
                dbms_output.put_line('  -> scor mic de adoptie');
                dbms_output.put_line('      -> necesar control medical + promovare in revista');
                
                dbms_output.put_line('Fisa medicala:');
                if v_date_animale(v_index).fisa_medicala.count = 0 then
                    dbms_output.put_line('  -> nu exista istoric medical');
                else
                    p_afisare_fisa_medicala(v_date_animale(v_index).fisa_medicala);
                end if;
                
                dbms_output.put_line('Incercare promovare:');
                
                v_numar_revista := f_verificare_locuri_revista(v_date_animale(v_index).cod_cip);
                if v_numar_revista > -1 then
                    dbms_output.put_line('  -> a fost adaugat in revista ' || v_numar_revista);
                else 
                    dbms_output.put_line('  -> a fost publicata o revista saptamana aceasta. reincercati peste o saptamana.');
                end if;
            end if;
            
            v_index := v_date_animale.next(v_index);
            
        end loop;
    exception
        when e_oras then
            dbms_output.put_line('Orasul ' || p_nume_oras || ' nu exista in baza de date.');
        when others then
        dbms_output.put_line('Eroare neprevazuta: ' || sqlcode || ' - ' || sqlerrm);
        
    end p_executie_flux;
                    
end pachet_management;
/  


select *
from custi c
inner join sedii s on c.numar_sediu = s.numar_sediu
inner join orase o on s.cod_oras = o.cod_oras
where lower(o.nume_oras) = 'iasi';


begin
    pachet_management.p_executie_flux('Iasi');
end;
/


-- vizualizare actualizari reviste
select ia.numar, r.data_aparitie, ia.cod_cip, a.nume
from istoric_aparitii ia
inner join reviste r on ia.numar = r.numar
inner join animale a on ia.cod_cip = a.cod_cip
-- ex 13

--===========================================================================
