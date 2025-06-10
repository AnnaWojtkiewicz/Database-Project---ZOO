-- FUNCKJE DO PROJEKTU W BAZIE

--fukcja zamieniajaca wartosci wybrane w formularzu na te odpowiadjace im tak aby pasowaly do tabeli kasa np. email zamieniamy na id_odwiedzajacego

CREATE OR REPLACE FUNCTION kup_bilet(email TEXT, w_rodzaj TEXT, datek INTEGER, data DATE) RETURNS NUMERIC AS $$
DECLARE
    id_odw INTEGER; 
    id_rodz INTEGER; 
    czy_dat BOOLEAN; 
    _id_biletu INTEGER; 	
    cena NUMERIC(6,2);
	
BEGIN
    SELECT id_odwiedzajacego INTO id_odw 
        FROM odwiedzajacy
            WHERE e_mail = email; 

    SELECT id_rodzaju INTO id_rodz
        FROM rodzaje_biletow 
            WHERE rodzaj = w_rodzaj; 

     IF datek = 1 THEN 
        czy_dat := TRUE; 
    ELSE
        czy_dat := FALSE;
    END IF;

    INSERT INTO kasa(id_rodzaju, data_wejscia, czy_datek, id_odwiedzajacego) 
        VALUES (id_rodz, data, czy_dat, id_odw) 
        RETURNING id_biletu INTO _id_biletu; 
		
    SELECT cena_koncowa INTO cena 
        FROM kasa
            WHERE id_biletu = _id_biletu;

    RETURN cena; 
END;
$$ LANGUAGE 'plpgsql';


-- funkcja ktora kontroluje czy email wprowadzony przez uzytkownika jest w bazie czy tez nie, jednoczesnie obslugujac komunikat dla uzytkownika

CREATE OR REPLACE FUNCTION dodaj_konto(imie1 TEXT, nazwisko1 TEXT, mail1 TEXT) RETURNS TEXT AS $$

DECLARE
    wynik TEXT; 

BEGIN

    wynik = 'Konto z tym e-mailem juz istnieje'; 

    IF mail1 NOT IN (SELECT e_mail FROM odwiedzajacy) THEN
        wynik = 'Konto zostalo utworzone'; 
        INSERT INTO odwiedzajacy(imie, nazwisko, e_mail) 
            VALUES (imie1, nazwisko1, mail1);
    END IF;

    return wynik; 
END;
$$ LANGUAGE 'plpgsql';



-- funkcja zwracajaca nazwe areny, ktora nas interesuje
-- w aplikacji bedziemy jej uzywac, aby po wybraniu przez uzytkownika zwierzecia (argument funkcji ponizej) wyswietlac atrakcje ktore znajduja sie na tej samej arenie co to zwierze 

CREATE OR REPLACE FUNCTION wypisz_arene(gatunek1 TEXT) RETURNS TEXT AS $$

DECLARE
    wynik TEXT; 
BEGIN

    SELECT DISTINCT nazwa_areny INTO wynik 
                FROM zwierzeta
                    JOIN wybiegi USING(id_wybiegu)
                    JOIN areny USING (id_areny)
                WHERE gatunek = gatunek1; 

    return wynik; 
END;
$$ LANGUAGE 'plpgsql';


--funkcja ktora dodaje lub podmienia ocene konkretnemu uzytkownikowi

CREATE OR REPLACE FUNCTION dodaj_opinie(email3 TEXT, ocena3 INTEGER) RETURNS VOID AS $$
	DECLARE
		id_email INTEGER; 
		stara_ocena INTEGER; 
	BEGIN
		SELECT id_odwiedzajacego INTO id_email FROM odwiedzajacy WHERE e_mail = email3; 
		SELECT ocena INTO stara_ocena FROM opinie WHERE id_odwiedzajacego = id_email; 
		IF(FOUND) THEN 
			UPDATE opinie SET ocena = ocena3 WHERE id_odwiedzajacego = id_email; 
		ELSE 
			INSERT INTO opinie(id_odwiedzajacego, ocena) VALUES (id_email, ocena3);
		END IF;
	END;
$$ LANGUAGE 'plpgsql';









-- WIDOKI 


--widok ktory wyświetla wszystkie zakupione bilety dla konkretnego uzytkownika (wybierany przez email)

CREATE VIEW historia_zakupow AS
    SELECT e_mail, data_wejscia, cena_koncowa, rodzaj, count(*) as liczba_biletow
        FROM kasa
            JOIN odwiedzajacy USING(id_odwiedzajacego)
            JOIN rodzaje_biletow USING(id_rodzaju)
        GROUP BY (e_mail, data_wejscia, cena_koncowa, rodzaj)
        ORDER BY data_wejscia;


--widok ktory wyswietla miejsca na mapie wraz z arena na ktorej sie znajduje 

CREATE VIEW przewodnik AS
    SELECT nazwa_areny, nazwa_miejsca
        FROM areny
            JOIN mapa USING(id_areny)
    UNION
    SELECT nazwa_areny, nazwa_wybiegu
        FROM areny
            JOIN wybiegi USING(id_areny);

--widok ktory wyswietla liste pokazow odbywajacych sie w zoo

CREATE VIEW harmonogram AS
    SELECT DISTINCT nazwa_pokazu, data_pokazu, godzina_pokazu, nazwa_wybiegu, gatunek
        FROM pokazy
            JOIN wybiegi USING(id_wybiegu)
            JOIN zwierzeta USING(id_wybiegu);

--widok ktory wyswietla krotki postaci (gatunek,arena,wybieg)

CREATE VIEW gdzie_zwierze AS
    SELECT DISTINCT gatunek, nazwa_areny, nazwa_wybiegu
        FROM zwierzeta
            JOIN wybiegi USING(id_wybiegu)
            JOIN areny USING (id_areny);

-- widok obliczajacy srednia ocen z tabeli opinie

CREATE VIEW srednia_opinii AS
	SELECT avg(ocena)
	FROM opinie;












--TRIGGERY

--trigger ktory przy wstawieniu nowej krotki do tabeli kasa oblicza wartość ceny koncowej, na podstawie tego czy uzytkownik wybral ofiarowanie datku czy nie

CREATE OR REPLACE FUNCTION cena_biletu() RETURNS TRIGGER AS $$
BEGIN
    IF (NEW.cena_koncowa IS NULL) THEN
        IF (NEW.czy_datek) THEN
            NEW.cena_koncowa = (SELECT 1.1 * cena
                                    FROM rodzaje_biletow
                                    WHERE rodzaje_biletow.id_rodzaju = NEW.id_rodzaju);
        ELSE
            NEW.cena_koncowa = (SELECT cena
                                    FROM rodzaje_biletow
                                    WHERE rodzaje_biletow.id_rodzaju = NEW.id_rodzaju);
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';


CREATE TRIGGER cena_biletu_trigger BEFORE INSERT ON kasa
    FOR EACH ROW EXECUTE PROCEDURE cena_biletu();




--trigger ktory przed wstawieniem nowej opinii sprawdza czy uzytkownik ma zakupiony bilet

CREATE OR REPLACE FUNCTION sprawdz_czy_bilet() RETURNS TRIGGER AS $$
BEGIN
    IF (NEW.id_odwiedzajacego NOT IN (SELECT id_odwiedzajacego
                                        FROM kasa)) THEN
        RAISE EXCEPTION 'Aby wystawić opinię, należy mieć zakupiony bilet na koncie.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';


CREATE TRIGGER sprawdz_czy_bilet_trigger BEFORE INSERT ON opinie
    FOR EACH ROW EXECUTE PROCEDURE sprawdz_czy_bilet();	