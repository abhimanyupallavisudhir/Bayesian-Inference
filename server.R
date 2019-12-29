library(shiny)
library(stats)
library(ggplot2)

function(input, output) {
  output$godDist_family1 = renderText({
    input$godDist_family
  })
  output$godDist_family2 = renderText({
    input$godDist_family
  })
  data = reactive({
    # Generate data and create density function (for inference)
    if (input$godDist_family == "Bernoulli") {
      data = rbinom(100, 1, input$godDist_param)
    } else if (input$godDist_family == "Poisson") {
      data = rpois(100, input$godDist_param)
    } else if (input$godDist_family == "Geometric") {
      data = rgeom(100, input$godDist_param)
    }
  })
  theories = reactive({
    # Generate data and create density function (for inference)
    if (input$godDist_family == "Bernoulli") {
      dsim = function(x, theta)
        dbinom(x, 1, theta)
    } else if (input$godDist_family == "Poisson") {
      dsim = function(x, theta)
        dpois(x, theta)
    } else if (input$godDist_family == "Geometric") {
      dsim = function(x, theta)
        dgeom(x, theta)
    }
    
    # prior distribution we assume: beta with parameters prior_alpha, prior_beta
    theory = function(theta)
      dbeta(theta, input$prior_alpha, input$prior_beta)
    
    # We will construct a function that evolves as exposed to more data.
    # theories[n](theta) represents the pdf upon exposure to first n data pts
    # so we have an iterative process, where x is the nth data point:
    # theories[n](theta) = theories[n-1](theta) * dsim(x, theta) /
    #   integrate(function(phi) theories[n-1](phi) * dsim(x, phi))
    
    interfere = function(prior, x) {
      overall = integrate(function(phi)
        prior(phi) * dsim(x, phi), 0, 1)$value
      function(theta) {
        prior(theta) * dsim(x, theta) / overall
      }
    }
    
    # initialize theories
    theories = c(theory)
    
    # update theories
    for (i in 1:100) {
      prior = theories[[i]]
      data_point = data()[i]
      posterior = interfere(prior, data_point)
      theories = c(theories, posterior)
    }
    
    theories
  })
  means = reactive({
    dist_mean = function(theory){
      integrate(function(phi) phi * theory(phi), 0, 1)$value
    }
    means = lapply(theories(), dist_mean)
    means
  })
  output$beliefs = renderPlot({
    theta = seq(0, 1, 0.001)
    p = theories()[[input$time]](theta)
    mode = 0.001 * (which.max(p) - 1)
    mean = means()[[input$time]]
    plot(theta, p, 'l', ylim = c(0, 20),
         xlab = 'Theory space (parameter value)',
         ylab = 'Probability density',
         main = 'Belief distribution')
    if (mode != 0 & mode != 1){
      abline(v = mode, lty = 'dashed', col = 'red')
      text(x = mode - 0.25 * sign(input$godDist_param - 0.5), y = 15, 
           col = 'red', labels = paste('Mode:', mode))
    }
    abline(v = mean, lty = 'dashed', col = 'blue')
    text(x = mean - 0.25 * sign(input$godDist_param - 0.5), y = 12, 
         col = 'blue', labels = paste('Mean:', round(mean, digits = 3)))
    text(x = 0.4, y = 18,
         labels = paste('Current data value:', data()[input$time]))
  })
  # output$beliefs = renderPlot({
  #   ggplot(data = plotato(), mapping = aes(theta, p)) +
  #     geom_line() +
  #     xlim(0, 1) +
  #     ylim(0, 20) +
  #     xlab('Theory space (parameter value)') +
  #     ylab('Probability density') +
  #     ggtitle('Belief distribution')
  # })
}