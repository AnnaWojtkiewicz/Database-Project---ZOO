
library("RPostgres")

open.my.connection <- function() {
  con <- dbConnect(RPostgres::Postgres(),dbname = 'projekt', 
                   host = 'localhost',
                   port = 5432, 
                   user = 'projekt_ja',
                   password = 'n0c')
  return (con)
}

close.my.connection <- function(con) {
  dbDisconnect(con)
}


load.emails <- function() {
  query = "SELECT e_mail as \"E-mail\" FROM odwiedzajacy"
  con = open.my.connection()
  res = dbSendQuery(con,query)
  emails = dbFetch(res)
  dbClearResult(res)
  close.my.connection(con)
  return(emails)
}


load.emails.kasa <- function() {
  query = "SELECT DISTINCT e_mail as \"E-mail\" FROM odwiedzajacy JOIN kasa USING(id_odwiedzajacego)"
  con = open.my.connection()
  res = dbSendQuery(con,query)
  emails10 = dbFetch(res)
  dbClearResult(res)
  close.my.connection(con)
  return(emails10)
}



load.rodzaje <- function() {
  query = "SELECT rodzaj as \"Rodzaj biletu\" FROM rodzaje_biletow"
  con = open.my.connection()
  res = dbSendQuery(con,query)
  rodzaje = dbFetch(res)
  dbClearResult(res)
  close.my.connection(con)
  return(rodzaje)
}


load.zwierzeta <- function() {
  query = "SELECT DISTINCT gatunek as \"Gatunek \" FROM zwierzeta ORDER BY gatunek"
  con = open.my.connection()
  res = dbSendQuery(con,query)
  zwierzeta = dbFetch(res)
  dbClearResult(res)
  close.my.connection(con)
  return(zwierzeta)
}


load.cennik <- function() {
  query = "SELECT rodzaj as \"Rodzaj biletu\", cena as \"Cena jednostkowa\" FROM rodzaje_biletow ORDER BY cena DESC"
  con = open.my.connection()
  res = dbSendQuery(con,query)
  rodzaje2 = dbFetch(res)
  dbClearResult(res)
  close.my.connection(con)
  return(rodzaje2)
}

  
kup.bilet <- function(email, rodzaj, datek, data) {
  query = paste0(
    "SELECT kup_bilet('",
    email, "', '", 
    rodzaj, "', ", 
    datek, ", '", 
    data, "')"
  )
  con = open.my.connection()
  res = dbSendQuery(con,query)
  result <- dbFetch(res)
  dbClearResult(res)
  close.my.connection(con)
  return(result)
}


zaloz.konto <- function(imie, nazwisko, mail) {
  if(trimws(imie)!="" & trimws(nazwisko) !=""){ 
   query <- paste0(
      "SELECT dodaj_konto('",
      imie, "', '", 
      nazwisko, "', '",
      mail, "')"
    )
    con <- open.my.connection()
    res <- dbSendQuery(con, query)
    result <- dbFetch(res)
    dbClearResult(res)
    close.my.connection(con)
    return(result)
}}



historia <- function(email) {
  query = paste0("SELECT data_wejscia as \"Data wejścia\", cena_koncowa AS \"Cena jednostkowa\", rodzaj as \"Rodzaj biletu\", liczba_biletow as \"Liczba biletów\" FROM historia_zakupow WHERE historia_zakupow.e_mail = '", email, "'")
  con = open.my.connection()
  res = dbSendQuery(con,query)
  rodzaje3 = dbFetch(res)
  dbClearResult(res)
  close.my.connection(con)
  return(rodzaje3)
}


load.tabela_zwierzeta <- function() {
  query = "SELECT rodzaj, cena FROM rodzaje_biletow ORDER BY cena DESC"
  con = open.my.connection()
  res = dbSendQuery(con,query)
  rodzaje2 = dbFetch(res)
  dbClearResult(res)
  close.my.connection(con)
  return(rodzaje2)
}


load.gdzie.zwierze <- function(gatunek) {
  query = paste0("SELECT nazwa_areny as \"Nazwa areny\", nazwa_wybiegu as \"Nazwa wybiegu\" FROM gdzie_zwierze WHERE gatunek = '", gatunek, "'")
  con = open.my.connection()
  res = dbSendQuery(con,query)
  zwierzeta = dbFetch(res)
  dbClearResult(res)
  close.my.connection(con)
  return(zwierzeta)
  
}


load.nazwa.areny <- function(gatunek) {
  query = paste0(
    "SELECT wypisz_arene('",
    gatunek, "')"
  )
  con = open.my.connection()
  res = dbSendQuery(con,query)
  arena = dbFetch(res)
  dbClearResult(res)
  close.my.connection(con)
  return(arena)
}


load.przewodnik <- function(nazwa) {
  query = paste0("SELECT nazwa_miejsca as \"Nazwa atrakcji\" FROM przewodnik WHERE nazwa_areny = '", nazwa, "'")
  con = open.my.connection()
  res = dbSendQuery(con,query)
  przew = dbFetch(res)
  dbClearResult(res)
  close.my.connection(con)
  return(przew)
}


load.pokazy <- function(data) {
  query = paste0("SELECT nazwa_pokazu as \"Nazwa pokazu\", data_pokazu as \"Data pokazu\", godzina_pokazu as \"Godzina pokazu\", nazwa_wybiegu as \"Nazwa wybiegu\", gatunek as \"Gatunek\"  FROM harmonogram WHERE data_pokazu ='", data, "'")
  con = open.my.connection()
  res = dbSendQuery(con,query)
  pokaz = dbFetch(res)
  dbClearResult(res)
  close.my.connection(con)
  return(pokaz)
}


dodaj.opinie_ <- function(email, ocena) {
  query = paste0("SELECT dodaj_opinie('",
                 email,"','",ocena,"')")
  con = open.my.connection()
  res = dbSendQuery(con,query)
  dbClearResult(res)
  close.my.connection(con)
}


load.ostatnie.opinie <- function() {
  query = "SELECT imie as \"Imie\", ocena as \"Ocena\" FROM opinie JOIN odwiedzajacy USING(id_odwiedzajacego) ORDER BY id_opinii DESC LIMIT 5"
  con = open.my.connection()
  res = dbSendQuery(con,query)
  opinie  = dbFetch(res)
  dbClearResult(res)
  close.my.connection(con)
  return(opinie)
}

load.srednia.opinii <- function() {
  query = "SELECT * FROM srednia_opinii"
  con = open.my.connection()
  res = dbSendQuery(con,query)
  rating = dbFetch(res)
  dbClearResult(res)
  close.my.connection(con)
  return(rating$avg)
}




















