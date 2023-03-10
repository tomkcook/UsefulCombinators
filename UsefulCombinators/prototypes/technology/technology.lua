data:extend({
  {
    type = "technology",
    name = "useful-combinators",
    icon = "__UsefulCombinators__/graphics/technology/clock.png",
    icon_size = 64,
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "timer-combinator"
      },
      {
        type = "unlock-recipe",
        recipe = "counting-combinator"
      },
      {
        type = "unlock-recipe",
        recipe = "random-combinator"
      },
      {
        type = "unlock-recipe",
        recipe = "converter-combinator"
      },
      {
        type = "unlock-recipe",
        recipe = "min-combinator"
      },
      {
        type = "unlock-recipe",
        recipe = "max-combinator"
      },
      {
        type = "unlock-recipe",
        recipe = "and-gate-combinator"
      },
      {
        type = "unlock-recipe",
        recipe = "nand-gate-combinator"
      },
      {
        type = "unlock-recipe",
        recipe = "nor-gate-combinator"
      },
      {
        type = "unlock-recipe",
        recipe = "not-gate-combinator"
      },
      {
        type = "unlock-recipe",
        recipe = "or-gate-combinator"
      },
      {
        type = "unlock-recipe",
        recipe = "xnor-gate-combinator"
      },
      {
        type = "unlock-recipe",
        recipe = "xor-gate-combinator"
      },
      {
        type = "unlock-recipe",
        recipe = "detector-combinator"
      },
      {
        type = "unlock-recipe",
        recipe = "sensor-combinator"
      },
      {
        type = "unlock-recipe",
        recipe = "railway-combinator"
      },
      {
        type = "unlock-recipe",
        recipe = "color-combinator"
      },
      {
        type = "unlock-recipe",
        recipe = "emitter-combinator"
      },
      {
        type = "unlock-recipe",
        recipe = "receiver-combinator"
      },
      {
        type = "unlock-recipe",
        recipe = "power-combinator"
      },
      {
        type = "unlock-recipe",
        recipe = "daytime-combinator"
      },
      {
        type = "unlock-recipe",
        recipe = "pollution-combinator"
      },
      {
        type = "unlock-recipe",
        recipe = "statistic-combinator"
      },
      {
        type = "unlock-recipe",
        recipe = "multiplex-combinator"
      }
    },
    prerequisites = {"circuit-network"},
    unit =
    {
      count = 100,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1}
      },
      time = 15
    },
    order = "a-d-d"
  }
})