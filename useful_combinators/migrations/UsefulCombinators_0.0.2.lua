for index, force in pairs(game.forces) do
  if force.technologies["useful-combinators"].researched then
    force.recipes["random-combinator"].enabled = true
    --force.recipes["logic-combinator"].enabled = true
    force.recipes["comparator-combinator"].enabled = true
  end
end