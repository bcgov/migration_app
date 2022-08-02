ui <- function(req) {
  shiny::fluidPage(
    theme = "bootstrap.css",
    HTML("<html lang='en'>"),
    fluidRow(


    ## Replace appname with the title that will appear in the header
    bcsapps::bcsHeaderUI(id = 'header', appname = "Migration of British Columbians"),

    ## CSS for resizing map based on browser window size
    tags$head(tags$style("#map{height:55vh !important;}")),

    column(width = 12,
           style = "margin-top:100px",

           ## Sidebar ----
           sidebarLayout(
             sidebarPanel(width = 3,
               h2("Select Reference Date"),
               "Select a year and quarter to visualize inter-provincial and international migration",
               br(),br(),
               uiOutput("year"),
               uiOutput("quarter"),
               #br(),
               h2("Download"),
               "Download the data powering this visualization from the ",
               a("BC Data Catalogue", href = "https://catalogue.data.gov.bc.ca/dataset/56610cfc-02ba-41a7-92ef-d9609ef507f1", target = "_blank"),
               br(),br(),
               downloadButton("interprov_dl", label = "Provincial"),
               br(),br(),
               downloadButton("internat_dl", label = "International"),
               br(),br(),
               h2("About the Data"),
               a("Inter-provincial migration data source:", href = "https://doi.org/10.25318/1710004501-eng", target = "_blank"),
               "Statistics Canada. Table 17-10-0045-01  Estimates of interprovincial migrants by province or territory of origin and destination, quarterly",
               br(),br(),
               a("International migration data source:", href = "https://doi.org/10.25318/1710004001-eng", target = "_blank"),
               "Statistics Canada. Table 17-10-0040-01  Estimates of the components of international migration, quarterly",
               br(),br(),
               tags$strong("For international data:"),
               br(),br(),
               "From BC = Emigrants + Net Temporary Emigrants – Returning Emigrants.",
               br(),br(),
               "To BC = International Immigrants + Net Non Permanant Residents."
             ),
             ## Main Panel ----
             mainPanel(width = 9,
                       h2("Net Migration by Province"),
                       plotOutput("map"),
                       h2("Migration Details"),
                       DTOutput("table")

             )
           )


           ),

    bcsapps::bcsFooterUI(id = 'footer')
  )
)}

server <- function(input, output) {

  ## Change links to false to remove the link list from the header
  bcsapps::bcsHeaderServer(id = 'header', links = TRUE)

  bcsapps::bcsFooterServer(id = 'footer')

  ## Select Ref Date ----

  output$year <- renderUI({

    choices <- interprovincial %>%
      select(Year) %>%
      unique() %>%
      arrange(desc(Year)) %>%
      pull()

    selectInput("map_year",
                label = "Year",
                choices = choices,
                selected = max(choices))

  })

  output$quarter <- renderUI({

    req(input$map_year)

    year <- input$map_year

    quarters <- interprovincial %>%
      filter(Year == year) %>%
      select(Quarter) %>%
      unique() %>%
      left_join(quarter_labels, by = "Quarter")

    choices <- setNames(quarters$Quarter, quarters$Label)

    selectInput("map_quarter",
                label = "Quarter",
                choices = choices)

  })

  ## Downloads ----
  output$interprov_dl <- downloadHandler(
    filename = function() {
      "interprovincial_migration.csv"
    },
    content = function(file) {
      write.csv(interprovincial, file)
    }
  )

  output$internat_dl <- downloadHandler(
    filename = function() {
      "international_migration.csv"
    },
    content = function(file) {
      write.csv(international, file)
    }
  )

  ## Reactive Data ----
  data <- reactive({

    req(input$map_year)
    req(input$map_quarter)

    ## interprovincial
    table_data_prep_prov <- interprovincial %>%
      filter(Year == input$map_year, Quarter == input$map_quarter) %>%
      select(-Total) %>%
      pivot_longer(-c(Year, Quarter, Origin), names_to = "Destination", values_to = "value") %>%
      filter(Origin == "B.C." | Destination == "B.C." )

    from_bc <- table_data_prep_prov %>%
      filter(Origin == "B.C.") %>%
      select(Year, Quarter, Jurisdiction = "Destination", `From BC` = value)

    to_bc <- table_data_prep_prov%>%
      filter(Destination == "B.C.") %>%
      select(Year, Quarter, Jurisdiction = "Origin", `To BC` = value)

    ## international
    table_data_prep_internat <- international %>%
      filter(Year == input$map_year, Quarter == input$map_quarter) %>%
      mutate(Jurisdiction = "International",
             `From BC`= Emigrants + Net_temporary_emigrants - Returning_emigrants,
             `To BC` = Immigrants + Net_non_permanent_residents) %>%
      select(Year, Quarter, Jurisdiction, `From BC`, `To BC`, `Net Migration` = Net_migration)

    table_data <- from_bc %>%
      left_join(to_bc, by = c("Year","Quarter", "Jurisdiction")) %>%
      mutate(`Net Migration` = `To BC`-`From BC`) %>%
      bind_rows(table_data_prep_internat) %>%
      adorn_totals("row",
                   fill = "-",
                   na.rm = TRUE,
                   name = "Total",
                   `From BC`:`Net Migration`) %>%
      filter(Jurisdiction != "B.C.")

  }) %>% bindCache(input$map_year, input$map_quarter)

  ## Map ----
  output$map <- renderPlot({

    map_data <- locations %>%
      left_join(data(), by = "Jurisdiction") %>%
      mutate(lat_start = ifelse(`Net Migration` < 0, BC_Latitude, Latitude),
             long_start = ifelse(`Net Migration` < 0, BC_Longitude, Longitude),
             lat_end = ifelse(`Net Migration` < 0, Latitude, BC_Latitude),
             long_end = ifelse(`Net Migration` < 0, Longitude, BC_Longitude),
             mig_color = ifelse(`Net Migration` < 0, "neg","pos")) 

    ggplot() +
      geom_sf(data = provinces, color = "#5b5f66") +
      geom_sf(data = provinces %>% filter(PRENAME == "British Columbia"), fill = "#FBC140") +
      geom_segment(data = map_data,
                           aes(x = long_start,
                               y = lat_start,
                               xend = long_end,
                               yend = lat_end,
                               color = mig_color,
                               size = abs(`Net Migration`)),
                           arrow = arrow(length = unit(0.4, "cm"), type = "closed"),
                           lineend = "round") +
      geom_label(data = map_data,
                            aes(Longitude,
                                Latitude,
                                label = paste(Jurisdiction, prettyNum(`Net Migration`, big.mark = ",")),
                                color = mig_color,
                                hjust = hjust,
                                vjust = vjust),
                                fontface = "bold") +
      scale_color_manual(values = colors) +
      scale_size_continuous(range = c(0.2,7)) +
      guides(color = "none",
             size = "none") +
      coord_sf(clip = "off", expand = TRUE, crs = 4326) +
      theme_map()
  })

  ## Table ----
  output$table <- renderDT({

    datatable(data(),
              rownames = FALSE,
              options= list(dom = "t",
                            paging = FALSE)) %>%
      formatRound(columns = 4:6, digits = 0)
  })

  }

shiny::shinyApp(ui = ui, server = server)
