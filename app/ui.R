shinyUI( fluidPage(
  
  includeCSS("www/styles.css"),
  
  # a JavaScript script for capturing the window size
  # found from https://stackoverflow.com/questions/36995142/get-the-size-of-the-window-in-shiny
  tags$head(tags$script('var dimension = [0, 0];
                          $(document).on("shiny:connected", function(e) {
                              dimension[0] = window.innerWidth;
                              dimension[1] = window.innerHeight;
                              Shiny.onInputChange("window_size", dimension);
                          });
                          $(window).resize(function(e) {
                              dimension[0] = window.innerWidth;
                              dimension[1] = window.innerHeight;
                              Shiny.onInputChange("window_size", dimension);
                          });')),
  
  titlePanel("Ninni"),
  
  sidebarLayout(
    # Sidebar contains inputs for searching Ninni's database for information
    # and filters for loaded datasets
    sidebarPanel(
      # Search options for choosing a dataset
      h4("Dataset"),
      uiOutput("ds_choice"),
      uiOutput("metadata_tags_ui"),
      textInput("var_keywords","Variable keywords"),
      # Filters for filtering associations
      # Like variable names, p-value, effect size
      uiOutput("standard_filters"),
      # Extra filters based on non-required columns.
      checkboxInput("toggle_extra_filters","Show extra filters"),
      conditionalPanel("input.toggle_extra_filters == true",
                       uiOutput("extra_filters")),
      # Filter for variables, e.g. at least one association with p < 0.05
      # Keeps all associations for particular variable
      uiOutput("variable_filters"),
      actionButton("filter",
                   label = "Filter"),
      
      br(),
      br(),
      # Basic information of the dataset
      htmlOutput("ds_info")
    ),
    mainPanel(
      tabsetPanel(
        # Welcom text and a list of the datasets in database
        tabPanel("Main",
                 h3("Welcome to use Ninni the visualization app!"),
                 p("You can browse Ninni's database using the search fields on the left."),
                 p("You can view the associations of the chosen dataset is the Data Table tab,
                   and visualize the data with the tools provided in other tabs."),
                 p("Ninni will try to provide you with interactive visualization. Unfortunately,
                   for very large datasets this is not possible. If the chosen dataset seems too large,
                   you must either settle for a static figure or filter the dataset."),
                 br(),
                 h3("Datasets"),
                 DT::dataTableOutput("dstable")
        ),
        # All the chosen associations in table format
        tabPanel("Data Table",
                 h3("Associations"),
                 DT::dataTableOutput("tabular"),
                 br(),
                 uiOutput("download")
        ),

        tabPanel("Heat Map",
                 # Toggle hierarchical clustering for heat map
                 radioButtons("clustering",
                              label = "Order",
                              choices = c("Alphabetical" = FALSE,"Clustering" = TRUE),
                              selected = FALSE,
                              inline = TRUE),
                 checkboxInput("lower_tri", "Lower-triangular"),
                 checkboxInput("symmetrical", "Fill to symmetrical"),
                 br(),
                 strong("Effect"),
                 checkboxInput("heatmap_log2",
                               label = "Log2 transform"),
                 checkboxInput("heatmap_discrete",
                               label = "Discretize"),
                 sliderInput("heatmap_breaks",
                              label = "Number of levels on discrete scale",
                              value = 5, min = 3, max = 11),
                 radioButtons("heatmap_color_scale",
                              label = "Type of color scale",
                              choices = c("Sequential", "Diverging")),
                 numericInput("heatmap_midpoint",
                              label = "Midpoint of diverging scale", value = 0),
                 # radioButtons("heatmap_p",
                 #              "Include p-values?",
                 #              choices = c("No" = "", "raw p-values" = "P", "FDR adjusted p-values" = "P_FDR")),
                 # numericInput("heatmap_p_limit",
                 #              "Ignore p-values above",
                 #              value = 0.1, min = 0, max = 1, step = 0.05),
                 # sliderInput("heatmap_point_range",
                 #             "Size range of the p-value points",
                 #             value = c(1,4), min = 1, max = 10),
                 uiOutput("heatmap")
        ),
        
        tabPanel("Volcano plot",
                 # Log2 scale effect?
                 checkboxInput("volcano_log2",
                               label = "log2 transform"),
                 # Choices for double filtering the volcano plot i.e. filtering by p-value and/or effect size
                 # Toggle double filtering
                 checkboxInput("double_filter",
                              label = "Apply visual filters"),
                 conditionalPanel("input.double_filter == true",
                                  fluidRow(
                                    column(4, # Set p-value limit
                                           textInput("df_p_limit",
                                                     label = "P-value <",
                                                     value = "0.05")),
                                    column(5, # Filter by unadjusted or FDR adjusted p-value
                                           radioButtons("df_p_limit_fdr",label = NULL,
                                                        choices = c("Unadjusted" = FALSE,
                                                                    "FDR" = TRUE),
                                                        selected = FALSE,
                                                        inline = TRUE))
                                    
                                  ),
                                  fluidRow(
                                    column(4, # Set limit for the effect
                                           textInput("df_effect_limit",
                                                     label = "Absolute effect >",
                                                     value = 3)),
                                    conditionalPanel("input.volcano_log2 == true",
                                                     column(5, # Filter by raw or log2 effect
                                                            radioButtons("df_eff_limit_log2",label = NULL,
                                                                         choices = c("Original" = FALSE,
                                                                                     "log2" = TRUE),
                                                                         selected = FALSE,
                                                                         inline = TRUE)))
                                    
                                  )
                 ),
                 checkboxInput("volcano_shape","Shape by dataset"),
                 
                 
                 # The actual volcano plot
                 uiOutput("volcano")
        ),
        
        tabPanel("Q-Q plot",
                 radioButtons("qq_choice",
                              label = "Choose the type of Q-Q plot",
                              choices = c("P-values" = "P",
                                          "Effect" = "Effect"),
                              inline = TRUE),
                 conditionalPanel("input.qq_choice == 'Effect'",
                                   checkboxInput("qq_log2",
                                                 label = "log2 transform")),
                 uiOutput("qq_plot_choices"),
                 uiOutput("qq_plot")
        ),
        
        tabPanel("Signed Manhattan plot",
                 checkboxInput("lady_log2", label = "use sign of log2-transformed effect"),
                 uiOutput("lady_manhattan_plot_choices"),
                 uiOutput("lady_manhattan_plot")),
        
        tabPanel("Lollipop plot",
                 uiOutput("lollipop_choices"),
                 uiOutput("lollipop_plot")),
        
        tabPanel("UpSet plot",
                 uiOutput("upset_choices"),
                 uiOutput("upset_plot"))
      )
    )
    
  )
))