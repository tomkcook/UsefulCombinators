local data = {}
local classes = {}
local selected = {}

function save()
  global["uc_data"] = data
end

classes["timer-combinator"] = {
  on_click = function(player, object)
    local gui = player.gui.center.uc["timer-combinator"]
    object.meta.reset = tonumber(gui["reset"].text) or object.meta.reset
    object.meta.ticks = tonumber(gui["ticks"].text) or object.meta.ticks
    if object.meta.running then
      object.meta.running = false
    end
    object.meta.count = 0
  end,
  on_key = function(player, object)
    if not (player.gui.center["uc"]) then
      local gui = player.gui.center
      local uc = gui.add{type = "frame", name = "uc", caption = "Timer Combinator"}
      local layout = uc.add{type = "table", name = "timer-combinator", column_count = 2}
      layout.add{type = "label", caption = "Reset Count: (?)", tooltip = {"timer-combinator.reset"}}
      layout.add{type = "textfield", name = "reset", style = "uc_text", text = object.meta.reset}
      layout.add{type = "label", caption = "Update Interval: (?)", tooltip = {"timer-combinator.ticks"}}
      layout.add{type = "textfield", name = "ticks", style = "uc_text", text = object.meta.ticks}
      layout.add{type = "button", name = "uc-exit", caption = "Ok"}
      layout.add{type = "label", caption = "(extra info)", tooltip = {"timer-combinator.extra"}}
    end
  end,
	on_place = function(entity, item)
		if item ~= nil and item.get_tag("uc_meta") ~= nil then
			local tag = item.get_tag("uc_meta")
      tag.meta.entity = entity
      return { meta = tag.meta }
		end
    return {
      meta = {
        entity = entity,
        count = 0,
        reset = 10,
        running = false,
        ticks = 60
      }
    }
  end,
  on_destroy = function(meta, item)

    item.set_tag("uc_meta", meta)
  end,
  on_tick = function(object)
    local control = object.meta.entity.get_control_behavior()
    if control then
      if control.enabled then
        if get_count(control, {type = "virtual", name = "start-signal"}) > 0 then
          object.meta.running = true
        end
        if get_count(control, {type = "virtual", name = "stop-signal"}) > 0 then
          object.meta.running = false
        end
        if object.meta.running then
          if (object.meta.ticks < 1) then object.meta.ticks = 1 end
          if (object.meta.ticks > 3600) then object.meta.ticks = 3600 end
          if (game.tick % object.meta.ticks) == 0 then
            object.meta.count = object.meta.count + 1
            if object.meta.count > object.meta.reset then
              object.meta.count = 0
            end
            control.parameters = {
              parameters = {
                {signal = {type = "virtual", name = "counting-signal"}, count = object.meta.count, index = 1}
              }
            }
          end
        end
      else
        control.parameters = {
          parameters = {
            {signal = {type = "virtual", name = "counting-signal"}, count = 0, index = 1}
          }
        }
      end
    end
  end
}

classes["counting-combinator"] = {
  on_click = function(player, object)
    local gui = player.gui.center.uc["counting-combinator"]
    object.meta.reset = tonumber(gui["reset"].text) or object.meta.reset
  end,
  on_key = function(player, object)
    if not (player.gui.center["uc"]) then
      local params = object.meta.params
      local gui = player.gui.center
      local uc = gui.add{type = "frame", name = "uc", caption = "Counting Combinator"}
      local layout = uc.add{type = "table", name = "counting-combinator", column_count = 2}
      layout.add{type = "label", caption = "Reset: (?)", tooltip = {"counting-combinator.reset"}}
      layout.add{type = "textfield", name = "reset", style = "uc_text", text = object.meta.reset}
      layout.add{type = "button", name = "uc-exit", caption = "Ok"}
      layout.add{type = "label", caption = "(extra info)", tooltip = {"counting-combinator.extra"}}
    end
  end,
  on_place = function(entity, item)
		if item ~= nil and item.get_tag("uc_meta") ~= nil then
			local tag = item.get_tag("uc_meta")
      tag.meta.entity = entity
      return { meta = tag.meta }
		end
    return {
      meta = {
        entity = entity,
        count = 0,
        reset = -1
      }
    }
  end,
  on_destroy = function(meta, item)

    item.set_tag("uc_meta", meta)
  end,
  on_tick = function(object)
    local control = object.meta.entity.get_control_behavior()
    if control then
      if control.enabled then
        if (object.meta.reset < -1) then object.meta.reset = -1 end
        if (object.meta.count < 0) then object.meta.count = 0 end
        if object.meta.reset > -1 and object.meta.count > object.meta.reset then
          object.meta.count = 0
        end
        object.meta.count = object.meta.count - get_count(control, {type = "virtual", name = "minus-one-signal"})
        object.meta.count = object.meta.count + get_count(control, {type = "virtual", name = "plus-one-signal"})
        if object.meta.reset > -1 and object.meta.count == -1 then
          object.meta.count = object.meta.reset
        end
        control.parameters = {
          parameters = {
            {signal = {type = "virtual", name = "counting-signal"}, count = object.meta.count, index = 1}
          }
        }
      end
    else
      control.parameters = {
        parameters = {
          {signal = {type = "virtual", name = "counting-signal"}, count = 0, index = 1}
        }
      }
    end
  end
}

classes["random-combinator"] = {
  on_click = function(player, object)
    local params = object.meta.params
    local gui = player.gui.center.uc["random-combinator"]
    if gui["signal1"].elem_value and gui["signal1"].elem_value.name then
      object.meta.params[1] = {signal = gui["signal1"].elem_value}
    else
      object.meta.params[1] = {signal = {type = "virtual"}}
    end
    if gui["signal2"].elem_value and gui["signal2"].elem_value.name then
      object.meta.params[2] = {signal = gui["signal2"].elem_value}
    else
      object.meta.params[2] = {signal = {type = "virtual"}}
    end
    object.meta.range.minimum = tonumber(gui["lower"].text) or object.meta.range.minimum
    object.meta.range.maximum = tonumber(gui["upper"].text) or object.meta.range.maximum
    object.meta.ticks = tonumber(gui["ticks"].text) or object.meta.ticks
  end,
  on_key = function(player, object)
    if not (player.gui.center["uc"]) then
      local params = object.meta.params
      local gui = player.gui.center
      local uc = gui.add{type = "frame", name = "uc", caption = "Random Combinator"}
      local layout = uc.add{type = "table", name = "random-combinator", column_count = 2}
      layout.add{type = "label", caption = "Trigger: (?)", tooltip = {"random-combinator.trigger"}}
      if params[1].signal and params[1].signal.name then
        layout.add{type = "choose-elem-button", name = "signal1", elem_type = "signal", signal = params[1].signal}
      else
        layout.add{type = "choose-elem-button", name = "signal1", elem_type = "signal"}
      end
      layout.add{type = "label", caption = "Output: (?)", tooltip = {"random-combinator.output"}}
      if params[2].signal and params[2].signal.name then
        layout.add{type = "choose-elem-button", name = "signal2", elem_type = "signal", signal = params[2].signal}
      else
        layout.add{type = "choose-elem-button", name = "signal2", elem_type = "signal"}
      end
      layout.add{type = "label", caption = "Lower Limit: (?)", tooltip = {"random-combinator.lower"}}
      layout.add{type = "textfield", name = "lower", style = "uc_text", text = object.meta.range.minimum}
      layout.add{type = "label", caption = "Upper  Limit: (?)", tooltip = {"random-combinator.upper"}}
      layout.add{type = "textfield", name = "upper", style = "uc_text", text = object.meta.range.maximum}
      layout.add{type = "label", caption = "Ticks: (?)", tooltip = {"random-combinator.ticks"}}
      layout.add{type = "textfield", name = "ticks", style = "uc_text", text = object.meta.ticks}
      layout.add{type = "button", name = "uc-exit", caption = "Ok"}
    end
  end,
  on_place = function(entity, item)
		if item ~= nil and item.get_tag("uc_meta") ~= nil then
			local tag = item.get_tag("uc_meta")
      tag.meta.entity = entity
      return { meta = tag.meta }
		end
  return {
    meta = {
        entity = entity,
        params = {
          {signal = {type = "virtual", name = "input-signal"}},
          {signal = {type = "virtual", name = "output-signal"}, count = 0},
        },
        range = {
          minimum = 1,
          maximum = 10
        },
        ticks = 60
      }
    }
  end,
  on_destroy = function(meta, item)

    item.set_tag("uc_meta", meta)
  end,
  on_tick = function(object)
    local control = object.meta.entity.get_control_behavior()
    if control then
      local params = object.meta.params
      if params[1].signal and params[1].signal.name then
        if control.enabled then
          if object.meta.range.minimum < 1 then object.meta.range.minimum = 1 end
          if object.meta.range.maximum <= object.meta.range.minimum then object.meta.range.maximum = object.meta.range.minimum + 1 end
          if object.meta.ticks < 1 then object.meta.ticks = 1 end
          if object.meta.ticks > 180 then object.meta.ticks = 180 end
          local count = control.parameters.parameters[1].count or 0
          if get_count(control, params[1].signal) >= 1 then
            count = math.random(object.meta.range.minimum,object.meta.range.maximum)
          end
          if (game.tick % object.meta.ticks) == 0 then
            control.parameters = {
              parameters = {
                {signal = params[2].signal, count = count, index = 1}
              }
            }
          end
        end
      else
        control.parameters = {
          parameters = {
            {signal = {type = "virtual", name = "output-signal"}, count = 0, index = 1}
          }
        }
      end
    end
  end
}

classes["min-combinator"] = {
  on_click = function(player, object)
    local params = object.meta.params
    local gui = player.gui.center.uc["min-combinator"]
    for i = 1,5 do
      if gui["signal"..i].elem_value and gui["signal"..i].elem_value.name then
        object.meta.params[i] = {signal = gui["signal"..i].elem_value}
      else
        object.meta.params[i] = {signal = {type = "virtual"}}
      end
    end
  end,
  on_key = function(player, object)
    if not (player.gui.center["uc"]) then
      local params = object.meta.params
      local gui = player.gui.center
      local uc = gui.add{type = "frame", name = "uc", caption = "Min Combinator"}
      local layout = uc.add{type = "table", name = "min-combinator", column_count = 6}
      layout.add{type = "label", caption = "Filter: (?)", tooltip = {"min-combinator.filter"}}
      for i = 1,5 do
        if params[i].signal and params[i].signal.name then
          layout.add{type = "choose-elem-button", name = "signal"..i, elem_type = "signal", signal = params[i].signal}
        else
          layout.add{type = "choose-elem-button", name = "signal"..i, elem_type = "signal"}
        end
      end
      layout.add{type = "button", name = "uc-exit", caption = "Ok"}
    end
  end,
  on_place = function(entity, item)
		if item ~= nil and item.get_tag("uc_meta") ~= nil then
			local tag = item.get_tag("uc_meta")
      tag.meta.entity = entity
      return { meta = tag.meta }
		end
    return {
      meta = {
        entity = entity,
        params = {
          {signal = {type = "virtual"}},
          {signal = {type = "virtual"}},
          {signal = {type = "virtual"}},
          {signal = {type = "virtual"}},
          {signal = {type = "virtual"}}
        }
      }
    }
  end,
  on_destroy = function(meta, item)

    item.set_tag("uc_meta", meta)
  end,
  on_tick = function(object)
    local control = object.meta.entity.get_control_behavior()
    if control then
      local params = object.meta.params
      if control.enabled then
        local slots = {}
        local signals = get_signals(control)
        local signal = {type = "virtual"}
        local count = math.huge
        for k,v in pairs(signals) do
          count = math.min(count, v.count)
          if count == v.count then
            signal = v.signal
          end
        end
        count = 1
        if count == math.huge then
          count = 0
        end
        for i = 1,5 do
          if params[i].signal and params[i].signal.name then
            if signal.name == params[i].signal.name then
              table.insert(slots, {signal = signal, count = count, index = 1})
              break
            end
          end
        end
        control.parameters = {
          parameters = slots
        }
      else
        control.parameters = {
          parameters = {}
        }
      end
    end
  end
}

classes["max-combinator"] = {
  on_click = function(player, object)
    local params = object.meta.params
    local gui = player.gui.center.uc["max-combinator"]
    for i = 1,5 do
      if gui["signal"..i].elem_value and gui["signal"..i].elem_value.name then
        object.meta.params[i] = {signal = gui["signal"..i].elem_value}
      else
        object.meta.params[i] = {signal = {type = "virtual"}}
      end
    end
  end,
  on_key = function(player, object)
    if not (player.gui.center["uc"]) then
      local params = object.meta.params
      local gui = player.gui.center
      local uc = gui.add{type = "frame", name = "uc", caption = "Max Combinator"}
      local layout = uc.add{type = "table", name = "max-combinator", column_count = 6}
      layout.add{type = "label", caption = "Filter: (?)", tooltip = {"max-combinator.filter"}}
      for i = 1,5 do
        if params[i].signal and params[i].signal.name then
          layout.add{type = "choose-elem-button", name = "signal"..i, elem_type = "signal", signal = params[i].signal}
        else
          layout.add{type = "choose-elem-button", name = "signal"..i, elem_type = "signal"}
        end
      end
      layout.add{type = "button", name = "uc-exit", caption = "Ok"}
    end
  end,
  on_place = function(entity, item)
		if item ~= nil and item.get_tag("uc_meta") ~= nil then
			local tag = item.get_tag("uc_meta")
      tag.meta.entity = entity
      return { meta = tag.meta }
		end
    return {
      meta = {
        entity = entity,
        params = {
          {signal = {type = "virtual"}},
          {signal = {type = "virtual"}},
          {signal = {type = "virtual"}},
          {signal = {type = "virtual"}},
          {signal = {type = "virtual"}}
        },

      }
    }
  end,
  on_destroy = function(meta, item)

    item.set_tag("uc_meta", meta)
  end,
  on_tick = function(object)
    local control = object.meta.entity.get_control_behavior()
    if control then
      local params = object.meta.params
      if control.enabled then
        local slots = {}
        local signals = get_signals(control)
        local signal = {type = "virtual"}
        local count = -math.huge
        for k,v in pairs(signals) do
          count = math.max(count, v.count)
          if count == v.count then
            signal = v.signal
          end
        end
        count = 1
        if count == -math.huge then
          count = 0
        end
        for _,i in pairs(params) do
          if i.signal.name then
            if signal.name == i.signal.name then
              table.insert(slots, {signal = signal, count = count, index = 1})
            end
          end
        end
        control.parameters = {
          parameters = slots
        }
      else
        control.parameters = {
          parameters = {}
        }
      end
    end
  end
}

classes["and-gate-combinator"] = {
  on_click = function(player, object)
    local gui = player.gui.center.uc["and-gate-combinator"]
    local params = object.meta.params
    if gui["signal_a"].elem_value and gui["signal_a"].elem_value.name then
      params[1] = {signal = gui["signal_a"].elem_value}
    else
      params[1] = {signal = {type = "virtual"}}
    end
    if gui["signal_b"].elem_value and gui["signal_b"].elem_value.name then
      params[2] = {signal = gui["signal_b"].elem_value}
    else
      params[2] = {signal = {type = "virtual"}}
    end
    if gui["signal_c"].elem_value and gui["signal_c"].elem_value.name then
      params[3] = {signal = gui["signal_c"].elem_value}
    else
      params[3] = {signal = {type = "virtual"}}
    end
  end,
  on_key = function(player, object)
    if not (player.gui.center["uc"]) then
      local params = object.meta.params
      local gui = player.gui.center
      local uc = gui.add{type = "frame", name = "uc", caption = "AND Gate Combinator"}
      local layout = uc.add{type = "table", name = "and-gate-combinator", column_count = 5}
      if params[1].signal and params[1].signal.name then
        layout.add{type = "choose-elem-button", name = "signal_a", elem_type = "signal", signal = params[1].signal}
      else
        layout.add{type = "choose-elem-button", name = "signal_a", elem_type = "signal"}
      end
      layout.add{type = "label", caption = "AND"}
      if params[2].signal and params[2].signal.name then
        layout.add{type = "choose-elem-button", name = "signal_b", elem_type = "signal", signal = params[2].signal}
      else
        layout.add{type = "choose-elem-button", name = "signal_b", elem_type = "signal"}
      end
      layout.add{type = "label", caption = " = "}
      if params[3].signal and params[3].signal.name then
        layout.add{type = "choose-elem-button", name = "signal_c", elem_type = "signal", signal = params[3].signal}
      else
        layout.add{type = "choose-elem-button", name = "signal_c", elem_type = "signal"}
      end
      layout.add{type = "button", name = "uc-exit", caption = "Ok"}
    end
  end,
  on_place = function(entity, item)
		if item ~= nil and item.get_tag("uc_meta") ~= nil then
			local tag = item.get_tag("uc_meta")
      tag.meta.entity = entity
      return { meta = tag.meta }
		end
    return {
      meta = {
        entity = entity,
        params = {
          {signal = {type = "virtual"}},
          {signal = {type = "virtual"}},
          {signal = {type = "virtual", name = "output-signal"}}
        }
      }
    }
  end,
  on_destroy = function(meta, item)

    item.set_tag("uc_meta", meta)
  end,
  on_tick = function(object)
    local control = object.meta.entity.get_control_behavior()
    if control then
      local params = object.meta.params
      if params[3].signal then
        if control.enabled then
          local slots = {}
          local c1,c2 = 0,0
          if params[1].signal.name then
            c1 = get_count(control, params[1].signal)
          end
          if params[2].signal.name then
            c2 = get_count(control, params[2].signal)
          end
          if params[3].signal.name then
            if (c1 > 0) and (c2 > 0) and (c1 == c2) then
              table.insert(slots, {signal = params[3].signal, count = 1, index = 1})
            else
              table.insert(slots, {signal = params[3].signal, count = 0, index = 1})
            end
          end
          control.parameters = {
            parameters = slots
          }
        end
      else
        control.parameters = {
          parameters = {
            {signal = {type = "virtual", name = "output-signal"}, count = 0, index = 1}
          }
        }
      end
    end
  end
}

classes["nand-gate-combinator"] = {
  on_click = function(player, object)
    local gui = player.gui.center.uc["nand-gate-combinator"]
    local params = object.meta.params
    if gui["signal_a"].elem_value and gui["signal_a"].elem_value.name then
      params[1] = {signal = gui["signal_a"].elem_value}
    else
      params[1] = {signal = {type = "virtual"}}
    end
    if gui["signal_b"].elem_value and gui["signal_b"].elem_value.name then
      params[2] = {signal = gui["signal_b"].elem_value}
    else
      params[2] = {signal = {type = "virtual"}}
    end
    if gui["signal_c"].elem_value and gui["signal_c"].elem_value.name then
      params[3] = {signal = gui["signal_c"].elem_value}
    else
      params[3] = {signal = {type = "virtual"}}
    end
  end,
  on_key = function(player, object)
    if not (player.gui.center["uc"]) then
      local params = object.meta.params
      local gui = player.gui.center
      local uc = gui.add{type = "frame", name = "uc", caption = "NAND Gate Combinator"}
      local layout = uc.add{type = "table", name = "nand-gate-combinator", column_count = 5}
      if params[1].signal and params[1].signal.name then
        layout.add{type = "choose-elem-button", name = "signal_a", elem_type = "signal", signal = params[1].signal}
      else
        layout.add{type = "choose-elem-button", name = "signal_a", elem_type = "signal"}
      end
      layout.add{type = "label", caption = "NAND"}
      if params[2].signal and params[2].signal.name then
        layout.add{type = "choose-elem-button", name = "signal_b", elem_type = "signal", signal = params[2].signal}
      else
        layout.add{type = "choose-elem-button", name = "signal_b", elem_type = "signal"}
      end
      layout.add{type = "label", caption = " = "}
      if params[3].signal and params[3].signal.name then
        layout.add{type = "choose-elem-button", name = "signal_c", elem_type = "signal", signal = params[3].signal}
      else
        layout.add{type = "choose-elem-button", name = "signal_c", elem_type = "signal"}
      end
      layout.add{type = "button", name = "uc-exit", caption = "Ok"}
    end
  end,
  on_place = function(entity, item)
		if item ~= nil and item.get_tag("uc_meta") ~= nil then
			local tag = item.get_tag("uc_meta")
      tag.meta.entity = entity
      return { meta = tag.meta }
		end
    return {
      meta = {
        entity = entity,
        params = {
          {signal = {type = "virtual"}},
          {signal = {type = "virtual"}},
          {signal = {type = "virtual", name = "output-signal"}}
        }
      }
    }
  end,
  on_destroy = function(meta, item)

    item.set_tag("uc_meta", meta)
  end,
  on_tick = function(object)
    local control = object.meta.entity.get_control_behavior()
    if control then
      local params = object.meta.params
      if params[3].signal then
        if control.enabled then
          local slots = {}
          local c1,c2 = 0,0
          if params[1].signal.name then
            c1 = get_count(control, params[1].signal)
          end
          if params[2].signal.name then
            c2 = get_count(control, params[2].signal)
          end
          if params[3].signal.name then
            if (c1 > 0) and (c2 > 0) and (c1 == c2) then
              table.insert(slots, {signal = params[3].signal, count = 0, index = 1})
            else
              table.insert(slots, {signal = params[3].signal, count = 1, index = 1})
            end
          end
          control.parameters = {
            parameters = slots
          }
        end
      else
        control.parameters = {
          parameters = {
            {signal = {type = "virtual", name = "output-signal"}, count = 0, index = 1}
          }
        }
      end
    end
  end
}

classes["nor-gate-combinator"] = {
  on_click = function(player, object)
    local gui = player.gui.center.uc["nor-gate-combinator"]
    local params = object.meta.params
    if gui["signal_a"].elem_value and gui["signal_a"].elem_value.name then
      params[1] = {signal = gui["signal_a"].elem_value}
    else
      params[1] = {signal = {type = "virtual"}}
    end
    if gui["signal_b"].elem_value and gui["signal_b"].elem_value.name then
      params[2] = {signal = gui["signal_b"].elem_value}
    else
      params[2] = {signal = {type = "virtual"}}
    end
    if gui["signal_c"].elem_value and gui["signal_c"].elem_value.name then
      params[3] = {signal = gui["signal_c"].elem_value}
    else
      params[3] = {signal = {type = "virtual"}}
    end
  end,
  on_key = function(player, object)
    if not (player.gui.center["uc"]) then
      local params = object.meta.params
      local gui = player.gui.center
      local uc = gui.add{type = "frame", name = "uc", caption = "NOR Gate Combinator"}
      local layout = uc.add{type = "table", name = "nor-gate-combinator", column_count = 5}
      if params[1].signal and params[1].signal.name then
        layout.add{type = "choose-elem-button", name = "signal_a", elem_type = "signal", signal = params[1].signal}
      else
        layout.add{type = "choose-elem-button", name = "signal_a", elem_type = "signal"}
      end
      layout.add{type = "label", caption = "NOR"}
      if params[2].signal and params[2].signal.name then
        layout.add{type = "choose-elem-button", name = "signal_b", elem_type = "signal", signal = params[2].signal}
      else
        layout.add{type = "choose-elem-button", name = "signal_b", elem_type = "signal"}
      end
      layout.add{type = "label", caption = " = "}
      if params[3].signal and params[3].signal.name then
        layout.add{type = "choose-elem-button", name = "signal_c", elem_type = "signal", signal = params[3].signal}
      else
        layout.add{type = "choose-elem-button", name = "signal_c", elem_type = "signal"}
      end
      layout.add{type = "button", name = "uc-exit", caption = "Ok"}
    end
  end,
  on_place = function(entity, item)
		if item ~= nil and item.get_tag("uc_meta") ~= nil then
			local tag = item.get_tag("uc_meta")
      tag.meta.entity = entity
      return { meta = tag.meta }
		end
    return {
      meta = {
        entity = entity,
        params = {
          {signal = {type = "virtual"}},
          {signal = {type = "virtual"}},
          {signal = {type = "virtual", name = "output-signal"}}
        }
      }
    }
  end,
  on_destroy = function(meta, item)

    item.set_tag("uc_meta", meta)
  end,
  on_tick = function(object)
    local control = object.meta.entity.get_control_behavior()
    if control then
      local params = object.meta.params
      if params[3].signal then
        if control.enabled then
          local slots = {}
          local c1,c2 = 0,0
          if params[1].signal.name then
            c1 = get_count(control, params[1].signal)
          end
          if params[2].signal.name then
            c2 = get_count(control, params[2].signal)
          end
          if params[3].signal.name then
            if (c1 >= 1) or (c2 >= 1) then
              table.insert(slots, {signal = params[3].signal, count = 0, index = 1})
            else
              table.insert(slots, {signal = params[3].signal, count = 1, index = 1})
            end
          end
          control.parameters = {
            parameters = slots
          }
        end
      else
        control.parameters = {
          parameters = {
            {signal = {type = "virtual", name = "output-signal"}, count = 0, index = 1}
          }
        }
      end
    end
  end
}

classes["not-gate-combinator"] = {
  on_click = function(player, object)
    local gui = player.gui.center.uc["not-gate-combinator"]
    local params = object.meta.params
    if gui["signal_a"].elem_value and gui["signal_a"].elem_value.name then
      params[1] = {signal = gui["signal_a"].elem_value}
    else
      params[1] = {signal = {type = "virtual"}}
    end
    if gui["signal_b"].elem_value and gui["signal_b"].elem_value.name then
      params[2] = {signal = gui["signal_b"].elem_value}
    else
      params[2] = {signal = {type = "virtual"}}
    end
  end,
  on_key = function(player, object)
    if not (player.gui.center["uc"]) then
      local params = object.meta.params
      local gui = player.gui.center
      local uc = gui.add{type = "frame", name = "uc", caption = "NOT Gate Combinator"}
      local layout = uc.add{type = "table", name = "not-gate-combinator", column_count = 4}
      layout.add{type = "label", caption = "NOT"}
      if params[1].signal and params[1].signal.name then
        layout.add{type = "choose-elem-button", name = "signal_a", elem_type = "signal", signal = params[1].signal}
      else
        layout.add{type = "choose-elem-button", name = "signal_a", elem_type = "signal"}
      end
      layout.add{type = "label", caption = " = "}
      if params[2].signal and params[2].signal.name then
        layout.add{type = "choose-elem-button", name = "signal_b", elem_type = "signal", signal = params[2].signal}
      else
        layout.add{type = "choose-elem-button", name = "signal_b", elem_type = "signal"}
      end
      layout.add{type = "button", name = "uc-exit", caption = "Ok"}
    end
  end,
  on_place = function(entity, item)
		if item ~= nil and item.get_tag("uc_meta") ~= nil then
			local tag = item.get_tag("uc_meta")
      tag.meta.entity = entity
      return { meta = tag.meta }
		end
    return {
      meta = {
        entity = entity,
        params = {
          {signal = {type = "virtual"}},
          {signal = {type = "virtual", name = "output-signal"}}
        }
      }
    }
  end,
  on_destroy = function(meta, item)

    item.set_tag("uc_meta", meta)
  end,
  on_tick = function(object)
    local control = object.meta.entity.get_control_behavior()
    if control then
      local params = object.meta.params
      if params[2].signal then
        if control.enabled then
          local slots = {}
          local c1,c2 = 0,0
          if params[1].signal.name then
            c1 = get_count(control, params[1].signal)
          end
          if params[2].signal.name then
            if (c1 > 0) then
              table.insert(slots, {signal = params[2].signal, count = 0, index = 1})
            else
              table.insert(slots, {signal = params[2].signal, count = 1, index = 1})
            end
          end
          control.parameters = {
            parameters = slots
          }
        end
      else
        control.parameters = {
          parameters = {
            {signal = {type = "virtual", name = "output-signal"}, count = 0, index = 1}
          }
        }
      end
    end
  end
}

classes["or-gate-combinator"] = {
  on_click = function(player, object)
    local gui = player.gui.center.uc["or-gate-combinator"]
    local params = object.meta.params
    if gui["signal_a"].elem_value and gui["signal_a"].elem_value.name then
      params[1] = {signal = gui["signal_a"].elem_value}
    else
      params[1] = {signal = {type = "virtual"}}
    end
    if gui["signal_b"].elem_value and gui["signal_b"].elem_value.name then
      params[2] = {signal = gui["signal_b"].elem_value}
    else
      params[2] = {signal = {type = "virtual"}}
    end
    if gui["signal_c"].elem_value and gui["signal_c"].elem_value.name then
      params[3] = {signal = gui["signal_c"].elem_value}
    else
      params[3] = {signal = {type = "virtual"}}
    end
  end,
  on_key = function(player, object)
    if not (player.gui.center["uc"]) then
      local params = object.meta.params
      local gui = player.gui.center
      local uc = gui.add{type = "frame", name = "uc", caption = "OR Gate Combinator"}
      local layout = uc.add{type = "table", name = "or-gate-combinator", column_count = 5}
      if params[1].signal and params[1].signal.name then
        layout.add{type = "choose-elem-button", name = "signal_a", elem_type = "signal", signal = params[1].signal}
      else
        layout.add{type = "choose-elem-button", name = "signal_a", elem_type = "signal"}
      end
      layout.add{type = "label", caption = "OR"}
      if params[2].signal and params[2].signal.name then
        layout.add{type = "choose-elem-button", name = "signal_b", elem_type = "signal", signal = params[2].signal}
      else
        layout.add{type = "choose-elem-button", name = "signal_b", elem_type = "signal"}
      end
      layout.add{type = "label", caption = " = "}
      if params[3].signal and params[3].signal.name then
        layout.add{type = "choose-elem-button", name = "signal_c", elem_type = "signal", signal = params[3].signal}
      else
        layout.add{type = "choose-elem-button", name = "signal_c", elem_type = "signal"}
      end
      layout.add{type = "button", name = "uc-exit", caption = "Ok"}
    end
  end,
  on_place = function(entity, item)
		if item ~= nil and item.get_tag("uc_meta") ~= nil then
			local tag = item.get_tag("uc_meta")
      tag.meta.entity = entity
      return { meta = tag.meta }
		end
    return {
      meta = {
        entity = entity,
        params = {
          {signal = {type = "virtual"}},
          {signal = {type = "virtual"}},
          {signal = {type = "virtual", name = "output-signal"}}
        }
      }
    }
  end,
  on_destroy = function(meta, item)

    item.set_tag("uc_meta", meta)
  end,
  on_tick = function(object)
    local control = object.meta.entity.get_control_behavior()
    if control then
      local params = object.meta.params
      if params[3].signal then
        if control.enabled then
          local slots = {}
          local c1,c2 = 0,0
          if params[1].signal.name then
            c1 = get_count(control, params[1].signal)
          end
          if params[2].signal.name then
            c2 = get_count(control, params[2].signal)
          end
          if params[3].signal.name then
            if (c1 >= 1) or (c2 >= 1) then
              table.insert(slots, {signal = params[3].signal, count = 1, index = 1})
            else
              table.insert(slots, {signal = params[3].signal, count = 0, index = 1})
            end
          end
          control.parameters = {
            parameters = slots
          }
        end
      else
        control.parameters = {
          parameters = {
            {signal = {type = "virtual", name = "output-signal"}, count = 0, index = 1}
          }
        }
      end
    end
  end
}

classes["xnor-gate-combinator"] = {
  on_click = function(player, object)
    local gui = player.gui.center.uc["xnor-gate-combinator"]
    local params = object.meta.params
    if gui["signal_a"].elem_value and gui["signal_a"].elem_value.name then
      params[1] = {signal = gui["signal_a"].elem_value}
    else
      params[1] = {signal = {type = "virtual"}}
    end
    if gui["signal_b"].elem_value and gui["signal_b"].elem_value.name then
      params[2] = {signal = gui["signal_b"].elem_value}
    else
      params[2] = {signal = {type = "virtual"}}
    end
    if gui["signal_c"].elem_value and gui["signal_c"].elem_value.name then
      params[3] = {signal = gui["signal_c"].elem_value}
    else
      params[3] = {signal = {type = "virtual"}}
    end
  end,
  on_key = function(player, object)
    if not (player.gui.center["uc"]) then
      local params = object.meta.params
      local gui = player.gui.center
      local uc = gui.add{type = "frame", name = "uc", caption = "XNOR Gate Combinator"}
      local layout = uc.add{type = "table", name = "xnor-gate-combinator", column_count = 5}
      if params[1].signal and params[1].signal.name then
        layout.add{type = "choose-elem-button", name = "signal_a", elem_type = "signal", signal = params[1].signal}
      else
        layout.add{type = "choose-elem-button", name = "signal_a", elem_type = "signal"}
      end
      layout.add{type = "label", caption = "XNOR"}
      if params[2].signal and params[2].signal.name then
        layout.add{type = "choose-elem-button", name = "signal_b", elem_type = "signal", signal = params[2].signal}
      else
        layout.add{type = "choose-elem-button", name = "signal_b", elem_type = "signal"}
      end
      layout.add{type = "label", caption = " = "}
      if params[3].signal and params[3].signal.name then
        layout.add{type = "choose-elem-button", name = "signal_c", elem_type = "signal", signal = params[3].signal}
      else
        layout.add{type = "choose-elem-button", name = "signal_c", elem_type = "signal"}
      end
      layout.add{type = "button", name = "uc-exit", caption = "Ok"}
    end
  end,
  on_place = function(entity, item)
		if item ~= nil and item.get_tag("uc_meta") ~= nil then
			local tag = item.get_tag("uc_meta")
      tag.meta.entity = entity
      return { meta = tag.meta }
		end
    return {
      meta = {
        entity = entity,
        params = {
          {signal = {type = "virtual"}},
          {signal = {type = "virtual"}},
          {signal = {type = "virtual", name = "output-signal"}}
        }
      }
    }
  end,
  on_destroy = function(meta, item)

    item.set_tag("uc_meta", meta)
  end,
  on_tick = function(object)
    local control = object.meta.entity.get_control_behavior()
    if control then
      local params = object.meta.params
      if params[3].signal then
        if control.enabled then
          local slots = {}
          local c1,c2 = 0,0
          if params[1].signal.name then
            c1 = get_count(control, params[1].signal)
          end
          if params[2].signal.name then
            c2 = get_count(control, params[2].signal)
          end
          if params[3].signal.name then
            if (c1 == c2) then
              table.insert(slots, {signal = params[3].signal, count = 1, index = 1})
            else
              table.insert(slots, {signal = params[3].signal, count = 0, index = 1})
            end
          end
          control.parameters = {
            parameters = slots
          }
        end
      else
        control.parameters = {
          parameters = {
            {signal = {type = "virtual", name = "output-signal"}, count = 0, index = 1}
          }
        }
      end
    end
  end
}

classes["xor-gate-combinator"] = {
  on_click = function(player, object)
    local gui = player.gui.center.uc["xor-gate-combinator"]
    local params = object.meta.params
    if gui["signal_a"].elem_value and gui["signal_a"].elem_value.name then
      params[1] = {signal = gui["signal_a"].elem_value}
    else
      params[1] = {signal = {type = "virtual"}}
    end
    if gui["signal_b"].elem_value and gui["signal_b"].elem_value.name then
      params[2] = {signal = gui["signal_b"].elem_value}
    else
      params[2] = {signal = {type = "virtual"}}
    end
    if gui["signal_c"].elem_value and gui["signal_c"].elem_value.name then
      params[3] = {signal = gui["signal_c"].elem_value}
    else
      params[3] = {signal = {type = "virtual"}}
    end
  end,
  on_key = function(player, object)
    if not (player.gui.center["uc"]) then
      local params = object.meta.params
      local gui = player.gui.center
      local uc = gui.add{type = "frame", name = "uc", caption = "XOR Gate Combinator"}
      local layout = uc.add{type = "table", name = "xor-gate-combinator", column_count = 5}
      if params[1].signal and params[1].signal.name then
        layout.add{type = "choose-elem-button", name = "signal_a", elem_type = "signal", signal = params[1].signal}
      else
        layout.add{type = "choose-elem-button", name = "signal_a", elem_type = "signal"}
      end
      layout.add{type = "label", caption = "XOR"}
      if params[2].signal and params[2].signal.name then
        layout.add{type = "choose-elem-button", name = "signal_b", elem_type = "signal", signal = params[2].signal}
      else
        layout.add{type = "choose-elem-button", name = "signal_b", elem_type = "signal"}
      end
      layout.add{type = "label", caption = " = "}
      if params[3].signal and params[3].signal.name then
        layout.add{type = "choose-elem-button", name = "signal_c", elem_type = "signal", signal = params[3].signal}
      else
        layout.add{type = "choose-elem-button", name = "signal_c", elem_type = "signal"}
      end
      layout.add{type = "button", name = "uc-exit", caption = "Ok"}
    end
  end,
  on_place = function(entity, item)
		if item ~= nil and item.get_tag("uc_meta") ~= nil then
			local tag = item.get_tag("uc_meta")
      tag.meta.entity = entity
      return { meta = tag.meta }
		end
    return {
      meta = {
        entity = entity,
        params = {
          {signal = {type = "virtual"}},
          {signal = {type = "virtual"}},
          {signal = {type = "virtual", name = "output-signal"}}
        }
      }
    }
  end,
  on_destroy = function(meta, item)

    item.set_tag("uc_meta", meta)
  end,
  on_tick = function(object)
    local control = object.meta.entity.get_control_behavior()
    if control then
      local params = object.meta.params
      if params[3].signal then
        if control.enabled then
          local slots = {}
          local c1,c2 = 0,0
          if params[1].signal.name then
            c1 = get_count(control, params[1].signal)
          end
          if params[2].signal.name then
            c2 = get_count(control, params[2].signal)
          end
          if params[3].signal.name then
            if (c1 == c2) then
              table.insert(slots, {signal = params[3].signal, count = 0, index = 1})
            else
              table.insert(slots, {signal = params[3].signal, count = 1, index = 1})
            end
          end
          control.parameters = {
            parameters = slots
          }
        end
      else
        control.parameters = {
          parameters = {
            {signal = {type = "virtual", name = "output-signal"}, count = 0, index = 1}
          }
        }
      end
    end
  end
}

classes["converter-combinator"] = {
  on_click = function(player, object)
    local gui = player.gui.center
    for i = 1,5 do
      if gui["uc"]["converter-combinator"]["from"..i].elem_value and gui["uc"]["converter-combinator"]["from"..i].elem_value.name then
        object.meta.params["from"][i] = {signal = gui["uc"]["converter-combinator"]["from"..i].elem_value}
      else
        object.meta.params["from"][i] = {type = "virtual"}
      end
      if gui["uc"]["converter-combinator"]["to"..i].elem_value and gui["uc"]["converter-combinator"]["to"..i].elem_value.name then
        object.meta.params["to"][i] = {signal = gui["uc"]["converter-combinator"]["to"..i].elem_value}
      else
        object.meta.params["to"][i] = {type = "virtual"}
      end
    end
  end,
  on_key = function(player, object)
    if not (player.gui.center["uc"]) then
      local params = object.meta.params
      local gui = player.gui.center
      local uc = gui.add{type = "frame", name = "uc", caption = "Converter Combinator"}
      local layout = uc.add{type = "table", name = "converter-combinator", column_count = 2}
      layout.add{type = "label", caption = "From: (?)", tooltip = {"converter-combinator.from"}}
      layout.add{type = "label", caption = "To: (?)", tooltip = {"converter-combinator.to"}}
      for i = 1,5 do
        if params["from"][i].signal and params["from"][i].signal.name then
          layout.add{type = "choose-elem-button", name = "from"..i, elem_type = "signal", signal = params["from"][i].signal}
        else
          layout.add{type = "choose-elem-button", name = "from"..i, elem_type = "signal"}
        end
        if params["to"][i].signal and params["to"][i].signal.name then
          layout.add{type = "choose-elem-button", name = "to"..i, elem_type = "signal", signal = params["to"][i].signal}
        else
          layout.add{type = "choose-elem-button", name = "to"..i, elem_type = "signal"}
        end
      end
      layout.add{type = "button", name = "uc-exit", caption = "Ok"}
    end
  end,
  on_place = function(entity, item)
		if item ~= nil and item.get_tag("uc_meta") ~= nil then
			local tag = item.get_tag("uc_meta")
      tag.meta.entity = entity
      return { meta = tag.meta }
		end
    return {
      meta = {
        entity = entity,
        params = {
          from = {
            {signal = {type = "virtual"}},
            {signal = {type = "virtual"}},
            {signal = {type = "virtual"}},
            {signal = {type = "virtual"}},
            {signal = {type = "virtual"}}
          },
          to = {
            {signal = {type = "virtual"}},
            {signal = {type = "virtual"}},
            {signal = {type = "virtual"}},
            {signal = {type = "virtual"}},
            {signal = {type = "virtual"}}
          }
        }
      }
    }
  end,
  on_destroy = function(meta, item)

    item.set_tag("uc_meta", meta)
  end,
  on_tick = function(object)
    local control = object.meta.entity.get_control_behavior()
    if control then
      if control.enabled then
        local slots = {}
        local params = object.meta.params
        if not params["from"] and not params["to"] then
          object.meta.params = {
            from = {
              {signal = {type = "virtual"}},
              {signal = {type = "virtual"}},
              {signal = {type = "virtual"}},
              {signal = {type = "virtual"}},
              {signal = {type = "virtual"}}
            },
            to = {
              {signal = {type = "virtual"}},
              {signal = {type = "virtual"}},
              {signal = {type = "virtual"}},
              {signal = {type = "virtual"}},
              {signal = {type = "virtual"}}
            }
          }
          params = object.meta.params
        end
        for i = 1,5 do
          if params["to"][i].signal and params["to"][i].signal.name then
            table.insert(slots, {signal = params["to"][i].signal, count = get_count(control, params["from"][i].signal), index = i})
          end
        end
        control.parameters = {
            parameters = slots
          }
      else
        control.parameters = {
          parameters = {}
        }
      end
    end
  end
}

classes["detector-combinator"] = {
  on_click = function(player, object)
    local gui = player.gui.center
    if gui["uc"]["detector-combinator"]["signal"].elem_value and gui["uc"]["detector-combinator"]["signal"].elem_value.name then
      object.meta.signal = gui["uc"]["detector-combinator"]["signal"].elem_value
    else
      object.meta.signal = {type = "virtual"}
    end
    object.meta.radius = tonumber(gui["uc"]["detector-combinator"]["radius"].text) or object.meta.radius
  end,
  on_key = function(player, object)
    if not (player.gui.center["uc"]) then
      local meta = object.meta
      local gui = player.gui.center
      local uc = gui.add{type = "frame", name = "uc", caption = "Detector Combinator"}
      local layout = uc.add{type = "table", name = "detector-combinator", column_count = 4}
      layout.add{type = "label", caption = "Radius: (?)", tooltip = {"detector-combinator.radius"}}
      layout.add{type = "textfield", name = "radius", style = "uc_text", text = meta.radius}
      layout.add{type = "label", caption = "Signal: (?)", tooltip = {"detector-combinator.signal"}}
      if meta.signal and meta.signal.name then
        layout.add{type = "choose-elem-button", name = "signal", elem_type = "signal", signal = meta.signal}
      else
        layout.add{type = "choose-elem-button", name = "signal", elem_type = "signal"}
      end
      layout.add{type = "button", name = "uc-exit", caption = "Ok"}
    end
  end,
  on_place = function(entity, item)
		if item ~= nil and item.get_tag("uc_meta") ~= nil then
			local tag = item.get_tag("uc_meta")
      tag.meta.entity = entity
      return { meta = tag.meta }
		end
    return {
      meta = {
        entity = entity,
        radius = 24,
        signal = {type = "virtual", name = "output-signal"}
      }
    }
  end,
  on_destroy = function(meta, item)

    item.set_tag("uc_meta", meta)
  end,
  on_tick = function(object)
    local control = object.meta.entity.get_control_behavior()
    if control then
      local signal = object.meta.signal
      if signal then
        if control.enabled then
          local r = object.meta.radius
          if r > 24 then
            r = 24
            object.meta.radius = 24
          end
          if r < 1 then
            r = 1
            object.meta.radius = 1
          end
          local slots = {}
          local pos = object.meta.entity.position
          local units = #object.meta.entity.surface.find_enemy_units(object.meta.entity.position, r + 0.5)
          if signal.name then
            table.insert(slots, {signal = signal, count = units, index = 1})
          end
          control.parameters = {
            parameters = slots
          }
        end
      else
        control.parameters = {
          parameters = {
            {signal = {type = "virtual", name = "output-signal"}, count = 0, index = 1}
          }
        }
      end
    end
  end
}

classes["sensor-combinator"] = {
  on_click = function(player, object)
    local gui = player.gui.center
    if gui["uc"]["sensor-combinator"]["signal"].elem_value and gui["uc"]["sensor-combinator"]["signal"].elem_value.name then
      object.meta.signal = gui["uc"]["sensor-combinator"]["signal"].elem_value
    else
      object.meta.signal = {type = "virtual"}
    end
    object.meta.radius = tonumber(gui["uc"]["sensor-combinator"]["radius"].text) or object.meta.radius
  end,
  on_key = function(player, object)
    if not (player.gui.center["uc"]) then
      local meta = object.meta
      local gui = player.gui.center
      local uc = gui.add{type = "frame", name = "uc", caption = "Sensor Combinator"}
      local layout = uc.add{type = "table", name = "sensor-combinator", column_count = 4}
      layout.add{type = "label", caption = "Radius: (?)", tooltip = {"sensor-combinator.radius"}}
      layout.add{type = "textfield", name = "radius", style = "uc_text", text = meta.radius}
      layout.add{type = "label", caption = "Signal: (?)", tooltip = {"sensor-combinator.signal"}}
      if meta.signal and meta.signal.name then
        layout.add{type = "choose-elem-button", name = "signal", elem_type = "signal", signal = meta.signal}
      else
        layout.add{type = "choose-elem-button", name = "signal", elem_type = "signal"}
      end
      layout.add{type = "button", name = "uc-exit", caption = "Ok"}
    end
  end,
  on_place = function(entity, item)
		if item ~= nil and item.get_tag("uc_meta") ~= nil then
			local tag = item.get_tag("uc_meta")
      tag.meta.entity = entity
      return { meta = tag.meta }
		end
    return {
      meta = {
        entity = entity,
        radius = 24,
        signal = {type = "virtual", name = "output-signal"}
      }
    }
  end,
  on_destroy = function(meta, item)

    item.set_tag("uc_meta", meta)
  end,
  on_tick = function(object)
    local control = object.meta.entity.get_control_behavior()
    if control then
      local signal = object.meta.signal
      if signal then
        if control.enabled then
          local r = object.meta.radius
          if r > 24 then
            r = 24
            object.meta.radius = 24
          end
          if r < 1 then
            r = 1
            object.meta.radius = 1
          end
          local slots = {}
          local pos = object.meta.entity.position
          local units = object.meta.entity.surface.count_entities_filtered(
          {
            area = {{pos.x - (r + 0.5), pos.y - (r + 0.5)}, {pos.x + (r + 0.5), pos.y + (r + 0.5)}},
            type = "player"
          })
          if signal.name then
            table.insert(slots, {signal = signal, count = units, index = 1})
          end
          control.parameters = {
            parameters = slots
          }
        end
      else
        control.parameters = {
          parameters = {
            {signal = {type = "virtual", name = "output-signal"}, count = 0, index = 1}
          }
        }
      end
    end
  end
}

classes["railway-combinator"] = {
  on_click = function(player, object)
    local gui = player.gui.center
    if gui["uc"]["railway-combinator"]["signal"].elem_value and gui["uc"]["railway-combinator"]["signal"].elem_value.name then
      object.meta.signal = gui["uc"]["railway-combinator"]["signal"].elem_value
    else
      object.meta.signal = {type = "virtual"}
    end
  end,
  on_key = function(player, object)
    if not (player.gui.center["uc"]) then
      local meta = object.meta
      local gui = player.gui.center
      local uc = gui.add{type = "frame", name = "uc", caption = "Railway Combinator"}
      local layout = uc.add{type = "table", name = "railway-combinator", column_count = 2}
      layout.add{type = "label", caption = "Output: (?)", tooltip = {"railway-combinator.output"}}
      if meta.signal and meta.signal.name then
        layout.add{type = "choose-elem-button", name = "signal", elem_type = "signal", signal = meta.signal}
      else
        layout.add{type = "choose-elem-button", name = "signal", elem_type = "signal"}
      end
      layout.add{type = "button", name = "uc-exit", caption = "Ok"}
    end
  end,
  on_place = function(entity, item)
		if item ~= nil and item.get_tag("uc_meta") ~= nil then
			local tag = item.get_tag("uc_meta")
      tag.meta.entity = entity
      return { meta = tag.meta }
		end
    return {
      meta = {
        entity = entity,
        signal = {type = "virtual", name = "output-signal"}
      }
    }
  end,
  on_destroy = function(meta, item)

    item.set_tag("uc_meta", meta)
  end,
  on_tick = function(object)
    local control = object.meta.entity.get_control_behavior()
    if control then
      local output = object.meta.signal
      if output then
        if control.enabled then
          local slots = {}
          local pos = object.meta.entity.position
          local units = object.meta.entity.surface.count_entities_filtered(
            {
              area = {{pos.x - 1, pos.y - 1}, {pos.x + 1, pos.y + 1}},
              type = "locomotive"
            })
          if output.name then
            table.insert(slots, {signal = output, count = units, index = 1})
          end
          control.parameters = {
            parameters = slots
          }
        end
      else
        control.parameters = {
          parameters = {
            {signal = {type = "virtual", name = "output-signal"}, count = 0, index = 1}
          }
        }
      end
    end
  end
}

classes["color-combinator"] = {
  on_click = function(player, object)
    local gui = player.gui.center
    for i = 1,6 do
      if gui["uc"]["color-combinator"]["signal"..i].elem_value and gui["uc"]["color-combinator"]["signal"..i].elem_value.name then
        object.meta.params[i] = {signal = gui["uc"]["color-combinator"]["signal"..i].elem_value, count = tonumber(gui["uc"]["color-combinator"]["count"..i].text) or object.meta.params[i].count}
      else
        object.meta.params[i] = {signal = {type = "virtual"}, count = 0}
      end
    end
  end,
  on_key = function(player, object)
    if not (player.gui.center["uc"]) then
      local gui = player.gui.center
      local params = object.meta.params
      local uc = gui.add{type = "frame", name = "uc", caption = "Color Combinator"}
      local layout = uc.add{type = "table", name = "color-combinator", column_count = 4}
      for i = 1,6 do
        if i == 1 then
          layout.add{type = "label", caption = "Red: (?)", tooltip = {"color-combinator.red"}}
          if params[i].signal and params[i].signal.name then
            layout.add{type = "choose-elem-button", name = "signal"..i, elem_type = "signal", signal = params[i].signal}
          else
            layout.add{type = "choose-elem-button", name = "signal"..i, elem_type = "signal"}
          end
          layout.add{type = "label", caption = " = "}
          layout.add{type = "textfield", name = "count"..i, style = "uc_text", text = params[i].count or 0}
        elseif i == 2 then
          layout.add{type = "label", caption = "Green: (?)", tooltip = {"color-combinator.green"}}
          if params[i].signal and params[i].signal.name then
            layout.add{type = "choose-elem-button", name = "signal"..i, elem_type = "signal", signal = params[i].signal}
          else
            layout.add{type = "choose-elem-button", name = "signal"..i, elem_type = "signal"}
          end
          layout.add{type = "label", caption = " = "}
          layout.add{type = "textfield", name = "count"..i, style = "uc_text", text = params[i].count or i}
        elseif i == 3 then
          layout.add{type = "label", caption = "Blue: (?)", tooltip = {"color-combinator.blue"}}
          if params[i].signal and params[i].signal.name then
            layout.add{type = "choose-elem-button", name = "signal"..i, elem_type = "signal", signal = params[i].signal}
          else
            layout.add{type = "choose-elem-button", name = "signal"..i, elem_type = "signal"}
          end
          layout.add{type = "label", caption = " = "}
          layout.add{type = "textfield", name = "count"..i, style = "uc_text", text = params[i].count or i}
        elseif i == 4 then
          layout.add{type = "label", caption = "Yellow: (?)", tooltip = {"color-combinator.yellow"}}
          if params[i].signal and params[i].signal.name then
            layout.add{type = "choose-elem-button", name = "signal"..i, elem_type = "signal", signal = params[i].signal}
          else
            layout.add{type = "choose-elem-button", name = "signal"..i, elem_type = "signal"}
          end
          layout.add{type = "label", caption = " = "}
          layout.add{type = "textfield", name = "count"..i, style = "uc_text", text = params[i].count or i}
        elseif i == 5 then
          layout.add{type = "label", caption = "Magenta: (?)", tooltip = {"color-combinator.magenta"}}
          if params[i].signal and params[i].signal.name then
            layout.add{type = "choose-elem-button", name = "signal"..i, elem_type = "signal", signal = params[i].signal}
          else
            layout.add{type = "choose-elem-button", name = "signal"..i, elem_type = "signal"}
          end
          layout.add{type = "label", caption = " = "}
          layout.add{type = "textfield", name = "count"..i, style = "uc_text", text = params[i].count or i}
        elseif i == 6 then
          layout.add{type = "label", caption = "Cyan: (?)", tooltip = {"color-combinator.cyan"}}
          if params[i].signal and params[i].signal.name then
            layout.add{type = "choose-elem-button", name = "signal"..i, elem_type = "signal", signal = params[i].signal}
          else
            layout.add{type = "choose-elem-button", name = "signal"..i, elem_type = "signal"}
          end
          layout.add{type = "label", caption = " = "}
          layout.add{type = "textfield", name = "count"..i, style = "uc_text", text = params[i].count or i}
        end
      end
      layout.add{type = "button", name = "uc-exit", caption = "Ok"}
    end
  end,
  on_place = function(entity, item)
		if item ~= nil and item.get_tag("uc_meta") ~= nil then
			local tag = item.get_tag("uc_meta")
      tag.meta.entity = entity
      return { meta = tag.meta }
		end
    return {
      meta = {
        entity = entity,
        params = {
          {signal = {type = "virtual", name = "red-signal"}, count = 1},
          {signal = {type = "virtual", name = "green-signal"}, count = 2},
          {signal = {type = "virtual", name = "blue-signal"}, count = 3},
          {signal = {type = "virtual", name = "yellow-signal"}, count = 4},
          {signal = {type = "virtual", name = "magenta-signal"}, count = 5},
          {signal = {type = "virtual", name = "cyan-signal"}, count = 6}
        }
      }
    }
  end,
  on_destroy = function(meta, item)

    item.set_tag("uc_meta", meta)
  end,
  on_tick = function(object)
    local control = object.meta.entity.get_control_behavior()
    if control then
      local params = object.meta.params
      if control.enabled then
        local slots = {
          {signal = {type = "virtual", name = "signal-red"}, count = 0, index = 1},
          {signal = {type = "virtual", name = "signal-green"}, count = 0, index = 2},
          {signal = {type = "virtual", name = "signal-blue"}, count = 0, index = 3},
          {signal = {type = "virtual", name = "signal-yellow"}, count = 0, index = 4},
          {signal = {type = "virtual", name = "signal-pink"}, count = 0, index = 5},
          {signal = {type = "virtual", name = "signal-cyan"}, count = 0, index = 6}
        }
        for i = 1,6 do
          if params[i].signal and params[i].signal.name then
            local color = ""
            if i == 1 then
              color = "signal-red"
            elseif i == 2 then
              color = "signal-green"
            elseif i == 3 then
              color = "signal-blue"
            elseif i == 4 then
              color = "signal-yellow"
            elseif i == 5 then
              color = "signal-pink"
            elseif i == 6 then
              color = "signal-cyan"
            end
            if get_count(control, params[i].signal) == params[i].count then
              table.insert(slots, {signal = {type = "virtual", name = color}, count = 1, index = i})
            else
              table.insert(slots, {signal = {type = "virtual", name = color}, count = 0, index = i})
            end
          end
        end
        control.parameters = {
          parameters = slots
        }
      else
        control.parameters = {
          parameters = {
            {signal = {type = "virtual", name = "signal-red"}, count = 0, index = 1},
            {signal = {type = "virtual", name = "signal-green"}, count = 0, index = 2},
            {signal = {type = "virtual", name = "signal-blue"}, count = 0, index = 3},
            {signal = {type = "virtual", name = "signal-yellow"}, count = 0, index = 4},
            {signal = {type = "virtual", name = "signal-pink"}, count = 0, index = 5},
            {signal = {type = "virtual", name = "signal-cyan"}, count = 0, index = 6}
          }
        }
      end
    end
  end
}

classes["emitter-combinator"] = {
  on_click = function(player, object)
    local gui = player.gui.center
    local params = {}
    for i = 1,6 do
      if gui["uc"]["emitter-combinator"]["signal"..i].elem_value then
        params[i] = {signal = gui["uc"]["emitter-combinator"]["signal"..i].elem_value}
      else
        params[i] = {signal = {type = "virtual"}}
      end
    end
    object.meta.params = params
  end,
  on_key = function(player, object)
    if not (player.gui.center["uc"]) then
      local gui = player.gui.center
      local params = object.meta.params
      local uc = gui.add{type = "frame", name = "uc", caption = "Emitter Combinator"}
      local layout = uc.add{type = "table", name = "emitter-combinator", column_count = 8}
      layout.add{type = "label", caption = "Signal: (?)", tooltip = {"emitter-combinator.signal"}}
      if params[1] and params[1].signal then
        layout.add{type = "choose-elem-button", name = "signal1", elem_type = "signal", signal = params[1].signal}
      else
        layout.add{type = "choose-elem-button", name = "signal1", elem_type = "signal"}
      end
      layout.add{type = "label", caption = "Filter: (?)", tooltip = {"emitter-combinator.filter"}}
      for i= 2,6 do
        if params[i] and params[i].signal then
          layout.add{type = "choose-elem-button", name = "signal" .. i, elem_type = "signal", signal = params[i].signal}
        else
          layout.add{type = "choose-elem-button", name = "signal" .. i, elem_type = "signal"}
        end
      end
      layout.add{type = "button", name = "uc-exit", caption = "Ok"}
    end
  end,
  on_place = function(entity, item)
		if item ~= nil and item.get_tag("uc_meta") ~= nil then
			local tag = item.get_tag("uc_meta")
      tag.meta.entity = entity
      return { meta = tag.meta }
		end
    return {
      meta = {
        entity = entity,
        params = {}
      }
    }
  end,
  on_destroy = function(meta, item)

    item.set_tag("uc_meta", meta)
  end,
  on_tick = function(object)
    local control = object.meta.entity.get_control_behavior()
    if control then
      local params = object.meta.params
      if control.enabled then
        for i = 2,6 do
          if params[i] and params[i].signal and params[i].signal.name then
            object.meta.params[i].count = get_count(control, params[i].signal)
          end
        end
      end
    end
  end
}

classes["receiver-combinator"] = {
  on_click = function(player, object)
    local gui = player.gui.center
    if gui["uc"]["receiver-combinator"]["signal"].elem_value then
      object.meta.signal = gui["uc"]["receiver-combinator"]["signal"].elem_value
    else
      object.meta.signal = { type = "virtual" }
    end
  end,
  on_key = function(player, object)
    if not (player.gui.center["uc"]) then
      local gui = player.gui.center
      local uc = gui.add{type = "frame", name = "uc", caption = "Receiver Combinator"}
      local layout = uc.add{type = "table", name = "receiver-combinator", column_count = 2}
      layout.add{type = "label", caption = "Signal: (?)", tooltip = {"receiver-combinator.signal"}}
      layout.add{type = "choose-elem-button", name = "signal", elem_type = "signal", signal = object.meta.signal}
      layout.add{type = "button", name = "uc-exit", caption = "Ok"}
    end
  end,
  on_place = function(entity, item)
		if item ~= nil and item.get_tag("uc_meta") ~= nil then
			local tag = item.get_tag("uc_meta")
      tag.meta.entity = entity
      return { meta = tag.meta }
		end
    return {
      meta = {
        entity = entity,
        signal = { type = "virtual", name = "signal-0"}
      }
    }
  end,
  on_destroy = function(meta, item)

    item.set_tag("uc_meta", meta)
  end,
  on_tick = function(object)
    local control = object.meta.entity.get_control_behavior()
    if control then
      local params = control.parameters.parameters
      if object.meta.signal.name then
        local slots = {}
        local p1 = object.meta.signal
        if control.enabled then
          local sender
          for k,v in pairs(data["emitter-combinator"]) do
            if v.meta.params[1] and (p1.name == v.meta.params[1].signal.name) then
              sender = v.meta
              break;
            end
          end
          if sender then
            local sender_control = sender.entity.get_control_behavior()
            for i = 2,6 do
              if sender.params[i].signal and sender.params[i].signal.name then
                table.insert(slots, {signal = sender.params[i].signal, count = sender.params[i].count, index = (i - 1)})
              end
            end
          end
          control.parameters = {
            parameters = slots
          }
        end
      else
        control.parameters = {
          parameters = {}
        }
      end
    end
  end
}

classes["power-combinator"] = {
  on_click = function(player, object)
    local gui = player.gui.center
    object.meta.ticks = tonumber(gui["uc"]["power-combinator"]["ticks"].text) or 1
  end,
  on_key = function(player, object)
    if not (player.gui.center["uc"]) then
      local gui = player.gui.center
      local uc = gui.add{type = "frame", name = "uc", caption = "Power Combinator"}
      local layout = uc.add{type = "table", name = "power-combinator", column_count = 2}
      layout.add{type = "label", caption = "Ticks: (?)", tooltip = {"power-combinator.ticks"}}
      layout.add{type = "textfield", name = "ticks", style = "uc_text", text = object.meta.ticks}
      layout.add{type = "button", name = "uc-exit", caption = "Ok"}
    end
  end,
  on_place = function(entity, item)
		if item ~= nil and item.get_tag("uc_meta") ~= nil then
			local tag = item.get_tag("uc_meta")
      tag.meta.entity = entity
      return { meta = tag.meta }
		end
    return {
      meta = {
        entity = entity,
        ticks = 1,
        prev = 0,
        params = {
          {signal = {type = "virtual", name = "watts-signal"}, count = 0, index = 4},
          {signal = {type = "virtual", name = "kilo-watts-signal"}, count = 0, index = 3},
          {signal = {type = "virtual", name = "mega-watts-signal"}, count = 0, index = 2},
          {signal = {type = "virtual", name = "giga-watts-signal"}, count = 0, index = 1}
        }
      }
    }
  end,
  on_destroy = function(object) end,
  on_tick = function(object)
    local control = object.meta.entity.get_control_behavior()
    if control then
      local params = object.meta.params
      if params[1].signal.name then
        local ticks = object.meta.ticks
        if ticks < 1 then
          ticks = 1
          object.meta.ticks = 1
        end
        if ticks > 3600 then
          ticks = 3600
          object.meta.ticks = 3600
        end
        if control.enabled then
          local slots = {
            {signal = params[4].signal, count = params[4].count, index = 4},
            {signal = params[3].signal, count = params[3].count, index = 3},
            {signal = params[2].signal, count = params[2].count, index = 2},
            {signal = params[1].signal, count = params[1].count, index = 1}
          }
          local pos = object.meta.entity.position
          local poles = object.meta.entity.surface.find_entities_filtered(
            {
              area = {{pos.x - 1, pos.y - 1}, {pos.x + 1, pos.y + 1}},
              type = "electric-pole"
            })
          local power = 0
          local watts = 0
          if #poles > 0 then
            for _,p in pairs(poles) do
              for k,v in pairs(p.electric_network_statistics.output_counts) do
                power = power + (p.electric_network_statistics.get_output_count(k) or 0)
              end
              if power > 0 then
                break
              end
            end
            watts = (power - object.meta.prev) * 60
            object.meta.prev = power
          end
          if ((game.tick % ticks) == 0) then
            slots = {}
            local w = watts % 1000
            local kw = ((watts - w) / 1000) % 1000
            local mw = ((watts - (w + (kw * 1000))) / (10 ^ 6)) % 1000
            local gw = ((watts - (w + (kw * 1000) + (mw * 10 ^ 6))) / (10 ^ 9))
            table.insert(slots, {signal = {type = "virtual", name = "giga-watts-signal"}, count = gw, index = 1})
            table.insert(slots, {signal = {type = "virtual", name = "mega-watts-signal"}, count = mw, index = 2})
            table.insert(slots, {signal = {type = "virtual", name = "kilo-watts-signal"}, count = kw, index = 3})
            table.insert(slots, {signal = {type = "virtual", name = "watts-signal"}, count = w, index = 4})
            object.meta.params = slots
          end
          control.parameters = {
            parameters = slots
          }
        end
      else
        control.parameters = {
          parameters = {
            {signal = {type = "virtual", name = "watts-signal"}, count = 0, index = 4},
            {signal = {type = "virtual", name = "kilo-watts-signal"}, count = 0, index = 3},
            {signal = {type = "virtual", name = "mega-watts-signal"}, count = 0, index = 2},
            {signal = {type = "virtual", name = "giga-watts-signal"}, count = 0, index = 1},
          }
        }
      end
    end
  end
}

classes["daytime-combinator"] = {
  on_click = function(player, object)
    local gui = player.gui.center
    if gui["uc"]["daytime-combinator"]["minutes"].elem_value and gui["uc"]["daytime-combinator"]["minutes"].elem_value.name then
      object.meta.minutes = gui["uc"]["daytime-combinator"]["minutes"].elem_value
    else
      object.meta.minutes = {type = "virtual", name = "signal-M"}
    end
    if gui["uc"]["daytime-combinator"]["hours"].elem_value and gui["uc"]["daytime-combinator"]["hours"].elem_value.name then
      object.meta.hours = gui["uc"]["daytime-combinator"]["hours"].elem_value
    else
      object.meta.hours = {type = "virtual", name = "signal-H"}
    end
  end,
  on_key = function(player, object)
    if not (player.gui.center["uc"]) then
      local meta = object.meta
      local gui = player.gui.center
      local uc = gui.add{type = "frame", name = "uc", caption = "Daytime Combinator"}
      local layout = uc.add{type = "table", name = "daytime-combinator", column_count = 2}
      layout.add{type = "label", caption = "Minutes: (?)", tooltip = {"daytime-combinator.minutes"}}
      if meta.minutes and meta.minutes.name then
        layout.add{type = "choose-elem-button", name = "minutes", elem_type = "signal", signal = meta.minutes}
      else
        layout.add{type = "choose-elem-button", name = "minutes", elem_type = "signal"}
      end
      layout.add{type = "label", caption = "Hours: (?)", tooltip = {"daytime-combinator.hours"}}
      if meta.hours and meta.hours.name then
        layout.add{type = "choose-elem-button", name = "hours", elem_type = "signal", signal = meta.hours}
      else
        layout.add{type = "choose-elem-button", name = "hours", elem_type = "signal"}
      end
      layout.add{type = "button", name = "uc-exit", caption = "Ok"}
    end
  end,
  on_place = function(entity, item)
		if item ~= nil and item.get_tag("uc_meta") ~= nil then
			local tag = item.get_tag("uc_meta")
      tag.meta.entity = entity
      return { meta = tag.meta }
		end
    return {
      meta = {
        entity = entity,
        minutes = {type = "virtual", name = "signal-M"},
        hours = {type = "virtual", name = "signal-H"}
      }
    }
  end,
  on_destroy = function(meta, item)
    item.set_tag("uc_meta", meta)
  end,
  on_tick = function(object)
    local control = object.meta.entity.get_control_behavior()
    if control then
      if control.enabled then
        local slots = {}
        local meta = object.meta
        local daytime = (meta.entity.surface.daytime * 24 + 12) % 24
        if meta.minutes and meta.minutes.name then
          table.insert(slots, {signal = meta.minutes, count = math.floor((daytime - math.floor(daytime)) * 60), index = 1})
        end
        if meta.hours and meta.hours.name then
          table.insert(slots, {signal = meta.hours, count = math.floor(daytime), index = 2})
        end
        control.parameters = {
          parameters = slots
        }
      end
    else
      control.parameters = {
        parameters = {
          {signal = {type = "virtual", name = "signal-M"}, count = 0, index = 1},
          {signal = {type = "virtual", name = "signal-H"}, count = 0, index = 2}
        }
      }
    end
  end
}

classes["pollution-combinator"] = {
  on_click = function(player, object)
    local gui = player.gui.center
    if gui["uc"]["pollution-combinator"]["output"].elem_value and gui["uc"]["pollution-combinator"]["output"].elem_value.name then
      object.meta.minutes = gui["uc"]["pollution-combinator"]["output"].elem_value
    else
      object.meta.minutes = {type = "virtual"}
    end
  end,
  on_key = function(player, object)
    if not (player.gui.center["uc"]) then
      local meta = object.meta
      local gui = player.gui.center
      local uc = gui.add{type = "frame", name = "uc", caption = "Pollution Combinator"}
      local layout = uc.add{type = "table", name = "pollution-combinator", column_count = 2}
      layout.add{type = "label", caption = "Output: (?)", tooltip = {"pollution-combinator.output"}}
      if meta.output and meta.output.name then
        layout.add{type = "choose-elem-button", name = "output", elem_type = "signal", signal = meta.output}
      else
        layout.add{type = "choose-elem-button", name = "output", elem_type = "signal"}
      end
      layout.add{type = "button", name = "uc-exit", caption = "Ok"}
    end
  end,
  on_place = function(entity, item)
		if item ~= nil and item.get_tag("uc_meta") ~= nil then
			local tag = item.get_tag("uc_meta")
      tag.meta.entity = entity
      return { meta = tag.meta }
		end
    return {
      meta = {
        entity = entity,
        output = {type = "virtual", name = "output-signal"}
      }
    }
  end,
  on_destroy = function(meta, item)
    item.set_tag("uc_meta", meta)
  end,
  on_tick = function(object)
    local control = object.meta.entity.get_control_behavior()
    if control then
      if control.enabled then
        local slots = {}
        local meta = object.meta
        local pollution = meta.entity.surface.get_pollution(meta.entity.position)
        if meta.output and meta.output.name then
          table.insert(slots, {signal = meta.output, count = pollution, index = 1})
        end
        control.parameters = {
          parameters = slots
        }
      end
    else
      control.parameters = {
        parameters = {
          {signal = {type = "virtual", name = "output-signal"}, count = 0, index = 1}
        }
      }
    end
  end
}

classes["statistic-combinator"] = {
  on_click = function(player, object)
    local gui = player.gui.center
    local params = {}
    for i = 1,5 do
      if gui["uc"]["statistic-combinator"]["signal"..i].elem_value then
        params[i] = {signal = {name = gui["uc"]["statistic-combinator"]["signal"..i].elem_value, type = "item"}}
        game.players[1].print(params[i].signal.name)
      else
        params[i] = {signal = {type = "item"}}
      end
    end
    object.meta.params = params
    object.meta.index = gui["uc"]["statistic-combinator"]["stat"].selected_index
    --object.meta.ticks = tonumber(gui["uc"]["statistic-combinator"]["ticks"].text) or 1
  end,
  on_key = function(player, object)
    if not (player.gui.center["uc"]) then
      local gui = player.gui.center
      local params = object.meta.params
      local uc = gui.add{type = "frame", name = "uc", caption = "Statistic Combinator"}
      local layout = uc.add{type = "table", name = "statistic-combinator", column_count = 8}
      layout.add{type = "label", caption = "Type: (?)", tooltip = {"statistic-combinator.stat"}}
      layout.add{type = "drop-down", name = "stat", items = {{"statistic-combinator.production"}, {"statistic-combinator.consumption"}}, selected_index = object.meta.index}
      --layout.add{type = "label", caption = "Ticks: (?)", tooltip = {"statistic-combinator.ticks"}}
      --layout.add{type = "textfield", name = "ticks", style = "uc_text", text = object.meta.ticks}
      layout.add{type = "label", caption = "Filter: (?)", tooltip = {"statistic-combinator.filter"}}
      for i= 1,5 do
        if params[i] and params[i].signal and params[i].signal.name then
          layout.add{type = "choose-elem-button", name = "signal" .. i, elem_type = "item", item = params[i].signal.name}
        else
          layout.add{type = "choose-elem-button", name = "signal" .. i, elem_type = "item"}
        end
      end
      layout.add{type = "button", name = "uc-exit", caption = "Ok"}
    end
  end,
  on_place = function(entity, item)
		if item ~= nil and item.get_tag("uc_meta") ~= nil then
			local tag = item.get_tag("uc_meta")
			tag.meta.entity = entity
			return { meta = tag.meta }
		end
    return {
      meta = {
        entity = entity,
        params = {
          {signal = {type = "item"}, count = 0, index = 1},
          {signal = {type = "item"}, count = 0, index = 2},
          {signal = {type = "item"}, count = 0, index = 3},
          {signal = {type = "item"}, count = 0, index = 4},
          {signal = {type = "item"}, count = 0, index = 5}
        },
        --ticks = 300,
        prev = {0, 0, 0, 0, 0},
        index = 1
      }
    }
  end,
  on_destroy = function(meta, item)

    item.set_tag("uc_meta", meta)
  end,
  on_tick = function(object)
    local control = object.meta.entity.get_control_behavior()
    if control then
      local params = object.meta.params
      if control.enabled then
        local slots = {
          {signal = params[1].signal, count = params[1].count or 0, index = 1},
          {signal = params[2].signal, count = params[2].count or 0, index = 2},
          {signal = params[3].signal, count = params[3].count or 0, index = 3},
          {signal = params[4].signal, count = params[4].count or 0, index = 4},
          {signal = params[5].signal, count = params[5].count or 0, index = 5}
        }
        --[[local ticks = object.meta.ticks
        if ticks < 1 then
          ticks = 1
          object.meta.ticks = 1
        end
        if ticks > 3600 then
          ticks = 3600
          object.meta.ticks = 3600
        end]]
        if ((game.tick % 60) == 0) then
          for i = 1,5 do
            if params[i] and params[i].signal and params[i].signal.name then
              local stats
              local flow
              if game.item_prototypes[params[i].signal.name] and game.item_prototypes[params[i].signal.name].type == "fluid" then
                stats = object.meta.entity.force.fluid_production_statistics
              else
                stats = object.meta.entity.force.item_production_statistics
              end
              if object.meta.index == 1 then
                flow = stats.get_input_count(params[i].signal.name) or 0
              elseif object.meta.index == 2 then
                flow = stats.get_output_count(params[i].signal.name) or 0
              end
              local old = object.meta.prev[i]
              object.meta.params[i].count = flow - old
              table.insert(slots, {signal = params[i].signal, count = object.meta.params[i].count, index = i})
              object.meta.prev[i] = flow
            end
          end
        end
        control.parameters = {
          parameters = slots
        }
      end
    else
      control.parameters = {
        parameters = {
          {signal = {type = "item", name = "coal"}, count = 1, index = 1},
          {signal = {type = "item"}, count = 0, index = 2},
          {signal = {type = "item"}, count = 0, index = 3},
          {signal = {type = "item"}, count = 0, index = 4},
          {signal = {type = "item"}, count = 0, index = 5}
        }
      }
    end
  end
}

classes["multiplex-combinator"] = {
  on_click = function(player, object)
    local gui = player.gui.center
    local params = {}
    if gui["uc"]["multiplex-combinator"]["signal"].elem_value then
      object.meta.signal = gui["uc"]["multiplex-combinator"]["signal"].elem_value
    else
      object.meta.signal = {type = "item"}
    end
    object.meta.scaled = gui["uc"]["multiplex-combinator"]["scaled"].state
    object.meta.items_only = gui["uc"]["multiplex-combinator"]["items_only"].state
  end,
  on_key = function(player, object)
    if not (player.gui.center["uc"]) then
      local gui = player.gui.center
      local meta = object.meta
      local uc = gui.add{type = "frame", name = "uc", caption = "Multiplex Combinator"}
      local layout = uc.add{type = "table", name = "multiplex-combinator", column_count = 2}
      layout.add{type = "label", caption = "Selection signal", tooltip={"multiplex-combinator.signal"}}
      if meta.signal and meta.signal.name then
        layout.add{type = "choose-elem-button", name = "signal", elem_type = "signal", signal = meta.signal}
      else
        layout.add{type = "choose-elem-button", name = "signal", elem_type = "signal"}
      end
      layout.add{type="label", caption="Scale inputs by values"}
      layout.add{type="checkbox", name="scaled", state=meta.scaled or false}
      layout.add{type="label", caption="Only items"}
      layout.add{type="checkbox", name="items_only", state=meta.items_only or false}
      layout.add{type = "button", name = "uc-exit", caption = "Ok"}
    end
  end,
  on_place = function(entity, item)
		if item ~= nil and item.get_tag("uc_meta") ~= nil then
			local tag = item.get_tag("uc_meta")
			tag.meta.entity = entity
			return { meta = tag.meta }
		end
    return {
      meta = {
        entity = entity,
        params = {
          signal = {type = "item"},
        },
        --ticks = 300,
      }
    }
  end,
  on_destroy = function(meta, item)
    item.set_tag("uc_meta", meta)
  end,
  on_tick = function(object)
    local control = object.meta.entity.get_control_behavior()
    local input_signals = object.meta.entity.get_merged_signals(defines.circuit_connector_id.combinator_input)
    if input_signals and control and object.meta.signal then
      local control_signal = nil
      local sorted_signals = {}
      for k, v in pairs(input_signals) do
        if v.signal.name == object.meta.signal.name then
          control_signal = v
        else
          if not object.meta.items_only or v.signal.type == "item" then
            if object.meta.scaled then
              for ii = 1, v.count, 1 do
                table.insert(sorted_signals, {v.signal, v.count})
              end
            else
              table.insert(sorted_signals, {v.signal, v.count})
            end
          end
        end
      end

      if object.meta.scaled == nil then
        object.meta.scaled = true
      end

      if object.meta.items_only == nil then
        object.meta.items_only = true
      end

      if not control_signal then
        control.parameters = {}
        return
      end

      table.sort(sorted_signals, function (a,b) return a[2] < b[2]; end)
      local total_count = #sorted_signals
      if total_count == 0 then
        control.parameters = {}
        return
      end
      local control_value = math.fmod(control_signal.count, total_count) + 1
      local output_signal = sorted_signals[control_value][1]
      local output_count = sorted_signals[control_value][2]
      control.parameters = {
        first_constant = output_count,
        second_constant = 1,
        output_signal = output_signal
      }
    else
      control.parameters = { parameters = {} }
    end
  end
}

function get_count(control, signal)
  if not signal then return 0 end
  local red = control.get_circuit_network(defines.wire_type.red, defines.circuit_connector_id.combinator_input)
  local green = control.get_circuit_network(defines.wire_type.green, defines.circuit_connector_id.combinator_input)
  local val = 0
  if red then
    val = red.get_signal(signal) or 0
  end
  if green then
    val = val + (green.get_signal(signal) or 0)
  end
  return val
end

function get_signals(control)
  local red = control.get_circuit_network(defines.wire_type.red)
  local green = control.get_circuit_network(defines.wire_type.green)
  local network = {}
  if red and red.signals then
    for _,v in pairs(red.signals) do
      if v.signal.name then
        network[v.signal.name] = v
      end
    end
  end
  if green and green.signals then
    for _,v in pairs(green.signals) do
      if v.signal.name then
        network[v.signal.name] = v
      end
    end
  end
  return network
end

function entity_built(event)
  if classes[event.created_entity.name] ~= nil then
    local tab = data[event.created_entity.name] or {}
    table.insert(tab, classes[event.created_entity.name].on_place(event.created_entity, event.stack))
    data[event.created_entity.name] = tab
    save()
  end
end

function pre_entity_removed(event)
  if classes[event.entity.name] ~= nil then
    for k,v in ipairs(data[event.entity.name]) do
      if v.meta.entity == event.entity then
        local tab = data[event.entity.name]
        table.remove(tab, k)
        classes[event.entity.name].on_destroy(v, event.buffer[1])
        data[event.entity.name] = tab
        for i,j in pairs(selected) do
          if j.entity == v.meta.entity then
            j.player.gui.center["uc"].destroy()
            table.remove(selected, i)
          end
        end
        save()
        break
      end
    end
  end
end

function tick()
  for k,v in pairs(classes) do
    if data ~= nil and data[k] ~= nil then
      for q,i in pairs(data[k]) do
        if i.meta and i.meta.entity.valid then
          v.on_tick(i, q)
        end
      end
    end
  end
end

function uc_load()
  data = global["uc_data"] or {}
end

function init()
  data = global["uc_data"] or {}
  for k,v in pairs(classes) do
    data[k] = data[k] or {}
  end
end

function configuration_changed(cfg)
  if cfg.mod_changes then
    local changes = cfg.mod_changes["UsefulCombinators"]
    if changes then
      init()
      if global["uc_data"] then
        for k,v in pairs(classes) do
          local tab = {}
          for _,s in pairs(game.surfaces) do
            for i,j in pairs(s.find_entities_filtered({name = k})) do
              table.insert(tab, classes[k].on_place(j))
              data[k] = tab
            end
          end
          save()
        end
      end
    end
  end
end

function on_key(event)
  local player = game.players[event.player_index]
  local entity = player.selected
  if entity and player.can_reach_entity(entity) then
    for k,v in pairs(classes) do
      if data ~= nil and data[k] ~= nil then
        if entity.name == k then
          for h,i in pairs(data[k]) do
            if i.meta.entity.valid then
              if i.meta.entity == entity then
                if not (player.gui.center["uc"]) and not player.cursor_stack.valid_for_read then
                  table.insert(selected, { player = player, entity = entity})
                  v.on_key(player, i)
                  if entity.operable then
                    entity.operable = false
                  end
                  break
                end
              end
            end
          end
        end
      end
    end
  end
end

function on_click_ok(event)
  local player = game.players[event.player_index]
  local element = event.element
  if element.name and element.name == "uc-exit" then
    for k,v in pairs(classes) do
      if data and data[k] then
        for h,i in pairs(data[k]) do
          for l,m in pairs(selected) do
            if i.meta.entity == m.entity then
              v.on_click(player, i)
              table.remove(selected, l)
              if not i.meta.entity.operable then
                i.meta.entity.operable = true
              end
              break
            end
          end
        end
      end
    end
    player.gui.center["uc"].destroy()
  end
end

script.on_init(init)
script.on_load(uc_load)
script.on_event(defines.events.on_built_entity, entity_built)
script.on_event(defines.events.on_robot_built_entity, entity_built)
script.on_event(defines.events.on_player_mined_entity, pre_entity_removed)
script.on_event(defines.events.on_robot_mined_entity, pre_entity_removed)
script.on_event(defines.events.on_entity_died, entity_removed)
script.on_event(defines.events.on_tick, tick)
script.on_event(defines.events.on_gui_click, on_click_ok)
script.on_event("uc-edit", on_key)
script.on_configuration_changed(configuration_changed)
