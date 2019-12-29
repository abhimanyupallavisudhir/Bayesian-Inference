library(shiny)
library(stats)

fluidPage(
  style = "text-align: center",
  tags$head(
    tags$style(
      "#godDist_family1, #godDist_family2 {display: inline; margin-right: -5px} 
      #para {margin-bottom: 10px}"
    )
  ),
  tags$div(
    style = "display: inline-block; text-align: justify",
    tags$h1('Bayesian Inference/Interference'),
    tags$div(id = 'para', 
             'This applet demonstrates the evolution of the beliefs of an 
             observer about a parameter value as he receives data sampled 
             from the True Distribution. His prior beliefs are modeled by
             a beta distributions whose parameters you can set. You can also
             play God and set the true distribution. The observer will know
             the distribution family (Bernoulli, etc.) but not its parameter, 
             which he will estimate from the data he collects.', 
             style = "width: 600px"),
    tags$div(id = 'para', 
             'If you want to be poetic, the observer places a probability 
             distribution on each possible', tags$em('theory'), 'about his 
             universe -- he woke up in this universe with a signboard in 
             his face saying "the right distribution is a',
             textOutput(outputId = "godDist_family1"),
             '", so he has already made some inference and modified his prior 
             -- all theories other than', 
             textOutput(outputId = "godDist_family2"),
             '(p) are given a prior probability density (whatever that means) 
             of zero.',
             style = "width: 600px"),
    tags$div(id = 'para', 
             'The default parameters are for tossing a (very unfair, as 
             the observer learns) coin, where the observer has no idea how
             a coin looks like in the real world. Press the PLAY button to 
             feed the observer some data.',
             style = "width: 600px"),
    tags$div(id = 'para',
             'To learn more about Bayesian inference, check out my post on
             The Winding Number:', 
             tags$a(href = 'https://thewindingnumber.blogspot.com/2019/12/introduction-to-bayesian-inference.html',
                    'Introduction to Bayesian inference'),
             style = "width: 600px"),
    tags$table(
      tags$tr(
        tags$td(
          tags$h3("True distribution (shh...)"),
          selectInput(inputId = 'godDist_family', 
                      label = 'True distribution (family)', 
                      choices = c("Bernoulli", "Poisson", "Geometric"),
                      selected = "Bernoulli"),
          sliderInput(inputId = 'godDist_param',
                      label = 'True distribution (parameter value)',
                      value = 0.85, min = 0, max = 1),
          tags$h3("Bayesian prior"),
          sliderInput(inputId = 'prior_alpha',
                      label = 'Prior beta (alpha)',
                      value = 1, min = 0, max = 24),
          sliderInput(inputId = 'prior_beta', 
                      label = 'Prior beta (beta)',
                      value = 1, min = 0, max = 24)
        ),
        tags$td(
          plotOutput(outputId = 'beliefs'),
          sliderInput(inputId = 'time', 
                      label = 'Feed data (press PLAY)', 
                      value = 1, step = 1, min = 1, max = 100,
                      animate = animationOptions(interval = 100, loop = FALSE))
        )
      )
    )
)
    )