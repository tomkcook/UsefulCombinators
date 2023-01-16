data:extend({
  {
    type = "recipe",
    name = "timer-combinator",
    enabled = "false",
    ingredients =
    {
      {"arithmetic-combinator", 1},
      {"constant-combinator", 1}
    },
    result = "timer-combinator"
  },
  {
    type = "recipe",
    name = "counting-combinator",
    enabled = "false",
    ingredients =
    {
      {"arithmetic-combinator", 1},
      {"decider-combinator", 1}
    },
    result = "counting-combinator"
  },
  {
    type = "recipe",
    name = "random-combinator",
    enabled = "false",
    ingredients =
    {
      {"advanced-circuit", 1},
      {"constant-combinator", 1}
    },
    result = "random-combinator"
  }--[[,
  {
    type = "recipe",
    name = "logic-combinator",
    enabled = "false",
    ingredients =
    {
      {"advanced-circuit", 1},
      {"decider-combinator", 1}
    },
    result = "logic-combinator"
  }]],
  {
    type = "recipe",
    name = "comparator-combinator",
    enabled = "false",
    ingredients =
    {
      {"constant-combinator", 1},
      {"decider-combinator", 1}
    },
    result = "comparator-combinator"
  },
  {
    type = "recipe",
    name = "min-combinator",
    enabled = "false",
    ingredients =
    {
      {"advanced-circuit", 1},
      {"decider-combinator", 1}
    },
    result = "min-combinator"
  },
  {
    type = "recipe",
    name = "max-combinator",
    enabled = "false",
    ingredients =
    {
      {"advanced-circuit", 1},
      {"decider-combinator", 1}
    },
    result = "max-combinator"
  },
  {
    type = "recipe",
    name = "and-gate-combinator",
    enabled = "false",
    ingredients =
    {
      {"electronic-circuit", 1},
      {"copper-cable", 2}
    },
    result = "and-gate-combinator"
  },
  {
    type = "recipe",
    name = "or-gate-combinator",
    enabled = "false",
    ingredients =
    {
      {"electronic-circuit", 1},
      {"copper-cable", 2}
    },
    result = "or-gate-combinator"
  },
  {
    type = "recipe",
    name = "not-gate-combinator",
    enabled = "false",
    ingredients =
    {
      {"electronic-circuit", 1},
      {"copper-cable", 2}
    },
    result = "not-gate-combinator"
  },
  {
    type = "recipe",
    name = "nand-gate-combinator",
    enabled = "false",
    ingredients =
    {
      {"electronic-circuit", 1},
      {"copper-cable", 2}
    },
    result = "nand-gate-combinator"
  },
  {
    type = "recipe",
    name = "nor-gate-combinator",
    enabled = "false",
    ingredients =
    {
      {"electronic-circuit", 1},
      {"copper-cable", 2}
    },
    result = "nor-gate-combinator"
  },
  {
    type = "recipe",
    name = "xor-gate-combinator",
    enabled = "false",
    ingredients =
    {
      {"electronic-circuit", 1},
      {"copper-cable", 2}
    },
    result = "xor-gate-combinator"
  },
  {
    type = "recipe",
    name = "xnor-gate-combinator",
    enabled = "false",
    ingredients =
    {
      {"electronic-circuit", 1},
      {"copper-cable", 2}
    },
    result = "xnor-gate-combinator"
  }
})