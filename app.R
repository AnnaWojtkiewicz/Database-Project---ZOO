#library(shiny)
#library(shinyjs)
#library(shinythemes)
#setwd("C:/Users/wojtk/OneDrive/Pulpit/bazy danych/projekt")
#library(bslib)





source(file = 'funkcje.R')

ui <- fluidPage(
  theme = shinytheme("flatly"),
  useShinyjs(),
  
  tags$style(HTML("
    body {
      background-color: #f9f9f9;
    }
    #sidebar {
      background-color: #2c3e50;
      color: white;
      padding: 20px;
    }
    #sidebar .btn {
      background-color: #3498db;
      color: white;
      border: none;
      margin-bottom: 10px;
      width: 100%; /* Przycisk na całą szerokość */
      text-align: left;
      padding: 12px 15px;
      font-size: 16px;
    }
    #sidebar .btn:hover {
      background-color: #2980b9;
    }
    #sidebar h3 {
      color: #ecf0f1;
      margin-bottom: 25px;
      font-size: 24px;
    }
    .panel-main {
      background-color: white;
      border-radius: 10px;
      padding: 20px;
      box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
    }
    .title-panel {
      text-align: center;
      color: #2c3e50;
      font-size: 36px; /* Większa czcionka dla tytułu */
      font-weight: bold;
      padding: 20px 0;
      margin-bottom: 20px;
    }
    .btn-action {
      background-color: #27ae60;
      color: white;
      border: none;
    }
    .btn-action:hover {
      background-color: #1e8449;
    }
    .welcome-image {
      width: 100%;
      max-height: 400px;
      object-fit: cover;
      border-radius: 10px;
      margin-bottom: 20px;
    }
    #sidebar .btn i {
      margin-right: 10px;
    }
  ")),
  
  titlePanel(
    div(class = "title-panel", "🐾 Zoo Przekręt 🐾")
  ),
  
  sidebarLayout(
    sidebarPanel(
      width = 3,
      id = "sidebar",
      h3("Menu główne"),
      div(style = "display: flex; flex-direction: column; gap: 10px;",
          actionButton(inputId = "btn_start", label = "📱 Strona główna", class = "btn"),
          actionButton(inputId = "btn_rejestracja", label = "📝 Rejestracja", class = "btn"),
          actionButton(inputId = "btn_kasa", label = "💰 Kasa", class = "btn"),
          actionButton(inputId = "btn_historia", label = "📚 Historia zakupów", class = "btn"),
          actionButton(inputId = "btn_mapa", label = "🗺️ Mapa", class = "btn"),
          actionButton(inputId = "btn_harmonogram", label = "📅 Harmonogram pokazów", class = "btn"),
          actionButton(inputId = "btn_opinie", label = "⭐ Opinie", class = "btn")
      )
    ),
    
    mainPanel(
      width = 9,
      class = "panel-main",
      uiOutput("main_content")
    )
  )
)

server <- function(input, output, session) {

  current_section <- reactiveVal("start")

  observeEvent(input$btn_start, { current_section("start") })
  observeEvent(input$btn_rejestracja, { current_section("rejestracja") })
  observeEvent(input$btn_kasa, { current_section("kasa") })
  observeEvent(input$btn_historia, { current_section("historia") })
  observeEvent(input$btn_mapa, { current_section("mapa") })
  observeEvent(input$btn_harmonogram, { current_section("harmonogram") })
  observeEvent(input$btn_opinie, { current_section("opinie") })
  

  output$main_content <- renderUI({
    switch(
      current_section(),
      "start" = {
        tagList(
          h1("Witamy w Zoo Przekręt!", class = "text-center"),
          img(src = "zoo1.jpg", alt = "Zdjęcie zwierząt w zoo", class = "welcome-image"),
          p("Witaj w aplikacji Zoo Przekręt. Tutaj możesz zarządzać swoimi rejestracjami, kupować bilety, przeglądać harmonogram pokazów 
            oraz dodawać opinie o naszym zoo. Wybierz opcję z menu po lewej stronie, aby rozpocząć!", 
            style = "font-size: 18px; text-align: center; color: #2c3e50;")
        )
      },
      "rejestracja" = {
        tagList(
          h3("Rejestracja"),
          textInput(inputId = 'imie', label = 'Imię'),
          textInput(inputId = 'nazwisko', label = 'Nazwisko'),
          textInput(inputId = 'email1', label = "E-mail"),
          actionButton(inputId = 'dodaj', label = "Utwórz konto", class = "btn-action"),
          verbatimTextOutput("napis")
        )
      },
      "kasa" = {
        tagList(
          h3("Kasa"),
          dataTableOutput('cennik'),
          selectInput(inputId = 'email', label = 'Wybierz swój e-mail', choices = load.emails()),
          selectInput(inputId = 'rodzaj', label = 'Wybierz rodzaj biletu', choices = load.rodzaje()),
          dateInput("data", "Wybierz datę wejścia"),
          radioButtons(
            "datek",
            "Wybierz, czy chcesz przekazać datek",
            choices = list("TAK" = 1, "NIE" = 2),
            selected = 2
          ),
          actionButton(inputId = 'zatwierdz', label = 'Kup bilet', class = "btn-action"),
          verbatimTextOutput("cena")
        )
      },
      "historia" = {
        tagList(
          h3("Historia zakupów"),
          selectInput(inputId = 'email_his', label = 'Wybierz swój e-mail', choices = load.emails()),
          dataTableOutput('historia_zak')
        )
      },
      "mapa" = {
        tagList(
          h3("Mapa"),
          selectInput(inputId = 'zwierzeta', label = 'Jakie zwierzę chcesz zobaczyć?', choices = load.zwierzeta()),
          textOutput('napis_zwierzeta'),
          dataTableOutput('tabela_zwierze'),
          textOutput('napis_wybieg'),
          dataTableOutput('przewodnik')
        )
      },
      "harmonogram" = {
        tagList(
          h3("Harmonogram pokazów"),
          dateInput("data2", "Wybierz datę"),
          dataTableOutput('pokazy')
        )
      },
      "opinie" = {
        tagList(
          h3("Opinie"),
          selectInput(inputId = 'email2', label = 'Wybierz swój e-mail', choices = load.emails.kasa()),
          sliderInput(inputId = 'rating', label = 'Wybierz ocenę', min = 0, max = 10, value = 10),
          actionButton(inputId = 'dodaj.opinie', label = 'Dodaj opinię', class = "btn-action"),
          textOutput('napis_opinie'),
          dataTableOutput('ostatnie_opinie'),
          textOutput('srednia.ocen')
        )
      }
    )
  })
  

  observeEvent(input$dodaj, {
    wynik1 <- zaloz.konto(input$imie, input$nazwisko, input$email1)
    output$napis <- renderText({ paste(wynik1) })
  })
  
  output$cennik <- renderDataTable(
    load.cennik(),
    options = list(
      paging = FALSE,
      lengthChange = FALSE,
      searching = FALSE,
      info = FALSE
    )
  )
  
  observeEvent(input$zatwierdz, {
    wynik <- kup.bilet(input$email, input$rodzaj, input$datek, input$data)
    output$cena <- renderText({ paste("Cena biletu wynosi:", wynik) })
  })
  
  output$historia_zak <- renderDataTable(
    historia(input$email_his),
    options = list(
      pageLength = 10,
      lengthChange = FALSE,
      searching = FALSE,
      info = FALSE
    )
  )
  
  output$napis_zwierzeta <- renderText(paste("Zwierzę, które chcesz zobaczyć, znajduje się w:"))
  output$tabela_zwierze <- renderDataTable(
    load.gdzie.zwierze(input$zwierzeta),
    options = list(
      paging = FALSE,
      lengthChange = FALSE,
      searching = FALSE,
      info = FALSE
    )
  )
  output$napis_wybieg <- renderText(paste("Na tej arenie znajdują się następujące atrakcje:"))
  output$przewodnik <- renderDataTable(
    load.przewodnik(load.nazwa.areny(input$zwierzeta)),
    options = list(
      pageLength = 10,
      lengthChange = FALSE,
      searching = FALSE,
      info = FALSE
    )
  )
  
  output$pokazy <- renderDataTable(
    load.pokazy(input$data2),
    options = list(
      pageLength = 10,
      lengthChange = FALSE,
      searching = FALSE,
      info = FALSE
    )
  )
  
  observeEvent(input$dodaj.opinie, {
    dodaj.opinie_(input$email2, input$rating)
  })
  output$napis_opinie <- renderText(paste("Najnowsze opinie:"))
  output$ostatnie_opinie <- renderDataTable(
    load.ostatnie.opinie(),
    options = list(
      paging = FALSE,
      lengthChange = FALSE,
      searching = FALSE,
      info = FALSE
    )
  )
  output$srednia.ocen <- renderText(paste("Średnia ocena:", load.srednia.opinii()))
  
  observeEvent(input$refresh, { refresh() })
}

shinyApp(ui = ui, server = server)
